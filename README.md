# LogonReport
Build an HTML report to display at logon (or other times)

This project is going to be about research as anything. The initial script gathers information about Chocolatey packages that are installed as well as a list of those packages that have an update available. This information is sent to a local html page and then opened as a report. At first this script will be set as a scheduled task to run at logon. However, there are machines I do not logoff from very often and would like the report to show up periodically.

## Data gathering improvements to explore:
* Last reboot time (from WMI)
* Last logon time (read event viewer?)
* Last Windows Update (and updates installed)

## Run as a task
* Set up script to run in two modes
* Logon mode (work on this first)
  * Read a parameter with logon as default
  * Little to no logic, just produce the report
* Scheduled mode
  * Run one or more times daily (9:AM and 3:PM?)
  * Only runs interactively
  * Only produce and display a report if last logon for current user is more than 12 hours ago.
