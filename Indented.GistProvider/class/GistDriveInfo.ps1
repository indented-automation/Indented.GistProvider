using namespace System.Management.Automation.Provider

class GistDriveInfo : PSDriveInfo {
    hidden [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    GistDriveInfo([PSDriveInfo] $driveInfo) : base($driveInfo) { }

    hidden static [Void] GetChildItemsOrNames(
        [String]        $path,
        [bool]          $recurse,
        [bool]          $nameOnly,
        [GistProvider]  $provider,
        [GistDriveInfo] $psDriveInfo
    ) {
        foreach ($accountName in $psDriveInfo.Accounts) {
            if ($nameOnly) {
                $item = $accountName
            }
            else {
                $item = [GistAccount]::new($accountName)
            }
            $provider.WriteItemObject(
                $item,
                $accountName,
                $true
            )

            if ($recurse) {
                [GistAccount]::GetChildItemsOrNames(
                    $accountName,
                    $recurse,
                    $nameOnly,
                    $provider
                )
            }
        }
    }
}
