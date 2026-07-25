function Update-DomeneshopDdns {
    <#
        .SYNOPSIS
        Updates dynamic DNS for a hostname.

        .DESCRIPTION
        Calls the Domeneshop DDNS update endpoint. The API creates the A/AAAA record if it does not exist.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('Host')]
        [string] $Hostname,

        [Parameter()]
        [Alias('IP')]
        [string] $MyIP,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = "$apiBaseUri/dyndns/update?hostname=$([uri]::EscapeDataString($Hostname))"
    if ($PSBoundParameters.ContainsKey('MyIP')) {
        $uri = "$uri&myip=$([uri]::EscapeDataString($MyIP))"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
