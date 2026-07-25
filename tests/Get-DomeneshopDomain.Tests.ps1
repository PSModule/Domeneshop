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

Describe 'Get-DomeneshopDomain' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'adds an escaped domain filter to list requests' {
        Get-DomeneshopDomain -Context 'demo' -Domain 'example & test'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains?domain=example%20%26%20test' -and
            $Context.ID -eq 'demo'
        }
    }

    It 'gets a domain by ID' {
        Get-DomeneshopDomain -Context 'demo' -DomainID 42

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/42'
        }
    }

    It 'rejects non-positive domain IDs' {
        { Get-DomeneshopDomain -Context 'demo' -DomainID 0 } | Should -Throw
    }
}
