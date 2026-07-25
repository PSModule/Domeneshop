function Add-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Add a DNS record to a Domeneshop domain.

        .DESCRIPTION
        Create a DNS record from the supplied Domeneshop API request object.

        .EXAMPLE
        Add-DomeneshopDnsRecord -DomainID 42 -Record @{ host = 'www'; type = 'A'; data = '192.0.2.10' }

        Add an A record to domain 42.

        .INPUTS
        None

        You can't pipe objects to Add-DomeneshopDnsRecord.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop API.

        .NOTES
        Uses the default context when Context is omitted.

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

        # The DNS record request object accepted by the Domeneshop API.
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
    $uri = "$apiBaseUri/domains/$DomainID/dns"

    if ($PSCmdlet.ShouldProcess("Domain [$DomainID] DNS records", 'Add DNS record')) {
        Invoke-DomeneshopApiRequest -Method Post -Uri $uri -Context $resolvedContext -Body $Record
    }
}
