using namespace Microsoft.PowerShell.SHiPS

class GistAccount : SHiPSDirectory {
    hidden static [Hashtable] $containerCache = @{}

    GistAccount([string] $name) : base($name) { }

    [object[]] GetChildItem() {
        if (-not $this.ProviderContext.Force -and [GistAccount]::containerCache.Contains($this.Name)) {
            $containerList = [GistAccount]::containerCache[$this.Name]
        } else {
            $params = @{
                RestMethod = 'users/{0}/gists' -f $this.Name
            }
            $containerList = foreach ($containerInfo in InvokeGistRestMethod @params) {
                [GistItem]::new(
                    $containerInfo.files.PSObject.Properties.ForEach{ $_ }[0].Name,
                    $this.Name,
                    $containerInfo
                )
            }
            [GistAccount]::containerCache[$this.Name] = $containerList
        }

        return $containerList
    }
}
