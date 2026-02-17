#!/bin/bash
# Basic User Audit Script

echo "=== User Account Audit ==="

echo -e "\n[+] Users with UID >= 1000 (Human Users):"
awk -F: '($3 >= 1000) {print "  User: " $1 " | UID: " $3 " | Shell: " $7}' /etc/passwd

echo -e "\n[+] Sudoers (Groups):"
grep "^%" /etc/sudoers /etc/sudoers.d/* 2>/dev/null

echo -e "\n[+] Root Account Status:"
sudo grep "^root" /etc/shadow | cut -d: -f2 | grep -q "!" && echo "  Root account is LOCKED (Good)" || echo "  Root account is ACTIVE (Warning)"

echo -e "\n[+] Users without passwords (Security Risk!):"
sudo awk -F: '($2 == "") {print $1}' /etc/shadow
