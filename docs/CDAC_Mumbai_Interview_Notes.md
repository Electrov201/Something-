# CDAC Mumbai — Complete Interview Preparation Guide

## 1. Company & Role Context

### What is CDAC?
**CDAC (Centre for Development of Advanced Computing)** is the premier R&D organization under the **Ministry of Electronics and Information Technology (MeitY)**, Government of India. It was established in 1988, originally to build India's first supercomputer — **PARAM 8000** — after the USA denied Cray supercomputers to India.

**Key divisions at CDAC Mumbai:**
- **Cyber Security & Cyber Forensics** — this is the division most relevant to the PG-DITISS role
- **Network Management & Information Security**
- **PARAM Supercomputing facility**

### What the Role Expects
Based on the job description, the interviewer will test you across these pillars:

| Pillar | What They Want | Depth Expected |
|:---|:---|:---|
| **Linux Administration** | Day-to-day server management | Hands-on commands, logs, troubleshooting |
| **Shell Scripting** | Automation of tasks | Write scripts on the spot |
| **Networking & Security** | Design, troubleshoot, secure networks | OSI, TCP/IP, Firewalls, VLANs |
| **Containerization** | Docker, Kubernetes | Deployment, orchestration |
| **Automation** | Ansible playbooks | Configuration management |
| **Compliance** | ISO 27001 ISMS Audit | Understand audit process and controls |

---

## 2. Linux System Administration (Core to Advanced)

### **2.1. Where Are Logs Saved?**

**Interview Answer:**
> "In Linux, almost all system logs are stored under `/var/log/`. The logging is handled by a daemon — on older systems it's `rsyslog`, on modern systems using systemd it's `journald`. Every service writes its own log file inside `/var/log/`, and we can also centralize logs to a remote syslog server for security monitoring."

**Detailed Breakdown of Key Log Files:**

| Log File | What It Contains | Real-World Use Case |
|:---|:---|:---|
| `/var/log/syslog` or `/var/log/messages` | General system activity — services starting/stopping, errors, warnings | **Scenario:** A web server suddenly stopped. You check `tail -f /var/log/syslog` and see "Out of memory: Killed process 1234 (apache2)" — the OOM Killer terminated Apache because the server ran out of RAM. |
| `/var/log/auth.log` or `/var/log/secure` | Every authentication event — SSH logins, `sudo` usage, failed passwords | **Scenario:** You suspect a brute-force attack. Run `grep "Failed password" /var/log/auth.log` and find 500 failed SSH attempts from IP 203.0.113.50 in 10 minutes → block with `iptables -A INPUT -s 203.0.113.50 -j DROP`. |
| `/var/log/dmesg` | Kernel ring buffer — hardware detection at boot, driver messages | **Scenario:** A new hard drive isn't showing up. Run `dmesg | grep sd` to see if the kernel detected the disk at all. |
| `/var/log/boot.log` | Boot-time service startup messages | Useful when a service fails to start on boot and you need to see the exact error. |
| `/var/log/kern.log` | Kernel-level events (panics, hardware failures, driver issues) | **Scenario:** Server crashes randomly → check `kern.log` for hardware errors like "MCE: CPU 0: Machine Check Exception". |
| `/var/log/cron` | Cron job execution logs | **Scenario:** A backup script that runs at midnight didn't execute. Check `/var/log/cron` to see if cron even tried to run it. |
| `/var/log/apache2/` or `/var/log/httpd/` | Web server access and error logs | `access.log` shows who visited what URLs (IP, timestamp, HTTP status). `error.log` shows PHP errors, permission denied, etc. |

**Important Log Commands:**
```bash
# Watch a log in real-time (like a live feed)
tail -f /var/log/syslog

# Search for specific errors in all logs
grep -r "error" /var/log/ --include="*.log"

# View systemd journal logs for a specific service
journalctl -u nginx.service --since "1 hour ago"

# View last 50 lines of authentication log
tail -n 50 /var/log/auth.log
```

---

### **2.2. Essential Linux Commands (With Explanations)**

**Interview Tip:** Don't just list commands. Explain WHEN and WHY you use them.

#### File & Directory Management
```bash
# List files with permissions, size, owner (human-readable)
ls -lah
# Real-world: First thing you run when troubleshooting permission issues

# Copy entire directory recursively
cp -r /var/www/html /backup/website_backup_$(date +%F)
# Real-world: Quick backup before making changes to a web server

# Move/Rename — also used to rename files
mv old_config.conf new_config.conf

# Remove directory and all contents (DANGEROUS — use carefully)
rm -rf /tmp/old_data/
# Real-world: Cleaning up temp files to free disk space

# Create nested directories in one command
mkdir -p /opt/myapp/config/ssl
```

#### Process Management
```bash
# View ALL running processes with full details
ps aux
# Column meanings: USER, PID, %CPU, %MEM, VSZ, RSS, TTY, STAT, START, TIME, COMMAND

# Real-time monitoring (like Task Manager in Windows)
top
# Press 'M' to sort by memory, 'P' to sort by CPU, 'k' to kill a process

# Find the PID of a specific process
pgrep -a nginx
# Output: 1234 nginx: master process /usr/sbin/nginx

# Graceful stop (SIGTERM — lets process clean up)
kill 1234

# Force kill (SIGKILL — last resort, process can't clean up)
kill -9 1234
# Real-world: Use kill -9 only when normal kill doesn't work after 30 seconds

# Kill all processes by name
killall python3
```

**Scenario Q: "A junior admin says the server is slow. Walk me through what you do."**
> **Answer:** "First, I run `top` to check CPU and memory usage. If CPU is at 100%, I sort by CPU (`P` key) to find the offending process. I check if it's a legitimate process (like a database query gone wild) or something malicious. Then I check `free -h` for memory, `df -h` for disk space, and `iostat` for disk I/O. I also run `netstat -tuln` to see if someone is flooding the server with connections."

#### Networking Commands
```bash
# Show all IP addresses on all interfaces
ip addr show
# Look for: inet 192.168.1.100/24 (your IP and subnet)

# Test connectivity + measure latency
ping -c 5 8.8.8.8
# Real-world: If this works but 'ping google.com' fails → DNS problem

# Show all listening ports and which process owns them
ss -tulnp
# Example output: tcp LISTEN 0 128 0.0.0.0:22 users:(("sshd",pid=892))
# This tells you SSH is listening on port 22

# Trace the path packets take to reach a destination
traceroute google.com
# Real-world: If packets stop at hop 5, the problem is at that router

# DNS lookup
nslookup cdac.in
dig cdac.in +short    # Cleaner output, shows just the IP

# Download files from the internet
wget https://example.com/file.tar.gz
curl -O https://example.com/file.tar.gz
```

#### Disk Usage Commands
```bash
# Check disk space on all mounted partitions
df -h
# Real-world: If /var is 95% full, logs might be filling up the disk

# Find which directory is eating up space
du -sh /var/log/*
# This shows size of each subdirectory under /var/log

# Find files larger than 100MB
find / -type f -size +100M -exec ls -lh {} \;
```

---

### **2.3. File Permissions (Detailed)**

**Interview Answer:**
> "Linux uses a permission model with three categories — Owner (u), Group (g), and Others (o). Each category can have Read (r=4), Write (w=2), and Execute (x=1) permissions. We use `chmod` to change permissions and `chown` to change ownership."

**Visual Breakdown:**
```
-rwxr-xr-- 1 root developers 4096 Feb 15 10:00 deploy.sh
│├─┤├─┤├─┤   │    │
│ │   │  │   │    └── Group owner
│ │   │  │   └─────── File owner
│ │   │  └─────────── Others: r-- (read only = 4)
│ │   └────────────── Group:  r-x (read + execute = 5)
│ └────────────────── Owner:  rwx (read + write + execute = 7)
└──────────────────── File type: - (regular file), d (directory), l (symlink)
```

**Numeric (Octal) Permissions:**
| Permission | Binary | Octal | Meaning |
|:---|:---|:---|:---|
| `rwx` | 111 | 7 | Full access |
| `rw-` | 110 | 6 | Read + Write |
| `r-x` | 101 | 5 | Read + Execute |
| `r--` | 100 | 4 | Read only |
| `---` | 000 | 0 | No access |

**Real-World Examples:**
```bash
# Web server config file — only root can read/write
chmod 600 /etc/nginx/ssl/private.key
# Why 600? Because private keys should NEVER be readable by others

# Shared project folder — team can read/write, others can read
chmod 775 /opt/project/
chown -R admin:developers /opt/project/

# Script needs to be executable
chmod +x /opt/scripts/backup.sh
```

**Special Permissions (Interview Favorite):**

