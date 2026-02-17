# Phase 3: Security Incident Simulation & Response

> **Goal:** Simulate real-world attacks (SSH brute-force) and implement automated defense mechanisms using Fail2Ban and firewall rules.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Log analysis, identifying start/stop times of incidents |
| SysAdmin | Configuring intrusion prevention systems (Fail2Ban) |
| DevOps | Automated remediation and security auditing |

---

## Step 1: Simulate SSH Brute-Force Attack

> **⚠️ WARNING:** Only perform these attacks on your *own* local lab environment.

### 1.1 Tool Setup (Attacker Machine)
If you have a Kali/Parrot VM (Full Lab), use that.
If you only have the Ubuntu Server (Minimal Lab), you can simulate this from your HOST machine (Windows/WSL) using `hydra`.

**Install Hydra on WSL/Linux:**
```bash
sudo apt install -y hydra
```

### 1.2 Launch the Attack
Target your Ubuntu server IP on port 2222.

```bash
# Create a password list
echo "123456" > pass.txt
echo "password" >> pass.txt
echo "admin123" >> pass.txt
# ... add more weak passwords

# Run Hydra (replace <server-ip> with actual IP)
# -l admin : try login as 'admin'
# -P pass.txt : use password list
# -s 2222 : target port 2222
hydra -l admin -P pass.txt ssh://<server-ip> -s 2222 -V
```

---

## Step 2: Detect the Attack (Log Analysis)

### 2.1 View Authentication Logs
On the Ubuntu Server:

```bash
# Watch logs in real-time
tail -f /var/log/auth.log

# Search for failed attempts
grep "Failed password" /var/log/auth.log | head -n 10
```

**What to look for:**
```
Feb 17 10:00:01 lab-server sshd[1234]: Failed password for admin from 192.168.1.5 port 54321 ssh2
Feb 17 10:00:02 lab-server sshd[1236]: Failed password for admin from 192.168.1.5 port 54322 ssh2
```

### 2.2 Identify Attacker IP & Frequency
```bash
# Count failed attempts by IP
grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
```
*Output:* `156 192.168.1.5` (One hundred fifty-six failed attempts from this IP).

---

## Step 3: Implement Defense (Fail2Ban)

### 3.1 Install Fail2Ban
```bash
sudo apt install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

### 3.2 Configure Jail for SSH
Fail2Ban is configured via `jail.local`.

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo vim /etc/fail2ban/jail.local
```

Find the `[sshd]` section and add/edit:
```ini
[sshd]
enabled = true
port    = 2222                 # IMPORTANT: Match your custom SSH port
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3                   # Ban after 3 failures
bantime  = 10m                 # Ban for 10 minutes
findtime = 10m                 # Window to count failures
ignoreip = 127.0.0.1/8 ::1     # Don't ban localhost
```

### 3.3 Restart and Verify
```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

---

## Step 4: Verify Prevention

### 4.1 Re-run the Attack
Run Hydra again from the attacker machine.
After 3 attempts, the connection should simply **time out** or be **refused**.

### 4.2 Check Ban Status
On the server:
```bash
sudo fail2ban-client status sshd
```
*Output:*
```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   192.168.1.5
```

### 4.3 Unban IP (Manual Intervention)
If you accidentally banned yourself:
```bash
sudo fail2ban-client set sshd unbanip 192.168.1.5
```

---

## Step 5: Incident Report Practice

For the interview, be ready to describe this scenario:

> "I noticed a spike in SSH login failures in `/var/log/auth.log`. Diagnostic commands confirmed repetitive attempts from a single IP. I installed **Fail2Ban** to automate IP blocking after 3 failed attempts, reducing the attack surface immediately. I also verified the custom SSH port 2222 was correctly configured in the jail settings."

---

## ✅ Phase 3 Checklist

- [ ] SSH brute-force attack simulated (Hydra)
- [ ] Logs analyzed manually (`grep`, `tail`)
- [ ] Fail2Ban installed and configured for custom SSH port
- [ ] Attack re-run to verify auto-banning
- [ ] Banned IP confirmed in Fail2Ban status
- [ ] Unban command practiced

---

## 🔗 Next Phase
→ [Phase 4: Automation](phase4-automation.md)
