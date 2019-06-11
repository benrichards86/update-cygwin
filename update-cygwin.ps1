param (
   [Parameter(Mandatory = $false, HelpMessage = "Run the 32-bit version of the Cygwin installer.")]
   [switch]$do32bit,
   [Parameter(Mandatory = $false, HelpMessage = "Run the installer interactively, allowing you to manually select packages to install, remove, or upgrade.")]
   [switch]$editpkgs
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
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition
   if ($do32bit) {
      $newProcess.Arguments += " -do32bit"
   }
   if ($editpkgs) {
      $newProcess.Arguments += " -editpkgs"
   }

   write-host $newprocess.arguments
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
}

# Run your code that needs to be elevated here
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (!$do32bit) {
   (new-object System.Net.WebClient).DownloadFile('https://www.cygwin.com/setup-x86_64.exe', $ENV:Temp + '\cygwin-setup.exe')
}
else {
   (new-object System.Net.WebClient).DownloadFile('https://www.cygwin.com/setup-x86.exe', $ENV:Temp + '\cygwin-setup.exe')
}

if (!$?) {
   Write-Host "Something wrong happened when downloading the Cygwin installer."
   Write-Host -NoNewLine "Press any key to continue..."
   $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   exit
}

Write-Host "Running: $ENV:Temp\cygwin-setup.exe ..."

if ($editpkgs) {
   $script:p = Start-Process $ENV:Temp\cygwin-setup.exe -ArgumentList "--upgrade-also" -wait -NoNewWindow -PassThru
}
else {
   $script:p = Start-Process $ENV:Temp\cygwin-setup.exe -ArgumentList "--upgrade-also --quiet-mode" -wait -NoNewWindow -PassThru
}

if ($script:p.ExitCode -ne 0) {
   Write-Host "Cygwin setup failed with an error!"
}

Remove-Item $ENV:Temp\cygwin-setup.exe

Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
