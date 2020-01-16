$class = @(
    '1.GistFile'
    '2.GistContainer'
    '3.GistAccount'
    '4.GistRoot'
)

foreach ($file in $class) {
    . ("{0}\class\{1}.ps1" -f $psscriptroot, $file)
}

$private = @(
    'GetFunctionInfo'
    'InvokeGitHubRestMethod'
)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Add-GistAccount'
    'Connect-GitHub'
    'Get-GistAccount'
    'Import-GistFunction'
    'Remove-GistAccount'
)

foreach ($file in $public) {
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Add-GistAccount'
    'Connect-GitHub'
    'Get-GistAccount'
    'Import-GistFunction'
    'Remove-GistAccount'
)
Export-ModuleMember -Function $functionsToExport


