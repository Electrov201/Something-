# Phase 6 — Documentation & Reporting (Ticket Simulation)

## What Is This Phase?
This phase simulates the **Professional Deliverables** of a Network/Security Engineer. Technical skills are useless if you can't communicate findings. We will create "Incident Reports" for the troubleshooting scenarios from previous phases, simulating real-world tickets (ServiceNow, JIRA, BMC Remedy).

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **Professionalism** | Engineers solve problems; Senior Engineers document solutions so they don't happen again. |
| **Knowledge Base (KB)** | Building a personal KB of "Simulated Tickets" proves you've encountered and solved these issues before. |
| **Management Visibility** | Executives don't read packet captures; they read "Root Cause Analysis" (RCA) reports. |
| **Interview Portfolio** | Bringing a sample "Incident Report" to an interview sets you apart immediately. |

## Incident Report Template (RCA)

### **Incident #:** [INC-2024-001]
**Title:** [Brief Description, e.g., "HR Dept VLAN 10 Connectivity Outage"]
**Date/Time:** [YYYY-MM-DD HH:MM]
**Severity:** [High/Medium/Low]
**Status:** [Resolved]

### **1. 🚨 Problem Description**
*What was reported? Who was affected?*
> Users in HR Department (VLAN 10) reported unable to access the internet or file shares. Error message: "No Internet Access".

### **2. 🔍 Investigation Steps**
*Chronological list of troubleshooting actions.*
- **Step 1:** Verified physical connectivity on Switch 1, Port 1. Link light green.
- **Step 2:** Checked IP configuration on affected PC. IP was `169.254.x.x` (APIPA).
- **Step 3:** Suspected DHCP failure. Checked DHCP Scope on Core Switch.
- **Step 4:** Found DHCP Pool `VLAN10_POOL` was exhausted (0 free addresses).
- **Step 5:** Wireshark capture confirmed DHCP Discover packets leaving PC but no Offer received.

### **3. 🛠️ Root Cause**
*The underlying technical reason.*
> The DHCP Scope for VLAN 10 (`192.168.30.0/24`) was fully utilized due to a misconfiguration where lease time was set to 30 days, retaining old addresses for too long.

### **4. ✅ Resolution**
*How was it fixed?*
- Cleared expired DHCP bindings: `clear ip dhcp binding *`
- Reduced DHCP lease time to 8 hours: `lease 0 8`
- Verified PCs received new IP addresses immediately.

### **5. 🛡️ Prevention / Lessons Learned**
*How to stop it from happening again?*
- Implement DHCP Snooping to prevent rogue servers.
- Set up monitoring alert for DHCP Scope Utilization > 90%.

---

## Deliverables for Project 1

To complete this project, create a **Portfolio Folder** containing:

1. **Topology Diagram:** High-quality Visio/Draw.io export of your lab.
2. **Configuration Backups:** Saved `running-config` from Core Switch, Router, and Firewall.
3. **PCAP Files:**
   - `normal_traffic.pcap` (Baseline)
   - `port_scan_detected.pcap` (Attack)
   - `dhcp_failure.pcap` (Troubleshooting)
4. **Incident Reports:** 3-5 PDF reports covering:
   - VLAN Mismatch (Phase 2)
   - Firewall Block (Phase 3)
   - VPN Connectivity Issue (Phase 5)

## Conclusion

Congratulations! You have built, broken, fixed, and documented a complete **Enterprise Network**. This project demonstrates competency in:
- **L1-L3 Networking** (Switching, Routing, VLANs)
- **Security** (Firewalls, ACLs, VPNs)
- **Analysis** (Wireshark, Packet Captures)
- **Soft Skills** (Documentation, RCA)

You are now ready to tackle real-world network challenges!
