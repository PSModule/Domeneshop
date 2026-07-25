function Test-DomeneshopContextName {
    <#
        .SYNOPSIS
        Validate a Domeneshop credential context name.

        .DESCRIPTION
        Reject names reserved for internal Domeneshop module configuration.

        .EXAMPLE
        Test-DomeneshopContextName -Context 'production'

        Confirm that production can be used as a credential context name.

        .INPUTS
        None

        You can't pipe objects to Test-DomeneshopContextName.

        .OUTPUTS
        System.Boolean

        True when the context name is available for credentials.

        .NOTES
        Throws when the context name is reserved.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The proposed credential context name.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Context
    )

    if ($Context -eq '__Domeneshop.Config') {
        throw "Context name [$Context] is reserved for Domeneshop module configuration."
    }

    $true
}
