#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$publicFunctionsPath = Join-Path -Path $sourcePath -ChildPath 'functions/public'
$testCases = Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' -Recurse |
    ForEach-Object {
        $relativePath = [IO.Path]::GetRelativePath($publicFunctionsPath, $_.FullName)
        @{
            FunctionName = $_.BaseName
            TestPath     = Join-Path -Path $PSScriptRoot -ChildPath (
                [IO.Path]::ChangeExtension($relativePath, '.Tests.ps1')
            )
        }
    }

Describe 'Public command test layout' {
    It 'mirrors the public source path for <FunctionName>' -ForEach $testCases {
        Test-Path -LiteralPath $TestPath -PathType Leaf | Should -BeTrue
    }
}
