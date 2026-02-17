# Phase 4: Automation (Bash & Ansible)

> **Goal:** Move from manual configuration to "Infrastructure as Code" (IaC). Automate server hardening, maintenance tasks, and application deployment.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Scripting routine backups and health checks |
| SysAdmin | Automating repetitive tasks via Cron |
| DevOps | Configuration management with Ansible, Idempotency |

---

## Part A: Bash Scripting

Create a scripts directory:
```bash
mkdir -p ~/scripts
```

### 1. Health Check Script
**File:** `~/scripts/health-check.sh`
Monitor disk, memory, and services.

```bash
#!/bin/bash
# Server Health Check Script

echo "=== Server Health Check: $(date) ==="

# Check Services
echo -e "\n[+] Service Status:"
for service in nginx sshd fail2ban; do
    systemctl is-active --quiet $service && echo "  $service: RUNNING" || echo "  $service: DOWN"
done

# Check Disk Usage
echo -e "\n[+] Disk Usage:"
df -h / | grep /

# Check Memory
echo -e "\n[+] Memory Usage:"
free -h | grep Mem

# Check Failed Logins
echo -e "\n[+] Recent Failed SSH Logins:"
grep "Failed password" /var/log/auth.log | tail -n 5

echo "=================================="
```

**Make executable & test:**
```bash
chmod +x ~/scripts/health-check.sh
./scripts/health-check.sh
```

### 2. Automated Backup Script
**File:** `~/scripts/backup.sh`
Backup web files and configs.

```bash
#!/bin/bash
# Backup Script

BACKUP_DIR="/var/backups/lab-backup"
DATE=$(date +%Y-%m-%d_%H-%M)
FILENAME="backup-$DATE.tar.gz"

mkdir -p $BACKUP_DIR

echo "[*] Starting backup..."
tar -czf $BACKUP_DIR/$FILENAME /etc/nginx /var/www/lab-site /etc/ssh/sshd_config 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[+] Backup successful: $BACKUP_DIR/$FILENAME"
else
    echo "[-] Backup failed!"
fi

# Retention: Keep only last 5 backups
find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -delete
```

### 3. Schedule with Cron
Automate the health check to run daily at 8 AM.

```bash
crontab -e
```
Add:
```
0 8 * * * /home/admin-user/scripts/health-check.sh >> /var/log/daily-health.log 2>&1
```

---

## Part B: Ansible Automation

> **Note:** Run Ansible from your **HOST machine** (WSL/Windows) or a separate "Control Node". Do not run it on the server itself if possible, to simulate remote management.

### 1. Setup Inventory
**File:** `inventory.ini`

```ini
[webservers]
192.168.1.100 ansible_user=admin ansible_port=2222 ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

### 2. Connectivity Test
```bash
ansible -i inventory.ini webservers -m ping
```
*Success Output:* `192.168.1.100 | SUCCESS => { "ping": "pong" }`

### 3. Playbook: Nginx & SSL
**File:** `playbook-nginx.yml`
Automates Phase 2 steps.

```yaml
---
- name: Deploy Nginx with HTTPS
  hosts: webservers
  become: yes
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Create web root
      file:
        path: /var/www/lab-site
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'

    - name: Deploy index.html
      copy:
        dest: /var/www/lab-site/index.html
        content: "<h1>Automated Deployment via Ansible!</h1>"

    - name: Copy Nginx Config
      copy:
        src: ./nginx.conf   # Ensure you have this file locally
        dest: /etc/nginx/sites-available/lab-site

    - name: Enable Site
      file:
        src: /etc/nginx/sites-available/lab-site
        dest: /etc/nginx/sites-enabled/lab-site
        state: link

    - name: Remove default site
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent

    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

### 4. Run the Playbook
```bash
ansible-playbook -i inventory.ini playbook-nginx.yml
```

---

## ✅ Phase 4 Checklist

- [ ] `health-check.sh` created and tested
- [ ] `backup.sh` created and tested
- [ ] Cron job scheduled for automated daily checks
- [ ] Ansible installed on host machine
- [ ] `inventory.ini` configured with custom SSH port
- [ ] Ansible ping verification successful
- [ ] `playbook-nginx.yml` written and executed successfully

---

## 🔗 Next Phase
→ [Phase 5: Centralized Logging & Dashboards](phase5-centralized-logging.md)
