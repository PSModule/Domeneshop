function Get-DomeneshopInvoice {
    <#
        .SYNOPSIS
        Gets Domeneshop invoices.

        .DESCRIPTION
        Lists invoices, or gets a specific invoice by invoice number.

        .EXAMPLE
        Get-DomeneshopInvoice

        List all Domeneshop invoices.

        .EXAMPLE
        Get-DomeneshopInvoice -InvoiceID 1001

        Get invoice 1001.

        .INPUTS
        None

        You can't pipe objects to Get-DomeneshopInvoice.

        .OUTPUTS
        System.Object

        The matching Domeneshop invoices.

        .NOTES
        Uses the default context when Context is omitted.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Invoices/Get-DomeneshopInvoice

        .LINK
        https://api.domeneshop.no/docs/
    #>
    [OutputType([object])]
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        # The numeric identifier of a specific invoice.
        [Parameter(Mandatory, ParameterSetName = 'Get by ID')]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('InvoiceNo')]
        [int] $InvoiceID,

        # The stored credential context to use instead of the default.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Context
    )

    $storedContext = if ($PSBoundParameters.ContainsKey('Context')) {
        Get-DomeneshopContext -Context $Context
    } else {
        Get-DomeneshopContext
    }
    $resolvedContext = Resolve-DomeneshopContext -Context $storedContext
    $apiBaseUri = Get-DomeneshopApiBaseUri -Context $resolvedContext
    $uri = if ($PSCmdlet.ParameterSetName -eq 'Get by ID') {
        "$apiBaseUri/invoices/$InvoiceID"
    } else {
        "$apiBaseUri/invoices"
    }

    Invoke-DomeneshopApiRequest -Method Get -Uri $uri -Context $resolvedContext
}
