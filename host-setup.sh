#!/bin/bash

# Host System Setup Script for SecureCorp Challenge
# This script sets up the host system with intentional vulnerabilities for privilege escalation

echo "🏗️ Setting up SecureCorp Challenge Host Environment..."

# Ensure we're running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "📦 Installing required packages..."
apt-get update
apt-get install -y docker.io docker-compose git curl wget nmap netcat-openbsd \
    elasticsearch kibana logstash htop iftop tcpdump wireshark-common \
    fail2ban ufw rsyslog auditd

# Enable and start services
systemctl enable docker
systemctl start docker
systemctl enable elasticsearch
systemctl start elasticsearch

echo "🐳 Setting up Docker group permissions..."
usermod -aG docker $SUDO_USER

echo "🔧 Creating vulnerable system configurations..."

# Create a vulnerable SUID binary for privilege escalation
cat > /tmp/host_vuln.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

int main(int argc, char *argv[]) {
    // Vulnerable binary that can be exploited for privilege escalation
    setuid(0);
    setgid(0);
    
    if (argc > 1) {
        // Command injection vulnerability
        char command[512];
        snprintf(command, sizeof(command), "echo 'Checking file: %s'", argv[1]);
        system(command);
    }
    
    return 0;
}
EOF

gcc /tmp/host_vuln.c -o /usr/local/bin/check_file
chmod 4755 /usr/local/bin/check_file
chown root:root /usr/local/bin/check_file

# Create vulnerable cron job
echo "*/5 * * * * root /usr/local/bin/system_cleanup.sh" >> /etc/crontab

# Create vulnerable cleanup script
cat > /usr/local/bin/system_cleanup.sh << 'EOF'
#!/bin/bash

# Vulnerable cleanup script that reads from user-writable directory
CLEANUP_DIR="/tmp/cleanup_tasks"
mkdir -p $CLEANUP_DIR
chmod 777 $CLEANUP_DIR

if [ -f "$CLEANUP_DIR/tasks.txt" ]; then
    while IFS= read -r line; do
        if [[ $line == cleanup:* ]]; then
            cmd="${line#cleanup:}"
            eval "$cmd"  # Command injection vulnerability
        fi
    done < "$CLEANUP_DIR/tasks.txt"
fi

# Default cleanup
find /tmp -name "*.tmp" -mtime +1 -delete 2>/dev/null
EOF

chmod +x /usr/local/bin/system_cleanup.sh

# Create vulnerable systemd service
cat > /etc/systemd/system/monitor-service.service << 'EOF'
[Unit]
Description=System Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/monitor.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

# Create vulnerable monitoring script
cat > /usr/local/bin/monitor.sh << 'EOF'
#!/bin/bash

# Vulnerable monitoring service that processes user input
CONFIG_FILE="/etc/monitor/config.conf"
mkdir -p /etc/monitor
chmod 755 /etc/monitor

# Default config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'CONF'
monitor_interval=60
log_file=/var/log/monitor.log
enable_commands=true
CONF
    chmod 644 "$CONFIG_FILE"
fi

while true; do
    # Read configuration (vulnerable to modification)
    source "$CONFIG_FILE"
    
    if [ "$enable_commands" = "true" ]; then
        # Check for commands in /tmp/monitor_commands (vulnerable)
        if [ -f "/tmp/monitor_commands" ]; then
            while IFS= read -r cmd; do
                if [[ ! -z "$cmd" ]]; then
                    eval "$cmd" >> "$log_file" 2>&1
                fi
            done < "/tmp/monitor_commands"
            rm -f "/tmp/monitor_commands"
        fi
    fi
    
    # Normal monitoring
    echo "$(date): System check - Load: $(uptime | awk '{print $10}')" >> "$log_file"
    
    sleep "$monitor_interval"
done
EOF

chmod +x /usr/local/bin/monitor.sh

echo "🔐 Setting up vulnerable sudo configuration..."

# Add vulnerable sudo rules
cat >> /etc/sudoers << 'EOF'

# Vulnerable sudo rules for challenge
www-data ALL=(root) NOPASSWD: /usr/local/bin/check_file
%docker ALL=(root) NOPASSWD: /usr/bin/docker
backup ALL=(root) NOPASSWD: /usr/local/bin/system_cleanup.sh
EOF

echo "🌐 Setting up network monitoring..."

# Create network monitoring script
cat > /usr/local/bin/netmon.sh << 'EOF'
#!/bin/bash

# Simple network monitoring with logging
LOG_FILE="/var/log/netmon.log"

