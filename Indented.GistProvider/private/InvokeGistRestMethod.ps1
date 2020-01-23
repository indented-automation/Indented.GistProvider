function InvokeGistRestMethod {
    [CmdletBinding(DefaultParameterSetName = 'RestMethod')]
    param (
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'RestMethod')]
        [string]
        $RestMethod,

        [Parameter(Mandatory, ParameterSetName = 'Uri')]
        [Uri]
        $Uri,

        [Microsoft.PowerShell.Commands.WebRequestMethod]
        $Method = 'GET',

        [Object]
        $Body,

        [PSTypeName('GistConnection')]
        $Connection
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

    if ($params['Uri'] -ne 'https://github.com/login/oauth/access_token') {
        $authInfo = GetGistAuthInfo

        if ($authInfo.AuthType -eq 'OAuth') {
            $params['Header'] = @{
                Authorization = 'token {0}' -f $authInfo.OAuthToken
            }
        } elseif ($authInfo.AuthType -eq 'Basic') {
            $params['Credential'] = $authInfo.Credential

            if ($psversiontable.PSVersion.Major -ge 6) {
                $params['Authentication'] = 'Basic'
            }
        }
    }

    if ($Body) {
        $params['Body'] = $Body | ConvertTo-Json
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

        $params['Uri'] = $next
    } while ($next)
    $Global:progresspreference = $existingProgressPreference
}
