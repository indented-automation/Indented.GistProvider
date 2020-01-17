$class = @(
    '1.GistFile'
    '2.GistItem'
    '3.GistAccount'
    '4.GistRoot'
)

foreach ($file in $class) {
    . ("{0}\class\{1}.ps1" -f $psscriptroot, $file)
}

$private = @(
    'GetFunctionInfo'
    'GetGistAuthInfo'
    'GetGistOAuthSecret'
    'GetGistOAuthToken'
    'InvokeGistRestMethod'
)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Add-GistAccount'
    'Connect-Gist'
    'Get-GistAccount'
    'Import-GistFunction'
    'Register-GistOAuthSecret'
    'Remove-GistAccount'
    'Unregister-GistOAuthSecret'
)

foreach ($file in $public) {
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Add-GistAccount'
    'Connect-Gist'
    'Get-GistAccount'
    'Import-GistFunction'
    'Register-GistOAuthSecret'
    'Remove-GistAccount'
    'Unregister-GistOAuthSecret'
)
Export-ModuleMember -Function $functionsToExport


