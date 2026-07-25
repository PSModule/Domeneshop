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

Describe 'Add-DomeneshopForward' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
        $script:Forward = @{ host = 'www'; url = 'https://example.net' }
    }

    It 'posts the forward to the domain endpoint' {
        Add-DomeneshopForward -Context 'demo' -DomainID 42 -Forward $script:Forward

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Post' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/forwards/' -and
            $Body -eq $script:Forward
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Add-DomeneshopForward -Context 'demo' -DomainID 42 -Forward $script:Forward -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}
