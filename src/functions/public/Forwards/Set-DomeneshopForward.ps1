function Set-DomeneshopForward {
    <#
        .SYNOPSIS
        Updates an HTTP forward on a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [Alias('Host')]
        [string] $ForwardHost,

        [Parameter(Mandatory)]
        [object] $Forward,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $encodedHost = [uri]::EscapeDataString($ForwardHost)
    $uri = "$apiBaseUri/domains/$DomainID/forwards/$encodedHost"

    Invoke-DomeneshopApiRequest -Method Put -Uri $uri -Context $resolvedContext -Body $Forward
}
