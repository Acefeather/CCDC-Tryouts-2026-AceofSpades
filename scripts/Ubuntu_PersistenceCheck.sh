#!/usr/bin/env bash
# Ubuntu_PersistenceCheck.sh
# Purpose: Read-only review of common persistence locations.
# Makes NO configuration changes.

set -u

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTFILE="Ubuntu_Persistence_${TIMESTAMP}.txt"

section() {
    printf "\n==================== %s ====================\n\n" "$1" >> "$OUTFILE"
}

echo "CCDC Ubuntu Persistence Review" > "$OUTFILE"
echo "Collected: $(date)" >> "$OUTFILE"

section "SYSTEM CRON"
cat /etc/crontab >> "$OUTFILE" 2>&1

section "CRON.D"
ls -la /etc/cron.d >> "$OUTFILE" 2>&1
for f in /etc/cron.d/*; do
    [ -f "$f" ] || continue
    echo "--- $f ---" >> "$OUTFILE"
    cat "$f" >> "$OUTFILE" 2>&1
done

section "ROOT CRONTAB"
sudo crontab -l >> "$OUTFILE" 2>&1

section "SYSTEMD TIMERS"
systemctl list-timers --all >> "$OUTFILE" 2>&1

section "CUSTOM SYSTEMD UNITS"
find /etc/systemd/system -maxdepth 2 -type f -print >> "$OUTFILE" 2>&1

section "SUID / SGID FILES"
sudo find / -perm /6000 -type f 2>/dev/null >> "$OUTFILE"

section "AUTHORIZED KEYS"
while IFS=: read -r user _ uid _ _ home shell; do
    if [ "$uid" -ge 0 ] && [ -d "$home/.ssh" ]; then
        echo "--- $user : $home/.ssh ---" >> "$OUTFILE"
        ls -la "$home/.ssh" >> "$OUTFILE" 2>&1
        if [ -f "$home/.ssh/authorized_keys" ]; then
            cat "$home/.ssh/authorized_keys" >> "$OUTFILE" 2>&1
        fi
    fi
done < /etc/passwd

section "SHELL STARTUP FILES"
for f in /etc/profile /etc/bash.bashrc /root/.bashrc /root/.profile; do
    echo "--- $f ---" >> "$OUTFILE"
    [ -f "$f" ] && cat "$f" >> "$OUTFILE" 2>&1
done

section "RECENT FILE CHANGES IN /ETC"
sudo find /etc -type f -mtime -2 -printf '%TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null |
    sort -r >> "$OUTFILE"

section "LISTENING PORTS"
sudo ss -tulpn >> "$OUTFILE" 2>&1

section "RUNNING PROCESSES"
ps auxf >> "$OUTFILE" 2>&1

echo "Persistence review complete: $OUTFILE"
