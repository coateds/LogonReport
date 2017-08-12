<#
Simple Function to test WMI connectivity on a remote machine
moving the Try...Catch block into isolation helps prevent any errors on the console
Return is the WMI OS object when sucessfully connects, Null when it does not
#>
Function Get-WMI_OS ($ComputerName)
    {
    Try {Get-Wmiobject -ComputerName $ComputerName -Class Win32_OperatingSystem -ErrorAction Stop}
    Catch {}
    }

Function Write-HtmlBlock
    {
    [CmdletBinding()]

    Param
        (
        [parameter(
        Mandatory=$true)]
        $File,
        [parameter(
        Mandatory=$true)]
        $Title,
        [parameter(
        Mandatory=$true)]
        $Content
        )

    $Output = "<b><em>$Title</em></b><br><hr>"
    $Output += "$Content<p></p>"
    $Output += "</body>"

    (Get-Content $File).replace('</body>', $Output) | Set-Content $File

    }

# Choco Installed
$InstalledList = choco list --local-only
$InstalledList = ForEach($Item in $InstalledList){"$Item<br>"}

# Choco Outdated
$OutdatedList = choco outdated
$OutdatedList = ForEach($Item in $OutdatedList){"$Item<br>"}

# Last Boot Time
$os = Get-WMI_OS -ComputerName .
If ($os -ne $null)
    {$BootTime = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)}
Else
    {$BootTime = "Error connection to WMI"}

# User Logon Info
$UserLogon = "$env:USERDOMAIN\$env:USERNAME"
$UserInfo = "Logged on User: $UserLogon<br>"
If (Test-Path ($WorkingFolder + '\' + $UserLogon.Replace('\', '_') + ".txt")) 
    {
    $Item = Get-Item ($WorkingFolder + '\' + $UserLogon.Replace('\', '_') + ".txt")
    $UserInfo += 'Last logon: ' + $Item.LastWriteTime + '<br>'
    }
Else
    {
    $UserInfo += "Last logon: Not recorded<br>"
    }

# Test for Scripts Dir, create if necessary
$WorkingFolder = 'C:\Scripts'
If (!(Test-Path $WorkingFolder)) {New-Item -ItemType Directory -Path $WorkingFolder}

# Create empyty HTML page with header
$WebServerFilePath = 'c:\Scripts\LogonReport.html'
$HtmlHeader = "<style>BODY{background-color:#737CA1;}</style>"
$null | ConvertTo-HTML -head $HtmlHeader | Out-File $WebServerFilePath

# Add Blocks of content
Write-HtmlBlock -File $WebServerFilePath -Title 'Installed' -Content $InstalledList
Write-HtmlBlock -File $WebServerFilePath -Title 'Outdated' -Content $OutdatedList
Write-HtmlBlock -File $WebServerFilePath -Title 'Last Boot Time' -Content $BootTime
Write-HtmlBlock -File $WebServerFilePath -Title 'User Logon Info' -Content $UserInfo

# Write logon flag file
Set-Content -Path ($WorkingFolder + '\' + $UserLogon.Replace('\', '_') + ".txt") -Value ''

# Open HTML report in IE
$ie = New-Object -com internetexplorer.application
$ie.visible = $true
$ie.navigate($WebServerFilePath)

# Detritus
# $adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
# $UserInfo += $adsi.Children | where {$_.SchemaClassName -eq 'user'} | ft name,lastlogin
# $UserInfo += '<br>'
