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

Describe 'Connect-DomeneshopAccount' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Set-Context {}
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = $null } }
        Mock Set-DomeneshopDefaultContext {}
        Mock Get-DomeneshopContext { [pscustomobject]@{ ID = 'demo' } }
    }

    It 'stores credentials securely and sets the first context as default' {
        $result = Connect-DomeneshopAccount -Token 'token' -Secret 'secret' -Context 'demo' -PassThru

        $result.ID | Should -Be 'demo'
        Should -Invoke Set-Context -Times 1 -Exactly -ParameterFilter {
            $ID -eq 'demo' -and
            $Vault -eq 'Domeneshop' -and
            $Context.Secret -is [securestring]
        }
        Should -Invoke Set-DomeneshopDefaultContext -Times 1 -Exactly -ParameterFilter {
            $Context -eq 'demo' -and $Confirm -eq $false
        }
    }

    It 'does not store credentials when WhatIf is specified' {
        Connect-DomeneshopAccount -Token 'token' -Secret 'secret' -Context 'demo' -WhatIf

        Should -Invoke Set-Context -Times 0 -Exactly
        Should -Invoke Set-DomeneshopDefaultContext -Times 0 -Exactly
    }

    It 'rejects unsupported secret types' {
        { Connect-DomeneshopAccount -Token 'token' -Secret 42 -Context 'demo' } |
            Should -Throw '*Secret must be a SecureString or String value*'
    }
}
