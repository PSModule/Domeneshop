function Get-DomeneshopContext {
    <#
        .SYNOPSIS
        Gets stored Domeneshop contexts.

        .DESCRIPTION
        Returns one or more contexts stored in the Domeneshop context vault.

        .EXAMPLE
        Get-DomeneshopContext
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'GetDefault')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'GetNamed')]
        [string] $Context,

        [Parameter(Mandatory, ParameterSetName = 'ListAvailable')]
        [switch] $ListAvailable
    )

    $id = switch ($PSCmdlet.ParameterSetName) {
        'GetNamed' { $Context; break }
        'ListAvailable' { '*'; break }
        default {
            $config = Get-DomeneshopConfig
            if ([string]::IsNullOrEmpty($config.DefaultContext)) {
                throw "No default Domeneshop context found. Run 'Connect-DomeneshopAccount' first."
            }
            $config.DefaultContext
        }
    }

    Get-Context -ID $id -Vault 'Domeneshop' | Where-Object { $_.ID -ne '__Domeneshop.Config' } | Sort-Object -Property ID
}
