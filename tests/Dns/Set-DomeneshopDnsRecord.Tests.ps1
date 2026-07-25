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

Describe 'Set-DomeneshopDnsRecord' {
    BeforeAll {
        . (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
        $script:Record = @{ host = 'www'; type = 'A'; data = '192.0.2.20' }
    }

    It 'puts the replacement record to the record endpoint' {
        Set-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordID 7 -Record $script:Record

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Put' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/dns/7' -and
            $Body -eq $script:Record
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Set-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordID 7 -Record $script:Record -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}
