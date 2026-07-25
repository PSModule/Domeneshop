[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'The fixed local test credential never leaves the mocked request boundary.'
)]
[CmdletBinding()]
param()

$sourcePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
$functionsPath = Join-Path -Path $sourcePath -ChildPath 'functions'
$functionFiles = Get-ChildItem -Path $functionsPath -Filter '*.ps1' -Recurse -File |
    Sort-Object -Property FullName
foreach ($file in $functionFiles) {
    . $file.FullName
}

$script:DomeneshopTestContext = [pscustomobject]@{
    ID         = 'demo'
    Token      = 'token'
    Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
    ApiBaseUri = 'https://api.domeneshop.no/v0'
}
