function Unregister-GistOAuthSecret {
    [CmdletBinding()]
    param ( )

    $path = Join-Path -Path $myinvocation.MyCommand.Module.ModuleBase -ChildPath '.oauth.csv'
    if (Test-Path $path) {
        Remove-Item -Path $path
    }
}
