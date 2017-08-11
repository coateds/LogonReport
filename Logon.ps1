# Choco Installed
$InstalledList = choco list --local-only
$InstalledList = ForEach($Item in $InstalledList){"$Item<br>"}

# Choco Outdated
$OutdatedList = choco outdated
$OutdatedList = ForEach($Item in $OutdatedList){"$Item<br>"}

# Test for Scripts Dir, create if necessary
$WorkingFolder = 'C:\Scripts'
If (!(Test-Path $WorkingFolder)) {New-Item -ItemType Directory -Path $WorkingFolder}

# Create empyty HTML page with header
$WebServerFilePath = 'c:\Scripts\LogonReport.html'
$HtmlHeader = "<style>BODY{background-color:#737CA1;}</style>"
$null | ConvertTo-HTML -head $HtmlHeader | Out-File $WebServerFilePath

# Add Blocks of content
(Get-Content $WebServerFilePath).replace('</body>', "Installed<br>$InstalledList<p></p></body>") | Set-Content $WebServerFilePath
(Get-Content $WebServerFilePath).replace('</body>', "Outdated<br>$OutdatedList<p></p></body>") | Set-Content $WebServerFilePath

# Open HTML report in IE
$ie = New-Object -com internetexplorer.application
$ie.visible = $true
$ie.navigate($WebServerFilePath)