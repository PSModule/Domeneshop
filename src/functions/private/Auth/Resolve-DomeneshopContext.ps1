function Resolve-DomeneshopContext {
    <#
        .SYNOPSIS
        Validate a resolved Domeneshop context.

        .DESCRIPTION
        Verify that a context resolved by a public command contains the credentials and API endpoint required by private helpers.

        .EXAMPLE
        Resolve-DomeneshopContext -Context $storedContext

        Validate and emit a stored Domeneshop context.

        .INPUTS
        None

        You can't pipe objects to Resolve-DomeneshopContext.

        .OUTPUTS
        System.Object

        The validated Domeneshop context.

        .NOTES
        This helper never selects or defaults a context. Public commands own that behavior.

        .LINK
        https://psmodule.io/Context/
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # The context object selected by a public command.
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Context
    )

    if ($null -eq $Context) {
        throw "No Domeneshop context found. Run 'Connect-DomeneshopAccount' first."
    }

    if ([string]::IsNullOrWhiteSpace([string] $Context.Token) -or -not ($Context.Secret -is [securestring])) {
        throw "The Domeneshop context [$($Context.ID)] is missing valid credentials."
    }

    if ([string]::IsNullOrWhiteSpace([string] $Context.ApiBaseUri)) {
        throw "The Domeneshop context [$($Context.ID)] is missing an API base URI."
    }

    $Context
}
