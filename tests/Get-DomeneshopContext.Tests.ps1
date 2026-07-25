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

Describe 'Get-DomeneshopContext' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    It 'gets the configured default context' {
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = 'demo' } }
        Mock Get-Context { [pscustomobject]@{ ID = 'demo' } }

        $result = Get-DomeneshopContext

        $result.ID | Should -Be 'demo'
        Should -Invoke Get-Context -Times 1 -Exactly -ParameterFilter {
            $ID -eq 'demo' -and $Vault -eq 'Domeneshop'
        }
    }

    It 'throws when no default context is configured' {
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = '' } }

        { Get-DomeneshopContext } | Should -Throw '*No default Domeneshop context found*'
    }

    It 'excludes the module configuration when listing contexts' {
        Mock Get-Context {
            @(
                [pscustomobject]@{ ID = '__Domeneshop.Config' }
                [pscustomobject]@{ ID = 'demo' }
            )
        }

        $result = Get-DomeneshopContext -ListAvailable

        $result.ID | Should -Be 'demo'
    }
}
