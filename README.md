# LogonReport
Build an HTML report to display at logon (or other times)

This project is going to be about research as anything. The initial script gathers information about Chocolatey packages that are installed as well as a list of those packages that have an update available. This information is sent to a local html page and then opened as a report. At first this script will be set as a scheduled task to run at logon. However, there are machines I do not logoff from very often and would like the report to show up periodically.

## Data gathering improvements to explore:
* Last reboot time (from WMI) - *Done*
* Last logon time (read event viewer?)
  * This will not work easily as would have to query local and domain adsi
  * Consider a per user test/flag file
* Last Windows Update (and updates installed)

Logon Flag file logic
```
At every logon instance of this script, write/overwrite a flag file with user name as filename in working directory
  (domain_username.txt)

scheduled task instance of this script will test for the existence of the flag file. If found it will compare modified date with current date. If delta is greater than 24 hours, will run the script
```

## Scheduled Tasks v Scheduled Jobs
* Try setting up both
  * Scheduled Task code - *Done*
  * Scheduled Job code
* <a href='https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/'>Differences explanation</a>
* See tasks.ps1 for documentation

## Run as a task
* Set up script to run in two modes
* Logon mode (work on this first)
  * Read a parameter with logon as default
  * Little to no logic, just produce the report
* Scheduled mode
  * Run one or more times daily (9:AM and 3:PM?)
  * Only runs interactively
  * Only produce and display a report if last logon for current user is more than 12 hours ago.

# At Boot Script on Lab 1 DC
Server10 (ADDC) in lab 1 is set up to monitor servers in the lab. The process is started at boot time. The process for starting the infinite look seems to work just fine. At the moment, however, the process is not copying the .htm file to the webserver as it should. Rather than fix that one, recreate the process on Server30 and Server31.

Short Term script StartupToolsManual.ps1
```
$CSVPath = 'C:\Scripts\CSVs'
$TempPath = 'C:\Scripts\TempData'
$ServersCSV = 'Servers.csv'

# Sets the web page to refresh
$HtmlHeader = "<meta http-equiv=`"refresh`" content=`"5`" >"

$WebServer = 'Server31'
$WebServerFileName = "LabServers.htm"
$WebServerFilePath = "\\$WebServer\wwwroot\$WebServerFileName"
$LocalHtmlFile = "$TempPath\$WebServerFileName"

While ($true)
    {
    Get-Date | Set-Content -Path 'c:\scripts\startuplog.txt'


    # Gather data into a collection of objects (Table)
    # Convert it to to html and output to a local file
    Get-MyServerCollection |
        Test-ServerConnectionOnPipeline |
        Get-SelectedServiceStatusString |
        Cleanup-PSSession |
        Select-Object ComputerName,Role,Location,Ping,WMI,PSRemote,BootTime,WatchedServices |
        Sort-Object 'Ping','Farm','Type','ComputerName' |
        ConvertTo-HTML -head $HtmlHeader |
        Out-File $LocalHtmlFile
    Process-HtmlFile $LocalHtmlFile

    # copy the local html file to the web server
    Copy-Item -Path $LocalHtmlFile -Destination $WebServerFilePath
    }
```

Issues
* Admin Share on Server31 not working
* GPOs in Domain not working
* Ping and WMI had to be allowed via Firewall on Server31

Dependencies
* Multiple files in C:\scripts\CSVs
* Module:  C:\Program Files\WindowsPowerShell\Modules\HtmlMonitor

To Setup run at boot NewStartup.ps1 is placed in C:\scripts
```
<#
Get-ScheduledJob | Unregister-ScheduledJob -force
Register-ScheduledJob -Name StartupJob -FilePath C:\Scripts\NewStartup.ps1 -Credential (Get-Credential coatelab\administrator) -MaxResultCount 30 -ScheduledJobOption (New-ScheduledJobOption -DoNotAllowDemandStart) -Trigger (New-JobTrigger -AtStartup)
#>

Start-AtBootFunction


<#
Get-ScheduledJob | Disable-ScheduledJob
Get-ScheduledJob | Enable-ScheduledJob

#>
```