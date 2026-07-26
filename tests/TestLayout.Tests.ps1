#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$publicFunctionsPath = Join-Path -Path $sourcePath -ChildPath 'functions/public'
$testCases = Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' -Recurse |
    ForEach-Object {
        $relativePath = [IO.Path]::GetRelativePath($publicFunctionsPath, $_.FullName)
        $group = Split-Path -Path $relativePath -Parent
        $testFile = if ($group) {
            "$group.Tests.ps1"
        } else {
            "$($_.BaseName).Tests.ps1"
        }
        @{
            FunctionName = $_.BaseName
            TestFile     = $testFile
            TestPath     = Join-Path -Path $PSScriptRoot -ChildPath $testFile
        }
    }

Describe 'Public command test layout' {
    It 'covers <FunctionName> in <TestFile>' -ForEach $testCases {
        Test-Path -LiteralPath $TestPath -PathType Leaf | Should -BeTrue
    }
}
