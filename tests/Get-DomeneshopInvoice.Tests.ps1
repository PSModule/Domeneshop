[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter', '',
    Justification = 'Required for Pester mock parameter filters.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester test setup.'
)]
[CmdletBinding()]
param()

Describe 'Get-DomeneshopInvoice' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    BeforeEach {
        Mock Get-DomeneshopContext { $script:DomeneshopTestContext }
        Mock Invoke-DomeneshopApiRequest {}
    }

    It 'lists invoices' {
        Get-DomeneshopInvoice -Context 'demo'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/invoices'
        }
    }

    It 'gets an invoice by ID' {
        Get-DomeneshopInvoice -Context 'demo' -InvoiceID 1001

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/invoices/1001'
        }
    }
}
