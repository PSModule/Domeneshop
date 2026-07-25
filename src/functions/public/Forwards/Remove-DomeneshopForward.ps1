function Remove-DomeneshopForward {
    <#
        .SYNOPSIS
        Remove an HTTP forward from a Domeneshop domain.

        .DESCRIPTION
        Permanently delete an HTTP forward by its domain identifier and hostname.

        .EXAMPLE
        Remove-DomeneshopForward -DomainID 42 -ForwardHost 'www'

        Remove the www forward from domain 42 after confirmation.

        .INPUTS
        None

        You can't pipe objects to Remove-DomeneshopForward.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop API.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The numeric identifier of the domain that owns the forward.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The hostname of the HTTP forward to remove.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Host')]
        [string] $ForwardHost,

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
    $encodedHost = [uri]::EscapeDataString($ForwardHost)
    $uri = "$apiBaseUri/domains/$DomainID/forwards/$encodedHost"

    if ($PSCmdlet.ShouldProcess("Domain $DomainID forward $ForwardHost", 'Remove')) {
        Invoke-DomeneshopApiRequest -Method Delete -Uri $uri -Context $resolvedContext
    }
}
