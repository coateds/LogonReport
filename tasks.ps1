# Bare minimum options to make PowerShell logon script work
$T = New-ScheduledTaskTrigger -AtLogon
# $A = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\Users\dcoate\Documents\GitRepositories\LogonReport\Logon.ps1"
$A = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "~\Documents\GitRepositories\LogonReport\Logon.ps1"
$S = New-ScheduledTaskSettingsSet

# This will set up a scheduled task to run the PowerShell logon script
Register-ScheduledTask -TaskName LogonScript -Action $A -Trigger $T -RunLevel Highest

# this will remove the logon script
Get-ScheduledTask -TaskName Logon* | Unregister-ScheduledTask

