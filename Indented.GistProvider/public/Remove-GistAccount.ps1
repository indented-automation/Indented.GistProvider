function Remove-GistAccount {
    <#
    .SYNOPSIS
        Remove an account from the provider.

    .DESCRIPTION
        Accounts may be removed from the provider using this command.
    #>

    [CmdletBinding()]
    param (
        [string]$Name
    )

    $null = [GistRoot]::Accounts.Remove($Name)
}
