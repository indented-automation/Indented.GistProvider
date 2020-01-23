function Remove-GistAccount {
    <#
    .SYNOPSIS
        Remove an account from the provider.

    .DESCRIPTION
        Accounts may be removed from the provider using this command.
    #>

    [CmdletBinding()]
    param (
        [string]$Name,

        [string]$DriveName = 'Gist'
    )

    (Get-PSDrive -Name $DriveName).Accounts.Remove($Name)
}
