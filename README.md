# update-cygwin
Stand-alone Powershell script to do an in-place automatic upgrade of pre-installed Cygwin packages.

This script will download the installer binary and run it in a mode that does an automatic in-place upgrade of any installed Cygwin packages.

Since the installer requires Administrator access, the script will elevate itself via UAC if required.

In order to run it, you will need to enable running of local Powershell scripts on the machine. From an elevated Powershell prompt, type:
> Set-ExecutionPolicy RemoteSigned

Answer Yes to the prompt. Then you can run this tool.
