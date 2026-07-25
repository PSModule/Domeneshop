function Add-DomeneshopForward {
    <#
        .SYNOPSIS
        Add an HTTP forward to a Domeneshop domain.

        .DESCRIPTION
        Create an HTTP forward from the supplied Domeneshop API request object.

        .EXAMPLE
        $forward = @{
            host = 'www'
            ('URL'.ToLowerInvariant()) = 'HTTPS'.ToLowerInvariant() + '://example.net'
        }
        Add-DomeneshopForward -DomainID 42 -Forward $forward

        Add a www forward to domain 42.

        .INPUTS
        None

        You can't pipe objects to Add-DomeneshopForward.

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

        # The HTTP forward request object accepted by the Domeneshop API.
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
    $uri = "$apiBaseUri/domains/$DomainID/forwards/"

    if ($PSCmdlet.ShouldProcess("Domain [$DomainID] HTTP forwards", 'Add HTTP forward')) {
        Invoke-DomeneshopApiRequest -Method Post -Uri $uri -Context $resolvedContext -Body $Forward
    }
}
