using namespace System.Management.Automation.Provider

class GistDriveInfo : PSDriveInfo {
    hidden [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    GistDriveInfo([PSDriveInfo] $driveInfo) : base($driveInfo) { }

    hidden static [Void] GetChildItem(
        [String]        $path,
        [GistProvider]  $provider,
        [GistDriveInfo] $psDriveInfo
    ) {
        foreach ($accountName in $psDriveInfo.Accounts) {
            $provider.WriteItemObject(
                [GistAccount]::new($accountName),
                $accountName,
                $true
            )
        }
    }
}
