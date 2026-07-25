function Get-DomeneshopForward {
    <#
        .SYNOPSIS
        Gets HTTP forwards for a Domeneshop domain.

        .DESCRIPTION
        Lists forwards for a domain, or gets one forward by host.

        .EXAMPLE
        Get-DomeneshopForward -DomainID 42

        List every HTTP forward for domain 42.

        .EXAMPLE
        Get-DomeneshopForward -DomainID 42 -ForwardHost 'www'

        Get the www forward for domain 42.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopForward.

        .OUTPUTS
        System.Object

        The matching Domeneshop HTTP forwards.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The numeric identifier of the domain that owns the forwards.
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

        # The hostname of a specific HTTP forward.
        [Parameter(Mandatory, ParameterSetName = 'Get by host')]
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

    $uri = if ($PSCmdlet.ParameterSetName -eq 'Get by host') {
        $encodedHost = [uri]::EscapeDataString($ForwardHost)
        "$apiBaseUri/domains/$DomainID/forwards/$encodedHost"
    } else {
        "$apiBaseUri/domains/$DomainID/forwards/"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
