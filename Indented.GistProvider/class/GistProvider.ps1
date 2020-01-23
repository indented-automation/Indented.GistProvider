using namespace System.Management.Automation.Provider

[CmdletProvider('Gist', [System.Management.Automation.Provider.ProviderCapabilities]::None)]
class GistProvider : NavigationCmdletProvider, IContentCmdletProvider {
    hidden static [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    #region:Drive
    [PSDriveInfo] NewDrive(
        [PSDriveInfo] $drive
    ) {
        return [GistDriveInfo]::new($drive)
    }
    #endregion

    #region:Items
    [void] GetItem(
        [string] $path
    ) {
        switch ($this.GetPathType($path)) {
            'Drive' {
                $this.WriteItemObject(
                    $this.PSDriveInfo,
                    [System.IO.Path]::DirectorySeparatorChar,
                    $true
                )
            }
            'Account' {
                $this.WriteItemObject(
                    [GistAccount]::new($path),
                    $path,
                    $true
                )
            }
            'Item' {
                [GistItem]::GetItem(
                    $path,
                    $this
                )
            }
            'File' {
                $this.WriteItemObject("IsAFile - $path", $path, $false)
            }
            'Invalid' {
                $this.WriteItemObject("IsInvalid - $path", $path, $false)
            }
        }
    }

    [bool] ItemExists(
        [string] $path
    ) {
        $accountName = $this.GetAccountName($path)

        $itemExists = switch ($this.GetPathType($path)) {
            'Drive'   { $true; break }
            'Account' { $this.PSDriveInfo.Accounts.Contains($path); break }
            'Item'    {
                [GistItem]::ItemExists(
                    $accountName,
                    $path,
                    $this
                )
                break
            }
            default   { $false }
        }
        return $itemExists
    }

    [bool] IsValidPath(
        [string] $Path
    ) {
        if (-not $Path) {
            return $false
        }
        if ($this.GetPathType($path) -eq 'Invalid') {
            return $false
        }
        return $true
    }
    #endregion

    #region:Container
    [void] GetChildItems(
        [string] $path
    ) {
        $this.GetChildItems($path, $false)
    }

    [void] GetChildItems(
        [string] $path,
        [bool]   $recurse
    ) {
        if ($this.PSDriveInfo.Accounts.Count -eq 0) {
            throw 'Must be connected to one or more accounts!'
        }

        switch ($this.GetPathType($path)) {
            'Drive' {
                foreach ($accountName in $this.PSDriveInfo.Accounts) {
                    [GistAccount]::new($accountName)
                }
            }
            'Account' {
                [GistAccount]::GetChildItem(
                    $path,
                    $this
                )
            }
            'Item' {
                [GistItem]::GetChildItem(
                    $path,
                    $this
                )
            }
        }
    }

    [void] GetChildNames(
        [string]           $path,
        [ReturnContainers] $returnContainers
    ) {
        switch ($this.GetPathType($path)) {
            'Drive' {
                foreach ($accountName in $this.PSDriveInfo.Accounts) {
                    [GistAccount]::new($accountName)
                }
            }
            'Account' {
                [GistAccount]::GetChildItem(
                    $path,
                    $false,
                    $this
                ).Name
            }
            'Item' {
                [GistItem]::GetChildItem(
                    $path,
                    $false,
                    $this
                ).Name
            }
        }
    }

    [bool] HasChildItems(
        [string] $path
    ) {
        if ($this.GetPathType($path) -eq 'File') {
            return $false
        }
        return $true
    }

    [void] CopyItem(
        [string] $path,
        [string] $destination,
        [bool]   $recurse
    ) {
        switch ($this.GetPathType($path)) {
            'File' {
                Get-Content $path | Set-Content -Destination $destination
            }
        }
    }
    #endregion

    #region:Navigation
    [bool] IsItemContainer(
        [string] $path
    ) {
        if ($this.GetPathType($path) -eq 'File') {
            return $false
        }
        return $true
    }

    # [string] GetChildName(
    #     [string] $path
    # ) {

    #     if ($this.GetPathType($path) -eq 'Drive') {
    #         return $path
    #     }
    #     return Split-Path $path -Leaf
    # }

    # [string] GetParentPath(
    #     [string] $path,
    #     [string] $root
    # ) {
    #     if ($path -eq '') {
    #         return ''
    #     }
    #     else {
    #         return Split-Path $path -Parent
    #     }
    # }
    #endregion

    #region:Content
    [IContentReader] GetContentReader(
        [string] $path
    ) {
        return [System.IO.StringReader]::new('Testing')
    }

    [object] GetContentReaderDynamicParameters(
        [string] $path
    ) {
        return $null
    }

    [IContentWriter] GetContentWriter(
        [string] $path
    ) {
        return [System.IO.StringReader]::new('Testing')
    }

    [object] GetContentWriterDynamicParameters(
        [string] $path
    ) {
        return $null
    }

    [void] ClearContent(
        [string] $path
    ) {
        throw 'Not supported'
    }

    [object] ClearContentDynamicParameters(
        [string] $path
    ) {
        return $null
    }
    #endregion

    #region:Helper
    hidden [GistPathType] GetPathType(
        [string] $path
    ) {
        if ([String]::IsNullOrWhiteSpace($path)) {
            return [GistPathType]::Drive
        }

        $tokens = $path -split '[\\/]'
        if ($gistPathType = @($tokens).Count -as [GistPathType]) {
            return $gistPathType
        }

        return [GistPathType]::Invalid
    }

    hidden [string] GetAccountName(
        [string] $path
    ) {
        if ($this.GetPathType($path) -notin 'Drive', 'Invalid') {
            $accountName, $null = $path -split '[\\/]'

            return $accountName
        }
        return ''
    }
    #endregion
}
