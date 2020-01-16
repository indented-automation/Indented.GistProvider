function InvokeGitHubRestMethod {
    [CmdletBinding(DefaultParameterSetName = 'RestMethod')]
    param (
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'RestMethod')]
        [string]
        $RestMethod,

        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [Uri]
        $Uri,

        [Parameter(ParameterSetName = 'RestMethod')]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = 'GET'
    )


    $params = @{
        Method          = $Method
        UseBasicParsing = $true
    }
    if ($pscmdlet.ParameterSetName -eq 'RestMethod') {
        $params['Uri'] = 'https://api.github.com/{0}' -f $RestMethod
    }
    else {
        $params['Uri'] = $Uri
    }

    if ($Body) {
        if ($Body -isnot [String] -and -not $Body.GetType().IsPrimitive) {
            $params['Body'] = $Body | ConvertTo-Json
        }
        $params['ContentType'] = 'application/json'
    }

    $existingProgressPreference = $Global:progresspreference
    $Global:progresspreference = 'SilentlyContinue'
    do {
        $response = Invoke-WebRequest @params
        if ($pscmdlet.ParameterSetName -eq 'RestMethod') {
            foreach ($entry in $response.Content | ConvertFrom-Json) {
                $entry
            }
        }
        else {
            $response.Content
        }

        if ($response.Headers['link'] -match '<([^>]+?)>;\s*rel="next"') {
            $next = $matches[1]
        }
        else {
            $next = $null
        }

        $params = @{
            Uri = $next
        }
    } while ($next)
    $Global:progresspreference = $existingProgressPreference
}
