#!/bin/bash
# Server Health Check Script

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "=== Server Health Check: $TIMESTAMP ==="

# 1. Check Service Status
SERVICES=("nginx" "sshd" "fail2ban" "ufw")
echo -e "\n[+] Service Status:"
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "  [OK] $service is RUNNING"
    else
        echo "  [!!] $service is DOWN / INACTIVE"
    fi
done

# 2. Check Disk Usage (Alert if > 80%)
echo -e "\n[+] Disk Usage:"
df -h / | awk 'NR==2 {print "  Root Partition: " $5 " used (" $4 " free)"}'

# 3. Check Memory Usage
echo -e "\n[+] Memory Usage:"
free -h | awk 'NR==2 {print "  RAM: " $3 " / " $2 " (" $4 " free)"}'

# 4. Security Audit - Open Ports
echo -e "\n[+] Listening Ports (Top 5):"
ss -tlnp | head -n 6

# 5. Security Audit - Recent Failed Logins
echo -e "\n[+] Recent SSH Failed Logins (Last 5):"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -n 5 || echo "  No access to auth.log or no failures found."

echo -e "\n=== Check Complete ==="
