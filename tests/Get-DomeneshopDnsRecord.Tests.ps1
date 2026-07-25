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

Describe 'Get-DomeneshopDnsRecord' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'builds an escaped list query' {
        Get-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordHost 'home office' -Type 'A' -Data '192.0.2.10'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/dns?host=home%20office&type=A&data=192.0.2.10'
        }
    }

    It 'gets a DNS record by ID' {
        Get-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordID 7

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/dns/7'
        }
    }
}
