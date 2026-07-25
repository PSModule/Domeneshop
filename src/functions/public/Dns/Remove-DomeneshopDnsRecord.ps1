function Remove-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Removes a DNS record from a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [int] $RecordID,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/dns/$RecordID"

    if ($PSCmdlet.ShouldProcess("Domain $DomainID DNS record $RecordID", 'Remove')) {
        Invoke-DomeneshopApiRequest -Method Delete -Uri $uri -Context $resolvedContext
    }
}
