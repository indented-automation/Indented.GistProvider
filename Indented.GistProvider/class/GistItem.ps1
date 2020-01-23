class GistItem : GistBase {
    [string]   $Id
    [bool]     $IsPublic
    [DateTime] $Created
    [DateTime] $Updated
    [string]   $Description

    hidden [string] $gistAccountName
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

        $this.gistAccountName = $accountName
        $this.files = $containerInfo.files
    }

    hidden static [void] GetItem(
        [string]       $path,
        [GistProvider] $provider
    ) {
        $accountName = $provider.GetAccountName($path)

        if ($provider.Force) {
            [GistCache]::UpdateCache($accountName)
        }

        foreach ($item in [GistCache]::GetCacheItem($path)) {
            $provider.WriteItemObject(
                $item,
                $path,
                $true
            )
        }
    }

    hidden static [Void] GetChildItem(
        [String]       $path,
        [GistProvider] $provider
    ) {
        $accountName = $provider.GetAccountName($path)

        $itemId = [GistCache]::GetIdFromPath($path)
        if ($provider.force) {
            [GistCache]::UpdateCache($accountName, $itemId)
        }

        $itemFiles = [GistCache]::GetCacheItem($itemId).Files
        foreach ($file in $itemFiles.PSObject.Properties.Name) {
            $provider.WriteItemObject(
                [GistFile]::new(
                    $file,
                    $accountName,
                    $itemFiles.files.$file
                ),
                $path,
                $false
            )
        }
    }

    hidden static [bool] ItemExists(
        [string]       $accountName,
        [string]       $path,
        [GistProvider] $provider
    ) {
        if ($provider.Force -or -not [GistCache]::AccountHasCache($accountName)) {
            [GistCache]::UpdateCache($accountName)
        }

        return [GistCache]::CacheItemExists($path)
    }
}
