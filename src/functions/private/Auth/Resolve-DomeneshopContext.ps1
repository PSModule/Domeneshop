function Resolve-DomeneshopContext {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Context
    )

    $resolvedContext = if ($Context) {
        Get-DomeneshopContext -Context $Context
    } else {
        Get-DomeneshopContext
    }

    if (-not $resolvedContext) {
        throw "No Domeneshop context found. Run 'Connect-DomeneshopAccount' first."
    }

    if ([string]::IsNullOrEmpty($resolvedContext.Token) -or -not ($resolvedContext.Secret -is [securestring])) {
        throw "The Domeneshop context [$($resolvedContext.ID)] is missing valid credentials."
    }

    $resolvedContext
}
