function Import-Gist {
    <#
    .SYNOPSIS
        Import content from gists into PowerShell.

    .DESCRIPTION
        Import-Gist attempts to import content into the current PowerShell session.

        By default, Import-Gist searches for and imports functions within a gist. Import-Gist can also
        import a dynamic module based on a gist.

    .EXAMPLE
        Get-Item gist:\username\gistname.ps1\gistfile.ps1 | Import-Gist

        Import all functions from gistfile.ps1 into the current session.

    .EXAMPLE
        Get-Item gist:\username\gistname.ps1 | Import-Gist -AsModule

        Import all gist files from gistname.ps1 as a dynamic PowerShell module.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [GistFile]$Gist,

        [Switch]$AsModule,

        [Switch]$AllowClobber
    )

    process {
        try {
            $Script = $Gist | Get-Content

            if (-not $AsModule -and $Script -match '^using namespace') {
                Write-Warning ('The script {0} contains "using namespace" declarations and may not execute.' -f $Gist.PSPath)
            }

            if ($AsModule) {
                $params = @{
                    Name        = [System.IO.Path]::GetFileNameWithoutExtension($Gist.PSChildName)
                    ScriptBlock = [ScriptBlock]::Create($Script)
                }
                New-Module @params | Import-Module -Global
            }
            else {
                foreach ($functionInfo in GetFunctionInfo -String $Script) {
                    if (-not $AllowClobber -and (Get-Command $functionInfo.Name -ErrorAction SilentlyContinue)) {
                        Write-Warning ('The command {0} already exists' -f $functionInfo.Name)
                    }
                    else {
                        Write-Verbose ('Creating function {0}' -f $functionInfo.Name)

                        $params = @{
                            Path  = 'function:global:{0}' -f $functionInfo.Name
                            Value = $functionInfo.ScriptBlock
                        }
                        Set-Item @params
                    }
                }
            }
        }
        catch {
            Write-Error -ErrorRecord $_
        }
    }
}
