using namespace Microsoft.PowerShell.SHiPS

class GistFile : GistBase {
    [string] $GistName
    [string] $Type
    [string] $Language
    [UInt64] $Size
    [string] $GistID

    hidden [string] $accountName
    hidden [string] $rawUrl

    GistFile(
        [string] $name,
        [string] $accountName,
        [object] $fileInfo,
        [string] $GistID
    ) : base($name) {
        $this.GistName = $fileInfo.filename
        $this.Type = $fileInfo.type
        $this.Language = $fileInfo.language
        $this.Size = $fileInfo.size
        $this.GistID = $GistID

        $this.accountName = $accountName
        $this.rawUrl = $fileInfo.raw_url
    }

    hidden static [void] GetItem(
        [string]       $path,
        [GistProvider] $provider
    ) {
        # if ($provider.Force) {
        #     [GistCache]::UpdateCache($provider.GetAccountName($path))
        # }

        foreach ($file in [GistCache]::GetCacheFile($path)) {
            $provider.WriteItemObject(
                $file,
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
        return [GistCache]::CacheFileExists($path)
    }

    [string] GetContent() {
        return InvokeGistRestMethod -Uri $this.rawUrl
    }

    [object] SetContent([string]$value, [string]$path) {
        # Invoke rest method here.

        return $this
    }
}
