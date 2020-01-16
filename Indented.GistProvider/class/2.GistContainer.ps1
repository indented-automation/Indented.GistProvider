using namespace Microsoft.PowerShell.SHiPS

class GistContainer : SHiPSDirectory {
    static [Hashtable] $fileCache = @{}

    [string]   $Id
    [bool]     $IsPublic
    [DateTime] $Created
    [DateTime] $Updated
    [string]   $Description

    hidden [object] $files

    GistContainer([string]$name): base($name) { }

    GistContainer([string]$name, [object] $containerInfo): base($name) {
        $this.Id = $containerInfo.Id
        $this.IsPublic = $containerInfo.Public
        $this.Created = Get-Date $containerInfo.created_at
        $this.Updated = Get-Date $containerInfo.updated_at
        $this.Description = $containerInfo.description

        $this.files = $containerInfo.files
    }

    [object[]] GetChildItem() {
        $fileList = foreach ($file in $this.files.PSObject.Properties.Name) {
            [GistFile]::new(
                $file,
                $this.files.$file
            )
        }

        return $fileList
    }
}
