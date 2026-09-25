<#
Windows_PersistenceCheck.ps1
Purpose: Read-only review of common persistence locations.
Makes NO configuration changes.
#>

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutFile = "Windows_Persistence_$Timestamp.txt"

function Section($Title) {
    Add-Content $OutFile "`n==================== $Title ====================`n"
}

"CCDC Windows Persistence Review" | Out-File $OutFile
"Collected: $(Get-Date)" | Add-Content $OutFile

Section "RUN KEYS"
$RunKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($Key in $RunKeys) {
    "`n[$Key]" | Add-Content $OutFile
    if (Test-Path $Key) {
        Get-ItemProperty $Key | Format-List | Out-String | Add-Content $OutFile
    } else {
        "Not present" | Add-Content $OutFile
    }
}

Section "STARTUP COMMANDS"
Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location, User |
    Format-Table -AutoSize |
    Out-String | Add-Content $OutFile

Section "SCHEDULED TASKS"
Get-ScheduledTask |
    Sort-Object TaskPath, TaskName |
    Select-Object TaskPath, TaskName, State |
    Format-Table -AutoSize |
    Out-String | Add-Content $OutFile

Section "SERVICES WITH EXECUTABLE PATHS"
Get-CimInstance Win32_Service |
    Select-Object Name, StartMode, State, StartName, PathName |
    Sort-Object Name |
    Format-Table -Wrap |
    Out-String | Add-Content $OutFile

Section "POWERSHELL PROFILES"
$Profiles = @(
    $PROFILE.AllUsersAllHosts,
    $PROFILE.AllUsersCurrentHost,
    $PROFILE.CurrentUserAllHosts,
    $PROFILE.CurrentUserCurrentHost
) | Sort-Object -Unique

foreach ($P in $Profiles) {
    "`n[$P]" | Add-Content $OutFile
    if (Test-Path $P) {
        Get-Content $P | Add-Content $OutFile
    } else {
        "Not present" | Add-Content $OutFile
    }
}

Section "RECENT SERVICE INSTALL EVENTS"
try {
    Get-WinEvent -FilterHashtable @{LogName='System'; Id=7045} -MaxEvents 50 |
        Select-Object TimeCreated, Id, Message |
        Format-List | Out-String | Add-Content $OutFile
} catch {
    "Could not query Event ID 7045." | Add-Content $OutFile
}

Section "RECENT USER CREATION EVENTS"
try {
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4720} -MaxEvents 50 |
        Select-Object TimeCreated, Id, Message |
        Format-List | Out-String | Add-Content $OutFile
} catch {
    "Could not query Event ID 4720." | Add-Content $OutFile
}

Write-Host "Persistence review complete: $OutFile"
