using namespace System.Collections
using namespace System.IO
using namespace System.Management.Automation.Provider

class GistContentReader : IContentReader {
    [string[]] $content
    [bool]     $hasMoreContent = $true

    GistContentReader(
        [string] $path
    ) {
        $file = [GistCache]::GetCacheFile($path)
        $this.content = InvokeGistRestMethod -Uri $file.rawUrl
    }

    # Read will execute until IList is empty
    [IList] Read(
        [long] $readCount
    ) {
        if ($this.hasMoreContent) {
            $this.hasMoreContent = $false

            return $this.content
        }
        return $null
    }

    [void] Seek(
        [long]       $offset,
        [SeekOrigin] $seekOrigin
    ) {
        [InvalidOperationException]::new('Seek is not supported')
    }

    [void] Close() { }

    [void] Dispose() { }
}
