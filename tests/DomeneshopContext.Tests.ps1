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
}
