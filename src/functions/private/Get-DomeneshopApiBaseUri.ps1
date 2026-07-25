function Get-DomeneshopApiBaseUri {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $Context
    )

    $apiBaseUri = [string] $Context.ApiBaseUri
    if ([string]::IsNullOrEmpty($apiBaseUri)) {
        $apiBaseUri = 'https://api.domeneshop.no/v0'
    }

    $apiBaseUri.TrimEnd('/')
}
