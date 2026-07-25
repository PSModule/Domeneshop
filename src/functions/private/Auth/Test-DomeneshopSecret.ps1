function Test-DomeneshopSecret {
    <#
        .SYNOPSIS
        Validate a Domeneshop API secret.

        .DESCRIPTION
        Reject empty string and secure string values before credential storage.

        .EXAMPLE
        Test-DomeneshopSecret -Secret $secret

        Confirm that the secret contains a value.

        .INPUTS
        None

        You can't pipe objects to Test-DomeneshopSecret.

        .OUTPUTS
        System.Boolean

        True when the secret is not empty.

        .NOTES
        Secret type validation remains the responsibility of the calling command.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The proposed API secret.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Secret
    )

    if (
        ($Secret -is [string] -and [string]::IsNullOrWhiteSpace($Secret)) -or
        ($Secret -is [securestring] -and $Secret.Length -eq 0)
    ) {
        throw 'Secret cannot be empty or whitespace.'
    }

    $true
}
