# SOC Projects Architecture Overview

This repository contains two primary projects focused on Security Operations Center (SOC) engineering:

1.  **Project 1: SOC Lab Environment** (Network Simulation)
2.  **Project 2: Linux Server Admin & Security** (The "All-Rounder")
3.  **Project 3: SOC Platform Implementation** (Kubernetes & SIEM)

---

## 1. Project 1: SOC Lab Environment
**Location:** `/project_1`

This project involves building a simulated enterprise network to practice L1-L3 troubleshooting, firewall configuration, and VPN setups. It uses **Cisco Packet Tracer**.

### 🏗️ Network Topology Diagram

```mermaid
graph TD
    subgraph "ISP / Internet"
        ISP[ISP Router]
        Cloud((Internet Cloud))
    end

    subgraph "Perimeter Security"
        FW[ASA 5506-X Firewall]
    end

    subgraph "DMZ (Demilitarized Zone)"
        WebSrv[Web Server - 192.168.10.10]
    end

    subgraph "Internal LAN (Trusted)"
        Core["Core Switch L3"]
        Acc1["Access Switch 1 - HR"]
        Acc2["Access Switch 2 - IT"]
        
        PC_HR["HR Workstation"]
        PC_IT["IT Workstation"]
        Kali["Kali Linux (Attacker)"]
    end

    Cloud --> ISP
    ISP -->|Gi0/0 - Outside| FW
    FW -->|Gi1/3 - DMZ| WebSrv
    FW -->|Gi1/2 - Inside| Core
    
    Core -->|Trunk| Acc1
    Core -->|Trunk| Acc2
    
    Acc1 -->|VLAN 10| PC_HR
    Acc2 -->|VLAN 20| PC_IT
    Acc2 -->|VLAN 20| Kali
```

### 🔑 Key Components
-   **ASA Firewall:** Enforces security zones (Outside, Inside, DMZ). Configured with ACLs and NAT.
-   **Core Switch:** Handles Inter-VLAN routing for HR (VLAN 10), IT (VLAN 20), and Management.
-   **DMZ:** Hosts public-facing services (Web Server) isolated from the internal LAN.
-   **VPN:** Remote Access VPN configured on the ASA for external users.

---

## 2. Project 3: SOC Platform (Kubernetes)
**Location:** `/docs` (Root Documentation)

This project implements a production-grade SOC stack using **Kubernetes (K8s)**. It replaces traditional Docker Compose setups with scalable Manifests for high availability.

### ☸️ Kubernetes Architecture Diagram

```mermaid
graph TD
    subgraph "Kubernetes Cluster (Namespace: soc)"
        
        subgraph "Ingress & Networking"
            Ingress["Ingress Controller / NodePort"]
        end

        subgraph "SIEM Core (Wazuh)"
            Manager["Wazuh Manager (Deployment)"]
            Indexer["Wazuh Indexer / OpenSearch (StatefulSet)"]
            Dashboard["Wazuh Dashboard (Deployment)"]
        end

        subgraph "Incident Response (TheHive)"
            Hive["TheHive 5 (Deployment)"]
            Cassa["Cassandra DB (StatefulSet)"]
        end

        subgraph "Visualization"
            Grafana["Grafana (Deployment)"]
        end
    end

    subgraph "Data Sources (Endpoints)"
        Win[Windows Agent]
        Lin[Linux Agent]
        Net[Syslog Devices]
    end

    %% Data Flow
    Win -->|Port 1514/TCP| Manager
    Lin -->|Port 1514/TCP| Manager
    Net -->|UDP 514| Manager

    %% Internal Flow
    Manager -->|Indexer API| Indexer
    Dashboard -->|Query API| Indexer
    Grafana -->|Query API| Indexer

    %% Incident Response Flow
    Hive -->|Store Data| Cassa
    Manager -->|Alerts| Hive

    %% User Access
    Ingress -->|HTTPS| Dashboard
    Ingress -->|HTTPS| Hive
    Ingress -->|HTTPS| Grafana
```

### 🔑 Key Components
-   **Wazuh Manager:** The brain of the SIEM. Receives logs, parses them, and triggers alerts.
-   **Wazuh Indexer:** A highly scalable search engine (OpenSearch) that stores indexed logs.
-   **TheHive:** A Security Incident Response Platform (SIRP) for case management.
-   **Grafana:** Provides specific security visualizations (EPS, Attack Maps) by querying the Indexer directly.

---

## 3. Project 2: Linux Server Administration & Security
**Location:** `/project_2`

This project is an **all-rounder infrastructure setup** designed to demonstrate core competencies for **IT Support**, **SysAdmin**, and **DevOps** roles. It features a hardened Linux server with automated monitoring and security response.

### 🐧 Server & Network Architecture

```mermaid
graph TD
    subgraph "Host / Hypervisor"
        subgraph "Ubuntu Server 22.04"
            SSH["SSH Service (Port 2222)"]
            Nginx["Nginx Web Server (HTTPS)"]
            UFW["UFW Firewall"]
            F2B["Fail2Ban IPS"]
            
            subgraph "Monitoring & Logging"
                NodeExp["Node Exporter"]
                Prom["Prometheus"]
                Graf["Grafana Dashboard"]
            end
        end
        
        subgraph "Automation & Attack Simulation"
            Ansible["Ansible Control Node"]
            Hydra["Hydra Brute-Force Tool"]
        end
    end

    %% Connections
    Ansible -->|"Configure & Harden"| SSH
    Hydra -->|"Attack (Brute Force)"| SSH
    F2B -->|"Block IP"| UFW
    
    %% Traffic Flow
    User((User)) -->|"HTTPS (443)"| Nginx
    Admin((Admin)) -->|"SSH (2222)"| SSH
    Admin -->|"View Dashboards (3000)"| Graf
    
    %% Internal Monitoring
    NodeExp -->|"Metrics"| Prom
    Prom -->|"Data Source"| Graf
```

### 🔑 Key Components
-   **Hardened SSH:** Custom port (2222), Key-based auth, Root login disabled.
-   **Automated Defense:** Fail2Ban configured to auto-ban IPs after failed login attempts.
-   **Web & Security:** Nginx with self-signed SSL (HTTPS) and security headers.
-   **Monitoring Stack:** Prometheus and Grafana for real-time CPU/RAM/Disk visualization.
-   **Automation:** Bash scripts for health checks/backups and Ansible playbooks for deployment.

