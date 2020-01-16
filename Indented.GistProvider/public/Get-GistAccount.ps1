function Get-GistAccount {
    [CmdletBinding()]
    param (
        [string]$Name
    )

    [GistRoot]::Accounts
}
