function Get-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Gets DNS records for a Domeneshop domain.

        .DESCRIPTION
        Lists DNS records for a domain, or gets one DNS record by ID.

        .EXAMPLE
        Get-DomeneshopDnsRecord -DomainID 42

        List every DNS record for domain 42.

        .EXAMPLE
        Get-DomeneshopDnsRecord -DomainID 42 -RecordID 7

        Get DNS record 7 from domain 42.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopDnsRecord.

        .OUTPUTS
        System.Object

        The matching Domeneshop DNS records.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Get-DomeneshopDnsRecord/

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The numeric identifier of the domain that owns the records.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The numeric identifier of a specific DNS record.
        [Parameter(Mandatory, ParameterSetName = 'Get by ID')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $RecordID,

        # A hostname filter for list requests.
        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [Alias('Host')]
        [string] $RecordHost,

        # A DNS record type filter for list requests.
        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string] $Type,

        # A record-data filter for list requests.
        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string] $Data,

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

    if ($PSCmdlet.ParameterSetName -eq 'Get by ID') {
        $uri = "$uri/$RecordID"
    } else {
        $queryParts = @()
        if ($PSBoundParameters.ContainsKey('RecordHost')) {
            $queryParts += "host=$([uri]::EscapeDataString($RecordHost))"
        }
        if ($PSBoundParameters.ContainsKey('Type')) {
            $queryParts += "type=$([uri]::EscapeDataString($Type))"
        }
        if ($PSBoundParameters.ContainsKey('Data')) {
            $queryParts += "data=$([uri]::EscapeDataString($Data))"
        }
        if ($queryParts.Count -gt 0) {
            $uri = "${uri}?{0}" -f ($queryParts -join '&')
        }
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
