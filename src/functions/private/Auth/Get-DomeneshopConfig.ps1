function Get-DomeneshopConfig {
    [CmdletBinding()]
    param()

    $vault = 'Domeneshop'
    $id = '__Domeneshop.Config'
    $config = Get-Context -ID $id -Vault $vault -ErrorAction SilentlyContinue

    if (-not $config) {
        $config = [ordered]@{
            DefaultContext = $null
            ApiBaseUri     = 'https://api.domeneshop.no/v0'
        }
        Set-Context -ID $id -Vault $vault -Context $config
        $config = Get-Context -ID $id -Vault $vault
    }

    $config
}
