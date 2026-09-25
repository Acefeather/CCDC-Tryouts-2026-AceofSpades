<#
Windows_QuickBaseline.ps1
Purpose: Read-only CCDC baseline collection for Windows Server.
Makes NO configuration changes.
#>

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutFile = "Windows_Baseline_$Timestamp.txt"

function Section($Title) {
    Add-Content $OutFile "`n==================== $Title ====================`n"
}

"CCDC Windows Quick Baseline" | Out-File $OutFile
"Collected: $(Get-Date)" | Add-Content $OutFile

Section "SYSTEM"
hostname | Add-Content $OutFile
whoami | Add-Content $OutFile
whoami /groups | Add-Content $OutFile
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsName |
    Format-List | Out-String | Add-Content $OutFile

Section "NETWORK"
ipconfig /all | Add-Content $OutFile
route print | Add-Content $OutFile

Section "LOCAL USERS"
Get-LocalUser | Format-Table Name, Enabled, LastLogon, PasswordExpires |
    Out-String | Add-Content $OutFile

Section "LOCAL ADMINISTRATORS"
try {
    Get-LocalGroupMember Administrators |
        Format-Table Name, ObjectClass, PrincipalSource |
        Out-String | Add-Content $OutFile
} catch {
    "Could not enumerate Administrators group: $($_.Exception.Message)" | Add-Content $OutFile
}

Section "RUNNING SERVICES"
Get-Service | Where-Object Status -eq "Running" |
    Sort-Object Name |
    Format-Table Name, DisplayName, Status |
    Out-String | Add-Content $OutFile

Section "LISTENING TCP PORTS"
try {
    Get-NetTCPConnection -State Listen |
        Sort-Object LocalPort |
        Select-Object LocalAddress, LocalPort, OwningProcess |
        Format-Table -AutoSize |
        Out-String | Add-Content $OutFile
} catch {
    netstat -ano | Add-Content $OutFile
}

Section "FIREWALL PROFILES"
try {
    Get-NetFirewallProfile |
        Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction |
        Out-String | Add-Content $OutFile
} catch {
    "Firewall profile query failed." | Add-Content $OutFile
}

Section "SCHEDULED TASKS"
try {
    Get-ScheduledTask |
        Sort-Object TaskPath, TaskName |
        Select-Object TaskPath, TaskName, State |
        Format-Table -AutoSize |
        Out-String | Add-Content $OutFile
} catch {
    schtasks /query /fo LIST /v | Add-Content $OutFile
}

Section "STARTUP COMMANDS"
try {
    Get-CimInstance Win32_StartupCommand |
        Select-Object Name, Command, Location, User |
        Format-Table -AutoSize |
        Out-String | Add-Content $OutFile
} catch {
    "Startup command query failed." | Add-Content $OutFile
}

Section "DEFENDER"
try {
    Get-MpComputerStatus |
        Select-Object AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated |
        Format-List | Out-String | Add-Content $OutFile

    "`nExclusions:" | Add-Content $OutFile
    Get-MpPreference |
        Select-Object ExclusionPath, ExclusionProcess, ExclusionExtension |
        Format-List | Out-String | Add-Content $OutFile
} catch {
    "Microsoft Defender cmdlets unavailable or access denied." | Add-Content $OutFile
}

Section "RECENT LOGONS (LAST 50)"
try {
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625} -MaxEvents 50 |
        Select-Object TimeCreated, Id, ProviderName, Message |
        Format-List | Out-String | Add-Content $OutFile
} catch {
    "Could not read Security event log." | Add-Content $OutFile
}

Write-Host "Baseline complete: $OutFile"
