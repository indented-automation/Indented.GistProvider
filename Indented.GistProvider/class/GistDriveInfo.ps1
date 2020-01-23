using namespace System.Management.Automation.Provider

class GistDriveInfo : PSDriveInfo {
    hidden [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    GistDriveInfo([PSDriveInfo] $driveInfo) : base($driveInfo) { }
}
