# Phase 6: Documentation & Reporting

> **Goal:** Create professional documentation, runbooks, and incident reports. This is often the differentiator between a "Junior" and a "Mid-Level" candidate.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Clear communication of issues and resolutions |
| SysAdmin | Creating reusable documentation (Runbooks) |
| DevOps | Post-mortem analysis and continuous improvement |

---

## 1. Incident Report Format

When discussing your project in interviews, use the **STAR** method, but documented formally.

### template: `reports/incident-report-ssh-bruteforce.md`

```markdown
# Security Incident Report: SSH Brute Force Attempt

| Application | Date | Severity | Reporter |
|---|---|---|---|
| SSH Service | 2024-02-17 | High | <Your Name> |

### 1. Incident Summary
Around 10:00 AM, the authentication logs (`/var/log/auth.log`) showed a spike in failed login attempts targeting the `admin` user. The request volume indicated an automated brute-force attack.

### 2. Timeline
- **10:00 AM:** Monitoring dashboard showed CPU usage spike (20%).
- **10:05 AM:** IT Admin reviewed `auth.log` and confirmed 150+ failed attempts from IP `192.168.1.5`.
- **10:10 AM:** Fail2Ban jail was configured to ban IPs after 3 failed attempts.
- **10:15 AM:** Attack ceased; Attacker IP was successfully banned.

### 3. Root Cause Analysis
Default SSH port access allowed attackers to attempt logins. No rate limiting was active initially.

### 4. Remediation Taken
- [x] Installed **Fail2Ban**.
- [x] Configured SSH Jail (`maxretry = 3`).
- [x] Verified customized SSH port (2222) is enforced.

### 5. Prevention Actions
- Enforce Key-Only Authentication (Disable Password Auth).
- Setup Alerting in Grafana for "Failed Login" spikes.
```

---

## 2. Standard Operating Procedures (Runbooks)

Create "Runbooks" for common tasks. This shows you think about **operational consistency**.

### Runbook: Restoring from Backup

> **Objective:** Restore the Nginx configuration from a backup tarball.

**Steps:**
1.  **Locate Backup:**
    ```bash
    ls -lh /var/backups/lab-backup/
    ```
2.  **Stop Service:**
    ```bash
    sudo systemctl stop nginx
    ```
3.  **Extract Files:**
    ```bash
    sudo tar -xzf /var/backups/lab-backup/backup-2024-02-17_12-00.tar.gz -C /
    ```
4.  **Validate Config:**
    ```bash
    sudo nginx -t
    ```
5.  **Restart Service:**
    ```bash
    sudo systemctl start nginx
    ```
6.  **Verify:**
    Check `https://lab-server.local` to ensure site is back online.

---

## 3. Project Final Summary for Resume

**Title:** Linux Server Infrastructure & Security Hardening
**Role:** Infrastructure Engineer (Self-Hosted)
**Tech Stack:** Ubuntu, Nginx, Prometheus, Grafana, Ansible, Bash, UFW.

**Key Achievements:**
- Deployed a secure Ubuntu server with **custom SSH port (2222)** and **UFW firewall rules**, reducing attack surface.
- Implemented **Fail2Ban** to automate intrusion prevention, successfully mitigating a simulated brute-force attack.
- Configured **Nginx with HTTPS (SSL)** and reverse proxy settings for a sample web application.
- Established **Automated Monitoring** using Prometheus & Grafana, visualizing CPU/Memory usage and reducing reaction time to incidents.
- Automated health checks and configuration changes using **Bash scripting** and **Ansible**, ensuring standard configuration across environments.

---

## ✅ Phase 6 Checklist

- [ ] Incident Report created based on Phase 3 simulation
- [ ] "Restore from Backup" Runbook created
- [ ] Resume bullet points updated with specific metrics
- [ ] Final Project Review completed

---

## 🏆 Project Completion
Congratulations! You have built a comprehensive Linux infrastructure project.
**Next Steps:**
- Upload to GitHub.
- Add screenshots to `reports/` directory.
- Practice explaining each phase aloud for your interview.
