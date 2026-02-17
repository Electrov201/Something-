#!/bin/bash
# Server Hardening Script
# Setup SSH, UFW, and Updates automatically

echo "=== Starting Server Hardening ==="

# 1. Update System
echo "[*] Updating system packages..."
apt update && apt upgrade -y

# 2. Install Essentials
echo "[*] Installing essential tools..."
apt install -y ufw fail2ban net-tools htop vim curl wget

# 3. Configure Firewall (UFW)
echo "[*] Configuring Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp comment 'SSH Custom Port'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable

# 4. Configure SSH (Sed magic)
echo "[*] Hardening SSH..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 5. Enable Fail2Ban
echo "[*] Enabling Fail2Ban..."
systemctl enable fail2ban
systemctl start fail2ban

echo "=== Hardening Complete. SSH is now on Port 2222 ==="
