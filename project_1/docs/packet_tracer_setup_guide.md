# Cisco Packet Tracer Lab Guide for Project 1 (SOC Architecture)

This comprehensive guide covers the implementation of **Phases 1-5** of the SOC Project 1 using **Cisco Packet Tracer**.

---

## 🏗️ Phase 1: Lab Topology & Initial Setup

### 1.1 Device Checklist
| Device Type | Model in Packet Tracer | Quantity | Role |
|---|---|---|---|
| **Router** | ISR 4331 or 2911 | 1 | ISP / Internet Simulator |
| **Firewall** | ASA 5506-X | 1 | Perimeter Security |
| **Switch (L3)** | 3560 or 3650 | 1 | Core Switch |
| **Switch (L2)** | 2960 | 2 | Access Switches |
| **Server** | Server-PT | 1 | Web Server (DMZ) |
| **PC** | PC-PT | 3 | HR, IT, Kali (Attacker) |

### 1.2 Physical Connections (Cabling)
- **ISP Router (Gi0/0/0)** <--> **ASA Firewall (Gi1/1)** [Connects to Outside]
- **ASA Firewall (Gi1/2)** <--> **Core Switch (Gi0/1)** [Connects to Inside]
- **ASA Firewall (Gi1/3)** <--> **Web Server** [Connects to DMZ]
- **Core Switch (Gi0/2)** <--> **Access Switch 1 (Gi0/1)** [Trunk]
- **Core Switch (Gi0/3)** <--> **Access Switch 2 (Gi0/1)** [Trunk]
- **Access Switch 1 (Fa0/1)** <--> **HR PC**
- **Access Switch 2 (Fa0/1)** <--> **IT PC**
- **Access Switch 2 (Fa0/2)** <--> **Kali PC**

---

## 🌐 Phase 2: L1/L2 Switching & Routing

### 2.1 ISP Router Config (Simulating Internet)
```cisco
enable
conf t
hostname ISP
interface range Gi0/0/0 - 2
 no shutdown
interface Gi0/0/0
 ip address 203.0.113.1 255.255.255.0
 description CONNECTION_TO_ASA_OUTSIDE
exit
! Route back to ASA for return traffic
ip route 0.0.0.0 0.0.0.0 203.0.113.2
```

### 2.2 Core Switch Config (VLANs, SVI, DHCP)
```cisco
enable
conf t
hostname Core-SW
ip routing
!
vlan 10
 name HR
vlan 20
 name IT
vlan 99
 name MGMT
!
! Connect to ASA (Routed Port)
interface Gi0/1
 no switchport
 ip address 192.168.20.2 255.255.255.0
 no shutdown
!
! Trunks to Access Switches
interface range Gi0/2 - 3
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 99
!
! SVIs (Gateway for VLANs)
interface vlan 10
 ip address 192.168.30.1 255.255.255.0
interface vlan 20
 ip address 192.168.40.1 255.255.255.0
interface vlan 99
 ip address 192.168.99.1 255.255.255.0
!
! DHCP Server
ip dhcp pool HR_POOL
 network 192.168.30.0 255.255.255.0
 default-router 192.168.30.1
 dns-server 8.8.8.8
!
ip dhcp pool IT_POOL
 network 192.168.40.0 255.255.255.0
 default-router 192.168.40.1
 dns-server 8.8.8.8
!
! Default Route to Firewall
ip route 0.0.0.0 0.0.0.0 192.168.20.1
```

### 2.3 Access Switch Config
**Access-SW1 (HR):**
```cisco
enable
conf t
hostname Access-SW1
vlan 10
!
interface Gi0/1
 switchport mode trunk
!
interface Fa0/1
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
```

**Access-SW2 (IT/Kali):**
```cisco
enable
conf t
hostname Access-SW2
vlan 20
!
interface Gi0/1
 switchport mode trunk
!
interface range Fa0/1 - 2
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
```

---

## 🔥 Phase 3: ASA Firewall & Security Policies

### 3.1 Initial ASA Interface Config
*Note: On Packet Tracer ASA 5506, we must remove bridge groups if present to use routed ports.*
```cisco
enable
conf t
hostname ASA-FW
!
! Configure Outside (WAN)
interface Gi1/1
 no shutdown
 nameif outside
 security-level 0
 ip address 203.0.113.2 255.255.255.0
!
! Configure Inside (LAN)
interface Gi1/2
 no shutdown
 nameif inside
 security-level 100
 ip address 192.168.20.1 255.255.255.0
!
! Configure DMZ
interface Gi1/3
 no shutdown
 nameif dmz
 security-level 50
 ip address 192.168.10.1 255.255.255.0
!
! Routing
route outside 0.0.0.0 0.0.0.0 203.0.113.1
route inside 192.168.30.0 255.255.255.0 192.168.20.2
route inside 192.168.40.0 255.255.255.0 192.168.20.2
```

