[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'The fixed local test credential never leaves the mocked request boundary.'
)]
[CmdletBinding()]
param()

$functionFiles = Get-ChildItem -Path "$PSScriptRoot\..\src\functions" -Filter '*.ps1' -Recurse -File |
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
