function GetGistOAuthSecret {
    [CmdletBinding()]
    param ( )

    $path = Join-Path -Path $myinvocation.MyCommand.Module.ModuleBase -ChildPath '.oauth.csv'
    if (Test-Path -Path $path) {
        Import-Csv -Path $path | Add-Member -TypeName Indented.Gist.OAuthSecret -PassThru
    }
    else {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [InvalidOperationException]::new('This module is not registered as an OAuth application. See about_GistProviderOAuth'),
            ('{0}/OAuthSecretMissing' -f $myinvocation.MyCommand.ModuleName),
            'InvalidOperation',
            $null
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
    }
}
