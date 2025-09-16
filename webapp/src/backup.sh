#!/bin/bash

# Vulnerable backup script for privilege escalation
# This script is run by cron as root

# Create backup directory
BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup web files (vulnerable - allows arbitrary file inclusion)
echo "Starting backup at $(date)"

# Read backup configuration from user-writable file (vulnerability)
CONFIG_FILE="/var/www/html/backup_config.txt"

if [ -f "$CONFIG_FILE" ]; then
    echo "Reading backup configuration from $CONFIG_FILE"
    
    # Vulnerable: Executing commands from user-controlled file
    while IFS= read -r line; do
        if [[ $line == backup_cmd:* ]]; then
            cmd="${line#backup_cmd:}"
            echo "Executing: $cmd"
            eval "$cmd"  # Command injection vulnerability
        fi
    done < "$CONFIG_FILE"
else
    # Default backup commands
    echo "No config file found, using default backup"
    tar -czf "$BACKUP_DIR/webapp_$DATE.tar.gz" /var/www/html/
    mysqldump -u root -pr00tp@ss123 securecorp > "$BACKUP_DIR/database_$DATE.sql"
fi

# Set permissive permissions (vulnerability)
chmod 777 "$BACKUP_DIR"
chmod 666 "$BACKUP_DIR"/*

echo "Backup completed at $(date)"

# Log backup status
echo "$(date): Backup completed - $BACKUP_DIR" >> /var/log/backup.log
chmod 666 /var/log/backup.log
