using namespace System.Management.Automation
using namespace System.Management.Automation.Provider
using namespace System.Management.Automation.Runspaces
using namespace System.Reflection

function Import-GistProvider {
    [CmdletBinding()]
    param ( )

    $sessionStateProviderEntry = [SessionStateProviderEntry]::new(
        'Gist',
        [GistProvider],
        $null
    )

    $type = [PowerShell].Assembly.GetType('System.Management.Automation.Runspaces.LocalPipeline')
    $method = $type.GetMethod(
        'GetExecutionContextFromTLS',
        [BindingFlags]'Static,NonPublic'
    )
    $context = $method.Invoke(
        $null,
        [BindingFlags]'Static,NonPublic',
        $null,
        $null,
        (Get-Culture)
    )

    $type = [PowerShell].Assembly.GetType('System.Management.Automation.SessionStateInternal')
    $constructor = $type.GetConstructor(
        [BindingFlags]'Instance,NonPublic',
        $null,
        $context.GetType(),
        $null
    )
    $sessionStateInternal = $constructor.Invoke($context)

    $method = $type.GetMethod(
        'AddSessionStateEntry',
        [BindingFlags]'Instance,NonPublic',
        $null,
        $sessionStateProviderEntry.GetType(),
        $null
    )
    $method.Invoke(
        $sessionStateInternal,
        $sessionStateProviderEntry
    )
}
