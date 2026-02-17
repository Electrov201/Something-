#!/bin/bash
# Backup Script for Project 2

BACKUP_DIR="/var/backups/lab-backup"
DATE=$(date +%Y-%m-%d_%H-%M)
FILENAME="backup-$DATE.tar.gz"

# Create backup dir if it doesn't exist
mkdir -p $BACKUP_DIR

echo "[*] Starting backup optimized for Lab Project..."

# Backup Nginx, SSH config, and Web Root
# Utilizing sudo to ensure we have permission to read these files
tar -czf $BACKUP_DIR/$FILENAME \
    /etc/nginx \
    /var/www/lab-site \
    /etc/ssh/sshd_config \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo "[+] Backup successful: $BACKUP_DIR/$FILENAME"
    ls -lh $BACKUP_DIR/$FILENAME
else
    echo "[-] Backup failed!"
fi

# Retention Policy: Keep only last 5 backups
find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -delete
echo "[*] Old backups cleaned up."
