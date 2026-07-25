function Get-DomeneshopApiBaseUri {
    <#
        .SYNOPSIS
        Get the API base URI from a resolved Domeneshop context.

        .DESCRIPTION
        Validate and normalize the API base URI stored on a resolved Domeneshop context.

        .EXAMPLE
        Get-DomeneshopApiBaseUri -Context $resolvedContext

        Get the normalized API base URI for a resolved context.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopApiBaseUri.

        .OUTPUTS
        System.String

        The normalized Domeneshop API base URI.

        .NOTES
        The caller must resolve and validate the context before invoking this helper.

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The resolved Domeneshop context containing an API base URI.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Context
    )

    $apiBaseUri = [string] $Context.ApiBaseUri
    if ([string]::IsNullOrWhiteSpace($apiBaseUri)) {
        throw "The Domeneshop context [$($Context.ID)] does not define an API base URI."
    }

    $parsedUri = $null
    if (-not [uri]::TryCreate($apiBaseUri, [System.UriKind]::Absolute, [ref] $parsedUri)) {
        throw "The Domeneshop context [$($Context.ID)] contains an invalid API base URI."
    }

    $parsedUri.AbsoluteUri.TrimEnd('/')
}
