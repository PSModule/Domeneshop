#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

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

Describe 'Domeneshop private helpers' {
    BeforeAll {
        . "$PSScriptRoot\Domeneshop.TestSetup.ps1"
    }

    It 'rejects a missing resolved context' {
        { Resolve-DomeneshopContext -Context $null } |
            Should -Throw '*No Domeneshop context found*'
    }

    It 'rejects a context without secure credentials' {
        $context = [pscustomobject]@{
            ID         = 'invalid'
            Token      = 'token'
            Secret     = 'plain-text'
            ApiBaseUri = 'https://api.domeneshop.no/v0'
        }

        { Resolve-DomeneshopContext -Context $context } |
            Should -Throw '*missing valid credentials*'
    }

    It 'rejects an invalid API base URI' {
        $context = [pscustomobject]@{
            ID         = 'invalid'
            ApiBaseUri = 'not a URI'
        }

        { Get-DomeneshopApiBaseUri -Context $context } |
            Should -Throw '*invalid API base URI*'
    }

    It 'uses basic authentication and terminating transport errors' {
        Mock Invoke-RestMethod { [pscustomobject]@{ ok = $true } }

        $result = Invoke-DomeneshopApiRequest -Method Get -Uri 'https://api.domeneshop.no/v0/domains' -Context $script:DomeneshopTestContext

        $result.ok | Should -BeTrue
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'Get' -and
            $Authentication -eq 'Basic' -and
            $Credential.UserName -eq 'token' -and
            $ErrorAction -eq 'Stop'
        }
    }
}
