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
        $functionFiles = Get-ChildItem -Path "$PSScriptRoot\..\src\functions" -Filter '*.ps1' -Recurse -File | Sort-Object -Property FullName
        foreach ($file in $functionFiles) {
            . $file.FullName
        }
    }

    It 'returns a greeting for the supplied name' {
        Get-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
}
