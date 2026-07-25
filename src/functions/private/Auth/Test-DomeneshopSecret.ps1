function Test-DomeneshopSecret {
    <#
        .SYNOPSIS
        Validate a Domeneshop API secret.

        .DESCRIPTION
        Reject unsupported and empty values before credential storage.

        .EXAMPLE
        Test-DomeneshopSecret -Secret $secret

        Confirm that the secret contains a value.

        .INPUTS
        None

        You can't pipe objects to Test-DomeneshopSecret.

        .OUTPUTS
        System.Boolean

        True when the secret has a supported type and is not empty.

        .NOTES
        Supported values are String and SecureString.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Auth/Connect-DomeneshopAccount
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The proposed API secret.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Secret
    )

    if ($Secret -isnot [string] -and $Secret -isnot [securestring]) {
        throw 'Secret must be a SecureString or String value.'
    }

    if (
        ($Secret -is [string] -and [string]::IsNullOrWhiteSpace($Secret)) -or
        ($Secret -is [securestring] -and $Secret.Length -eq 0)
    ) {
        throw 'Secret cannot be empty or whitespace.'
    }

    $true
}
