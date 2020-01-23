function Get-GistAccount {
    [CmdletBinding()]
    param (
        [string]$Name,

        [string]$DriveName = 'Gist'
    )

    (Get-PSDrive -Name $DriveName).Accounts
}
