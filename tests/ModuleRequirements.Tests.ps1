#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester test discovery.'
)]
[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$testCases = @(
    @{
        RequiredVersions = @(
            Get-ChildItem -Path $sourcePath -Filter '*.ps1' -Recurse -File |
                Select-String -Pattern '^\s*#Requires\s+-Version\s+(?<Version>\S+)\s*$' |
                ForEach-Object { $_.Matches[0].Groups['Version'].Value } |
                Sort-Object -Unique
        )
    }
)

Describe 'Module requirements' {
    It 'targets only the latest PowerShell LTS' -ForEach $testCases {
        param($RequiredVersions)

        $RequiredVersions | Should -HaveCount 1
        $RequiredVersions[0] | Should -Be '7.6'
    }
}
