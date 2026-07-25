function Add-DomeneshopForward {
    <#
        .SYNOPSIS
        Adds an HTTP forward to a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [object] $Forward,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/forwards/"

    Invoke-DomeneshopApiRequest -Method Post -Uri $uri -Context $resolvedContext -Body $Forward
}
