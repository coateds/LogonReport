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
