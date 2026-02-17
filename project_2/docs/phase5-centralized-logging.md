# Phase 5: Centralized Logging & Dashboards

> **Goal:** Set up a monitoring stack using Prometheus and Grafana to visualize server performance and centralize logs.
>
> **Note:** Optimized for **Low RAM** environments. We will install Prometheus and Grafana directly on the Ubuntu Server (or a lightweight second VM if you have >8GB RAM).

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Identifying resource bottlenecks (CPU/RAM spikes) |
| SysAdmin | Configuring centralized logging (Rsyslog) |
| DevOps | Setting up observability stacks (Prometheus + Grafana) |

---

## Step 1: Install Prometheus Node Exporter
The "Agent" that collects metrics from the server.

```bash
# Download Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# Extract and move binary
tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

Verify metrics are available:
```bash
curl http://localhost:9100/metrics | head
```

---

## Step 2: Install Prometheus Server

```bash
# Update repo and install
sudo apt install -y prometheus

# Verify running
sudo systemctl status prometheus
```

### Configure Prometheus to Scrape Node Exporter
Edit `/etc/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

Restart Prometheus:
```bash
sudo systemctl restart prometheus
```

---

## Step 3: Install Grafana (Visualization)

```bash
# Install dependencies
sudo apt-get install -y apt-transport-https software-properties-common wget

# Add Grafana GPG key
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add repo
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install and start
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

---

## Step 4: Setup Dashboards

1. **Access Grafana:** Open `http://<server-ip>:3000` in your browser.
2. **Login:** Default is `admin` / `admin`.
3. **Add Data Source:**
   - Type: Prometheus
   - URL: `http://localhost:9090`
   - Click "Save & Test".
4. **Import Dashboard:**
   - Click "+" -> "Import".
   - Using ID: `1860` (Node Exporter Full).
   - Select your Prometheus data source.
   - Click "Import".

**Result:** You now have a professional dashboard showing CPU, RAM, Disk IO, and Network Traffic.

---

## Step 5: Centralized Logging (Rsyslog)
In a real environment, you'd send logs to a dedicated server. Here, we'll configure Rsyslog to prepare for that.

### 5.1 Enable TCP/UDP Reception
Uncomment these lines in `/etc/rsyslog.conf`:
```ini
module(load="imudp")
input(type="imudp" port="514")

module(load="imtcp")
input(type="imtcp" port="514")
```

Restart:
```bash
sudo systemctl restart rsyslog
```

---

## ✅ Phase 5 Checklist

- [ ] Node Exporter installed and running (Port 9100)
- [ ] Prometheus installed and scraping Node Exporter (Port 9090)
- [ ] Grafana installed and accessible (Port 3000)
- [ ] Prometheus data source added to Grafana
- [ ] Node Exporter dashboard (ID 1860) imported
- [ ] Rsyslog configured to accept remote logs (Simulated)
- [ ] Visualized CPU/RAM usage in Grafana

---

## 🔗 Next Phase
→ [Phase 6: Documentation & Reports](phase6-documentation-reports.md)
