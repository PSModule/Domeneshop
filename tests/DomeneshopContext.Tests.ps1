[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter', '',
    Justification = 'Required for Pester tests'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester tests'
)]
[CmdletBinding()]
param()

Describe 'Domeneshop context and auth flow' {
    BeforeAll {
        $functionFiles = Get-ChildItem -Path "$PSScriptRoot\..\src\functions" -Filter '*.ps1' -Recurse -File | Sort-Object -Property FullName
        foreach ($file in $functionFiles) {
            . $file.FullName
        }
    }

    It 'Connect-DomeneshopAccount stores credentials in Context and can set default' {
        Mock Set-Context {}
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = $null } }
        Mock Set-DomeneshopDefaultContext {}
        Mock Get-DomeneshopContext { [pscustomobject]@{ ID = 'demo' } }

        Connect-DomeneshopAccount -Token 'token' -Secret 'secret' -Context 'demo' -PassThru | Should -Not -BeNullOrEmpty

        Should -Invoke Set-Context -Times 1 -Exactly -ParameterFilter {
            $ID -eq 'demo' -and
            $Vault -eq 'Domeneshop' -and
            $Context.Secret -is [securestring]
        }
        Should -Invoke Set-DomeneshopDefaultContext -Times 1 -Exactly
    }

    It 'Get-DomeneshopContext throws when default context is not configured' {
        Mock Get-DomeneshopConfig { [pscustomobject]@{ DefaultContext = '' } }

        { Get-DomeneshopContext } | Should -Throw
    }

    It 'Get-DomeneshopDomain calls domains endpoint with domain filter' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @() }

        { Get-DomeneshopDomain -Context 'demo' -Domain '.no' } | Should -Not -Throw

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains?domain=.no' -and
            $Context.ID -eq 'demo'
        }
    }

    It 'Invoke-DomeneshopApiRequest uses basic authentication' {
        Mock Invoke-RestMethod { [pscustomobject]@{ ok = $true } }
        $contextObject = [pscustomobject]@{
            Token  = 'token'
            Secret = ConvertTo-SecureString -AsPlainText 'secret' -Force
        }

        $result = Invoke-DomeneshopApiRequest -Method Get -Uri 'https://api.domeneshop.no/v0/domains' -Context $contextObject

        $result.ok | Should -BeTrue
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Authentication -eq 'Basic' -and
            $Credential.UserName -eq 'token'
        }
    }

    It 'Get-DomeneshopDomain can get a domain by ID' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @{} }

        { Get-DomeneshopDomain -Context 'demo' -DomainID 42 } | Should -Not -Throw
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/42'
        }
    }

    It 'Get-DomeneshopDnsRecord builds list query and endpoint' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @() }

        Get-DomeneshopDnsRecord -DomainID 9 -Host 'www' -Type 'A' -Data '127.0.0.1'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/9/dns?host=www&type=A&data=127.0.0.1'
        }
    }

    It 'Get-DomeneshopDnsRecord can get record by ID' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @{} }

        Get-DomeneshopDnsRecord -DomainID 9 -RecordID 3

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -eq 'https://api.domeneshop.no/v0/domains/9/dns/3'
        }
    }

    It 'DNS mutating commands call expected endpoints' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @{} }

        $record = @{ host = 'www'; type = 'A'; data = '127.0.0.1' }
        Add-DomeneshopDnsRecord -DomainID 9 -Record $record
        Set-DomeneshopDnsRecord -DomainID 9 -RecordID 3 -Record $record
        Remove-DomeneshopDnsRecord -DomainID 9 -RecordID 3 -Confirm:$false

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Post' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/dns'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Put' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/dns/3'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Delete' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/dns/3'
        }
    }

    It 'Forward commands call expected endpoints' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @{} }

        $forward = @{ host = 'www'; url = 'https://example.net' }
        Get-DomeneshopForward -DomainID 9
        Get-DomeneshopForward -DomainID 9 -Host 'www'
        Add-DomeneshopForward -DomainID 9 -Forward $forward
        Set-DomeneshopForward -DomainID 9 -Host 'www' -Forward $forward
        Remove-DomeneshopForward -DomainID 9 -Host 'www' -Confirm:$false

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/forwards/'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/forwards/www'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Post' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/forwards/'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Put' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/forwards/www'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Delete' -and $Uri -eq 'https://api.domeneshop.no/v0/domains/9/forwards/www'
        }
    }

    It 'Get-DomeneshopInvoice supports list and by ID' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @() }

        Get-DomeneshopInvoice
        Get-DomeneshopInvoice -InvoiceID 7

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/invoices'
        }
        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/invoices/7'
        }
    }

    It 'Update-DomeneshopDdns builds hostname and myip query' {
        Mock Resolve-DomeneshopContext {
            [pscustomobject]@{
                ID         = 'demo'
                Token      = 'token'
                Secret     = ConvertTo-SecureString -AsPlainText 'secret' -Force
                ApiBaseUri = 'https://api.domeneshop.no/v0'
            }
        }
        Mock Invoke-DomeneshopApiRequest { @{} }

        Update-DomeneshopDdns -Hostname 'home.example.com' -MyIP '1.2.3.4'

        Should -Invoke Invoke-DomeneshopApiRequest -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and $Uri -eq 'https://api.domeneshop.no/v0/dyndns/update?hostname=home.example.com&myip=1.2.3.4'
        }
    }
}
