#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6' }

function Get-DomeneshopContext {
    <#
        .SYNOPSIS
        Gets stored Domeneshop contexts.

        .DESCRIPTION
        Returns one or more contexts stored in the Domeneshop context vault.

        .EXAMPLE
        Get-DomeneshopContext

        Get the default Domeneshop context.

        .EXAMPLE
        Get-DomeneshopContext -ListAvailable

        List all stored Domeneshop credential contexts.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopContext.

        .OUTPUTS
        System.Object

        One or more stored Domeneshop contexts.

        .NOTES
        The configuration entry used to track the default is excluded from list output.

        .LINK
        https://psmodule.io/Context/
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'Get default')]
    param(
        # The name of a specific stored context.
        [Parameter(Mandatory, ParameterSetName = 'Get named')]
        [ValidateNotNullOrEmpty()]
        [string] $Context,

        # List every stored Domeneshop credential context.
        [Parameter(Mandatory, ParameterSetName = 'List available')]
        [switch] $ListAvailable
    )

    if ($ListAvailable) {
        $id = '*'
    } elseif ($PSBoundParameters.ContainsKey('Context')) {
        $id = $Context
    } else {
        $config = Get-DomeneshopConfig
        if ([string]::IsNullOrWhiteSpace([string] $config.DefaultContext)) {
            throw "No default Domeneshop context found. Run 'Connect-DomeneshopAccount' first."
        }
        $id = $config.DefaultContext
    }

    Get-Context -ID $id -Vault 'Domeneshop' | Where-Object { $_.ID -ne '__Domeneshop.Config' } | Sort-Object -Property ID
}
