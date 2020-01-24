class GistAccount : GistBase {
    GistAccount([string] $name) : base($name) { }

    hidden static [void] GetItem(
        [String]       $path,
        [GistProvider] $provider
    ) {
        $accountName = Split-Path -Path $path -Leaf

        $provider.WriteItemObject(
            [GistAccount]::new($accountName),
            $path,
            $true
        )
    }

    hidden static [Void] GetChildItemsOrNames(
        [String]       $path,
        [bool]         $recurse,
        [bool]         $nameOnly,
        [GistProvider] $provider
    ) {
        $accountName = $provider.GetAccountName($path)

        foreach ($item in [GistCache]::GetAccountCacheItem($accountName)) {
            $childPath = Join-Path -Path $path -ChildPath $item.Name

            if ($nameOnly) {
                $item = $item.Name
            }

            $provider.WriteItemObject(
                $item,
                $childPath,
                $true
            )

            if ($recurse) {
                [GistItem]::GetChildItemsOrNames(
                    $childPath,
                    $recurse,
                    $nameOnly,
                    $provider
                )
            }
        }
    }
}
