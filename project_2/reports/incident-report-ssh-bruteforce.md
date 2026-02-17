# Security Incident Report: SSH Brute Force Attempt

**Date:** 2024-02-17
**Reporter:** Admin
**Severity:** High
**Status:** Resolved

## 1. Executive Summary
At 10:00 AM, our monitoring system detected unusual traffic patterns on the SSH service. Analysis confirmed a brute-force attack originating from IP `192.168.1.5`, attempting to guess passwords for the `admin` account. The attack was successfully mitigated using Fail2Ban.

## 2. Event Timeline
- **10:00 AM:** CPU usage spike observed on `lab-server` (20% above baseline).
- **10:02 AM:** Administrator accessed the server via console to investigate.
- **10:03 AM:** `tail -f /var/log/auth.log` revealed rapid failed login attempts (5 attempts/second).
- **10:05 AM:** Automated defense (Fail2Ban) triggered, banning the source IP `192.168.1.5`.
- **10:10 AM:** Verified that the IP remained banned and no further attempts were recorded.

## 3. Impact Assessment
- **Data Loss:** None.
- **Service Availability:** No downtime for legitimate users.
- **Unauthorized Access:** None. All attempts failed due to strong password policies and eventual IP ban.

## 4. Root Cause Analysis
The SSH service was listening on port 2222 but `PasswordAuthentication` was temporarily enabled for testing, which allowed the brute-force tool (Hydra) to attempt logins.

## 5. Corrective Actions
1.  **Immediate:** Banned attacker IP via Fail2Ban.
2.  **Configuration:** Disabled `PasswordAuthentication` in `/etc/ssh/sshd_config`.
3.  **Monitoring:** Added alert rule in Grafana for >10 failed SSH logins per minute.

## 6. Lessons Learned
- Moving SSH to non-standard ports (2222) does not prevent scanning but reduces noise.
- Fail2Ban is essential for public-facing services.
- Key-based authentication should be the *only* allowed method.