| Permission | Numeric | Real-World Example | Explanation |
|:---|:---|:---|:---|
| **SUID** | `4xxx` | `/usr/bin/passwd` has `chmod 4755` | When a normal user runs `passwd`, it temporarily runs as **root** because it needs to write to `/etc/shadow`. Without SUID, users couldn't change their own passwords. |
| **SGID** | `2xxx` | `/opt/shared_project/` has `chmod 2770` | Any file created inside this directory automatically inherits the **group ownership** of the directory, not the user's primary group. Perfect for team collaboration. |
| **Sticky Bit** | `1xxx` | `/tmp` has `chmod 1777` | Everyone can write to `/tmp`, but you can only **delete your own files**. Without the sticky bit, User A could delete User B's temporary files. |

**Scenario Q: "A developer says they can't write to a shared folder. How do you fix it?"**
> **Answer:** "First, I check the current permissions with `ls -la /shared/folder`. Then I check who owns it with `stat /shared/folder`. If the developer isn't in the correct group, I add them: `usermod -aG developers john`. Then I ensure the directory has group write permission: `chmod 2775 /shared/folder` — the SGID (2) ensures new files inherit the group."

---

### **2.4. User Management & Crucial Commands**

**Key Configuration Files:**

| File | Contents | Example Entry |
|:---|:---|:---|
| `/etc/passwd` | Username, UID, GID, home dir, shell | `john:x:1001:1001:John Doe:/home/john:/bin/bash` |
| `/etc/shadow` | Encrypted password hashes, aging | `john:$6$xyz...hash:19500:0:99999:7:::` (The `$6$` means SHA-512 hash) |
| `/etc/group` | Group names and members | `developers:x:1002:john,jane,bob` |
| `/etc/sudoers` | Who can run `sudo` commands | `john ALL=(ALL:ALL) ALL` — john can run any command as any user |

**User Management Commands in Detail:**
```bash
# Create user with a home directory and bash shell
useradd -m -s /bin/bash -c "John Doe" john
# -m = create home directory, -s = set shell, -c = comment/full name

# Set password (interactive)
passwd john

# Add user to a group WITHOUT removing from other groups
usermod -aG docker john
# CRITICAL: Always use -a (append). Without -a, it REPLACES all groups!

# Lock a user account (disable login immediately)
usermod -L john
# Real-world: Employee leaves the company → lock account first, delete later

# Delete user AND their home directory
userdel -r john

# Check which groups a user belongs to
groups john
# Output: john : john developers docker

# Check who is currently logged in
who
w        # More detailed: shows what they're doing
last     # Login history
```

**Scenario Q: "An employee left the company. What steps do you take?"**
> **Answer:** "Immediately: (1) Lock the account: `usermod -L ex_employee`. (2) Force logout any active sessions: `pkill -u ex_employee`. (3) Change any shared passwords they knew. (4) Review their `crontab -l -u ex_employee` for any scheduled tasks. (5) Backup their home directory. (6) After 30 days (per company policy), delete the account: `userdel -r ex_employee`. (7) Document everything in the ticket system."

---

### **2.5. Inode Numbers (Deep Dive)**

**Interview Answer:**
> "An inode is a data structure on the filesystem that stores all metadata about a file — permissions, owner, timestamps, size, and pointers to the actual data blocks on disk. The one thing it does NOT store is the filename. The filename is stored in the directory entry, which is just a mapping of filename → inode number."

**How Inodes Work — Visual:**
```
Directory Entry (like a phone book)
┌──────────────────┬──────────┐
│ Filename         │ Inode #  │
├──────────────────┼──────────┤
│ report.pdf       │ 524301   │
│ backup.tar.gz    │ 524302   │
│ config.yml       │ 524303   │
└──────────────────┴──────────┘

Inode 524301 (the actual metadata)
┌─────────────────────────────────┐
│ Owner: root                     │
│ Permissions: 644                │
│ Size: 2.3 MB                    │
│ Created: 2026-01-15             │
│ Data Block Pointers: [45, 46]   │
└─────────────────────────────────┘
```

**Commands:**
```bash
# See inode number of a file
ls -i report.pdf
# Output: 524301 report.pdf

# Check inode usage on the filesystem
df -i
# Output shows: Inodes Used, Inodes Free, IUse%
```

**Classic Scenario Q: "Disk shows space available but you can't create files. Why?"**
> **Answer:** "This is inode exhaustion. Every file (no matter how small) uses one inode. If you have millions of tiny files (like a mail server with millions of small email files in Maildir format), you can use up all inodes even though disk space remains. To diagnose: run `df -i` and check if IUse% is 100%. To fix: delete unnecessary small files, or recreate the filesystem with more inodes (`mkfs.ext4 -N <inode_count>` — but this formats the disk)."

**Why Hard Links Share Inodes:**
```bash
# Create a hard link
ln report.pdf report_link.pdf

# Both point to the SAME inode
ls -i report.pdf report_link.pdf
# 524301 report.pdf
# 524301 report_link.pdf
# Deleting report.pdf doesn't delete the data — report_link.pdf still works!
```

---

### **2.6. Linux vs Windows — Detailed Comparison**

