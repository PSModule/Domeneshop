#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$publicFunctionsPath = Join-Path -Path $sourcePath -ChildPath 'functions/public'
$testCases = Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' -Recurse |
    ForEach-Object {
        $relativePath = [IO.Path]::GetRelativePath($publicFunctionsPath, $_.FullName)
        $relativeDirectory = Split-Path -Path $relativePath -Parent
        if ([string]::IsNullOrWhiteSpace($relativeDirectory) -or $relativeDirectory -eq '.') {
            @{
                TestScope = $_.BaseName
                TestPath  = Join-Path -Path $PSScriptRoot -ChildPath (
                    [IO.Path]::ChangeExtension($relativePath, '.Tests.ps1')
                )
            }
        } else {
            $groupName = Split-Path -Path $relativeDirectory -Leaf
            @{
                TestScope = $groupName
                TestPath  = Join-Path -Path $PSScriptRoot -ChildPath (
                    Join-Path -Path $groupName -ChildPath "$groupName.Tests.ps1"
                )
            }
        }
    } |
    Group-Object -Property TestPath |
    ForEach-Object { $_.Group[0] }

Describe 'Public command test layout' {
    It 'has a grouped test file for <TestScope>' -ForEach $testCases {
        Test-Path -LiteralPath $TestPath -PathType Leaf | Should -BeTrue
    }
}
