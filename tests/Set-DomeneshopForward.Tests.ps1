#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter', '',
    Justification = 'Required for Pester mock parameter filters.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester test setup.'
)]
[CmdletBinding()]
param()

Describe 'Set-DomeneshopForward' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
        $script:Forward = @{ host = 'www'; url = 'https://example.org' }
    }

    It 'puts the replacement forward to the host endpoint' {
        Set-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost 'www' -Forward $script:Forward

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Put' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/forwards/www' -and
            $Body -eq $script:Forward
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Set-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost 'www' -Forward $script:Forward -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }

    It 'rejects whitespace-only forward hosts' {
        {
            Set-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost ' ' -Forward $script:Forward
        } | Should -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}
