using namespace Microsoft.PowerShell.SHiPS

class GistRoot : SHiPSDirectory {
    static [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    GistRoot([string]$name): base($name) { }

    [object[]] GetChildItem() {
        if ([GistRoot]::Accounts.Count -eq 0) {
            throw 'Must be connected to one or more accounts!'
        }

        $accountList = foreach ($account in [GistRoot]::Accounts) {
            [GistAccount]::new($account)
        }

        return $accountList
    }
}
