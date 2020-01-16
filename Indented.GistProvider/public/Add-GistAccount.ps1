function Add-GistAccount {
    <#
    .SYNOPSIS
        Adds a new account to the provider.

    .DESCRIPTION
        Accounts must be explicitly added to list content.
    #>

    [CmdletBinding()]
    param (
        # The name of the account to add to the provider.
        [string]$Name
    )

    $null = [GistRoot]::Accounts.Add($Name)
}
