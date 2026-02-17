#!/bin/bash
# Server Hardening Script
# Setup SSH, UFW, and Updates automatically
# Usage: sudo bash server-hardening.sh

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: This script must be run as root (use sudo)."
    exit 1
fi

echo "=== Starting Server Hardening ==="

# 1. Update System
echo "[*] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install Essentials
echo "[*] Installing essential tools..."
sudo apt install -y ufw fail2ban net-tools htop vim curl wget libpam-pwquality

# 3. Configure Firewall (UFW)
echo "[*] Configuring Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp comment 'SSH Custom Port'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw allow 9100/tcp comment 'Node Exporter'
sudo ufw --force enable

# 4. Configure SSH
echo "[*] Hardening SSH..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 5. Enable Fail2Ban
echo "[*] Enabling Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "=== Hardening Complete. SSH is now on Port 2222 ==="
echo "[!] IMPORTANT: Reconnect using: ssh -p 2222 <user>@<server-ip>"
