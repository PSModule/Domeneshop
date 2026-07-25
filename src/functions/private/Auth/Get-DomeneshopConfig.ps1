#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6' }

function Get-DomeneshopConfig {
    <#
        .SYNOPSIS
        Get the Domeneshop module configuration.

        .DESCRIPTION
        Read the module configuration from the Context vault or return an in-memory default when no configuration has been stored.

        .EXAMPLE
        Get-DomeneshopConfig

        Get the current Domeneshop module configuration.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopConfig.

        .OUTPUTS
        System.Object

        The stored or default Domeneshop module configuration.

        .NOTES
        This read helper does not create or update Context vault entries.

        .LINK
        https://psmodule.io/Context/
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param()

    $vault = 'Domeneshop'
    $id = '__Domeneshop.Config'
    $config = Get-Context -ID $id -Vault $vault

    if (-not $config) {
        $config = [pscustomobject][ordered]@{
            DefaultContext = $null
            ApiBaseUri     = 'https://api.domeneshop.no/v0'
        }
    }

    $config
}
