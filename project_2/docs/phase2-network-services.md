# Phase 2: Network Services & Monitoring

> **Goal:** Install and configure Nginx with HTTPS, set up DNS resolution, and master network diagnostic tools for service troubleshooting.

## 🎯 What This Phase Proves

| Role | Skill Demonstrated |
|---|---|
| IT Support | Port troubleshooting, service diagnostics, connectivity testing |
| SysAdmin | Web server deployment, SSL certificates, DNS configuration |
| DevOps | Service deployment, reverse proxy, production-level configuration |

---

## Step 1: Nginx Installation & Configuration

### 1.1 Install Nginx

```bash
# Install Nginx
sudo apt install -y nginx

# Start and enable
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify
sudo systemctl status nginx
curl http://localhost
```

### 1.2 Create a Virtual Host

```bash
# Create site directory
sudo mkdir -p /var/www/lab-site
sudo chown -R www-data:www-data /var/www/lab-site

# Create a sample page
sudo tee /var/www/lab-site/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Lab Server</title></head>
<body>
    <h1>🔒 SOC Lab Server</h1>
    <p>Server is running. Nginx + HTTPS deployed successfully.</p>
    <p>Hostname: <strong>lab-server</strong></p>
</body>
</html>
EOF
```

### 1.3 Configure Virtual Host

```bash
sudo tee /etc/nginx/sites-available/lab-site > /dev/null <<'EOF'
server {
    listen 80;
    server_name lab-server lab-server.local;

    root /var/www/lab-site;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/lab-site /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 2: HTTPS with Self-Signed SSL Certificate

### 2.1 Generate Self-Signed Certificate

```bash
# Create SSL directory
sudo mkdir -p /etc/nginx/ssl

# Generate certificate (valid for 365 days)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/lab-server.key \
    -out /etc/nginx/ssl/lab-server.crt \
    -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=SOCLab/CN=lab-server.local"

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/lab-server.key
sudo chmod 644 /etc/nginx/ssl/lab-server.crt
```

### 2.2 Update Nginx for HTTPS

```bash
sudo tee /etc/nginx/sites-available/lab-site > /dev/null <<'EOF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name lab-server lab-server.local;
    return 301 https://$host$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl;
    server_name lab-server lab-server.local;

    ssl_certificate /etc/nginx/ssl/lab-server.crt;
    ssl_certificate_key /etc/nginx/ssl/lab-server.key;

    # SSL hardening
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /var/www/lab-site;
    index index.html;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Test and reload
sudo nginx -t
sudo systemctl reload nginx

# Verify HTTPS
curl -k https://localhost
```

---

## Step 3: DNS / Host Resolution

```bash
# On the Ubuntu server - set hostname
sudo hostnamectl set-hostname lab-server

# Edit /etc/hosts for local resolution
sudo tee -a /etc/hosts > /dev/null <<'EOF'
192.168.1.100   lab-server lab-server.local
EOF

# On your HOST machine (Windows) — edit C:\Windows\System32\drivers\etc\hosts:
# Add: <server-ip>   lab-server lab-server.local

# Verify
ping lab-server.local
nslookup lab-server.local    # Will work if DNS is configured
```

---

## Step 4: Network Monitoring & Diagnostics

### 4.1 Port Monitoring

```bash
# View all listening ports with process info
sudo ss -tlnp

# Expected output:
# State    Recv-Q   Send-Q   Local Address:Port   Peer Address:Port   Process
# LISTEN   0        511      0.0.0.0:80           0.0.0.0:*           users:(("nginx",pid=...))
# LISTEN   0        511      0.0.0.0:443          0.0.0.0:*           users:(("nginx",pid=...))
# LISTEN   0        128      0.0.0.0:2222         0.0.0.0:*           users:(("sshd",pid=...))

# Alternative: using netstat
sudo netstat -tlnp

# Check specific port
sudo ss -tlnp | grep ':443'
```

### 4.2 Service Management

```bash
# List all active services
systemctl list-units --type=service --state=running

# Check specific service
systemctl status nginx
systemctl status sshd

# View recent logs for a service
journalctl -u nginx --since "1 hour ago"
journalctl -u sshd -n 50 --no-pager

# Check failed services (troubleshooting)
systemctl --failed
```

### 4.3 Self-Audit with Nmap

```bash
# Install nmap (on the server itself or attacker VM)
sudo apt install -y nmap

# Scan your own server (from host or another VM)
nmap -sV -p 1-10000 <server-ip>

# Expected output:
# PORT     STATE  SERVICE  VERSION
# 80/tcp   open   http     nginx 1.x.x
# 443/tcp  open   ssl/http nginx 1.x.x
# 2222/tcp open   ssh      OpenSSH 8.x
# 9100/tcp open   http     Prometheus node_exporter  (after Phase 5)
```

### 4.4 Connectivity Troubleshooting

```bash
# Test HTTP/HTTPS connectivity
curl -I http://lab-server.local
curl -Ik https://lab-server.local

# Test specific port connectivity
nc -zv lab-server.local 2222   # SSH
nc -zv lab-server.local 443    # HTTPS

# Trace route (network path)
traceroute lab-server.local

# DNS resolution
dig lab-server.local
host lab-server.local
```

---

## Step 5: Common Troubleshooting Scenarios

### Scenario 1: Port Conflict (Apache vs Nginx)

```bash
# Problem: Nginx fails to start — "Address already in use"
# Diagnose:
sudo ss -tlnp | grep ':80'
# If apache2 is using port 80:
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo systemctl start nginx
```

### Scenario 2: SSL Certificate Errors

```bash
# Check certificate details
openssl x509 -in /etc/nginx/ssl/lab-server.crt -text -noout

# Check certificate expiry
openssl x509 -in /etc/nginx/ssl/lab-server.crt -enddate -noout

# Test SSL handshake
openssl s_client -connect lab-server.local:443
```

### Scenario 3: Nginx Config Syntax Error

```bash
# Always test before reloading
sudo nginx -t
# nginx: [emerg] unknown directive "servr_name" in /etc/nginx/sites-enabled/lab-site:3
# Fix the typo, then:
sudo nginx -t && sudo systemctl reload nginx
```

---

## ✅ Phase 2 Checklist

- [ ] Nginx installed and running
- [ ] Virtual host configured with security headers
- [ ] Self-signed SSL certificate generated
- [ ] HTTPS configured with HTTP→HTTPS redirect
- [ ] DNS / hosts file configured for local resolution
- [ ] Port monitoring mastered (`ss`, `netstat`)
- [ ] Service management practiced (`systemctl`, `journalctl`)
- [ ] Self-audit with `nmap` completed
- [ ] All 3 troubleshooting scenarios practiced

---

## 🔗 Next Phase
→ [Phase 3: Security Incident Simulation](phase3-security-incident-sim.md)
