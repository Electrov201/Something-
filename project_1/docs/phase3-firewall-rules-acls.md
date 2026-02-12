# Phase 3 — Firewall Rules & ACLs (pfSense / Cisco ASA)

## What Is This Phase?
This phase focuses on configuring **Layer 3/4 Security Policies**. We'll move from open connectivity (Phase 2) to a "zero trust" model where traffic is explicitly allowed. We will configure NAT (Network Address Translation) to allow internet access and rules to segment DMZ, LAN, and Guest networks.

## Why Are We Implementing This?

| Reason | Explanation |
|---|---|
| **Perimeter Security** | The firewall is the first line of defense. Understanding stateful inspection vs. stateless ACLs is foundational |
| **Segmentation Enforcement** | VLANs separate broadcast domains; Firewalls separate security zones. We prevent unauthorized lateral movement (e.g., Guest -> HR VLAN) |
| **NAT/PAT** | Essential for internet connectivity. Troubleshooting NAT issues is a daily task for network engineers |
| **Rule Proficiency** | Learning to write precise rules (Src, Dst, Port, Action) avoids "allow any any" security holes |

## Security Zones Design

| Zone | Interface | Traffic Policy |
|---|---|---|
| **WAN (Untrusted)** | Outside | Block all inbound by default. Allow return traffic (stateful) |
| **LAN (Trusted)** | Inside | Allow outbound to WAN. Allow specific access to DMZ. Block access to Guest |
| **DMZ (Semi-Trusted)** | DMZ | Allow inbound HTTP/HTTPS from WAN. Block access to LAN |
| **Guest (Untrusted)** | Guest | Allow outbound to WAN (Web only). Block access to LAN/DMZ |

## How to Implement (pfSense Example)

### Step 1: Interface Assignment
- **WAN:** DHCP (from ISP/upstream router)
- **LAN:** Static `192.168.20.1/24`
- **DMZ:** Static `192.168.10.1/24`

### Step 2: NAT Configuration (Outbound)
- **Mode:** Hybrid Outbound NAT
- **Rule:** Interface WAN, Source `192.168.0.0/16`, Destination Any -> MASQUERADE (Interface Address)

### Step 3: Firewall Rules (The Policy)

#### LAN Rules (Allow Outbound)
| Action | Proto | Source | Port | Dest | Port | Description |
|---|---|---|---|---|---|---|
| Pass | TCP/UDP | LAN net | * | * | 53 (DNS) | Allow DNS |
| Pass | TCP | LAN net | * | * | 80/443 | Allow Web Browsing |
| Block | Any | LAN net | * | Guest net | * | Block LAN to Guest |
| Pass | ICMP | LAN net | * | * | * | Allow Ping (Troubleshooting) |

#### DMZ Rules (Allow Inbound Web)
| Action | Proto | Source | Port | Dest | Port | Description |
|---|---|---|---|---|---|---|
| Pass | TCP | * | * | DMZ Address | 80 | Allow Public Web Access |
| Block | Any | DMZ net | * | LAN net | * | **Critical:** Prevent DMZ compromise from reaching LAN |

## Cisco Switch ACLs (Internal Segmentation)
For added security, apply ACLs on the Core Switch (SVI interfaces) for inter-VLAN control.

**Example: Restrict HR Access**
```cisco
ip access-list extended HR_RESTRICT
 remark Allow HR to Internet
 permit tcp 192.168.30.0 0.0.0.255 any eq 80
 permit tcp 192.168.30.0 0.0.0.255 any eq 443
 remark Allow HR to DNS
 permit udp 192.168.30.0 0.0.0.255 any eq 53
 remark Block HR to IT Management
 deny ip 192.168.30.0 0.0.0.255 192.168.20.0 0.0.0.255
 remark Permit leftovers
 permit ip any any

interface vlan 10
 ip access-group HR_RESTRICT in
```

## Troubleshooting Scenarios

### Scenario 1: "Website is Blocked" (Rule Order Issue)
**Simulation:** Place a "Block Any Any" rule *above* the "Allow HTTP" rule.
**Symptoms:** User cannot browse but can ping gateway.
**Fix:** Reorder rules. Specific (Allow HTTP) must come before General (Block All).

### Scenario 2: "Internally Accessible, Externally Dead" (NAT Failure)
**Simulation:** Disable Outbound NAT for the DMZ subnet.
**Symptoms:** Web server works from LAN but not from simulated Internet.
**Fix:** Check NAT mappings (`show nat` or Firewall > NAT > Outbound).

### Scenario 3: "DNS Failure" (UDP blocked)
**Simulation:** Block UDP 53 on LAN interface.
**Symptoms:** `ping 8.8.8.8` works, but `ping google.com` fails.
**Fix:** Allow UDP port 53.

## What Success Looks Like
- ✅ LAN PCs can browse the internet.
- ✅ External (WAN) triggers port forward to DMZ Web Server.
- ✅ DMZ Server **cannot** ping LAN PCs (Security verified).
- ✅ Guest VLAN can browse internet but cannot access LAN file shares.

## What's Next?
→ **Phase 4:** We will capture traffic using **Wireshark** to "see" these rules in action (e.g., seeing a TCP SYN packet get dropped vs. rejected).
