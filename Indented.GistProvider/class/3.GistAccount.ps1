using namespace Microsoft.PowerShell.SHiPS

class GistAccount : SHiPSDirectory {
    static [Hashtable] $containerCache = @{}

    GistAccount([string]$name) : base($name) { }

    [object[]] GetChildItem() {
        $params = @{
            RestMethod = 'users/{0}/gists' -f $this.Name
        }

        if ([GistAccount]::containerCache.Contains($this.Name)) {
            $containerList = [GistAccount]::containerCache[$this.Name]
        } else {
            $containerList = foreach ($containerInfo in InvokeGitHubRestMethod @params) {
                [GistContainer]::new(
                    $containerInfo.files.PSObject.Properties.ForEach{ $_ }[0].Name,
                    $containerInfo
                )
            }
            [GistAccount]::containerCache[$this.Name] = $containerList
        }

        return $containerList
    }
}
