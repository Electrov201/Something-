# Phase 4 — Traffic Analysis with Wireshark (Anomaly Detection)

## What Is This Phase?
This phase moves beyond configuration to **analysis**. We will generate legitimate and malicious traffic (e.g., ping sweeps, port scans) and use **Wireshark** to capture, dissect, and identify anomalies. This is the core skill for L2/L3 troubleshooting and security incident detection.

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **Root Cause Analysis** | Is it the app, the network, or the server? Wireshark proves it definitively. "The packets don't lie." |
| **Security Baseline** | You must know what "normal" looks like (ARP broadcasts, DNS queries) to spot "abnormal" (ARP poisoning, DNS tunneling). |
| **Protocol Proficiency** | Deep dive into TCP Handshakes (SYN, SYN-ACK, ACK), HTTP methods, and ICMP types. |
| **Interview Value** | Demonstrating you can filter a 1GB PCAP to find the single malicious packet is a highly sought-after skill. |

## Key Wireshark Concepts

### 1. Capture Filters (BPF)
Limit what you capture to save disk space and reduce noise.
- `host 192.168.1.1` (Only traffic to/from this IP)
- `port 80` (Only HTTP)
- `net 192.168.0.0/24` (Entire subnet)

### 2. Display Filters
Find the needle in the haystack *after* capturing.
- `ip.addr == 192.168.1.5`
- `tcp.flags.syn == 1 and tcp.flags.ack == 0` (SYN packets only)
- `http.request.method == "POST"`
- `dns.qry.name contains "malicous"`

### 3. Protocol Hierarchy & Conversations
- **Statistics > Protocol Hierarchy:** Quick overview of protocols (e.g., 90% UDP? Investigate).
- **Statistics > Conversations:** Who is talking to whom the most? (Top talkers).

## Analysis Scenarios

### Scenario 1: TCP Handshake Analysis (Normal vs. Failed)
**Simulation:**
1. **Normal:** Browse to a web server.
   - Look for: `SYN` → `SYN-ACK` → `ACK` (Relative Seq/Ack numbers).
2. **Failed (Closed Port):** Telnet to a closed port.
   - Look for: `SYN` → `RST, ACK` (Reset packet indicating port closed).
3. **Dropped (Firewall):** Telnet to a filtered port.
   - Look for: `SYN` → [No Response] → `TCP Retransmission` (Silence = Drop).

### Scenario 2: Detecting a Port Scan (Nmap)
**Simulation:** Run `nmap -sS <Target_IP>` (Stealth Scan) from Kali.
**Wireshark Analysis:**
- Filter: `tcp.flags.syn == 1 and tcp.flags.ack == 0`
- **Anomaly:** Thousands of SYN packets from one Source IP to many Destination Ports in < 1 second.
- **Pattern:** Sequential port numbers (e.g., 80, 81, 82) or randomized.
- **Metric:** Graph "I/O Graph" shows massive spike in TCP packets.

### Scenario 3: ARP Poisoning (Man-in-the-Middle)
**Simulation:** Run `arpspoof` or `bettercap` in lab.
**Wireshark Analysis:**
- Filter: `arp.duplicate-address-detected` or `arp`
- **Anomaly:** "Duplicate IP address configured" warning.
- **Pattern:** One MAC address claiming to be the Gateway IP (192.168.1.1) constantly.
- **Impact:** Attacker sees all traffic.

### Scenario 4: Ping Sweep (ICMP Reconnaissance)
**Simulation:** Run `fping -a -g 192.168.1.0/24`.
**Wireshark Analysis:**
- Filter: `icmp.type == 8` (Echo Request)
- **Anomaly:** One Source IP sending Echo Requests to every IP in the subnet (x.1, x.2, x.3...) sequentially.
- **Response:** Only live hosts reply with `icmp.type == 0` (Echo Reply).

## Troubleshooting "Slow Network" Scenario
**Simulation:** Generate large file transfer or broadcast storm.
**Wireshark Steps:**
1. **Check for Retransmissions:** `tcp.analysis.retransmission`. High % = Packet Loss.
2. **Check Round Trip Time (RTT):** `tcp.analysis.ack_rtt > 0.5` (Latency > 500ms).
3. **Check Window Scale:** `tcp.window_size == 0` (Zero Window = Receiver is overwhelmed/buffer full).

## What Success Looks Like
- ✅ You can identify a successful 3-Way Handshake.
- ✅ You can distinguish between a "Connection Refused" (RST) and "Connection Timed Out" (Drop).
- ✅ You captured an Nmap scan and identified the scanner's IP.
- ✅ You saved a `.pcap` file of an anomaly for documentation (Phase 6).

## What's Next?
→ **Phase 5:** Now that we can analyze local traffic, we'll set up **VPN & Remote Access** to simulate enterprise remote work scenarios and troubleshoot tunnel issues.
