function Get-DomeneshopDnsRecord {
    <#
        .SYNOPSIS
        Gets DNS records for a Domeneshop domain.

        .DESCRIPTION
        Lists DNS records for a domain, or gets one DNS record by ID.
    #>
    [OutputType([object[]])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory, ParameterSetName = 'GetByID')]
        [int] $RecordID,

        [Parameter(ParameterSetName = 'List')]
        [Alias('Host')]
        [string] $RecordHost,

        [Parameter(ParameterSetName = 'List')]
        [string] $Type,

        [Parameter(ParameterSetName = 'List')]
        [string] $Data,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/domains/$DomainID/dns"

    if ($PSCmdlet.ParameterSetName -eq 'GetByID') {
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
