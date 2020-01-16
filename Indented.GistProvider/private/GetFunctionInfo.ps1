function GetFunctionInfo {
    <#
    .SYNOPSIS
        Get an instance of FunctionInfo.
    .DESCRIPTION
        FunctionInfo does not present a public constructor. This function calls an internal / private constructor on FunctionInfo to create a description of a function from a script block or file containing one or more functions.
    .EXAMPLE
        Get-ChildItem -Filter *.psm1 | Get-FunctionInfo

        Get all functions declared within the *.psm1 file and construct FunctionInfo.
    .EXAMPLE
        Get-ChildItem C:\Scripts -Filter *.ps1 -Recurse | Get-FunctionInfo

        Get all functions declared in all ps1 files in C:\Scripts.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    [OutputType([System.Management.Automation.FunctionInfo])]
    param (
        # The path to a file containing one or more functions.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPath')]
        [Alias('FullName')]
        [String]
        $Path,

        # A script block containing one or more functions.
        [Parameter(ParameterSetName = 'FromScriptBlock')]
        [ScriptBlock]
        $ScriptBlock,

        # A string containing one or more functions.
        [Parameter(ParameterSetName = 'FromString')]
        [String]
        $String,

        # By default functions nested inside other functions are ignored. Setting this parameter will allow nested functions to be discovered.
        [Switch]
        $IncludeNested
    )

    begin {
        $executionContextType = [PowerShell].Assembly.GetType('System.Management.Automation.ExecutionContext')
        $constructor = [System.Management.Automation.FunctionInfo].GetConstructor(
            [System.Reflection.BindingFlags]'NonPublic, Instance',
            $null,
            [System.Reflection.CallingConventions]'Standard, HasThis',
            ([String], [ScriptBlock], $executionContextType),
            $null
        )
    }

    process {
        switch ($pscmdlet.ParameterSetName) {
            'FromPath' {
                $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                    $Path,
                    [ref]$null,
                    [ref]$null
                )
                break
            }
            'FromScriptBlock' {
                $ast = $ScriptBlock.Ast
                break
            }
            'FromString' {
                $ast = [System.Management.Automation.Language.Parser]::ParseInput(
                    $String,
                    [ref]$null,
                    [ref]$null
                )
                break
            }
        }

        $nodes = $ast.FindAll( {
                param( $ast )

                $ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
            },
            $IncludeNested
        )
        foreach ($node in $nodes) {
            try {
                $internalScriptBlock = $node.Body.GetScriptBlock()
            } catch {
                Write-Debug $_.Exception.Message
            }
            if ($internalScriptBlock) {
                $constructor.Invoke(([String]$node.Name, $internalScriptBlock, $null))
            }
        }
    }
}
