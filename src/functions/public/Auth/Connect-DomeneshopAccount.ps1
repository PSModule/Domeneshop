#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6' }

function Connect-DomeneshopAccount {
    <#
        .SYNOPSIS
        Stores Domeneshop API credentials in a secure context.

        .DESCRIPTION
        Stores Domeneshop API credentials using the Context module. The first stored context becomes the
        default automatically, and Default replaces an existing default.

        .EXAMPLE
        Connect-DomeneshopAccount -Token 'my-token' -Secret (Read-Host -AsSecureString)

        Store credentials in the default named context.

        .INPUTS
        None

        You can't pipe objects to Connect-DomeneshopAccount.

        .OUTPUTS
        System.Object

        The stored context when PassThru is specified.

        .NOTES
        Credentials are encrypted by the Context module.

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'String secrets remain supported for compatibility and are converted before storage.'
    )]
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The Domeneshop API token used as the Basic authentication username.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Token,

        # The Domeneshop API secret as a string or secure string.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateScript({ Test-DomeneshopSecret -Secret $_ })]
        [object] $Secret,

        # The name used to store and retrieve this credential context.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-DomeneshopContextName -Context $_ })]
        [string] $Context = 'default',

        # Replace the default context; the first stored context becomes the default automatically.
        [Parameter()]
        [switch] $Default,

        # Emit the stored context after it is saved.
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

    if ($PSCmdlet.ShouldProcess("Domeneshop context [$Context]", 'Store API credentials')) {
        $null = Set-Context -ID $Context -Vault 'Domeneshop' -Context $contextObject

        $config = Get-DomeneshopConfig
        if ($Default -or [string]::IsNullOrWhiteSpace([string] $config.DefaultContext)) {
            Set-DomeneshopDefaultContext -Context $Context -Confirm:$false
        }

        if ($PassThru) {
            Get-DomeneshopContext -Context $Context
        }
    }
}
