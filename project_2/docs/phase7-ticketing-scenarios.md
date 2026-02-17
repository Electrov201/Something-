# Phase 7: Ticketing System & User Support Scenarios

> **Goal:** Deploy a self-hosted ticketing system (osTicket) and simulate real-world IT Support scenarios. This phase is the "Cherry on Top" that pushes your project rating to **10/10** for IT Support roles.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Handling tickets, password resets, user provisioning |
| SysAdmin | Deploying a LAMP Stack (Linux, Nginx, MySQL, PHP) |
| DevOps | Understanding application dependencies |

---

## Part A: Setup Cloud Ticketing (Free SaaS)

> **Why Cloud?** In 2025, most companies use cloud-hosted ticketing systems (SaaS). Using a free cloud tier saves system resources (RAM) and lets you focus on **ticket management workflows** rather than server maintenance.

### Option 1: Spiceworks Cloud (Best for IT Support)
**Spiceworks** is widely used in the industry for internal IT helpdesks.
1.  **Sign Up:** Go to [Spiceworks Cloud Help Desk](https://www.spiceworks.com/free-help-desk-software/) and create a free account.
2.  **Configuration:**
    -   **Portal URL:** You will get a custom URL (e.g., `my-lab.on.spiceworks.com`).
    -   **Email Settings:** Set up the "Support Email" (or just use the interface to create tickets manually for testing).
3.  **Create Users:** Create a few dummy users (e.g., `user1@example.com`, `manager@example.com`) to simulate requesters.

### Option 2: Jira Service Management (Best for DevOps/IT)
**Atlassian Jira** is the standard for DevOps and modern IT teams.
1.  **Sign Up:** Go to [Jira Service Management](https://www.atlassian.com/software/jira/service-management/free) and selecting the **Free** plan (up to 3 agents).
2.  **Create Project:** Select "IT Service Management" template.
3.  **Queue Setup:** Notice the pre-built queues for "Incidents", "Service Requests", and "Change Requests".

> **Action:** Choose one platform, sign up, and keep the tab open for Part B.

---

## Part B: IT Support Scenarios (The 10/10 Skills)

Once your ticketing platform is set up (Spiceworks or Jira), practice these common tickets. **Document these in your portfolio as "Solved Tickets".**

### 🎟️ Scenario 1: "User Locked Out"
**Ticket:** "I forgot my password and now my account is locked."

**Solution (Linux Command Line):**
1.  **Check Status:**
    ```bash
    sudo passwd -S user1
    # Output: user1 L 02/17/2026 0 99999 7 -1 (L = Locked)
    ```
2.  **Unlock Account:**
    ```bash
    sudo passwd -u user1
    ```
3.  **Reset Password:**
    ```bash
    sudo passwd user1
    ```
4.  **Force Change on Next Login:**
    ```bash
    sudo chage -d 0 user1
    ```

### 🎟️ Scenario 2: "I Can't Access the Shared Folder"
**Ticket:** "I need to save files to `/opt/project` but it says Permission Denied."

**Diagnosis:**
```bash
ls -ld /opt/project
# drwxr-s--- 2 root developers ...
id user2
# uid=1002(user2) gid=1002(user2) groups=1002(user2)  <-- Not in 'developers' group
```

**Solution:**
```bash
sudo usermod -aG developers user2
```
*Note: Tell the user to log out and log back in for group changes to take effect.*

### 🎟️ Scenario 3: "The Printer Service is Down" (Simulation)
**Ticket:** "We can't print anything."

**Simulation:** Stop the print service (CUPS is standard, but we might not have it installed. Let's simulate with Cron).
```bash
# Simulate a stopped service
sudo systemctl stop cron
```

**Diagnosis:**
```bash
systemctl status cron
# Active: inactive (dead)
```

**Solution:**
```bash
sudo systemctl start cron
sudo systemctl enable cron
```

---

## ✅ Phase 7 Checklist

- [ ] Cloud Ticketing Account created (Spiceworks/Jira).
- [ ] Users/"Customers" configured in the portal.
- [ ] **Scenario 1 Practiced:** Ticket created → Password reset on Linux → Ticket Closed.
- [ ] **Scenario 2 Practiced:** Ticket created → Permissions fixed → Ticket Resolved.
- [ ] **Scenario 3 Practiced:** Ticket created → Service restarted → Ticket Resolved.

---

## 🏆 Final Touch
Add a section to your resume:
**"Administered IT Service Management (ITSM) workflows using Spiceworks/Jira; resolved simulated tickets including user access management, file permission troubleshooting, and service restoration."**
