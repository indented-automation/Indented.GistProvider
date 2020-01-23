using namespace Microsoft.PowerShell.SHiPS

class GistFile : GistBase {
    [string] $GistName
    [string] $Type
    [string] $Language

    hidden [string] $accountName
    hidden [string] $rawUrl

    GistFile([string] $name) : base($name) { }

    GistFile(
        [string] $name,
        [string] $accountName,
        [object] $fileInfo
    ) : base($name) {
        $this.GistName = $fileInfo.filename
        $this.Type = $fileInfo.type
        $this.Language = $fileInfo.Language

        $this.accountName = $accountName
        $this.rawUrl = $fileInfo.raw_url
    }

    [string] GetContent() {
        return InvokeGistRestMethod -Uri $this.rawUrl
    }

    [object] SetContent([string]$value, [string]$path) {
        # Invoke rest method here.

        return $this
    }
}
