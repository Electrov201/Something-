# Phase 1: Server Deployment & Hardening

> **Goal:** Deploy a secure Ubuntu Server in a virtualized environment with SSH hardening, firewall rules, and proper user/group management.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | OS installation, SSH troubleshooting, user management |
| SysAdmin | Security hardening, access control policies |
| DevOps | Infrastructure provisioning, repeatable setup |

---

## Step 1: VM Creation (VirtualBox)

### VM Specifications (Optimized for 8 GB RAM Host)

| Setting | Value |
|---|---|
| OS | Ubuntu Server 22.04 LTS |
| RAM | **2 GB** (2048 MB) |
| CPU | 2 cores |
| Disk | 20 GB (dynamically allocated) |
| Network | Bridged Adapter (for SSH from host) |

### Commands After Installation

```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y net-tools curl wget vim htop tree openssh-server ufw

# Check IP address
ip addr show
```

---

## Step 2: SSH Configuration & Hardening

### 2.1 Change SSH Port (Security Through Obscurity + Awareness)

```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Edit SSH config
sudo vim /etc/ssh/sshd_config
```

**Key changes in `/etc/ssh/sshd_config`:**

```ini
# Change default port
Port 2222

# Disable root login
PermitRootLogin no

# Use key-based authentication only (after setting up keys)
PubkeyAuthentication yes
# PasswordAuthentication no   ← Enable this AFTER setting up SSH keys

# Limit login attempts
MaxAuthTries 3

# Set login grace time
LoginGraceTime 60

# Disable empty passwords
PermitEmptyPasswords no

# Disable X11 forwarding (not needed for server)
X11Forwarding no
```

### 2.2 SSH Key Setup

```bash
# On your HOST machine (Windows PowerShell / WSL):
ssh-keygen -t ed25519 -C "admin@lab-server"

# Copy the public key to the server:
ssh-copy-id -p 2222 admin@<server-ip>

# After confirming key login works, disable password auth:
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### 2.3 Verify SSH Service

```bash
# Check SSH status
sudo systemctl status sshd

# Check SSH is listening on port 2222
sudo ss -tlnp | grep 2222

# Test connection from host
ssh -p 2222 admin@<server-ip>
```

---

## Step 3: Firewall Configuration (UFW)

### 3.1 Setup Rules

```bash
# Enable UFW
sudo ufw enable

# Default policies: deny all incoming, allow all outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH on custom port
sudo ufw allow 2222/tcp comment 'SSH Custom Port'

# Allow HTTP and HTTPS (for Phase 2)
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Allow Prometheus Node Exporter (for Phase 5)
sudo ufw allow 9100/tcp comment 'Node Exporter'

# Check status
sudo ufw status verbose
```

### 3.2 Expected UFW Output

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
2222/tcp                   ALLOW IN    Anywhere        # SSH Custom Port
80/tcp                     ALLOW IN    Anywhere        # HTTP
443/tcp                    ALLOW IN    Anywhere        # HTTPS
9100/tcp                   ALLOW IN    Anywhere        # Node Exporter
```

---

## Step 4: User & Group Management

### 4.1 Create Users and Groups

```bash
# Create groups
sudo groupadd sysadmins
sudo groupadd developers
sudo groupadd monitoring

# Create users with specific groups
sudo useradd -m -s /bin/bash -G sysadmins,sudo admin-user
sudo useradd -m -s /bin/bash -G developers dev-user
sudo useradd -m -s /bin/bash -G monitoring mon-user

# Set passwords
sudo passwd admin-user
sudo passwd dev-user
sudo passwd mon-user

# Verify
id admin-user
# Output: uid=1001(admin-user) gid=1001(admin-user) groups=1001(admin-user),27(sudo),1002(sysadmins)
```

### 4.2 Password Policy

```bash
# Install password quality library
sudo apt install -y libpam-pwquality

# Edit password policy
sudo vim /etc/security/pwquality.conf
```

Key settings:
```ini
minlen = 10
dcredit = -1      # At least 1 digit
ucredit = -1      # At least 1 uppercase
lcredit = -1      # At least 1 lowercase
ocredit = -1      # At least 1 special character
```

### 4.3 Sudoers Configuration

```bash
# Create a custom sudoers file (safer than editing /etc/sudoers directly)
sudo visudo -f /etc/sudoers.d/lab-users
```

Content:
```
# sysadmins group gets full sudo
%sysadmins ALL=(ALL:ALL) ALL

# developers can restart specific services only
%developers ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx, /usr/bin/systemctl status nginx
```

### 4.4 File Permissions Practice

```bash
# Create shared project directory
sudo mkdir -p /opt/project
sudo chown root:developers /opt/project
sudo chmod 2775 /opt/project   # SetGID: new files inherit group

# Verify
ls -la /opt/
# drwxrwsr-x  2 root developers 4096 ... project
```

---

## Step 5: Diagnostic Commands Cheatsheet

These are the commands interviewers expect you to know:

| Command | Purpose | Example |
|---|---|---|
| `ip addr show` | View network interfaces & IPs | `ip a` |
| `ss -tlnp` | View listening TCP ports | `ss -tlnp \| grep sshd` |
| `systemctl status <svc>` | Check service status | `systemctl status sshd` |
| `journalctl -u <svc>` | View service logs | `journalctl -u sshd -n 50` |
| `ufw status verbose` | View firewall rules | — |
| `whoami` / `id` | Check current user & groups | `id admin-user` |
| `last` | View last logins | `last -n 10` |
| `df -h` | Disk usage | — |
| `free -h` | Memory usage | — |
| `top` / `htop` | Real-time process monitoring | — |

---

## ✅ Phase 1 Checklist

- [ ] Ubuntu Server VM created (2 GB RAM, 2 cores, 20 GB disk)
- [ ] System updated and essential tools installed
- [ ] SSH configured on port 2222 with key-based auth
- [ ] Root login disabled
- [ ] UFW enabled with explicit allow/deny rules
- [ ] Users and groups created with proper permissions
- [ ] Password policies configured
- [ ] Sudoers configured per group
- [ ] All diagnostic commands tested

---

## 🔗 Next Phase
→ [Phase 2: Network Services & Monitoring](phase2-network-services.md)
