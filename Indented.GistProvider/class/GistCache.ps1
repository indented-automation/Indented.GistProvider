class GistCache {
    static [Hashtable] $itemCache = @{}
    static [System.Collections.Specialized.OrderedDictionary] $itemNameToID = [Ordered]@{}

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
            if ($id = [GistCache]::GetIdFromPath($pathOrID)) {
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

    static [bool] CacheItemExists(
        [string] $pathOrId
    ) {
        if ([GistCache]::itemCache.Contains($pathOrID)) {
            return $true
        }

        $id = [GistCache]::GetIdFromPath($pathOrId)
        return (-not [String]::IsNullOrWhiteSpace($id))
    }

    static [bool] AccountHasCache(
        [string] $accountName
    ) {
        return [GistCache]::itemNameToID.Contains($accountName)
    }

    hidden static [string] GetIdFromPath(
        [string] $path
    ) {
        $accountName, $null = $path -split '[\\/]'
        $leafName = Split-Path -Path $path -Leaf

        return [GistCache]::itemNameToID[$accountName][$leafName]
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
            [GistCache]::itemNameToID[$accountName] = @{}

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
}
