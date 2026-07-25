function Connect-DomeneshopAccount {
    <#
        .SYNOPSIS
        Stores Domeneshop API credentials in a secure context.

        .DESCRIPTION
        Stores Domeneshop API credentials using the Context module and optionally sets the context as default.

        .EXAMPLE
        Connect-DomeneshopAccount -Token 'my-token' -Secret (Read-Host -AsSecureString)
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter(Mandatory)]
        [object] $Secret,

        [Parameter()]
        [string] $Context = 'default',

        [Parameter()]
        [switch] $Default,

        [Parameter()]
        [switch] $PassThru
    )

    $secureSecret = switch ($Secret) {
        { $_ -is [securestring] } { $_; break }
        { $_ -is [string] } { ConvertTo-SecureString -AsPlainText $Secret -Force; break }
        default { throw 'Secret must be a SecureString or String value.' }
    }

    $contextObject = [ordered]@{
        Name        = $Context
        Token       = $Token
        Secret      = $secureSecret
        AuthType    = 'BasicAuth'
        ApiBaseUri  = 'https://api.domeneshop.no/v0'
        ConnectedAt = Get-Date
    }

    Set-Context -ID $Context -Vault 'Domeneshop' -Context $contextObject

    $config = Get-DomeneshopConfig
    if ($Default -or [string]::IsNullOrEmpty($config.DefaultContext)) {
        Set-DomeneshopDefaultContext -Context $Context
    }

    if ($PassThru) {
        Get-DomeneshopContext -Context $Context
    }
}
