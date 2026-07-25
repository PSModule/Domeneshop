function Update-DomeneshopDdns {
    <#
        .SYNOPSIS
        Update dynamic DNS for a hostname.

        .DESCRIPTION
        Calls the Domeneshop DDNS update endpoint. The API creates the A/AAAA record if it does not exist.

        .EXAMPLE
        Update-DomeneshopDdns -Hostname 'home.example.com' -MyIP '192.0.2.10'

        Update the dynamic DNS address for home.example.com.

        .INPUTS
        None

        You can't pipe objects to Update-DomeneshopDdns.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop DDNS endpoint.

        .NOTES
        Uses the caller's public IP address when MyIP is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Ddns/Update-DomeneshopDdns

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns', '',
        Justification = 'DDNS is the established singular name of the Domeneshop API capability.'
    )]
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The fully qualified hostname to update.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [Alias('Host')]
        [string] $Hostname,

        # The IPv4 or IPv6 address to publish.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [Alias('IP')]
        [string] $MyIP,

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
    $uri = "$apiBaseUri/dyndns/update?hostname=$([uri]::EscapeDataString($Hostname))"
    if ($PSBoundParameters.ContainsKey('MyIP')) {
        $uri = "$uri&myip=$([uri]::EscapeDataString($MyIP))"
    }

    if ($PSCmdlet.ShouldProcess("Dynamic DNS host [$Hostname]", 'Update address')) {
        Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
    }
}
