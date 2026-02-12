# Phase 1 — Lab Environment Setup (GNS3 / Cisco Packet Tracer)

## What Is This Phase?
This phase involves building the **virtual network lab** that will serve as the foundation for all subsequent troubleshooting and security analysis tasks. We will create a realistic enterprise topology featuring a Firewall (pfSense/Cisco ASA), a Core Switch, Access Switches, and endpoint machines (Windows/Linux VMs).

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **Safe Sandbox** | Perform destructive tests (breaking routing, blocking ports) without affecting a real network |
| **Realistic Complexities** | A simple flat network won't teach you VLANs or routing. We need a multi-segment network |
| **Tool Familiarity** | GNS3 and Packet Tracer are industry-standard simulation tools used for CCNA/CCNP certification |
| **Foundation** | You can't troubleshoot "broken connectivity" if you haven't first built a working network |

## Lab Topology Design

We will implement a **3-Tier Architecture** (simplified):

```mermaid
graph TD
    Cloud[Internet] -->|WAN| FW[Firewall (pfSense/ASA)]
    FW -->|DMZ| WebSrv[Web Server (DMZ)]
    FW -->|LAN| Core[Core Switch (L3)]
    Core -->|Trunk| Acc1[Access Switch 1]
    Core -->|Trunk| Acc2[Access Switch 2]
    Acc1 -->|VLAN 10| PC1[HR PC]
    Acc2 -->|VLAN 20| PC2[IT PC]
    Acc2 -->|VLAN 20| Kali[Kali Linux (Attacker)]
```

## How to Implement

### Option A: GNS3 (Recommended for Advanced/Realistic Simulation)
**Requirements:** PC with 16GB+ RAM, VirtualBox/VMware Workstation.
1. **Install GNS3** and GNS3 VM.
2. **Download Images:**
   - Router: Cisco c7200 (or VyOS for free alternative)
   - Switch: GNS3 built-in or Cisco IOU level 2
   - Firewall: pfSense Community Edition ISO
   - Endpoints: Windows 10 VM, Kali Linux VM (lightweight)
3. **Configure Integration:** Connect GNS3 to VirtualBox/VMware to run the actual OSes.

### Option B: Cisco Packet Tracer (Recommended for Beginners/Lighter Resources)
**Requirements:** Packet Tracer 8.x (Free from Cisco NetAcad).
1. **Drag & Drop Devices:**
   - 1x ISR 4331 Router (Edge)
   - 1x ASA 5506-X Firewall (Security)
   - 1x 3560 Multilayer Switch (Core)
   - 2x 2960 Switches (Access)
   - 3x PCs, 1x Server
2. **Cabling:** Use Straight-through for device-to-switch, Crossover for switch-to-switch.

### Step-by-Step Implementation Strategy

#### Step 1: Physical Connectivity (L1)
- Connect Cloud/NAT node to Firewall WAN port.
- Connect Firewall LAN port to Core Switch.
- Connect Core Switch to Access Switches.
- Connect Endpoints to Access Switches.
- **Verification:** Ensure link lights are green (or green/amber for STP).

#### Step 2: Basic IP Addressing (L3)
Define subnets:
- **WAN:** DHCP (from ISP/Home Network)
- **DMZ:** `192.168.10.0/24`
- **LAN Management:** `192.168.20.0/24`
- **User VLAN 10:** `192.168.30.0/24`
- **User VLAN 20:** `192.168.40.0/24`

#### Step 3: Initial Device Config
On Cisco devices (CLI):
```cisco
enable
configure terminal
hostname Core-Switch
interface vlan 1
 ip address 192.168.20.2 255.255.255.0
 no shutdown
exit
ip default-gateway 192.168.20.1
```

## What Success Looks Like
- ✅ All devices are powered on and connected.
- ✅ You can ping the default gateway from the Core Switch.
- ✅ GNS3/Packet Tracer project file is saved and stable.
- ✅ Topology diagram matches the implementation.

## What's Next?
→ **Phase 2:** We will break things! We'll configure VLANs and simple routing, then introduce "tickets" (simulated faults) to troubleshoot.
