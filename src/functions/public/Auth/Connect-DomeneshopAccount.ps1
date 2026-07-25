#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6' }

function Connect-DomeneshopAccount {
    <#
        .SYNOPSIS
        Stores Domeneshop API credentials in a secure context.

        .DESCRIPTION
        Stores Domeneshop API credentials using the Context module. The first stored context becomes the
        default automatically, and Default replaces an existing default. When Secret is omitted, opens the
        Domeneshop API settings page and securely prompts for it.

        .EXAMPLE
        Connect-DomeneshopAccount -Token 'my-token' -Secret (Read-Host -AsSecureString)

        Store credentials in the default named context.

        .EXAMPLE
        Connect-DomeneshopAccount -Token 'my-token'

        Open the Domeneshop API settings page and securely prompt for the API secret.

        .INPUTS
        None

        You can't pipe objects to Connect-DomeneshopAccount.

        .OUTPUTS
        System.Object

        The stored context when PassThru is specified.

        .NOTES
        Credentials are encrypted by the Context module.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Auth/Connect-DomeneshopAccount

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
        [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })]
        [string] $Token,

        # The Domeneshop API secret as a string or secure string.
        [Parameter()]
        [ValidateNotNull()]
        [ValidateScript({ Test-DomeneshopSecret -Secret $_ })]
        [Alias('Key')]
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

    if ($PSCmdlet.ShouldProcess("Domeneshop context [$Context]", 'Store API credentials')) {
        if (-not $PSBoundParameters.ContainsKey('Secret')) {
            Start-Process -FilePath 'https://domene.shop/admin?view=api'
            $Secret = Read-Host -Prompt 'Enter the Domeneshop API secret' -AsSecureString
            $null = Test-DomeneshopSecret -Secret $Secret
        }

        $secureSecret = if ($Secret -is [securestring]) {
            $Secret
        } else {
            ConvertTo-SecureString -AsPlainText $Secret -Force
        }

        $contextObject = [ordered]@{
            Name        = $Context
            Token       = $Token
            Secret      = $secureSecret
            AuthType    = 'BasicAuth'
            ApiBaseUri  = 'https://api.domeneshop.no/v0'
            ConnectedAt = Get-Date
        }

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
