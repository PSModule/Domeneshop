function Get-DomeneshopInvoice {
    <#
        .SYNOPSIS
        Gets Domeneshop invoices.

        .DESCRIPTION
        Lists invoices, or gets a specific invoice by invoice number.
    #>
    [OutputType([object[]])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'GetByID')]
        [Alias('InvoiceNo')]
        [int] $InvoiceID,

        [Parameter()]
        [string] $Context
    )

    $resolvedContext = Resolve-DomeneshopContext -Context $Context
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = if ($PSCmdlet.ParameterSetName -eq 'GetByID') {
        "$apiBaseUri/invoices/$InvoiceID"
    } else {
        "$apiBaseUri/invoices"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
