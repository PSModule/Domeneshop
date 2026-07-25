function Invoke-DomeneshopApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete')]
        [string] $Method,

        [Parameter(Mandatory)]
        [string] $Uri,

        [Parameter(Mandatory)]
        [object] $Context,

        [Parameter()]
        [AllowNull()]
        [object] $Body
    )

    $credential = [pscredential]::new(
        [string] $Context.Token,
        [securestring] $Context.Secret
    )

    $params = @{
        Method         = $Method
        Uri            = $Uri
        Authentication = 'Basic'
        Credential     = $credential
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $params['ContentType'] = 'application/json'
        $params['Body'] = ($Body | ConvertTo-Json -Depth 100)
    }

    Invoke-RestMethod @params
}
