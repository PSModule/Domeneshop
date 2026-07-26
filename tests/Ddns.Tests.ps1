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

Describe 'Update-DomeneshopDdns' {
    BeforeAll {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'builds an escaped hostname and IP query' {
        Update-DomeneshopDdns -Context 'demo' -Hostname 'home example.com' -MyIP '192.0.2.10'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/dyndns/update?hostname=home%20example.com&myip=192.0.2.10'
        }
    }

    It 'does not send a request when WhatIf is specified' {
        Update-DomeneshopDdns -Context 'demo' -Hostname 'home.example.com' -WhatIf

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }

    It 'rejects whitespace-only hostnames and IP addresses' {
        { Update-DomeneshopDdns -Context 'demo' -Hostname ' ' } | Should -Throw
        { Update-DomeneshopDdns -Context 'demo' -Hostname 'home.example.com' -MyIP ' ' } | Should -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 0 -Exactly
    }
}
