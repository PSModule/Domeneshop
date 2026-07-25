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

Describe 'Add-DomeneshopDnsRecord' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
        $script:Record = @{ host = 'www'; type = 'A'; data = '192.0.2.10' }
    }

    It 'posts the DNS record to the domain endpoint' {
        Add-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -Record $script:Record

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Post' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/dns' -and
            $Body -eq $script:Record
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Add-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -Record $script:Record -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}
