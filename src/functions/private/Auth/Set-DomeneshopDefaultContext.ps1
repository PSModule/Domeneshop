#Requires -Modules @{ ModuleName = 'Context'; ModuleVersion = '8.1.6' }

function Set-DomeneshopDefaultContext {
    <#
        .SYNOPSIS
        Set the default Domeneshop context name.

        .DESCRIPTION
        Persist the selected default context name in the Domeneshop configuration entry.

        .EXAMPLE
        Set-DomeneshopDefaultContext -Context 'production'

        Set production as the default Domeneshop context.

        .INPUTS
        None

        You can't pipe objects to Set-DomeneshopDefaultContext.

        .OUTPUTS
        None

        Set-DomeneshopDefaultContext doesn't emit output.

        .NOTES
        Supports WhatIf and Confirm before changing the module configuration.

        .LINK
        https://psmodule.io/Context/
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        # The name of an existing Domeneshop context.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-DomeneshopContextName -Context $_ })]
        [string] $Context
    )

    $config = Get-DomeneshopConfig
    $config.DefaultContext = $Context
    if ($PSCmdlet.ShouldProcess('Domeneshop module configuration', "Set [$Context] as the default context")) {
        $null = Set-Context -ID '__Domeneshop.Config' -Vault 'Domeneshop' -Context $config
    }
}
