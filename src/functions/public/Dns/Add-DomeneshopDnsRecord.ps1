function Add-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Adds a DNS record to a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [object] $Record,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/dns"

    Invoke-DomeneshopApiRequest -Method Post -Uri $uri -Context $resolvedContext -Body $Record
}
