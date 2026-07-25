function Get-DomeneshopDomain {
    <#
        .SYNOPSIS
        Lists Domeneshop domains.

        .DESCRIPTION
        Uses the stored Domeneshop context credentials and calls the /domains endpoint.

        .EXAMPLE
        Get-DomeneshopDomain

        .EXAMPLE
        Get-DomeneshopDomain -Domain '.no'
    #>
    [OutputType([object[]])]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Domain,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = [string] $resolvedContext.ApiBaseUri
    if ([string]::IsNullOrEmpty($apiBaseUri)) {
        $apiBaseUri = 'https://api.domeneshop.no/v0'
    }

    $uri = "$apiBaseUri/domains"
    if ($Domain) {
        $encodedDomain = [uri]::EscapeDataString($Domain)
        $uri = "${uri}?domain=$encodedDomain"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
