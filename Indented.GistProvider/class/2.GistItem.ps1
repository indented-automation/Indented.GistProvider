using namespace Microsoft.PowerShell.SHiPS

class GistItem : SHiPSDirectory {
    [string]   $Id
    [bool]     $IsPublic
    [DateTime] $Created
    [DateTime] $Updated
    [string]   $Description

    hidden [object] $containerInfo
    hidden [string] $accountName
    hidden [object] $files

    GistItem([string] $name) : base($name) { }

    GistItem(
        [string] $name,
        [string] $accountName,
        [object] $containerInfo
    ) : base($name) {
        $this.Id = $containerInfo.Id
        $this.IsPublic = $containerInfo.Public
        $this.Created = Get-Date $containerInfo.created_at
        $this.Updated = Get-Date $containerInfo.updated_at
        $this.Description = $containerInfo.description

        $this.accountName = $accountName
        $this.files = $containerInfo.files
    }

    [object[]] GetChildItem() {
        if ($this.ProviderContext.Force) {
            $params = @{
                RestMethod = 'users/{0}/gists/{1}' -f $this.accountName, $this.Id
            }
            $this.files = (InvokeGistRestMethod @params).files
            $this.containerInfo.files = $this.files
        }

        $fileList = foreach ($file in $this.files.PSObject.Properties.Name) {
            [GistFile]::new(
                $file,
                $this.accountName,
                $this.files.$file
            )
        }

        return $fileList
    }
}
