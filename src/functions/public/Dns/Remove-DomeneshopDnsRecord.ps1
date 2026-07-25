function Remove-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Remove a DNS record from a Domeneshop domain.

        .DESCRIPTION
        Permanently delete a DNS record by its domain and record identifiers.

        .EXAMPLE
        Remove-DomeneshopDnsRecord -DomainID 42 -RecordID 7

        Remove DNS record 7 from domain 42 after confirmation.

        .INPUTS
        None

        You can't pipe objects to Remove-DomeneshopDnsRecord.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop API.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Dns/Remove-DomeneshopDnsRecord

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The numeric identifier of the domain that owns the record.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The numeric identifier of the DNS record to remove.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $RecordID,

        # The stored credential context to use instead of the default.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Context
    )

    $storedContext = if ($PSBoundParameters.ContainsKey('Context')) {
        Get-DomeneshopContext -Context $Context
    } else {
        Get-DomeneshopContext
    }
    $resolvedContext = Resolve-DomeneshopContext -Context $storedContext
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/dns/$RecordID"

    if ($PSCmdlet.ShouldProcess("Domain [$DomainID] DNS record [$RecordID]", 'Remove')) {
        Invoke-DomeneshopApiRequest -Method Delete -Uri $uri -Context $resolvedContext
    }
}
