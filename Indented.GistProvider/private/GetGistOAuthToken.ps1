function GetGistOAuthToken {
    <#
    .SYNOPSIS
        Requests an OAUTH token.

    .DESCRIPTION
        Requests an OAUTH token from GitHub using the default browser.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Indented.Gist.OAuthSecret')]
        $Secret
    )

    process {
        $httpListener = [System.Net.HttpListener]::new()
        if (-not $Secret.CallbackUrl.EndsWith('/')) {
            $Secret.CallbackUrl = '{0}/' -f $Secret.CallbackUrl
        }
        $httpListener.Prefixes.Add($Secret.CallbackUrl)
        $httpListener.Start()

        $authorizeUrl = 'https://github.com/login/oauth/authorize?client_id={0}&scope={1}' -f @(
            $Secret.ClientID
            'gist'
        )
        Start-Process -FilePath $authorizeUrl

        $context = $httpListener.GetContext()
        $buffer = [Byte[]][Char[]]"<html><body>OAuth complete! Please return to PowerShell!</body></html>"

        $context.Response.OutputStream.Write(
            $buffer,
            0,
            $buffer.Count
        )

        $context.Response.OutputStream.Close()
        $httpListener.Stop()

        $params = @{
            Uri    = 'https://github.com/login/oauth/access_token'
            Method = 'POST'
            Body   = @{
                client_id     = $Secret.ClientId
                client_secret = $Secret.ClientSecret
                code          = $context.Request.QueryString['code']
            }
        }
        $response = InvokeGistRestMethod @params
        if ($response -as [Byte[]]) {
            $response = [String]::new([Char[]][Byte[]]$response)
        }

        foreach ($entry in $response -split '&') {
            $key, $value = $entry -split '='

            if ($key -eq 'access_token') {
                return $value
            }
        }
    }
}
