function Invoke-DomeneshopApiRequest {
    <#
        .SYNOPSIS
        Send an authenticated request to the Domeneshop API.

        .DESCRIPTION
        Build an HTTP Basic credential from a resolved Domeneshop context and send a REST request, optionally with a JSON body.

        .EXAMPLE
        Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext

        Send an authenticated GET request.

        .EXAMPLE
        Invoke-DomeneshopApiRequest -Method Post -Uri $uri -Context $resolvedContext -Body $body

        Send an authenticated POST request with a JSON body.

        .INPUTS
        None

        You can't pipe objects to Invoke-DomeneshopApiRequest.

        .OUTPUTS
        System.Object

        The response returned by the Domeneshop API.

        .NOTES
        Transport errors are terminating so public callers fail fast.

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # The HTTP method accepted by the Domeneshop API.
        [Parameter(Mandatory)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete')]
        [string] $Method,

        # The absolute Domeneshop API endpoint URI.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [uri] $Uri,

        # The resolved Domeneshop context containing valid credentials.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Context,

        # The request payload to serialize as JSON.
        [Parameter()]
        [AllowNull()]
        [object] $Body
    )

    $credential = [pscredential]::new(
        [string] $Context.Token,
        [securestring] $Context.Secret
    )

    $params = @{
        Method      = $Method
        Uri         = $Uri
        Credential  = $credential
        ErrorAction = 'Stop'
    }

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $params['Authentication'] = 'Basic'
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $params['ContentType'] = 'application/json'
        $params['Body'] = ($Body | ConvertTo-Json -Depth 100)
    }

    Write-Debug "Sending $Method request to [$Uri]."
    Invoke-RestMethod @params
}
