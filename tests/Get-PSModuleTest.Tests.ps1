#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter', '',
    Justification = 'Required for Pester tests'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester tests'
)]
[CmdletBinding()]
param()

Describe 'Get-PSModuleTest' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    It 'returns a greeting for the supplied name' {
        Get-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
}
