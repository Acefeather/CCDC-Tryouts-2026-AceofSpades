#!/usr/bin/env bash
# Ubuntu_QuickBaseline.sh
# Purpose: Read-only CCDC baseline collection for Ubuntu.
# Makes NO configuration changes.

set -u

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTFILE="Ubuntu_Baseline_${TIMESTAMP}.txt"

section() {
    printf "\n==================== %s ====================\n\n" "$1" >> "$OUTFILE"
}

echo "CCDC Ubuntu Quick Baseline" > "$OUTFILE"
echo "Collected: $(date)" >> "$OUTFILE"

section "SYSTEM"
hostname >> "$OUTFILE" 2>&1
whoami >> "$OUTFILE" 2>&1
id >> "$OUTFILE" 2>&1
uname -a >> "$OUTFILE" 2>&1
lsb_release -a >> "$OUTFILE" 2>&1

section "NETWORK"
ip addr >> "$OUTFILE" 2>&1
ip route >> "$OUTFILE" 2>&1

section "USERS"
cat /etc/passwd >> "$OUTFILE" 2>&1

section "SUDO GROUP"
getent group sudo >> "$OUTFILE" 2>&1

section "UID 0 ACCOUNTS"
awk -F: '($3 == 0) {print $1 ":" $3 ":" $7}' /etc/passwd >> "$OUTFILE" 2>&1

section "LISTENING PORTS"
sudo ss -tulpn >> "$OUTFILE" 2>&1

section "RUNNING SERVICES"
systemctl --type=service --state=running >> "$OUTFILE" 2>&1

section "ENABLED SERVICES"
systemctl list-unit-files --state=enabled >> "$OUTFILE" 2>&1

section "PROCESSES"
ps auxf >> "$OUTFILE" 2>&1

section "FIREWALL"
sudo ufw status verbose >> "$OUTFILE" 2>&1

section "ROOT CRONTAB"
sudo crontab -l >> "$OUTFILE" 2>&1

section "SYSTEM CRONTAB"
cat /etc/crontab >> "$OUTFILE" 2>&1

section "SYSTEMD TIMERS"
systemctl list-timers --all >> "$OUTFILE" 2>&1

section "RECENT LOGINS"
last -a | head -50 >> "$OUTFILE" 2>&1
who >> "$OUTFILE" 2>&1
w >> "$OUTFILE" 2>&1

section "RECENT AUTH LOG"
if [ -f /var/log/auth.log ]; then
    sudo tail -n 200 /var/log/auth.log >> "$OUTFILE" 2>&1
else
    echo "/var/log/auth.log not found" >> "$OUTFILE"
fi

section "APPARMOR"
sudo aa-status >> "$OUTFILE" 2>&1

echo "Baseline complete: $OUTFILE"
