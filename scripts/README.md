# CCDC Defensive Script Pack v1

These scripts are designed for an authorized CCDC environment and are intentionally **read-only**.

They do not:
- disable services
- change firewall rules
- delete users
- modify passwords
- kill processes
- change registry values
- edit SSH settings

Their purpose is to quickly collect a baseline and help identify suspicious persistence while minimizing the risk of breaking scored services.

## Scripts

### Windows_QuickBaseline.ps1
Collects:
- system identity
- network configuration
- local users
- local administrators
- running services
- listening ports
- firewall profile status
- scheduled tasks
- startup commands
- Microsoft Defender status/exclusions
- recent successful/failed logons

Run from an elevated PowerShell session when possible:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Windows_QuickBaseline.ps1
```

### Windows_PersistenceCheck.ps1
Reviews:
- Run / RunOnce registry keys
- startup commands
- scheduled tasks
- service executable paths
- PowerShell profiles
- recent service installation events
- recent user creation events

```powershell
.\Windows_PersistenceCheck.ps1
```

### Ubuntu_QuickBaseline.sh
Collects:
- system/network information
- users and sudo membership
- UID 0 accounts
- listening ports
- running/enabled services
- processes
- UFW status
- cron jobs
- systemd timers
- login history
- recent auth logs
- AppArmor status

```bash
chmod +x Ubuntu_QuickBaseline.sh
sudo ./Ubuntu_QuickBaseline.sh
```

### Ubuntu_PersistenceCheck.sh
Reviews:
- cron
- systemd timers and custom units
- SUID/SGID files
- authorized SSH keys
- shell startup files
- recent /etc changes
- listening ports
- running processes

```bash
chmod +x Ubuntu_PersistenceCheck.sh
sudo ./Ubuntu_PersistenceCheck.sh
```

## CCDC workflow suggestion

1. Run the baseline script as soon as you have access.
2. Save the output before making major changes.
3. Run the persistence script when you suspect compromise.
4. Compare later output to the initial baseline.
5. Do not treat any single finding as automatically malicious; verify it before changing the system.

## Competition rule note

If you intend to use these during the BYU tryout, publish the scripts to a publicly accessible repository if required by the competition's resource rules.
