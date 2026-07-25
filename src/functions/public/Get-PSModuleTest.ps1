function Get-PSModuleTest {
    <#
        .SYNOPSIS
        Get a greeting for a supplied name.

        .DESCRIPTION
        Return a simple greeting used to verify that the module imports and invokes exported commands.

        .EXAMPLE
        Get-PSModuleTest -Name 'World'

        Get the greeting "Hello, World!".

        .INPUTS
        None

        You can't pipe objects to Get-PSModuleTest.

        .OUTPUTS
        System.String

        A greeting containing the supplied name.

        .NOTES
        This command is retained as the module's baseline smoke-test command.

        .LINK
        https://psmodule.io/Domeneshop/Functions/Get-PSModuleTest/

        .LINK
        https://github.com/PSModule/Domeneshop
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The name to include in the greeting.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )

    "Hello, $Name!"
}
