# Phase 2 — L1/L2 Troubleshooting (VLANs, STP, DHCP)

## What Is This Phase?
Now that the lab is up, we’ll configure **Layer 2 (Data Link)** and **Layer 1 (Physical)** connectivity. The core objective is to simulate and troubleshoot common connectivity problems like VLAN mismatches, STP loops, and DHCP failures.

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **Real-World Relevance** | 60% of network issues are L1/L2 (e.g., "port is dead" or "I can't get an IP"). Resolving these quickly is a core Network/SOC skill |
| **VLAN Segmentation** | Essential for security. Isolating user traffic from management traffic is a must-have skill |
| **STP/Loops** | Accidental loops can bring down an entire network. Understanding Spanning Tree Protocol is critical |
| **Troubleshooting Mindset** | Learning to isolate the issue to a specific layer (OSI Model) is more valuable than just knowing commands |

## Key Concepts & Configs

### 1. VLAN Configuration (Segmentation)
We will create VLANs on the Core Switch and trunk them to Access Switches.

**Core Switch Config:**
```cisco
vlan 10
 name HR_Dept
vlan 20
 name IT_Dept
vlan 99
 name Management

interface range g0/1 - 2
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 99
```

**Access Switch Config:**
```cisco
interface range f0/1 - 10
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
```

### 2. Spanning Tree Protocol (STP)
Ensure the Core Switch is the **Root Bridge** for all VLANs to prevent suboptimal paths.

**Core Switch Config:**
```cisco
spanning-tree mode rapid-pvst
spanning-tree vlan 1,10,20,99 root primary
```

### 3. DHCP Services
Configure the Core Switch (or a separate server) to hand out IPs.

**Core Switch Config:**
```cisco
ip dhcp pool VLAN10_POOL
 network 192.168.30.0 255.255.255.0
 default-router 192.168.30.1
 dns-server 8.8.8.8
```

## Troubleshooting Scenarios (The "Labs")

### Scenario 1: "User Can't Connect to Network" (VLAN Mismatch)
**Simulation:**
- Configure Switch Port 1 for VLAN 10.
- Configure PC 1 to expect VLAN 20 (or plug it into the wrong port).
- Result: Logical disconnect.

**Troubleshooting Steps:**
1. Check physical link: `show interface status` (Is it connected?)
2. Check VLAN assignment: `show vlan brief` (Is Port 1 in VLAN 10?)
3. Check Trunk status: `show interfaces trunk` (Is VLAN 10 allowed on the uplink?)

### Scenario 2: "Network Loop / Broadcast Storm" (STP Failure)
**Simulation:**
- Disable STP on two switches connected by redundant links: `no spanning-tree vlan 10`.
- Result: Packet storm, high CPU usage, network freeze.

**Troubleshooting Steps:**
1. Check CPU load: `show processes cpu` (High utilization?)
2. Check interface counters: `show interfaces` (Input rate unusually high?)
3. Re-enable STP and identify the blocked port: `show spanning-tree`.

### Scenario 3: "No IP Address / APIPA" (DHCP Failure)
**Simulation:**
- Misconfigure the DHCP helper address on the router interface, or exhaust the DHCP scope.
- Result: PC gets `169.254.x.x` address.

**Troubleshooting Steps:**
1. Check if PC sent Discover: Wireshark on PC interface.
2. Check switch config: `show run | section dhcp` (Is `ip helper-address` correct if relaying?)
3. Check pool status: `show ip dhcp binding`.

## What Success Looks Like
- ✅ PCs in VLAN 10 get 192.168.30.x addresses automatically.
- ✅ PCs in VLAN 10 can ping their gateway (192.168.30.1).
- ✅ PCs in different VLANs cannot talk (until L3 routing is enabled next phase).
- ✅ Unplugging a cable activates the redundant link via STP (ping drops for <2 seconds).

## What's Next?
→ **Phase 3:** Now that L2 is stable, we'll configure the **Firewall** to control traffic between VLANs and out to the internet, enforcing security rules.
