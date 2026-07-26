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
        $relativePath = [IO.Path]::GetRelativePath($publicFunctionsPath, $_.FullName)
        $relativeDirectory = Split-Path -Path $relativePath -Parent
        $documentationPath = if ($relativeDirectory) {
            '{0}/{1}' -f ($relativeDirectory -replace '[\\/]', '/'), $_.BaseName
        } else {
            $_.BaseName
        }

        @{
            DocumentationPath = $documentationPath
            Path              = $_.FullName
        }
    }

Describe 'Public function help links' {
    It 'puts the canonical documentation link first for <DocumentationPath>' -ForEach $testCases {
        param($DocumentationPath, $Path)

        $content = Get-Content -Path $Path -Raw
        $links = [regex]::Matches($content, '(?ms)^\s*\.LINK\s*\r?\n\s*(?<Uri>\S+)')

        $links.Count | Should -BeGreaterThan 0
        $links[0].Groups['Uri'].Value |
            Should -Be "https://psmodule.io/Domeneshop/Functions/$DocumentationPath/"
    }
}
