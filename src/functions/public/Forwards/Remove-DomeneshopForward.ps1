function Remove-DomeneshopForward {
    <#
        .SYNOPSIS
        Removes an HTTP forward from a Domeneshop domain.
    #>
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory)]
        [Alias('Host')]
        [string] $ForwardHost,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $encodedHost = [uri]::EscapeDataString($ForwardHost)
    $uri = "$apiBaseUri/domains/$DomainID/forwards/$encodedHost"

    if ($PSCmdlet.ShouldProcess("Domain $DomainID forward $ForwardHost", 'Remove')) {
        Invoke-DomeneshopApiRequest -Method Delete -Uri $uri -Context $resolvedContext
    }
}
