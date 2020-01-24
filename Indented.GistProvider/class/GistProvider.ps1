using namespace System.Management.Automation
using namespace System.Management.Automation.Provider

[CmdletProvider('Gist', [System.Management.Automation.Provider.ProviderCapabilities]::None)]
class GistProvider : NavigationCmdletProvider, IContentCmdletProvider {
    hidden static [System.Collections.Generic.HashSet[String]] $Accounts = [System.Collections.Generic.HashSet[String]]::new()

    #region:Drive
    [PSDriveInfo] NewDrive(
        [PSDriveInfo] $drive
    ) {
        if (-not $drive) {
            return $null
        }

        return [GistDriveInfo]::new($drive)
    }

    [PSDriveInfo] RemoveDrive(
        [PSDriveInfo] $drive
    ) {
        if (-not $drive) {
            $errorRecord = [ErrorRecord]::new(
                [ArgumentNullException]::new('Drive does not exist'),
                'NullDrive',
                'InvalidArgument',
                $null
            )
            Write-Error -ErrorRecord $errorRecord
            return $null

        }

        [GistCache]::ClearCache()

        return $drive
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
                [GistAccount]::GetItem(
                    $path,
                    $this
                )
            }
            'Item' {
                [GistItem]::GetItem(
                    $path,
                    $this
                )
            }
            'File' {
                [GistFile]::GetItem(
                    $path,
                    $this
                )
            }
            'Invalid' {
                throw 'Invalid path specification'
            }
        }
    }

    [bool] ItemExists(
        [string] $path
    ) {
        $accountName = $this.GetAccountName($path)

        $itemExists = switch ($this.GetPathType($path)) {
            { $_ -ne 'File' } { $path = $path -replace '[\\/]$' }
            'Drive'           { $true; break }
            'Account'         {
                $this.PSDriveInfo.Accounts.Contains($path)
                break
            }
            'Item'            {
                [GistItem]::ItemExists(
                    $accountName,
                    $path,
                    $this
                )
                break
            }
            'File'            {
                [GistFile]::ItemExists(
                    $accountName,
                    $path,
                    $this
                )
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
        $this.GetChildItemsOrNames(
            $path,
            $false,
            [ReturnContainers]::ReturnAllContainers,
            $false
        )
    }

    [void] GetChildNames(
        [string]           $path,
        [ReturnContainers] $returnContainers
    ) {
        $this.GetChildItemsOrNames(
            $path,
            $false,
            $returnContainers,
            $true
        )
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
                Write-Host $path
                # Get-Content $path | Set-Content -Destination $destination
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

    [string] GetChildName(
        [string] $path
    ) {
        if ($this.GetPathType($path) -eq 'Drive') {
            return $path
        }
        return Split-Path $path -Leaf
    }

    [string] GetParentPath(
        [string] $path,
        [string] $root
    ) {
        if ($path -eq '') {
            return ''
        }
        else {
            return Split-Path $path -Parent
        }
    }

    [string] NormalizeRelativePath(
        [string] $path,
        [string] $basePath
    ) {
        if ([String]::IsNullOrEmpty($basePath)) {
            return $path
        }
        return Join-Path -Path $basePath -ChildPath $path
    }
    #endregion

    #region:Content
    [IContentReader] GetContentReader(
        [string] $path
    ) {
        if ($this.GetPathType($path) -eq 'File') {
            return [GistContentReader]::new($path)
        }
        return $null
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

        $tokens = $path -replace '[\\/]$' -split '[\\/]'
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

    [void] GetChildItemsOrNames(
        [string]           $path,
        [bool]             $recurse,
        [ReturnContainers] $returnContainers,
        [bool]             $nameOnly
    ) {
        if ($this.PSDriveInfo.Accounts.Count -eq 0) {
            throw 'Must be connected to one or more accounts!'
        }

        switch ($this.GetPathType($path)) {
            'Drive' {
                [GistDriveInfo]::GetChildItemsOrNames(
                    $path,
                    $recurse,
                    $nameOnly,
                    $this,
                    $this.PSDriveInfo
                )
            }
            'Account' {
                [GistAccount]::GetChildItemsOrNames(
                    $path,
                    $recurse,
                    $nameOnly,
                    $this
                )
            }
            'Item' {
                [GistItem]::GetChildItemsOrNames(
                    $path,
                    $recurse,
                    $nameOnly,
                    $this
                )
            }
        }
    }
    #endregion
}
