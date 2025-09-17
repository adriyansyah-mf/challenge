#!/bin/bash


BACKUP_DIR="/tmp/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "Starting backup at $(date)"

CONFIG_FILE="/var/www/html/backup_config.txt"

if [ -f "$CONFIG_FILE" ]; then
    echo "Reading backup configuration from $CONFIG_FILE"
    
    while IFS= read -r line; do
        if [[ $line == backup_cmd:* ]]; then
            cmd="${line#backup_cmd:}"
            echo "Executing: $cmd"
            eval "$cmd"
        fi
    done < "$CONFIG_FILE"
else
    echo "No config file found, using default backup"
    tar -czf "$BACKUP_DIR/webapp_$DATE.tar.gz" /var/www/html/
    mysqldump -u root -pr00tp@ss123 securecorp > "$BACKUP_DIR/database_$DATE.sql"
fi

chmod 777 "$BACKUP_DIR"
chmod 666 "$BACKUP_DIR"/*

echo "Backup completed at $(date)"

echo "$(date): Backup completed - $BACKUP_DIR" >> /var/log/backup.log
chmod 666 /var/log/backup.log
