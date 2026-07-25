function Set-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Update a DNS record on a Domeneshop domain.

        .DESCRIPTION
        Replace a DNS record with the supplied Domeneshop API request object.

        .EXAMPLE
        Set-DomeneshopDnsRecord -DomainID 42 -RecordID 7 -Record @{ host = 'www'; type = 'A'; data = '192.0.2.20' }

        Update DNS record 7 on domain 42.

        .INPUTS
        None

        You can't pipe objects to Set-DomeneshopDnsRecord.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop API.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Set-DomeneshopDnsRecord/

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The numeric identifier of the domain that owns the record.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The numeric identifier of the DNS record to update.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $RecordID,

        # The replacement DNS record accepted by the Domeneshop API.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Record,

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

    if ($PSCmdlet.ShouldProcess("Domain [$DomainID] DNS record [$RecordID]", 'Update')) {
        Invoke-DomeneshopApiRequest -Method Put -Uri $uri -Context $resolvedContext -Body $Record
    }
}
