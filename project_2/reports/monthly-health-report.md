# Monthly Server Health Report

**Period:** February 2024
**Server:** lab-server (Ubuntu 22.04 LTS)
**Uptime:** 15 days, 4 hours

## 1. Resource Utilization Protocol
| Resource | Average Usage | Peak Usage | Status |
|---|---|---|---|
| **CPU** | 5% | 45% | ✅ Healthy |
| **RAM** | 1.2 GB / 2.0 GB | 1.8 GB | ⚠️ Warning (Near Capacity) |
| **Disk** | 45% (9 GB / 20 GB) | 45% | ✅ Healthy |

## 2. Security Audit
- **Open Ports:** 2222 (SSH), 80 (HTTP), 443 (HTTPS), 9100 (Metrics)
- **Failed Login Attempts:** 1,245 (Blocked by Fail2Ban)
- **Root Login:** Disabled
- **Patch Status:** All critical security patches applied as of Feb 15.

## 3. Maintenance Activities executed
- [x] Weekly backup of `/etc` and `/var/www` completed successfully.
- [x] Log rotation verified; disk space reclaimed from old logs.
- [x] SSL Certificate verified (Expires in 340 days).

## 4. Recommendations
- **RAM Upgrade:** Memory usage is consistently above 60%. Recommend increasing VM RAM to 4GB if managing more monitoring tools.
- **Off-site Backup:** Currently backups are local. Recommended to rsync backups to designated backup server.
