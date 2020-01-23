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

    hidden static [Void] GetChildItem(
        [String]       $path,
        [GistProvider] $provider
    ) {
        $accountName = $provider.GetAccountName($path)

        foreach ($item in [GistCache]::GetAccountCacheItem($accountName)) {
            $provider.WriteItemObject(
                $item,
                (Join-Path -Path $path -ChildPath $item.Name),
                $true
            )
        }
    }
}
