function Import-GistFunction {
    <#
    .SYNOPSIS
        Import a function from a Gist.

    .DESCRIPTION
        Import a function from a Gist into global scope.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [GistFile]$Gist,

        [Switch]$AllowClobber
    )

    process {
        try {
            $Script = $Gist | Get-Content

            if ($Script -match '^using namespace') {
                Write-Warning ('The script {0} contains "using namespace" declarations and may not execute.' -f $Gist.PSPath)
            }

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
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}
