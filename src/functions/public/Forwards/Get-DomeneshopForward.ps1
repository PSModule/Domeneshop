function Get-DomeneshopForward {
    <#
        .SYNOPSIS
        Gets HTTP forwards for a Domeneshop domain.

        .DESCRIPTION
        Lists forwards for a domain, or gets one forward by host.
    #>
    [OutputType([object[]])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(Mandatory)]
        [int] $DomainID,

        [Parameter(Mandatory, ParameterSetName = 'GetByHost')]
        [Alias('Host')]
        [string] $ForwardHost,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext

    $uri = if ($PSCmdlet.ParameterSetName -eq 'GetByHost') {
        $encodedHost = [uri]::EscapeDataString($ForwardHost)
        "$apiBaseUri/domains/$DomainID/forwards/$encodedHost"
    } else {
        "$apiBaseUri/domains/$DomainID/forwards/"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
