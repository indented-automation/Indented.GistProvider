class GistAccount : GistBase {
    GistAccount([string] $name) : base($name) { }

    hidden static [Void] GetChildItem(
        [String]       $path,
        [GistProvider] $provider
    ) {
        $accountName = $provider.GetAccountName($path)

        if ($provider.Force -or -not [GistCache]::AccountHasCache($accountName)) {
            [GistCache]::UpdateCache($accountName)
        }

        foreach ($item in [GistCache]::GetAccountCacheItem($accountName)) {
            $provider.WriteItemObject(
                $item,
                (Join-Path -Path $path -ChildPath $item.Name),
                $true
            )
        }
    }
}
