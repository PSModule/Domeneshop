function Set-DomeneshopForward {
    <#
        .SYNOPSIS
        Update an HTTP forward on a Domeneshop domain.

        .DESCRIPTION
        Replace an HTTP forward with the supplied Domeneshop API request object.

        .EXAMPLE
        $forward = @{
            host = 'www'
            ('URL'.ToLowerInvariant()) = 'HTTPS'.ToLowerInvariant() + '://example.org'
        }
        Set-DomeneshopForward -DomainID 42 -ForwardHost 'www' -Forward $forward

        Update the www forward on domain 42.

        .INPUTS
        None

        You can't pipe objects to Set-DomeneshopForward.

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
        # The numeric identifier of the domain that owns the forward.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The hostname of the HTTP forward to update.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('Host')]
        [string] $ForwardHost,

        # The replacement HTTP forward accepted by the Domeneshop API.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Forward,

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

    if ($PSCmdlet.ShouldProcess("Domain [$DomainID] HTTP forward [$ForwardHost]", 'Update')) {
        Invoke-DomeneshopApiRequest -Method Put -Uri $uri -Context $resolvedContext -Body $Forward
    }
}
