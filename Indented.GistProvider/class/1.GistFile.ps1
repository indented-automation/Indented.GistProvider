using namespace Microsoft.PowerShell.SHiPS

class GistFile : SHiPSLeaf {
    [string] $GistName
    [string] $Type
    [string] $Language

    hidden [string] $rawUrl

    GistFile([string]$name): base($name) { }

    GistFile([string]$name, [object] $fileInfo): base($name) {
        $this.GistName = $fileInfo.filename
        $this.Type = $fileInfo.type
        $this.Language = $fileInfo.Language
        $this.rawUrl = $fileInfo.raw_url
    }

    [string] GetContent() {
        return InvokeGitHubRestMethod -Uri $this.rawUrl
    }
}
