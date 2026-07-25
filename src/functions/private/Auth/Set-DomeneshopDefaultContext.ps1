function Set-DomeneshopDefaultContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Context
    )

    $config = Get-DomeneshopConfig
    $config.DefaultContext = $Context
    Set-Context -ID '__Domeneshop.Config' -Vault 'Domeneshop' -Context $config
}
