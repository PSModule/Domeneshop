#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester test discovery.'
)]
[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$publicFunctionsPath = Join-Path -Path $sourcePath -ChildPath 'functions'
$publicFunctionsPath = Join-Path -Path $publicFunctionsPath -ChildPath 'public'
$testCases = Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' -Recurse -File |
    Sort-Object -Property FullName |
    ForEach-Object {
        @{
            FunctionName = $_.BaseName
            Group        = if ($_.DirectoryName -eq $publicFunctionsPath) {
                $null
            } else {
                Split-Path -Path $_.DirectoryName -Leaf
            }
            Path         = $_.FullName
        }
    }

Describe 'Public function help links' {
    It 'puts the canonical documentation link first for <FunctionName>' -ForEach $testCases {
        param($FunctionName, $Group, $Path)

        $content = Get-Content -Path $Path -Raw
        $links = [regex]::Matches($content, '(?ms)^\s*\.LINK\s*\r?\n\s*(?<Uri>\S+)')
        $expectedLink = if ($Group) {
            "https://psmodule.io/Domeneshop/Functions/$Group/$FunctionName"
        } else {
            "https://psmodule.io/Domeneshop/Functions/$FunctionName"
        }

        $links.Count | Should -BeGreaterThan 0
        $links[0].Groups['Uri'].Value | Should -Be $expectedLink
    }
}
