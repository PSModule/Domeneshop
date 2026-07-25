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
    #>
    [OutputType([object[]])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'List')]
        [string] $Domain,

        [Parameter(Mandatory, ParameterSetName = 'GetByID')]
        [int] $DomainID,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext

    $uri = switch ($PSCmdlet.ParameterSetName) {
        'GetByID' { "$apiBaseUri/domains/$DomainID"; break }
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