### 3.2 NAT & ACLs (The Core Security)
```cisco
! Enable ICMP inspection (allow ping return)
policy-map global_policy
 class inspection_default
  inspect icmp
!
! Network Objects
object network LAN_NET
 subnet 192.168.0.0 255.255.0.0
object network DMZ_SERVER
 host 192.168.10.10
!
! NAT (Allow LAN to Internet)
nat (inside,outside) source dynamic LAN_NET interface
!
! Static NAT (Port Forwarding for DMZ Web Server)
! Maps Public IP 203.0.113.2 port 80 to Internal 192.168.10.10 port 80
nat (dmz,outside) source static DMZ_SERVER interface service tcp 80 80
!
! Access Control Lists (ACLs)
! 1. Allow Internet to Access DMZ Web Server
access-list OUTSIDE_IN extended permit tcp any object DMZ_SERVER eq 80
access-group OUTSIDE_IN in interface outside
!
! 2. Prevent DMZ from accessing LAN (Security)
access-list DMZ_OUT extended deny ip any object LAN_NET
access-list DMZ_OUT extended permit ip any any
access-group DMZ_OUT in interface dmz
```

---

## 🕵️ Phase 4: Traffic Analysis Simulation

Packet Tracer cannot run Wireshark, but it has a **Simulation Mode** that visualizes packets.

1.  **Enter Simulation Mode:** Click the "Simulation" tab (bottom right) or press `Shift+S`.
2.  **Filter Events:** Click "Edit Filters" and verify only **ICMP**, **TCP**, **UDP**, **DNS**, and **ARP** are selected.
3.  **Run a Test:**
    -   Open PC1 Command Prompt.
    -   Type `ping 192.168.40.1` (Inter-VLAN ping).
    -   Click the "Play" button in Simulation panel.
4.  **Observe:**
    -   Watch the envelope (packet) travel to Switch -> Core -> Router.
    -   **Click the envelope** at any hop to see the "Different Layers" (L2 Ethernet II, L3 IP, L4 ICMP).
    -   This effectively simulates looking at a PCAP.

---

## 🔒 Phase 5: Remote Access VPN (Client-Based)

Packet Tracer supports a simplified **IPSec Remote Access VPN**.

### 5.1 ASA VPN Configuration
```cisco
conf t
! 1. Configure IP Address Pool for VPN Clients
ip local pool VPN_POOL 10.10.10.1 10.10.10.50 mask 255.255.255.0
!
! 2. Configure Split Tunneling (Access Internal LAN only)
access-list SPLIT_TUN standard permit 192.168.0.0 255.255.0.0
!
! 3. Configure Group Policy
group-policy VPN_POLICY internal
group-policy VPN_POLICY attributes
 dns-server value 8.8.8.8
 vpn-tunnel-protocol ipsec 
 split-tunnel-policy tunnelspecified
 split-tunnel-network-list value SPLIT_TUN
!
! 4. Configure User Account
username vpnuser password cisco123 privilege 0
!
! 5. Configure Tunnel Group (Connection Profile)
tunnel-group VPN_group type remote-access
tunnel-group VPN_group general-attributes
 address-pool VPN_POOL
 default-group-policy VPN_POLICY
tunnel-group VPN_group ipsec-attributes
 ikev1 pre-shared-key cisco123
!
! 6. Enable IKEv1 on Outside Interface
crypto ikev1 enable outside
crypto ikev1 policy 10
 authentication pre-share
 encryption aes-256
 hash sha
 group 14
 lifetime 86400
!
! 7. Crypto Map (Transform Set)
crypto ipsec ikev1 transform-set MYSET esp-aes-256 esp-sha-hmac
crypto dynamic-map DYN_MAP 10 set transform-set MYSET
crypto map OUTSIDE_MAP 10 ipsec-isakmp dynamic DYN_MAP
crypto map OUTSIDE_MAP interface outside
```

### 5.2 Connecting the Client
1.  Add a **"Laptop"** to the workspace and connect it to the **ISP Router** (or a home switch connected to ISP).
2.  Configure Laptop IP: `203.0.113.100`, GW `203.0.113.1`.
3.  Open **"VPN"** software on the Laptop Desktop.
4.  Enter details:
    -   Group Name: `VPN_group`
    -   Group Key: `cisco123`
    -   Host IP: `203.0.113.2` (ASA Outside IP)
    -   Username: `vpnuser`
    -   Password: `cisco123`
5.  Click **Connect**.
6.  **Verify:** Ping `192.168.20.10` (Web Server) from the Laptop. It should work!

