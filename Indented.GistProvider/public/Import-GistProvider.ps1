using namespace System.Management.Automation
using namespace System.Management.Automation.Provider
using namespace System.Management.Automation.Runspaces
using namespace System.Reflection

function Import-GistProvider {
    [CmdletBinding()]
    param ( )

    $sessionStateProviderEntry = [SessionStateProviderEntry]::new(
        'GistProvider',
        [Provider],
        $null
    )

    $type = [PowerShell].Assembly.GetType('System.Management.Automation.Runspaces.LocalPipeline')
    $method = $type.GetMethod(
        'GetExecutionContextFromTLS',
        [BindingFlags]'Static,NonPublic')
    # Invoke the method to get an instance of ExecutionContext.
    $context = $method.Invoke(
        $null,
        [BindingFlags]'Static,NonPublic',
        $null,
        $null,
        (Get-Culture)
    )

    # Get the SessionStateInternal type
    $type = [PowerShell].Assembly.GetType('System.Management.Automation.SessionStateInternal')
    # Get a valid constructor which accepts a param of type ExecutionContext
    $constructor = $type.GetConstructor(
        [BindingFlags]'Instance,NonPublic',
        $null,
        $context.GetType(),
        $null)
    # Get the SessionStateInternal for this execution context
    $sessionStateInternal = $constructor.Invoke($context)

    # This attempts to verify that we have the "right" session state
    # $currentLocation = $type.GetProperty('CurrentLocation', [Reflection.BindingFlags]'Instance,NonPublic')
    # $currentLocation.GetValue($sessionStateInternal)

    # Get the method which allows Providers to be added to the session
    $method = $type.GetMethod(
        'AddSessionStateEntry',
        [BindingFlags]'Instance,NonPublic',
        $null,
        $sessionStateProviderEntry.GetType(),
        $null)
    # Invoke the method.
    $method.Invoke($sessionStateInternal, $sessionStateProviderEntry)
}