| Feature | Linux | Windows |
|:---|:---|:---|
| **Kernel** | Monolithic (Linux Kernel) — all drivers run in kernel space | Hybrid (NT Kernel) — mix of kernel and user space drivers |
| **Filesystem** | Hierarchical tree from `/` root. Ext4, XFS, Btrfs. **Case-sensitive** (`File.txt` ≠ `file.txt`) | Drive letters (`C:\`, `D:\`). NTFS, FAT32. **Case-insensitive** |
| **User Interface** | CLI-first. GUI optional (GNOME, KDE). Servers typically run headless (no GUI) | GUI-first. PowerShell/CMD for CLI. Server Core is headless option |
| **Package Management** | `apt` (Debian/Ubuntu), `yum`/`dnf` (RHEL/CentOS) | MSI installers, Windows Store, `choco` (community) |
| **Security Model** | File permissions (rwx), SELinux/AppArmor, iptables | ACLs, Windows Defender, Group Policy, BitLocker |
| **Superuser** | `root` (UID 0) — unlimited power | `Administrator` — can be restricted by UAC |
| **Remote Access** | SSH (Port 22) — command line | RDP (Port 3389) — full GUI desktop |
| **Process Management** | `ps`, `top`, `kill`, `systemctl` | Task Manager, `tasklist`, `taskkill`, Services.msc |
| **Licensing** | Open source (GPL). Free to use and modify | Proprietary. Requires Commercial License (CALs for server) |
| **Server Usage** | 96.3% of top 1 million web servers run Linux | Dominant in enterprise (AD, Exchange, SharePoint) |
| **Scripting** | Bash, Python | PowerShell, Batch |

**Scenario Q: "Why would you choose Linux over Windows for a server?"**
> **Answer:** "For a web server or containerized environment, Linux is the clear choice — it's lightweight (no GUI overhead), more secure by default, free (no licensing costs), and Docker/Kubernetes run natively on Linux. However, for an enterprise environment that needs Active Directory, Exchange mail, or runs .NET applications, Windows Server is the better choice. In CDAC's case, since the role involves Docker, Kubernetes, and Ansible, Linux is the primary OS."

---

### **2.8. Linux Run Levels**

**Interview Answer:**
> "Run levels define the state of the machine — what services are running. In modern Linux (systemd), they are called 'targets' instead of run levels."

| Run Level | systemd Target | State | Description |
|:---|:---|:---|:---|
| **0** | `poweroff.target` | Halt | System is shutting down |
| **1** | `rescue.target` | Single-User | Maintenance mode (no network, root only). Used for password reset. |
| **2** | `multi-user.target` | Multi-User (no NFS) | Debian-specific, multi-user without networking |
| **3** | `multi-user.target` | Multi-User with Network | **Most servers run here** — full CLI, all services, no GUI |
| **4** | — | Unused/Custom | Reserved for custom use |
| **5** | `graphical.target` | Multi-User + GUI | Desktop systems (GNOME/KDE login screen) |
| **6** | `reboot.target` | Reboot | System is rebooting |

**Commands:**
```bash
# Check current run level (old way)
runlevel
# Output: N 3  (previous: None, current: 3)

# Check current target (modern way)
systemctl get-default
# Output: multi-user.target

# Change run level temporarily
systemctl isolate graphical.target    # Switch to GUI
systemctl isolate multi-user.target   # Switch to CLI only

# Change default permanently (survives reboot)
systemctl set-default multi-user.target   # Server (no GUI)
systemctl set-default graphical.target    # Desktop (with GUI)
```

**Scenario Q: "You need to reset the root password on a Linux server. How?"**
> **Answer:** "Reboot the server → at GRUB menu, edit the kernel line and append `init=/bin/bash` or `rd.break` → boot into single-user mode → remount root filesystem as read-write (`mount -o remount,rw /`) → run `passwd root` → set new password → reboot. This works because run level 1 (rescue mode) gives root access without requiring the old password."

---

### **2.9. Sticky Bit, SUID, SGID, Umask**

#### **Sticky Bit**

**Interview Answer:**
> "The sticky bit is a special permission set on directories. When set, only the file OWNER (or root) can delete or rename files in that directory — even if others have write permission. The classic example is `/tmp` — everyone can write to it, but you can't delete someone else's files."

```bash
# Check sticky bit on /tmp
ls -ld /tmp
# Output: drwxrwxrwt 15 root root 4096 Feb 15 10:00 /tmp
#                  ^ The 't' at the end = sticky bit is set

# Set sticky bit
chmod +t /shared_folder
chmod 1777 /shared_folder    # 1 = sticky bit

# Real-world: Without sticky bit on /tmp, any user could delete
# other users' temporary files, breaking running applications
```

#### **SUID (Set User ID)**

**Interview Answer:**
> "When SUID is set on an executable, it runs with the permissions of the FILE OWNER, not the user executing it. The classic example is `/usr/bin/passwd` — a normal user runs it, but it needs root permission to write to `/etc/shadow`. SUID makes this possible."

```bash
# Check SUID
ls -l /usr/bin/passwd
# Output: -rwsr-xr-x 1 root root 68208 Feb 15 /usr/bin/passwd
#            ^ The 's' in owner execute position = SUID

# Set SUID
chmod u+s /path/to/binary
chmod 4755 /path/to/binary    # 4 = SUID

# ⚠️ SECURITY RISK: Never set SUID on scripts or editors!
# An SUID shell or vim would give root access to any user.
# Find all SUID files (security audit):
find / -perm -4000 -type f 2>/dev/null
```

#### **SGID (Set Group ID)**

**Interview Answer:**
> "When SGID is set on a directory, new files created inside it inherit the GROUP of the directory, not the group of the user who created them. This is perfect for shared project directories."

```bash
# Example: Team project directory
mkdir /project/team_alpha
chgrp developers /project/team_alpha
chmod g+s /project/team_alpha
chmod 2775 /project/team_alpha    # 2 = SGID

# Now when user 'alice' (group: alice) creates a file inside:
# The file's group will be 'developers', not 'alice'
# This ensures all team members can access each other's files
```

#### **Umask**

**Interview Answer:**
> "Umask is a mask that determines the DEFAULT permissions for newly created files and directories. The default umask is usually 022, which means new files get 644 (rw-r--r--) and new directories get 755 (rwxr-xr-x). The formula is: File = 666 - umask, Directory = 777 - umask."

```bash
# Check current umask
umask
# Output: 0022

# How it works:
# For FILES:    666 - 022 = 644 (rw-r--r--)
# For DIRS:     777 - 022 = 755 (rwxr-xr-x)

# Set more restrictive umask (for security-sensitive servers)
umask 027
# Files: 666 - 027 = 640 (rw-r-----)
# Dirs:  777 - 027 = 750 (rwxr-x---)

# Make persistent: add to ~/.bashrc or /etc/profile
```

**Special Permissions Summary:**
| Permission | Numeric | On File | On Directory |
|:---|:---|:---|:---|
| **Sticky Bit** | 1 | (rarely used) | Only owner can delete files (`/tmp`) |
| **SUID** | 4 | Runs as file owner | (rarely used) |
| **SGID** | 2 | Runs as file group | New files inherit directory group |
| **Umask** | N/A | Controls default permissions | Controls default permissions |

---

### **2.10. Linux Boot Process**

**Interview Answer:**
> "The Linux boot process goes through 6 stages: BIOS/UEFI → Boot Loader (GRUB) → Kernel → Init System (systemd) → Run Level/Target → Login prompt."

```
Power On
    ↓
┌─────────────────────────┐
│ 1. BIOS/UEFI            │ → Hardware check (POST), finds boot device
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ 2. Boot Loader (GRUB2)  │ → Shows kernel options, loads kernel + initramfs
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ 3. Kernel                │ → Initializes hardware, mounts root filesystem
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ 4. systemd (PID 1)      │ → First process. Starts all services in parallel
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ 5. Target (Run Level)   │ → multi-user.target (servers) or graphical.target
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│ 6. Login Prompt          │ → getty (CLI) or Display Manager (GUI)
└─────────────────────────┘
```

---

### **2.11. Cron Jobs (Task Scheduling)**

```bash
# Edit cron for current user
crontab -e

# Cron format:
# MIN  HOUR  DAY  MONTH  WEEKDAY  COMMAND
# *    *     *    *      *        command_to_run

# Examples:
# Run backup every day at 2:30 AM
30 2 * * * /scripts/backup.sh

# Run disk check every Monday at 6 AM
0 6 * * 1 /scripts/disk_check.sh

# Run log rotation every hour
0 * * * * /usr/sbin/logrotate /etc/logrotate.conf

# Run security scan at midnight on 1st of every month
0 0 1 * * /scripts/security_scan.sh

# List all cron jobs for current user
crontab -l

# List cron jobs for specific user (as root)
crontab -l -u apache
```

---

### **2.12. Soft Links vs Hard Links**

| Feature | Hard Link | Soft Link (Symlink) |
|:---|:---|:---|
| **Command** | `ln file1 file2` | `ln -s file1 link1` |
| **Inode** | Same inode number as original | Different inode number |
| **Cross Filesystem** | No (must be on same partition) | Yes (can link across partitions) |
| **Original Deleted** | Link still works (data exists until all hard links removed) | Link breaks (becomes dangling/dead) |
| **Directories** | Cannot hard-link directories | Can link to directories |
| **Size** | Same as original | Small (stores path only) |

```bash
# Create and verify
echo "Hello" > original.txt
ln original.txt hardlink.txt       # Hard link
ln -s original.txt softlink.txt    # Soft link

ls -li                             # -i shows inode numbers
# 12345 -rw-r--r-- 2 user user 6 original.txt     ← inode 12345, link count 2
# 12345 -rw-r--r-- 2 user user 6 hardlink.txt     ← SAME inode 12345!
# 67890 lrwxrwxrwx 1 user user 12 softlink.txt -> original.txt  ← different inode

rm original.txt
cat hardlink.txt    # Still works! Data exists because hard link remains
cat softlink.txt    # ERROR! "No such file" — soft link is now broken
```

---

### **2.13. Process States**

| State | Code | Meaning | Example |
|:---|:---|:---|:---|
| **Running** | R | Actively using CPU | A web server processing a request |
| **Sleeping** | S | Waiting for an event (interruptible) | Apache waiting for a new HTTP connection |
| **Disk Sleep** | D | Waiting for I/O (uninterruptible) | Process reading from a slow NFS mount |
| **Stopped** | T | Suspended (Ctrl+Z) | You paused a `find` command |
| **Zombie** | Z | Finished but parent hasn't collected exit status | Buggy parent process didn't call `wait()` |

```bash
# View process states
ps aux
# USER  PID  %CPU %MEM  VSZ   RSS TTY  STAT  START  TIME COMMAND
# root    1  0.0  0.1  225828  9752 ?    Ss    10:00  0:01 /sbin/init
#                                        ^^
#                               S = Sleeping, s = session leader

# Kill zombie processes (kill the PARENT, not the zombie)
ps aux | grep Z        # Find zombies
kill -SIGCHLD <parent_PID>    # Tell parent to reap
```

---

## 3. Windows Server & Active Directory

### **3.1. Active Directory (AD) — The Backbone of Enterprise Windows**

**Interview Answer:**
> "Active Directory is Microsoft's directory service that stores information about objects on a network — users, computers, printers, groups — and makes this information easy to find and manage. It runs on a Windows Server called a Domain Controller, and it uses LDAP (Lightweight Directory Access Protocol) and Kerberos for authentication."

**Key AD Components Explained:**

| Component | What It Is | Real-World Analogy |
|:---|:---|:---|
| **Domain** | A logical boundary containing users, computers, and policies | Like a company — everyone inside follows the same rules |
| **Domain Controller (DC)** | The server that runs AD DS and authenticates every login | Like the security guard at the company entrance — checks your ID |
| **Forest** | The top-level container — one or more domain trees sharing a common schema | Like a parent corporation owning multiple companies |
| **OU (Organizational Unit)** | A container within a domain used to organize objects and apply GPOs | Like departments within a company (HR, IT, Finance) |
| **Sites** | Physical network locations (e.g., Mumbai office, Delhi office) | Used for replication optimization — replicate within site first |

**Group Policy (GPO) — How It Works:**
> GPO is the most powerful tool in Windows Server. It allows you to control **everything** — from password complexity to which software users can install to whether USB drives work.

**GPO Processing Order (LSDOU):**
```
Local Policy → Site Policy → Domain Policy → OU Policy
     ↓              ↓             ↓              ↓
  (Weakest)                                  (Strongest)
```
The last policy applied wins. So OU-level policies override Domain-level policies.

**Real-World GPO Examples:**
- **Password Policy:** Minimum 12 characters, must contain uppercase + number + special character, expires every 90 days
- **Account Lockout:** Lock account after 5 failed attempts for 30 minutes
- **Software Restriction:** Block `.exe` files from running from `%TEMP%` folder (prevents ransomware)
- **Drive Mapping:** Automatically map `\\fileserver\shared` as drive `S:` when users log in
- **Disable USB Storage:** Deploy via GPO to prevent data theft on sensitive machines

**Scenario Q: "A new department of 50 employees joins. How do you set them up in AD?"**
> **Answer:** "I create a new OU called 'NewDepartment' under the domain. Then I create a Security Group called 'NewDept_Users'. I use PowerShell to bulk-create 50 user accounts from a CSV file:
> ```powershell
> Import-Csv users.csv | ForEach-Object {
>   New-ADUser -Name $_.Name -SamAccountName $_.Username -Path "OU=NewDepartment,DC=cdac,DC=in"
> }
> ```
> Then I create GPOs for their specific needs (drive mappings, printer assignments, software restrictions) and link them to the NewDepartment OU."

---

### **3.2. Server Roles (Detailed)**

#### **FSRM (File Server Resource Manager)**
> FSRM lets you control and manage the data stored on your file server.

**Key Features:**
- **Quotas:** Set a 500 MB limit per user's home folder. Soft quota = warning, Hard quota = blocks writes.
- **File Screens:** Block users from saving `.mp3`, `.mkv`, `.torrent` files to the file server. **Real-world:** Prevents employees from filling up company storage with personal media.
- **Storage Reports:** Generate reports showing who's using the most space, what file types are stored, etc.

#### **DFS (Distributed File System)**
> DFS provides two technologies: DFS Namespaces and DFS Replication.

**Real-World Example:**
```
Without DFS:                         With DFS:
\\server1\projects                    \\cdac.in\shared\projects
\\server2\hr_docs                     \\cdac.in\shared\hr_docs
\\server3\finance                     \\cdac.in\shared\finance
(Users must remember 3 servers)       (One unified namespace!)
```
**DFS Replication:** Keeps folders synchronized across multiple servers. If Mumbai server goes down, Delhi server has the same data.

#### **NLB (Network Load Balancing)**
> Distributes incoming network traffic across multiple servers to ensure no single server gets overwhelmed.

**How It Works:**
```
                    ┌────────────────┐
  Client Request →  │  NLB Cluster   │
                    │  (Virtual IP)  │
                    └───────┬────────┘
                    ┌───────┼────────┐
                    ↓       ↓        ↓
                 Server1  Server2  Server3
                 (Web)    (Web)    (Web)
```
**Real-World:** CDAC's website `www.cdac.in` might use NLB — if one web server crashes, the other two continue serving traffic. Users never notice the failure.

#### **NPS (Network Policy Server)**
> NPS is Microsoft's implementation of RADIUS (Remote Authentication Dial-In User Service).

**When It's Used:**
- **VPN Authentication:** Employee connects via VPN → NPS checks their AD credentials and whether their device meets health policies (updated antivirus, patches).
- **Wi-Fi Authentication (802.1X):** Laptop connects to corporate Wi-Fi → switch/AP forwards credentials to NPS → NPS checks AD → allows or denies access.
- **Wired 802.1X:** Same concept but for wired Ethernet ports.

---

### **3.3. Exchange Server — Enterprise Email**

**Interview Answer:**
> "Exchange Server is Microsoft's enterprise mail platform. It handles sending, receiving, and storing emails, calendars, contacts, and tasks. It integrates tightly with Active Directory for user authentication and address books."

**Architecture:**
```
User (Outlook) ←→ Client Access Server (CAS) ←→ Mailbox Server ←→ Database (EDB)
                        Port 443 (HTTPS)            Stores mail data
                        Handles OWA, ActiveSync      in Mailbox Databases
```

| Component | Purpose | Port |
|:---|:---|:---|
| **SMTP** | Sending emails between servers | 25 (server-to-server), 587 (client submission) |
| **POP3** | Download emails to client (deletes from server) | 110 (unencrypted), 995 (SSL) |
| **IMAP** | Sync emails across devices (keeps on server) | 143 (unencrypted), 993 (SSL) |
| **OWA** | Outlook Web Access — browser-based email | 443 (HTTPS) |

**IPAM (IP Address Management):**
> IPAM is a Windows Server feature that lets you discover, monitor, and manage IP address space across your network. It integrates with DNS and DHCP to give you a single pane of glass for all IP addresses — which IPs are assigned, which are free, which DHCP leases are about to expire.

**DAG (Database Availability Group):**
> A DAG is a group of up to 16 Exchange Mailbox servers that provides automatic database-level failover. If Server1 goes down, Server2 automatically takes over the mailbox database within 30 seconds. Users don't notice.

---

### **3.4. PowerShell — Automation Engine**

**Interview Answer:**
> "PowerShell is not just a shell — it's a complete automation framework. It uses a Verb-Noun syntax (like `Get-Service`, `Set-ADUser`), works with objects instead of text (unlike Bash), and can manage everything from Active Directory to Exchange to Azure."

**Essential PowerShell Commands:**
```powershell
# AD User Management
Get-ADUser -Filter * -Properties LastLogonDate | Where {$_.LastLogonDate -lt (Get-Date).AddDays(-90)}
# Real-world: Find all users who haven't logged in for 90 days (potential stale accounts)

# Service Management
Get-Service | Where-Object {$_.Status -eq "Stopped" -and $_.StartType -eq "Automatic"}
# Real-world: Find services that should be running but have crashed

# System Info
Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsTotalVisibleMemorySize

# Remote Management (like SSH for Windows)
Enter-PSSession -ComputerName Server02
Invoke-Command -ComputerName Server02,Server03 -ScriptBlock { Get-Process }

# Export to CSV
Get-ADUser -Filter * | Select Name,Email,LastLogonDate | Export-Csv -Path C:\report.csv
```

**PowerShell vs Bash:**
| Feature | PowerShell | Bash |
|:---|:---|:---|
| **Output** | Objects (structured data) | Text (strings) |
| **Piping** | Passes objects between commands | Passes text between commands |
| **Syntax** | `Verb-Noun` | Free-form |
| **Remote** | WinRM | SSH |
---

## 4. Networking Core

### **4.1. IP Addressing (IPv4) — Deep Dive**

**Interview Answer:**
> "IPv4 uses 32-bit addresses, giving us about 4.3 billion unique addresses. The header is minimum 20 bytes and contains critical fields like Source IP, Destination IP, TTL, Protocol, and Header Checksum."

**IPv4 Header (20 bytes minimum):**
```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |    DSCP/TOS   |         Total Length          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|    Fragment Offset      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  TTL (hops)   |   Protocol    |       Header Checksum         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source IP Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination IP Address                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Key Header Fields:**
| Field | Size | Purpose | Interview Example |
|:---|:---|:---|:---|
| **TTL** | 8 bits | Prevents routing loops. Decremented by 1 at each router | If TTL=0, router drops packet and sends ICMP "Time Exceeded" — this is how `traceroute` works! |
| **Protocol** | 8 bits | Identifies upper-layer protocol | 6=TCP, 17=UDP, 1=ICMP |
| **Flags** | 3 bits | Controls fragmentation | DF (Don't Fragment) bit — if set and packet too large, router drops it and sends ICMP "Fragmentation Needed" |

**IP Classes:**

| Class | Range | Default Mask | Private Range | Max Hosts | Use Case |
|:---|:---|:---|:---|:---|:---|
| **A** | 1.0.0.0 – 126.255.255.255 | /8 (255.0.0.0) | 10.0.0.0/8 | 16.7 million | Large enterprises, ISPs |
| **B** | 128.0.0.0 – 191.255.255.255 | /16 (255.255.0.0) | 172.16.0.0 – 172.31.255.255 | 65,534 | Universities, mid-size orgs |
| **C** | 192.0.0.0 – 223.255.255.255 | /24 (255.255.255.0) | 192.168.0.0/16 | 254 | Small offices, home networks |
| **D** | 224.0.0.0 – 239.255.255.255 | N/A | N/A | N/A | Multicast (IPTV, streaming) |
| **E** | 240.0.0.0 – 255.255.255.255 | N/A | N/A | N/A | Experimental/Reserved |

> **Note:** 127.0.0.0/8 is reserved for **loopback** (localhost). 127.0.0.1 is "yourself".

**Ethernet Frame Structure:**
```
┌──────────┬──────────┬──────────┬──────┬────────────┬─────┐
│ Preamble │ Dest MAC │ Src MAC  │ Type │  Payload   │ FCS │
│ (8 bytes)│ (6 bytes)│ (6 bytes)│(2 B) │ (46-1500B) │(4 B)│
└──────────┴──────────┴──────────┴──────┴────────────┴─────┘
```

**Important Port Numbers:**
| Port | Service | Protocol |
|:---|:---|:---|
| 20, 21 | FTP (Data, Control) | TCP |
| 22 | SSH | TCP |
| 23 | Telnet (insecure) | TCP |
| 25 | SMTP (Email sending) | TCP |
| 53 | DNS | TCP/UDP |
| 67, 68 | DHCP (Server, Client) | UDP |
| 80 | HTTP | TCP |
| 443 | HTTPS | TCP |
| 110 | POP3 | TCP |
| 143 | IMAP | TCP |
| 3389 | RDP | TCP |

---

### **4.2. OSI Model — Each Layer in Detail**

**Interview Answer:**
> "The OSI model is a 7-layer conceptual framework that standardizes how data flows across a network. Each layer has specific responsibilities. I remember it as 'All People Seem To Need Data Processing' (from Layer 7 down)."

**OSI Layers — Function, Attacks, Prevention, Protocols:**

| OSI Layer | Function | Protocols | Attacks | Prevention |
|:---|:---|:---|:---|:---|
| **7. Application** | Provides network services directly to user applications (browsing, email) | HTTP, HTTPS, FTP, SMTP, DNS, SNMP | SQL Injection, XSS, Phishing, DNS Poisoning | WAF, Input validation, DNSSEC, user training |
| **6. Presentation** | Data translation, encryption/decryption, compression | SSL/TLS, JPEG, MPEG, ASCII | Man-in-the-Middle (if weak encryption), Malware in files | Strong encryption (TLS 1.3), certificate validation |
| **5. Session** | Establishes, manages, and terminates sessions between apps | NetBIOS, RPC, PPTP, SIP | Session Hijacking, Session Replay | Session tokens with expiration, TLS mutual auth |
| **4. Transport** | Reliable (TCP) or fast (UDP) delivery, flow control, error recovery | TCP, UDP, SCTP | SYN Flood, UDP Flood, Port scanning | Firewalls, SYN cookies, rate limiting, IDS/IPS |
| **3. Network** | Logical addressing (IP), routing, path selection | IP, ICMP, IPSec, ARP, OSPF, BGP | IP Spoofing, Ping of Death, Smurf Attack, Route poisoning | ACLs, packet filtering, IPSec, anti-spoofing |
| **2. Data Link** | Physical addressing (MAC), error detection, frame delivery | Ethernet, PPP, 802.1Q, STP | MAC Flooding, ARP Spoofing, VLAN Hopping | Port security, Dynamic ARP Inspection (DAI), 802.1X |
| **1. Physical** | Transmits raw bits over physical medium | Ethernet cables, Fiber, Wi-Fi radio | Wiretapping, Jamming, Cable cutting | Physical access controls, locked server rooms, wireless encryption |

**TCP/IP Model (4 Layers):**
```
OSI Model (7 layers)          TCP/IP Model (4 layers)
┌─────────────────┐
│  7. Application │
├─────────────────┤           ┌──────────────────┐
│  6. Presentation│ ────────→ │  4. Application  │
├─────────────────┤           └──────────────────┘
│  5. Session     │
├─────────────────┤           ┌──────────────────┐
│  4. Transport   │ ────────→ │  3. Transport    │
├─────────────────┤           └──────────────────┘
│  3. Network     │ ────────→ │  2. Internet     │
├─────────────────┤           └──────────────────┘
│  2. Data Link   │           ┌──────────────────┐
├─────────────────┤ ────────→ │  1. Network      │
│  1. Physical    │           │     Access       │
└─────────────────┘           └──────────────────┘
```

**TCP vs UDP:**
| Feature | TCP | UDP |
|:---|:---|:---|
| **Connection** | Connection-oriented (3-way handshake: SYN → SYN-ACK → ACK) | Connectionless (fire and forget) |
| **Reliability** | Guaranteed delivery (ACK, retransmission) | No guarantee — packets can be lost |
| **Speed** | Slower (overhead for reliability) | Faster (no overhead) |
| **Use Cases** | HTTP, FTP, SSH, Email — anything where data MUST arrive correctly | DNS queries, Video streaming, VoIP, Gaming — speed matters more than perfection |
| **Header Size** | 20 bytes | 8 bytes |

---

### **4.3. Network Devices — Purpose & Differences**

| Device | OSI Layer | Purpose | Intelligence |
|:---|:---|:---|:---|
| **Hub** | Layer 1 | Repeats signal to ALL ports (broadcast) | Dumb — no filtering, creates collisions |
| **Repeater** | Layer 1 | Amplifies/regenerates weak signal | Extends physical distance of a network |
| **Switch** | Layer 2 | Forwards frames based on MAC address table | Smart — learns which device is on which port, sends data only to the correct port |
| **Router** | Layer 3 | Forwards packets between different networks using IP addresses | Smartest — uses routing tables, NAT, ACLs, connects different networks (LAN to WAN) |

**Scenario Q: "What happens when Host A (on VLAN 10) pings Host B (on VLAN 20)?"**
> **Answer:** "Since they are on different VLANs, a Layer 2 switch alone cannot handle this — VLANs are separate broadcast domains. You need inter-VLAN routing, which requires either a Layer 3 switch or a router. The packet goes: Host A → Switch → Router (routes between VLAN 10 and VLAN 20) → Switch → Host B. The router decrements the TTL and changes the source/destination MAC addresses."

---

### **4.4. Router Packet Flow (The "Hopping" Process)**

**Interview Answer:**
> "When a router receives a packet, it strips the Layer 2 frame, reads the destination IP, looks up its routing table, decrements the TTL, rewrites the MAC addresses, and forwards it out the correct interface. The IP addresses stay the same (unless NAT is involved), but the MAC addresses change at every hop."

**Step-by-Step Visualization:**
```
PC-A (192.168.1.10) → Router-1 → Router-2 → Server-B (10.0.0.5)

Step 1: PC-A creates a packet
  ┌─────────────┬──────────────┬─────────────┬──────────────┐
  │ Src MAC: A  │ Dst MAC: R1  │ Src IP: A   │ Dst IP: B    │
  └─────────────┴──────────────┴─────────────┴──────────────┘

Step 2: Router-1 receives it
  - Strips Layer 2 (removes MAC header)
  - Reads Dst IP (10.0.0.5) → Routing table says "send to Router-2"
  - Decrements TTL: 64 → 63
  - Re-encapsulates with NEW MACs:
  ┌──────────────┬──────────────┬─────────────┬──────────────┐
  │ Src MAC: R1  │ Dst MAC: R2  │ Src IP: A   │ Dst IP: B    │ ← IPs unchanged!
  └──────────────┴──────────────┴─────────────┴──────────────┘

Step 3: Router-2 → Server-B (same process)
```

---

### **4.5. DHCP, DNS, Routing Protocols, VLANs**

#### **DHCP (Dynamic Host Configuration Protocol)**

**DORA Process — Detailed:**
```
 Client                                            DHCP Server
   │                                                    │
   │── 1. DHCP DISCOVER (Broadcast: 255.255.255.255) ──→│
   │   "Hey! I'm new here. I need an IP address."       │
   │                                                    │
   │←── 2. DHCP OFFER ────────────────────────────────── │
   │   "Here, take 192.168.1.100, mask 255.255.255.0,   │
   │    gateway 192.168.1.1, DNS 8.8.8.8,               │
   │    lease time: 8 hours"                             │
   │                                                    │
   │── 3. DHCP REQUEST ──────────────────────────────→   │
   │   "OK, I'll take 192.168.1.100 please."            │
   │   (Broadcast so other DHCP servers know)            │
   │                                                    │
   │←── 4. DHCP ACK ─────────────────────────────────── │
   │   "Confirmed! 192.168.1.100 is yours for 8 hours." │
```

**Scenario Q: "A PC gets a 169.254.x.x address. What happened?"**
> **Answer:** "That's an APIPA (Automatic Private IP Addressing) address. It means the DHCP Discover broadcast never received an Offer. Either the DHCP server is down, the network cable is unplugged, or there's a VLAN mismatch (the client's DHCP Discover can't reach the server). I'd check: (1) Physical connectivity, (2) DHCP server status, (3) Whether a DHCP relay agent is needed if the server is on a different subnet."

#### **DNS (Domain Name System) — Complete Working**

**How a DNS Query Works (step by step):**
```
You type "www.cdac.in" in your browser:

1. Browser Cache → "Do I already know this IP?" → No
2. OS Cache (/etc/hosts or DNS cache) → No
3. Recursive DNS Resolver (ISP/8.8.8.8) → "Let me find out for you"
4. Root Server (13 worldwide) → "I don't know cdac.in, but ask .in TLD server"
5. TLD Server (.in) → "I don't know www.cdac.in, but ask cdac.in's Authoritative NS"
6. Authoritative NS (ns1.cdac.in) → "www.cdac.in = 14.139.187.11"
7. Resolver caches the answer and returns it to your browser
8. Browser connects to 14.139.187.11
```

**DNS Record Types:**
| Record | Purpose | Example |
|:---|:---|:---|
| **A** | Maps hostname to IPv4 address | `www.cdac.in → 14.139.187.11` |
| **AAAA** | Maps hostname to IPv6 address | `www.cdac.in → 2001:db8::1` |
| **CNAME** | Alias (one name pointing to another) | `mail.cdac.in → cdac-in.mail.protection.outlook.com` |
| **MX** | Mail Exchange — where to send email | `cdac.in → mail.cdac.in (priority 10)` |
| **NS** | Name Server — authoritative DNS for this domain | `cdac.in → ns1.cdac.in` |
| **PTR** | Reverse DNS (IP → hostname) | `14.139.187.11 → www.cdac.in` |
| **SOA** | Start of Authority — primary info about the zone | Contains serial number, refresh interval, admin email |
| **TXT** | Arbitrary text (used for SPF, DKIM, verification) | `v=spf1 include:_spf.google.com ~all` |

**DNS Zone Files:**
> A Zone File is a text file that describes a DNS zone — it contains all the DNS records for a domain.

```
; Zone file for cdac.in
$TTL 86400          ; Default TTL: 24 hours
@   IN  SOA  ns1.cdac.in. admin.cdac.in. (
            2026021501  ; Serial (YYYYMMDDNN)
            3600        ; Refresh (1 hour)
            900         ; Retry (15 min)
            604800      ; Expire (1 week)
            86400       ; Minimum TTL
)
@       IN  NS      ns1.cdac.in.
@       IN  NS      ns2.cdac.in.
@       IN  A       14.139.187.11
www     IN  A       14.139.187.11
mail    IN  A       14.139.187.20
@       IN  MX  10  mail.cdac.in.
```

#### **Routing Protocols — Comparison**

| Protocol | Type | Metric | Max Hops | Convergence | Best For |
|:---|:---|:---|:---|:---|:---|
| **RIP** | Distance Vector | Hop count | 15 | Slow (30s updates) | Small networks, learning |
| **IGRP** | Distance Vector | Bandwidth + Delay | 255 | Moderate | Legacy Cisco networks |
| **EIGRP** | Hybrid (Advanced DV) | Bandwidth + Delay + Load + Reliability | 255 | Fast (triggered updates) | Cisco-heavy enterprises |
| **OSPF** | Link State | Cost (based on bandwidth) | No limit | Very Fast (LSA flooding) | Enterprise standard, multi-vendor |
| **MSTP** | Spanning Tree | Path cost | N/A | N/A | Loop prevention in Layer 2 |

**OSPF Explained (Interview Favorite):**
> "OSPF divides a network into Areas. Area 0 is the backbone — all other areas must connect to it. Routers in the same area share Link State Advertisements (LSAs) to build a complete topology map. Then each router independently runs Dijkstra's algorithm to calculate the shortest path. The metric is Cost = Reference Bandwidth / Interface Bandwidth."

#### **VLAN — Virtual LAN**

**Interview Answer:**
> "A VLAN logically segments a physical switch into multiple broadcast domains. Without VLANs, all ports on a switch are in the same broadcast domain — meaning if one device sends a broadcast (like ARP), every other device receives it. With VLANs, broadcast traffic stays within its VLAN."

**Enterprise VLAN Design Example (CDAC):**
| VLAN ID | Name | Subnet | Purpose |
|:---|:---|:---|:---|
| 10 | MGMT | 10.0.10.0/24 | Network device management |
| 20 | SERVERS | 10.0.20.0/24 | Server farm |
| 30 | EMPLOYEES | 10.0.30.0/24 | Regular employee workstations |
| 40 | GUESTS | 10.0.40.0/24 | Guest Wi-Fi (restricted access) |
| 100 | SECURITY | 10.0.100.0/24 | Security cameras, access control |

**802.1Q Tagging:**
> When a frame travels between switches (trunk link), a 4-byte VLAN tag is inserted into the Ethernet frame to identify which VLAN it belongs to. Access ports (connecting to end devices) strip this tag.

#### **NAT (Network Address Translation)**

**Interview Answer:**
> "NAT translates private IPs to public IPs, allowing multiple devices on a private network to share a single public IP for internet access. This is essential because we've run out of IPv4 addresses."

**Types:**
| Type | How It Works | Example |
|:---|:---|:---|
| **Static NAT** | 1-to-1 mapping (one private → one public) | Server 192.168.1.10 always appears as 203.0.113.5 |
| **Dynamic NAT** | Pool of public IPs, first-come-first-served | 50 internal users share a pool of 10 public IPs |
| **PAT (Port Address Translation)** | Many-to-1 — all internal IPs share ONE public IP, differentiated by port numbers | 100 devices share one public IP — device A uses port 50001, device B uses port 50002 |

**Real-World:** Your home router uses PAT — all your devices (phone, laptop, TV) share one ISP-given public IP.

---

## 5. Security & Cyber Defense

### **5.1. Windows Defender — How It Works (Deep Dive)**

**Interview Answer:**
> "Windows Defender is Microsoft's built-in endpoint protection platform. It uses a multi-layered detection approach: signature-based detection for known threats, heuristic/behavioral analysis for unknown threats, and cloud-delivered protection for real-time intelligence."

**How Windows Defender Detects Malicious Activity:**

| Detection Method | How It Works | Real-World Example |
|:---|:---|:---|
| **Signature-Based** | Compares file hash (SHA-256) against a database of known malware hashes. If match found → blocked. | Defender downloads daily definition updates. When you download `setup.exe`, it calculates its SHA-256 hash and checks if it matches any known malware signature. |
| **Heuristic Analysis** | Analyzes code behavior patterns without running it. Looks for suspicious characteristics (packed executables, obfuscated code). | A file is flagged because it tries to modify the Windows registry `Run` key (auto-start), disable security software, and encrypt files — classic ransomware pattern. |
| **Behavioral Monitoring** | Watches running processes in real-time for suspicious activity. | A PowerShell process suddenly starts downloading files from the internet, disabling Defender, and encrypting documents → Defender kills the process immediately. |
| **Cloud Protection** | Sends suspicious file metadata to Microsoft's cloud for analysis. Machine learning models classify it. | A new zero-day malware that doesn't match any signature is sent to the cloud, where ML identifies it as malicious within seconds. |

**Why Windows Defender?**
- Free (built into Windows)
- No third-party conflicts
- Integrates with Group Policy for enterprise management
- Microsoft Defender for Endpoint (paid) adds EDR (Endpoint Detection and Response) capabilities

#### **Hash Values — How to Calculate**

**What is Hashing?**
> A hash is a one-way mathematical function that converts any data into a fixed-length string. Even a 1-bit change produces a completely different hash. It's used for **integrity verification** — proving a file hasn't been tampered with.

| Algorithm | Output Length | Security | Use Case |
|:---|:---|:---|:---|
| **MD5** | 128 bits (32 hex chars) | Broken (collisions found) | Legacy checksums only |
| **SHA-1** | 160 bits (40 hex chars) | Deprecated | Git commits (still) |
| **SHA-256** | 256 bits (64 hex chars) | Secure | File integrity, certificates, malware signatures |

**How to Calculate Hash:**
```bash
# Linux
sha256sum suspicious_file.exe
# Output: a3f2b8c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1  suspicious_file.exe

md5sum suspicious_file.exe

# Windows (PowerShell)
Get-FileHash -Path "C:\Downloads\setup.exe" -Algorithm SHA256
Get-FileHash -Path "C:\Downloads\setup.exe" -Algorithm MD5
```

**Real-World Scenario:** You download a Linux ISO from the official website. The website shows: `SHA256: abc123...`. You calculate the hash of your downloaded file. If they match → file is authentic. If different → file was corrupted or tampered with (man-in-the-middle attack).

---

### **5.2. Infrastructure Security Concepts**

#### **Firewalls**

**Interview Answer:**
> "A firewall is a network security device that monitors and filters incoming and outgoing network traffic based on predefined security rules. It establishes a barrier between a trusted internal network and untrusted external networks."

**Types of Firewalls:**
| Type | OSI Layer | How It Works | Example |
|:---|:---|:---|:---|
| **Packet Filtering** | Layer 3/4 | Checks Source/Dest IP, Port, Protocol. Simple rules. | `iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT` (Allow SSH only from internal network) |
| **Stateful Inspection** | Layer 3/4 | Tracks connection state (NEW, ESTABLISHED, RELATED). More intelligent. | Allows response traffic for connections YOU initiated, blocks unsolicited inbound |
| **Application Firewall (WAF)** | Layer 7 | Inspects actual HTTP content. Can detect SQL injection, XSS. | ModSecurity on Apache/Nginx |
| **Next-Gen Firewall (NGFW)** | All Layers | Combines packet filtering + deep packet inspection + IPS + application awareness | Palo Alto, Fortinet, Cisco Firepower |

**iptables Basic Rules (Linux):**
```bash
# View current rules
iptables -L -n -v

# Allow SSH from specific subnet
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block everything else (default deny)
iptables -A INPUT -j DROP

# Save rules (persist after reboot)
iptables-save > /etc/iptables/rules.v4
```

#### **ACL (Access Control List)**
> ACLs on routers filter traffic at network boundaries. Two types:
- **Standard ACL (1-99):** Filters based on source IP only. Place close to destination.
- **Extended ACL (100-199):** Filters based on source IP, dest IP, port, protocol. Place close to source.

```
! Cisco Router example: Block all traffic from 10.0.0.0/8 to web server 192.168.1.100
access-list 100 deny tcp 10.0.0.0 0.255.255.255 host 192.168.1.100 eq 80
access-list 100 permit ip any any
interface GigabitEthernet0/0
  ip access-group 100 in
```

---

### **5.3. ISO 27001 (ISMS) — Detailed for CDAC**

**Interview Answer:**
> "ISO 27001 is the international standard for Information Security Management Systems (ISMS). It provides a framework for managing sensitive company information and ensuring it remains secure. It covers people, processes, and technology. CDAC, being a government R&D organization handling sensitive data, would need ISO 27001 compliance."

**The CIA Triad:**
| Principle | Meaning | Real-World Example | Control |
|:---|:---|:---|:---|
| **Confidentiality** | Only authorized people can access data | CDAC research data should only be accessible to project members | Encryption, Access Control, MFA |
| **Integrity** | Data is accurate and hasn't been tampered with | Source code must not be modified by unauthorized users | Hashing, Digital Signatures, Version Control |
| **Availability** | Data and systems are accessible when needed | CDAC website and services must be available 24/7 | Redundancy, Backups, DDoS Protection |

**PDCA Cycle (Plan-Do-Check-Act):**
```
     ┌────────────────┐
     │     PLAN       │ ← Identify risks, define security policies
     │  Risk Assessment│    "What could go wrong?"
     └───────┬────────┘
             ↓
     ┌────────────────┐
     │      DO        │ ← Implement controls (firewalls, training, encryption)
     │ Implement      │    "Put safeguards in place"
     └───────┬────────┘
             ↓
     ┌────────────────┐
     │    CHECK       │ ← Monitor, audit, review effectiveness
     │  Audit/Monitor │    "Are controls working?"
     └───────┬────────┘
             ↓
     ┌────────────────┐
     │      ACT       │ ← Fix issues, improve processes
     │ Correct/Improve│    "What needs to change?"
     └────────────────┘
```

**Key ISO 27001 Controls (Annex A):**
- **A.5:** Information Security Policies
- **A.6:** Organization of Information Security
- **A.8:** Asset Management
- **A.9:** Access Control
- **A.12:** Operations Security (Malware protection, Backup, Logging)
- **A.13:** Communications Security (Network controls, Data transfer)
- **A.18:** Compliance

**Scenario Q: "How would you prepare for an ISO 27001 audit at CDAC?"**
> **Answer:** "I would: (1) Review and update the ISMS scope document defining what's covered. (2) Conduct an internal risk assessment — identify all information assets, threats, and vulnerabilities. (3) Ensure all Annex A controls are documented and implemented (access control policies, incident response procedures, backup verification). (4) Perform internal audits to catch gaps before the external auditor arrives. (5) Prepare evidence — logs showing access control enforcement, backup test records, security training attendance, incident reports. (6) Brief all staff so they can answer auditor questions about their security responsibilities."

---

## 6. Advanced Topics & Scenarios

### **6.1. SDN (Software Defined Networking)**

**Interview Answer:**
> "SDN separates the Control Plane (the brain that decides WHERE to send traffic) from the Data Plane (the muscle that actually forwards traffic). In traditional networking, every switch/router has its own brain. In SDN, one centralized controller makes all the decisions and pushes rules down to switches."

**Architecture:**
```
┌─────────────────────────────────────┐
│        Application Layer            │
│  (Network Apps, Security, Monitoring)│
├─────────────────────────────────────┤
│        Control Layer                │
│  (SDN Controller - OpenDaylight)    │  ← Northbound API (REST)
│  Makes all forwarding decisions     │
├─────────────────────────────────────┤  ← Southbound API (OpenFlow)
│        Infrastructure Layer         │
│  (Switches, Routers - just forward) │
└─────────────────────────────────────┘
```

- **OpenFlow:** The protocol between the SDN Controller and switches. The controller sends flow rules ("if packet matches X, forward to port Y").
- **OpenDaylight:** Open-source SDN controller platform (Java-based). Supports AAA, NETCONF, YANG models.
- **AAA (Authentication, Authorization, Accounting):**
  - **Authentication:** "Who are you?" (username/password, certificates)
  - **Authorization:** "What are you allowed to do?" (role-based access)
  - **Accounting:** "What did you do?" (logging all actions for audit)
  - Implemented via **RADIUS** or **TACACS+** protocols.

---

### **6.2. SSH — Secure Shell (Detailed)**

**Interview Answer:**
> "SSH provides encrypted remote access to servers over port 22. It replaces insecure protocols like Telnet (which sends passwords in plaintext). SSH uses public-key cryptography for authentication and symmetric encryption for the data channel."

**How SSH Key Authentication Works:**
```
1. Admin generates a key pair:
   ssh-keygen -t rsa -b 4096
   → Private key: ~/.ssh/id_rsa (KEEP SECRET — never share!)
   → Public key:  ~/.ssh/id_rsa.pub (safe to share)

2. Public key is placed on the server:
   ssh-copy-id user@server
   → Copies public key to server's ~/.ssh/authorized_keys

3. Login process:
   Client                                  Server
     │── "I want to connect as 'admin'" ──→│
     │←── "Here's a random challenge" ─────│
     │── Signs challenge with private key ─→│
     │←── Verifies with public key ─────── │
     │── "SESSION ESTABLISHED" ────────────│
```

**Hardening SSH (Interview Favorite):**
```bash
# Edit /etc/ssh/sshd_config
PermitRootLogin no              # Never allow direct root login
PasswordAuthentication no       # Force key-based authentication only
Port 2222                       # Change from default port 22 (security through obscurity)
MaxAuthTries 3                  # Lock out after 3 failed attempts
AllowUsers admin deployer       # Only these users can SSH in
Protocol 2                      # Use only SSH protocol version 2

# Restart SSHD after changes
systemctl restart sshd
```

---

### **6.3. Disk Management**

**fdisk — Partition Management:**
```bash
# List all disks and partitions
fdisk -l

# Partition a new disk
fdisk /dev/sdb
# Interactive: n (new partition) → p (primary) → 1 → Enter → Enter → w (write)

# Format the new partition
mkfs.ext4 /dev/sdb1

# Mount it
mount /dev/sdb1 /mnt/data

# Persistent mount (add to /etc/fstab)
echo "/dev/sdb1  /mnt/data  ext4  defaults  0  2" >> /etc/fstab
```

**LVM (Logical Volume Manager) — Flexible Storage:**
> LVM adds a layer of abstraction between physical disks and filesystems, allowing you to resize volumes without downtime.

```bash
# Physical Volume → Volume Group → Logical Volume → Filesystem
# PV (disk) → VG (pool) → LV (partition) → mount point

pvcreate /dev/sdb                     # Create Physical Volume
vgcreate data_vg /dev/sdb             # Create Volume Group
lvcreate -L 50G -n app_lv data_vg     # Create 50GB Logical Volume
mkfs.ext4 /dev/data_vg/app_lv         # Format
mount /dev/data_vg/app_lv /opt/app    # Mount

# RESIZE (the killer feature) — no downtime!
lvextend -L +20G /dev/data_vg/app_lv  # Add 20GB
resize2fs /dev/data_vg/app_lv         # Extend filesystem
```

---

### **6.4. VPN, Squid Proxy, NTP, FTP, NFS**

#### **VPN (Virtual Private Network)**
> Creates an encrypted tunnel through the public internet, allowing secure remote access to a private network.

| Type | Use Case | Example |
|:---|:---|:---|
| **Site-to-Site** | Connects two offices permanently | CDAC Mumbai ↔ CDAC Pune — always connected, all traffic encrypted |
| **Remote Access** | Individual user connects from home | Employee uses OpenVPN to access internal servers from home |

**Protocols:** IPSec (Layer 3, strong security), OpenVPN (SSL/TLS, flexible), WireGuard (modern, fast)

#### **Squid & Reverse Proxy**
- **Forward Proxy (Squid):** Sits between clients and internet. Caches web pages, filters content, logs browsing.
  - **Real-world:** CDAC uses Squid to block social media sites during work hours and cache frequently accessed websites.
- **Reverse Proxy (Nginx):** Sits in front of web servers. Distributes load, provides SSL termination, hides backend servers.
  - **Real-world:** `www.cdac.in` → Nginx reverse proxy → balances between 3 Apache servers.

#### **NTP (Network Time Protocol)**
> Synchronizes clocks across all devices. **Critical** because:
- **Log correlation:** If Server A says an attack happened at 10:05 and Server B says 10:08, but they're both the same event — your investigation is wrong.
- **Kerberos (AD authentication):** If client clock is off by >5 minutes from the DC, authentication fails.
- **Certificates:** Expired or not-yet-valid certificates cause TLS failures.

#### **FTP vs NFS**
| Feature | FTP | NFS |
|:---|:---|:---|
| **Purpose** | Transfer files between systems | Share filesystem across network (like a shared drive) |
| **Protocol** | TCP (Port 20/21) | RPC-based |
| **Authentication** | Username/Password | IP-based or Kerberos |
| **Use Case** | Upload files to a web server | Mount /shared/data on all servers so they access the same files |

---

### **6.5. Service Management & Bash Scripting**

#### **systemd Service Management**
```bash
# Start a service
systemctl start nginx

# Stop a service
systemctl stop nginx

# Enable auto-start on boot
systemctl enable nginx

# Check status (shows if running, last errors, PID, memory usage)
systemctl status nginx

# View all failed services
systemctl --failed

# Reload config without restarting (zero-downtime)
systemctl reload nginx

# View service logs
journalctl -u nginx --since "2 hours ago"
```

#### **Bash Scripting (Interview Examples)**

**Example 1: Automated Backup Script**
```bash
#!/bin/bash
# Daily backup script for CDAC web server

BACKUP_DIR="/backup/$(date +%F)"
SOURCE="/var/www/html"
LOG="/var/log/backup.log"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/website.tar.gz" "$SOURCE" 2>> "$LOG"

if [ $? -eq 0 ]; then
    echo "$(date): Backup SUCCESS → $BACKUP_DIR" >> "$LOG"
else
    echo "$(date): Backup FAILED!" >> "$LOG"
    mail -s "Backup Failed on $(hostname)" admin@cdac.in < "$LOG"
fi

# Delete backups older than 30 days
find /backup/ -type d -mtime +30 -exec rm -rf {} \;
```

**Example 2: Monitor Disk Space**
```bash
#!/bin/bash
# Alert if any partition exceeds 90% usage

THRESHOLD=90

df -h | awk 'NR>1 {print $5, $6}' | while read usage mount; do
    usage_num=${usage%\%}    # Remove % sign
    if [ "$usage_num" -gt "$THRESHOLD" ]; then
        echo "WARNING: $mount is at $usage" | mail -s "Disk Alert" admin@cdac.in
    fi
done
```

---

## 7. Scenario-Based Interview Questions (Must Prepare)

### **Q1: A user cannot access a website. How do you troubleshoot?**
> **Answer (Layer-by-Layer approach):**
> 1. **Layer 1 (Physical):** Is the network cable plugged in? Does the link light on the NIC blink? Try a different cable/port.
> 2. **Layer 2 (Data Link):** Check if the device has a valid MAC address and is assigned to the correct VLAN on the switch.
> 3. **Layer 3 (Network):** Run `ipconfig` (Windows) or `ip addr` (Linux). Is IP valid (not 169.254.x.x)? Ping the default gateway. If gateway fails → local network issue.
> 4. **Layer 4 (Transport):** Ping `8.8.8.8` — if this works but websites don't open → DNS issue, not internet issue.
> 5. **Layer 7 (Application):** Run `nslookup google.com` — if DNS fails → check DNS server config. If DNS works → try `curl -I https://google.com` to check HTTP response.
> 6. **Trace the path:** `traceroute google.com` — see where packets stop.
> 7. **Check firewall:** Is outbound port 80/443 blocked? Check `iptables -L` or Windows Firewall rules.

### **Q2: High CPU usage on a Linux Server**
> **Answer:**
> 1. Run `top` or `htop` — identify the process consuming the most CPU (sort by `P`).
> 2. Check if it's a legitimate process: `ps aux | grep <PID>` — is it Apache, MySQL, a cron job?
> 3. If it's a runaway process (like a PHP script in infinite loop): `kill <PID>`. If unresponsive: `kill -9 <PID>`.
> 4. Check logs: `journalctl -u <service> --since "1 hour ago"` for errors.
> 5. If it's a Java application: check for memory leaks with `jstack <PID>`.
> 6. Long-term fix: Set up monitoring with Prometheus + Grafana to catch such issues early.

### **Q3: A server suddenly became unreachable over SSH**
> **Answer:**
> 1. Can you reach it via `ping`? If no → network issue. Check physical connectivity, VLAN, IP conflicts.
> 2. If ping works but SSH doesn't → SSH daemon might have crashed. Check via console/IPMI/KVM access: `systemctl status sshd`.
> 3. Check firewall: `iptables -L -n | grep 22` — was port 22 accidentally blocked?
> 4. Check `/var/log/auth.log` — was the server attacked (too many failed attempts) and fail2ban blocked your IP?
> 5. Check disk space: `df -h` — if `/` is 100% full, sshd can't create temp files and dies.
> 6. Check system load: `uptime` — load average of 50+ means the server is overwhelmed.

### **Q4: How do you secure a newly deployed Linux server?**
> **Answer:**
> 1. **Update everything:** `apt update && apt upgrade -y`
> 2. **Disable root SSH:** Edit `/etc/ssh/sshd_config` → `PermitRootLogin no`
> 3. **Use SSH keys only:** `PasswordAuthentication no`
> 4. **Set up firewall:** `ufw enable` → allow only needed ports (22, 80, 443)
> 5. **Install fail2ban:** Auto-blocks IPs after repeated failed login attempts
> 6. **Remove unnecessary services:** `systemctl disable --now telnet cups bluetooth`
> 7. **Set up automatic security updates:** `apt install unattended-upgrades`
> 8. **Enable audit logging:** Install `auditd` for compliance tracking
> 9. **Configure NTP:** Ensure accurate timestamps for logs
> 10. **Set up monitoring:** Install Wazuh or OSSEC for security monitoring

### **Q5: Explain how Docker and Kubernetes relate to this role**
> **Answer:** "In a CDAC environment, Docker containerizes applications — instead of installing software directly on servers (which creates dependency conflicts), we package each application with its dependencies into a container. Kubernetes then orchestrates these containers — it handles deployment, scaling (if traffic increases, Kubernetes automatically spins up more containers), self-healing (if a container crashes, Kubernetes restarts it), and load balancing. For security, we use tools like Falco for runtime security monitoring and CIS benchmarks for hardening."

### **Q6: What is Ansible and how would you use it at CDAC?**
> **Answer:** "Ansible is an agentless configuration management tool. It uses SSH to connect to servers and YAML playbooks to describe the desired state. At CDAC, I would use Ansible to: (1) Deploy standard configurations across 100+ servers consistently. (2) Automate patch management — push security updates to all servers simultaneously. (3) Enforce compliance — ensure all servers meet ISO 27001 requirements (correct firewall rules, disabled unnecessary services, proper logging). (4) Disaster recovery — rebuild a server from a playbook in minutes instead of hours."
