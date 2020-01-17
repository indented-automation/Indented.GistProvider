function Register-GistOAuthSecret {
    <#
    .SYNOPSIS
        Registers OAuth secrets for use with the gist provider.

    .DESCRIPTION
        OAuth applications are registered to accounts in GitHub under Developer Settings.

        The secrets used by this provider are stored in this modules directory in clear text. OAuth should
        only be used if the risk is acceptible.

        When configuring the application, the Authorization Callback URL must be set to http://localhost. A
        port number may be used, for example http://localhost:40000. The callback URL is stored when the secrets
        are registered. An HTTP listener is created to accept the authorization token from the callback URL.

    #>

    [CmdletBinding()]
    param (
        # The ClientID for this GitHub application.
        [Parameter(Mandatory)]
        [string]
        $ClientID,

        # The ClientSecret for this GitHub application.
        [Parameter(Mandatory)]
        [string]
        $ClientSecret,

        # The Callback URL which should be used for this GitHub application.
        [Parameter(Mandatory)]
        [Uri]
        $CallbackUrl
    )

    [PSCustomObject]@{
        ClientID     = $ClientID
        ClientSecret = $ClientSecret
        CallbackUrl  = $CallbackUrl
    } | Export-Csv (Join-Path -Path $myinvocation.MyCommand.Module.ModuleBase -ChildPath '.oauth.csv') -NoTypeInformation
}
