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

Describe 'Add-DomeneshopDnsRecord' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
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

Describe 'Get-DomeneshopDnsRecord' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
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

    It 'rejects whitespace-only list filters' {
        { Get-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordHost ' ' } | Should -Throw
        { Get-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -Type ' ' } | Should -Throw
        { Get-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -Data ' ' } | Should -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}

Describe 'Remove-DomeneshopDnsRecord' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'deletes the DNS record endpoint' {
        Remove-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordID 7 -Confirm:$false

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Delete' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42/dns/7'
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Remove-DomeneshopDnsRecord -Context 'demo' -DomainID 42 -RecordID 7 -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}

Describe 'Set-DomeneshopDnsRecord' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
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

