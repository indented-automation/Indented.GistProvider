class GistItem : GistBase {
    [string]     $ID
    [bool]       $IsPublic
    [DateTime]   $Created
    [DateTime]   $Updated
    [string]     $Description
    [GistFile[]] $Files
    [string]     $GistAccountName

    GistItem([string] $name) : base($name) { }

    GistItem(
        [string] $name,
        [string] $accountName,
        [object] $containerInfo
    ) : base($name) {
        $this.ID = $containerInfo.ID
        $this.IsPublic = $containerInfo.Public
        $this.Created = Get-Date $containerInfo.created_at
        $this.Updated = Get-Date $containerInfo.updated_at
        $this.Description = $containerInfo.description
        $this.GistAccountName = $accountName
        $this.Files = foreach ($file in $containerInfo.Files.PSObject.Properties.Name) {
            [GistFile]::new(
                $file,
                $accountName,
                $containerInfo.Files.$file,
                $this.ID
            )
        }
    }

    hidden static [void] GetItem(
        [string]       $path,
        [GistProvider] $provider
    ) {
        # if ($provider.Force) {
        #     [GistCache]::UpdateCache($accountName)
        # }

        foreach ($item in [GistCache]::GetCacheItem($path)) {
            $provider.WriteItemObject(
                $item,
                $path,
                $true
            )
        }
    }

    hidden static [Void] GetChildItemsOrNames(
        [String]       $path,
        [bool]         $recurse,
        [bool]         $nameOnly,
        [GistProvider] $provider
    ) {
        foreach ($file in [GistCache]::GetCacheItem($path).Files) {
            $childPath = Join-Path -Path $path -ChildPath $file.Name

            if ($nameOnly) {
                $file = $file.Name
            }

            $provider.WriteItemObject(
                $file,
                $childPath,
                $false
            )
        }
    }

    hidden static [bool] ItemExists(
        [string]       $accountName,
        [string]       $path,
        [GistProvider] $provider
    ) {
        return [GistCache]::CacheItemExists($path)
    }
}
