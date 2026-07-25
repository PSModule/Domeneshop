function Set-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Updates a DNS record on a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [int] $RecordID,

        [Parameter(Mandatory)]
        [object] $Record,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/dns/$RecordID"

    Invoke-DomeneshopApiRequest -Method Put -Uri $uri -Context $resolvedContext -Body $Record
}
