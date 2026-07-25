function Get-DomeneshopDomain {
    <#
        .SYNOPSIS
        Lists Domeneshop domains.

        .DESCRIPTION
        Uses the stored Domeneshop context credentials and calls the /domains endpoint.

        .EXAMPLE
        Get-DomeneshopDomain

        .EXAMPLE
        Get-DomeneshopDomain -Domain '.no'

        List domains ending in .no.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopDomain.

        .OUTPUTS
        System.Object

        The matching Domeneshop domain records.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Domains/Get-DomeneshopDomain

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # A domain-name filter for list requests.
        [Parameter(ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string] $Domain,

        # The numeric identifier of a specific domain.
        [Parameter(Mandatory, ParameterSetName = 'Get by ID')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $DomainID,

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

    $uri = switch ($PSCmdlet.ParameterSetName) {
        'Get by ID' { "$apiBaseUri/domains/$DomainID"; break }
        default {
            $listUri = "$apiBaseUri/domains"
            if ($Domain) {
                $encodedDomain = [uri]::EscapeDataString($Domain)
                $listUri = "${listUri}?domain=$encodedDomain"
            }
            $listUri
        }
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
