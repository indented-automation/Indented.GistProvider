class GistCache {
    static [Hashtable] $itemCache = @{}
    static [Hashtable] $itemNameToID = @{}

    static [void] AddOrUpdateCacheItem(
        [GistItem] $itemInfo,
        [string]   $accountName
    ) {
        if ([GistCache]::itemCache.Contains($itemInfo.ID)) {
            [GistCache]::itemCache[$itemInfo.ID] = $itemInfo
        }
        else {
            [GistCache]::itemCache.Add(
                $itemInfo.ID,
                $itemInfo
            )
        }
        if ([GistCache]::itemNameToID[$accountName].Contains($itemInfo.Name)) {
            [GistCache]::itemNameToID[$accountName][$itemInfo.Name].Add($itemInfo.ID)
        }
        else {
            [GistCache]::itemNameToID[$accountName].Add(
                $itemInfo.Name,
                [System.Collections.Generic.List[string]]$itemInfo.ID
            )
        }
    }

    static [GistItem[]] GetCacheItem(
        [string] $pathOrId
    ) {
        if ([GistCache]::itemCache.Contains($pathOrID)) {
            return [GistCache]::itemCache[$pathOrID]
        }
        else {
            if ($id = [GistCache]::GetIDFromPath($pathOrID)) {
                $items = foreach ($value in $id) {
                    [GistCache]::itemCache[$value]
                }
                return $items
            }
        }
        return $null
    }

    static [GistItem[]] GetAccountCacheItem(
        [string] $accountName
    ) {
        $items = foreach ($value in [GistCache]::itemNameToID[$accountName].Values) {
            foreach ($id in $value) {
                [GistCache]::GetCacheItem($id)
            }
        }

        return $items
    }

    static [GistFile[]] GetCacheFile(
        [string] $path
    ) {
        $fileName = Split-Path -Path $path -Leaf
        $files = [GistCache]::GetCacheItem($path).Files |
            Where-Object Name -eq $fileName

        return $files
    }

    static [bool] CacheItemExists(
        [string] $pathOrId
    ) {
        if ([GistCache]::itemCache.Contains($pathOrID)) {
            return $true
        }

        $id = [GistCache]::GetIDFromPath($pathOrId)
        return (-not [String]::IsNullOrWhiteSpace($id))
    }

    static [bool] CacheFileExists(
        [string] $path
    ) {
        if ([GistCache]::GetCacheFile($path)) {
            return $true
        }

        return $false
    }

    static [bool] AccountHasCache(
        [string] $accountName
    ) {
        return [GistCache]::itemNameToID.Contains($accountName)
    }

    hidden static [string] GetIDFromPath(
        [string] $path
    ) {
        $accountName, $gistName, $null = $path -split '[\\/]'
        return [GistCache]::itemNameToID[$accountName][$gistName]
    }

    hidden static [void] UpdateCache(
        [string] $accountName
    ) {
        [GistCache]::UpdateCache($accountName, '')
    }

    hidden static [void] UpdateCache(
        [string] $accountName,
        [string] $id
    ) {
        if ($id) {
            $params = @{
                RestMethod = 'gists/{1}' -f $accountName, $id
            }
            $response = InvokeGistRestMethod @params

            [GistCache]::itemCache[$id].Files = $response.files
        }
        else {
            [GistCache]::itemNameToID[$accountName] = [Ordered]@{}

            $params = @{
                RestMethod = 'users/{0}/gists' -f $accountName
            }
            foreach ($containerInfo in InvokeGistRestMethod @params) {
                $item = [GistItem]::new(
                    $containerInfo.files.PSObject.Properties.ForEach{ $_ }[0].Name,
                    $accountName,
                    $containerInfo
                )
                [GistCache]::AddOrUpdateCacheItem($item, $accountName)
            }
        }
    }

    hidden static [void] ClearCache() {
        [GistCache]::itemCache.Clear()
        [GistCache]::itemNameToID.Clear()
    }
}