while true; do
    # Monitor for suspicious network activity
    netstat -tuln | grep LISTEN >> "$LOG_FILE"
    ss -tuln >> "$LOG_FILE"
    
    # Log docker container network activity
    docker ps --format "table {{.Names}}\t{{.Ports}}" >> "$LOG_FILE"
    
    sleep 300  # Check every 5 minutes
done
EOF

chmod +x /usr/local/bin/netmon.sh

echo "📊 Setting up ELK Stack configuration..."

# Configure Elasticsearch
cat > /etc/elasticsearch/elasticsearch.yml << 'EOF'
cluster.name: securecorp
node.name: securecorp-node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
EOF

# Configure Kibana
cat > /etc/kibana/kibana.yml << 'EOF'
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
logging.dest: /var/log/kibana/kibana.log
EOF

echo "🛡️ Setting up basic firewall rules..."

# Configure UFW with some rules (but leave attack vectors open)
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp     # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp    # HTTPS
ufw allow 8080/tcp   # Web app
ufw allow 3306/tcp   # MySQL (vulnerable - should not be exposed)
ufw allow 9200/tcp   # Elasticsearch (vulnerable - should not be exposed)
ufw allow 5601/tcp   # Kibana
ufw --force enable

echo "📝 Creating system users for challenge..."

# Create additional users with various privilege levels
useradd -m -s /bin/bash challenger
echo "challenger:challenge123" | chpasswd
usermod -aG docker challenger

useradd -m -s /bin/bash service_account
echo "service_account:service123" | chpasswd
usermod -aG sudo service_account

useradd -m -s /bin/bash backup
echo "backup:backup123" | chpasswd

echo "🔍 Setting up monitoring and logging..."

# Configure rsyslog to capture more details
cat >> /etc/rsyslog.conf << 'EOF'

# Additional logging for challenge
*.* /var/log/challenge.log
authpriv.* /var/log/auth_challenge.log
EOF

systemctl restart rsyslog

# Configure auditd for system call monitoring
cat > /etc/audit/rules.d/challenge.rules << 'EOF'
# Monitor file access
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes

# Monitor network connections
-a always,exit -F arch=b64 -S socket -F success=1 -k network_connect
-a always,exit -F arch=b32 -S socket -F success=1 -k network_connect

# Monitor process execution
-a always,exit -F arch=b64 -S execve -k process_execution
-a always,exit -F arch=b32 -S execve -k process_execution

# Monitor docker commands
-w /usr/bin/docker -p x -k docker_execution
EOF

systemctl enable auditd
systemctl restart auditd

echo "📂 Creating challenge directories..."

# Create directories for the challenge
mkdir -p /var/challenge/{logs,uploads,backups,scripts}
chmod 755 /var/challenge
chmod 777 /var/challenge/uploads  # Vulnerable permissions
chmod 766 /var/challenge/scripts  # Vulnerable permissions

# Create some interesting files for discovery
echo "Internal network: 172.16.0.0/16" > /var/challenge/network_config.txt
echo "Backup server: backup.internal.securecorp.com" >> /var/challenge/network_config.txt
echo "Admin portal: https://admin.securecorp.internal:8443" >> /var/challenge/network_config.txt

cat > /var/challenge/scripts/internal_backup.sh << 'EOF'
#!/bin/bash
# Internal backup script
# Credentials: backup_user:BackupPass2024!
rsync -av /var/www/html/ backup@backup.internal.securecorp.com:/backups/web/
mysqldump -u backup_user -pBackupPass2024! --all-databases | gzip > /tmp/db_backup_$(date +%Y%m%d).sql.gz
EOF

chmod +x /var/challenge/scripts/internal_backup.sh

echo "✅ Host system setup completed!"
echo ""
echo "🎯 Challenge Environment Ready:"
echo "   - Vulnerable web application will be available on port 8080"
echo "   - MySQL exposed on port 3306 (vulnerable)"
echo "   - Elasticsearch on port 9200 (vulnerable)"
echo "   - Kibana on port 5601"
echo "   - Multiple privilege escalation paths configured"
echo "   - Docker escape vectors prepared"
echo ""
echo "🚀 Next steps:"
echo "   1. Run: docker-compose up -d"
echo "   2. Wait for services to start (2-3 minutes)"
echo "   3. Access http://localhost:8080 to begin"
echo ""
echo "⚠️ WARNING: This system contains intentional vulnerabilities!"
echo "   Only use in isolated lab environments!"

# Enable and start the monitoring service
systemctl enable monitor-service
systemctl start monitor-service

echo "🔧 System monitoring service started"
