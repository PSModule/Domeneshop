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
        . (Join-Path -Path $PSScriptRoot -ChildPath 'Domeneshop.TestSetup.ps1')
    }

    BeforeEach {
        Mock Set-Context {}
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = $null } }
        Mock Set-DomeneshopDefaultContext {}
        Mock Get-DomeneshopContext { [pscustomobject]@{ ID = 'demo' } }
        Mock Start-Process {}
        Mock Read-Host { $script:PromptedSecret }
        $script:PromptedSecret = [securestring]::new()
        'prompted-secret'.ToCharArray() | ForEach-Object { $script:PromptedSecret.AppendChar($_) }
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

    It 'opens API settings and securely prompts when Secret is omitted' {
        Connect-DomeneshopAccount -Token 'token' -Context 'demo'

        Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'https://domene.shop/admin?view=api'
        }
        Should -Invoke Read-Host -Times 1 -Exactly -ParameterFilter {
            $Prompt -eq 'Enter the Domeneshop API secret' -and $AsSecureString
        }
        Should -Invoke Set-Context -Times 1 -Exactly -ParameterFilter {
            $ID -eq 'demo' -and
            $Vault -eq 'Domeneshop' -and
            [object]::ReferenceEquals($Context.Secret, $script:PromptedSecret)
        }
    }

    It 'does not open API settings or prompt when WhatIf omits Secret' {
        Connect-DomeneshopAccount -Token 'token' -Context 'demo' -WhatIf

        Should -Invoke Start-Process -Times 0 -Exactly
        Should -Invoke Read-Host -Times 0 -Exactly
        Should -Invoke Set-Context -Times 0 -Exactly
    }

    It 'accepts Key as an alias for an explicit secure secret' {
        Connect-DomeneshopAccount -Token 'token' -Key $script:PromptedSecret -Context 'demo'

        Should -Invoke Start-Process -Times 0 -Exactly
        Should -Invoke Read-Host -Times 0 -Exactly
        Should -Invoke Set-Context -Times 1 -Exactly -ParameterFilter {
            [object]::ReferenceEquals($Context.Secret, $script:PromptedSecret)
        }
    }

    It 'rejects unsupported secret types' {
        { Connect-DomeneshopAccount -Token 'token' -Secret 42 -Context 'demo' } |
            Should -Throw '*Secret must be a SecureString or String value*'
    }

    It 'rejects empty string and secure string secrets' {
        { Connect-DomeneshopAccount -Token 'token' -Secret ' ' -Context 'demo' } |
            Should -Throw '*Secret cannot be empty or whitespace*'
        { Connect-DomeneshopAccount -Token 'token' -Secret ([securestring]::new()) -Context 'demo' } |
            Should -Throw '*Secret cannot be empty or whitespace*'

        Should -Invoke Set-Context -Times 0 -Exactly
    }

    It 'rejects the reserved module configuration context name' {
        { Connect-DomeneshopAccount -Token 'token' -Secret 'secret' -Context '__Domeneshop.Config' } |
            Should -Throw '*reserved for Domeneshop module configuration*'

        Should -Invoke Set-Context -Times 0 -Exactly
    }
}
