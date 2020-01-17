function Connect-Gist {
    <#
    .SYNOPSIS
        Provides authentication options for GitHub accounts.

    .DESCRIPTION
        Provides either OAUTH or Basic authentication options for GitHub accounts.

        To use OAUTH see Get-Help about_GistProviderOAuth
    #>

    [CmdletBinding(DefaultParameterSetName = 'OAuth')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'OAuth')]
        [string]
        $Username,

        [Parameter(Mandatory, ParameterSetName = 'Basic')]
        [PSCredential]
        $Credential
    )

    if ($pscmdlet.ParameterSetName -eq 'OAuth') {
        try {
            $Script:Auth = [PSCustomObject]@{
                AuthType   = 'OAuth'
                OAuthToken = GetGistOAuthSecret | GetGistOAuthToken
            }
        }
        catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    else {
        $Script:Auth = [PSCustomObject]@{
            AuthType   = 'Basic'
            Credential = $Credential
        }
    }
}
