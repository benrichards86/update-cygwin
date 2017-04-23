# Parameters
param (
   [switch]$32bit = $false,
   [switch]$nocleanup = $false,
   [switch]$interactive = $false
)

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)) {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
}
else {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition
   if ($32bit) {
      $newProcess.Arguments += " -32bit"
   }
   if ($nocleanup) {
      $newProcess.Arguments += " -nocleanup"
   }
   if ($interactive) {
      $newProcess.Arguments += " -interactive"
   }
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas"
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess)
   
   # Exit from the current, unelevated, process
   exit
}

# Run your code that needs to be elevated here
if ($32bit) {
    $file = "http://cygwin.com/setup-x86.exe"
}
else {
    $file = "http://cygwin.com/setup-x86_64.exe"
}
(new-object System.Net.WebClient).DownloadFile($file,'cyg_setup.exe')

if (!$?) {
   Write-Host "Something wrong happened when downloading the Cygwin installer."
   Write-Host -NoNewLine "Press any key to continue..."
   $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}

$options = ""
if (!$interactive) {
    $options = "-g -q"
}

if ($options -ne "") {
    $p = Start-Process .\cyg_setup.exe -ArgumentList "$options" -wait -NoNewWindow -PassThru
}
else {
    $p = Start-Process .\cyg_setup.exe -wait -NoNewWindow -PassThru
}

if ($p.ExitCode -ne 0) {
    Write-Host "Cygwin setup failed with an error!"
}

if (!$nocleanup) {
    Remove-Item .\cyg_setup.exe
}

Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
