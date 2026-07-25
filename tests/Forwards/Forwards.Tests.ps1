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

Describe 'Add-DomeneshopForward' {
    BeforeAll {
        . (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Domeneshop.TestSetup.ps1')
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

Describe 'Get-DomeneshopForward' {
    BeforeAll {
        . (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'lists forwards for a domain' {
        Get-DomeneshopForward -Context 'demo' -DomainID 42

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/forwards/'
        }
    }

    It 'gets a forward by escaped host name' {
        Get-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost 'home office'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/forwards/home%20office'
        }
    }

    It 'rejects whitespace-only forward hosts' {
        { Get-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost ' ' } | Should -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}

Describe 'Remove-DomeneshopForward' {
    BeforeAll {
        . (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'deletes the host endpoint' {
        Remove-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost 'www' -Confirm:$false

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Delete' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/forwards/www'
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Remove-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost 'www' -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }

    It 'rejects whitespace-only forward hosts' {
        { Remove-DomeneshopForward -Context 'demo' -DomainID 42 -ForwardHost ' ' -Confirm:$false } | Should -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}

Describe 'Set-DomeneshopForward' {
    BeforeAll {
        . (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Domeneshop.TestSetup.ps1')
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
