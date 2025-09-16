# 🎯 SecureCorp Challenge Guide
## Attack & Defense Lab - Corporate Breach

### 📋 Overview
Selamat datang di SecureCorp Challenge! Ini adalah lab Attack & Defense yang dirancang khusus untuk training anak magang. Challenge ini mensimulasikan serangan real-world terhadap sistem perusahaan dengan multiple attack vectors dan defensive opportunities.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                HOST SYSTEM (Ubuntu)                 │
│  ┌─────────────────────────────────────────────────┐│
│  │              DOCKER CONTAINERS                  ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐││
│  │  │   Web App   │ │   MySQL     │ │   ELK       │││
│  │  │   (PHP)     │ │   Database  │ │   Stack     │││
│  │  │   Port 8080 │ │   Port 3306 │ │   Ports     │││
│  │  │             │ │             │ │   9200,5601 │││
│  │  └─────────────┘ └─────────────┘ └─────────────┘││
│  └─────────────────────────────────────────────────┘│
│                                                     │
│  Vulnerable Host Services:                          │
│  • SSH (Port 22)                                    │
│  • Vulnerable SUID binaries                        │
│  • Weak cron jobs                                   │
│  • Misconfigured services                          │
└─────────────────────────────────────────────────────┘
```

---

## 🎮 Tim & Roles

### 🔴 Tim Red (Offense) - 3 Orang
**Objektif**: Penetrasi sistem dari awal hingga mendapat root access

**Pembagian Role**:
1. **Web Application Tester** - Focus pada vulnerability web app
2. **System Penetrator** - Focus pada container escape dan privilege escalation  
3. **Network Analyst** - Focus pada network reconnaissance dan lateral movement

### 🔵 Tim Blue (Defense) - 3 Orang
**Objektif**: Detect, analyze, dan mitigate serangan

**Pembagian Role**:
1. **SOC Analyst** - Monitor logs dan detect anomalies
2. **Incident Responder** - Response terhadap detected threats
3. **Forensics Specialist** - Analyze attack patterns dan create mitigations

---

## 🛤️ Attack Path & Scoring

### Phase 1: Initial Reconnaissance (15 points)
- **Target**: Web application discovery
- **Red Team Tasks**:
  - Port scanning
  - Web application enumeration
  - Directory/file discovery
- **Blue Team Tasks**:
  - Setup monitoring
  - Baseline normal traffic
  - Configure alerting

### Phase 2: Web Application Exploitation (25 points)
- **Target**: Gain initial access via web vulnerabilities
- **Red Team Tasks**:
  - SQL Injection exploitation
  - Authentication bypass
  - File upload vulnerabilities
  - XSS/Command injection
- **Blue Team Tasks**:
  - Web application firewall setup
  - Log analysis untuk detect attacks
  - Block malicious IPs

### Phase 3: Remote Code Execution (20 points)
- **Target**: Execute commands pada server
- **Red Team Tasks**:
  - Command injection exploitation
  - File upload untuk web shell
  - Reverse shell establishment
- **Blue Team Tasks**:
  - Process monitoring
  - Network connection monitoring
  - Incident response procedures

### Phase 4: Container Escape (25 points)
- **Target**: Escape dari Docker container
- **Red Team Tasks**:
  - Docker socket exploitation
  - Privileged container abuse
  - Host filesystem access
- **Blue Team Tasks**:
  - Container security monitoring
  - Host-level defensive measures
  - Container isolation verification

### Phase 5: Privilege Escalation (30 points)
- **Target**: Escalate ke root privileges
- **Red Team Tasks**:
  - SUID binary exploitation
  - Cron job manipulation
  - Service exploitation
- **Blue Team Tasks**:
  - Privilege monitoring
  - System hardening
  - Access control verification

### Phase 6: Persistence & Lateral Movement (25 points)
- **Target**: Maintain access dan explore network
- **Red Team Tasks**:
  - Backdoor installation
  - Credential harvesting
  - Network scanning
- **Blue Team Tasks**:
  - Persistence detection
  - Network segmentation
  - Credential monitoring

**Total Points**: 140 points

---

## 🚀 Quick Start Guide

### Prerequisites
- Ubuntu 20.04+ server
- Docker & Docker Compose installed
- Minimum 4GB RAM, 20GB disk space
- Root access untuk setup

### 1. Setup Host Environment
```bash
# Clone challenge repository
cd /opt
git clone <repository-url> securecorp-challenge
cd securecorp-challenge

# Make setup script executable
chmod +x host-setup.sh

# Run host setup (as root)
sudo ./host-setup.sh
```

### 2. Start Challenge Environment
```bash
# Start all services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs if needed
docker-compose logs
```

### 3. Access Challenge
- **Web Application**: http://localhost:8080
- **Kibana Dashboard**: http://localhost:5601
- **MySQL Database**: localhost:3306
- **Elasticsearch**: http://localhost:9200

---

## 🔍 Built-in Vulnerabilities

### Web Application
1. **SQL Injection** - Login bypass dan data extraction
2. **Command Injection** - Network tools page
3. **File Upload** - Unrestricted file upload
4. **XSS** - Stored dan reflected XSS
5. **Local File Inclusion** - Directory traversal
6. **Information Disclosure** - Debug page dengan sensitive info
7. **Authentication Bypass** - Weak session management

### Container Level
1. **Privileged Container** - Docker escape possibilities
2. **Docker Socket Mount** - Host Docker access
3. **Weak File Permissions** - World-writable directories
4. **SUID Binaries** - Custom vulnerable binaries

### Host Level
1. **Vulnerable Cron Jobs** - Command injection via user-writable files
2. **SUID Binaries** - Custom binaries dengan command injection
3. **Weak sudo Rules** - Dangerous sudo permissions
4. **Service Misconfigurations** - Vulnerable systemd services
5. **Network Exposure** - Services exposed yang seharusnya internal

---

## 🛡️ Defense Strategies

### Monitoring Points
1. **Web Access Logs** - `/var/log/apache2/access.log`
2. **System Audit Logs** - `/var/log/audit/audit.log`
3. **Container Logs** - `docker logs <container>`
4. **Network Connections** - `netstat`, `ss`, `tcpdump`
5. **Process Monitoring** - `ps`, `htop`, `pstree`

### Key Indicators of Compromise
- Unusual HTTP requests (SQL injection patterns)
- High number of 404 errors (directory enumeration)
- Unexpected file uploads
- New processes running as www-data
- Docker commands execution
- Network connections to external IPs
- New files in `/tmp` directory
- Changes to system files

### Defensive Actions
1. **Block malicious IPs** using `ufw` atau `iptables`
2. **Disable vulnerable services** temporarily
3. **Patch vulnerabilities** yang ditemukan
4. **Monitor file integrity** untuk detect changes
5. **Kill malicious processes** 
6. **Isolate containers** yang compromised

---

## 📊 Monitoring & Logging

### ELK Stack Setup
Kibana dashboard sudah pre-configured untuk monitoring:
- Web access patterns
- System events
- Docker container activities
- Network connections

### Key Log Files
```bash
# Application logs
/var/log/apache2/access.log
/var/log/apache2/error.log

# System logs  
/var/log/syslog
/var/log/auth.log
/var/log/audit/audit.log

# Challenge-specific logs
/var/log/challenge.log
/var/log/netmon.log
/var/log/backup.log

# Container logs
docker logs securecorp_portal
docker logs securecorp_db
```

---

## 🎯 Hints & Tips

### For Red Team
1. Start dengan basic reconnaissance (nmap, dirb/gobuster)
2. Check debug pages untuk information disclosure
3. Test semua input fields untuk injection
4. Look for file upload vulnerabilities
5. Analyze container environment untuk escape paths
6. Check cron jobs dan services untuk privilege escalation

### For Blue Team
1. Setup comprehensive logging dari awal
2. Create baseline normal traffic patterns
3. Monitor file system changes
4. Watch process executions
5. Track network connections
6. Analyze log patterns untuk anomalies

---

## 🔧 Troubleshooting

### Common Issues

**Services not starting**:
```bash
# Check service status
docker-compose ps
docker-compose logs

# Restart services
docker-compose restart
```

**Database connection errors**:
```bash
# Check MySQL container
docker logs securecorp_db

# Reset database
docker-compose down
docker volume rm securecorp_db_data
docker-compose up -d
```

**Elasticsearch not accessible**:
```bash
# Check Elasticsearch status
curl http://localhost:9200

# Restart Elasticsearch
sudo systemctl restart elasticsearch
```

**Permission issues**:
```bash
# Fix permissions
sudo chown -R www-data:www-data webapp/src/
sudo chmod -R 755 webapp/src/
```

---

## ⚠️ Security Warnings

**PENTING**: Challenge ini mengandung vulnerabilities yang sengaja dibuat!

1. **Jangan deploy di production environment**
2. **Gunakan only di isolated lab network**
3. **Matikan firewall external access**
4. **Hapus environment setelah challenge selesai**
5. **Jangan gunakan credentials ini di sistem real**

---

## 🏆 Success Criteria

### Red Team Success
- [ ] Successfully login ke web application
- [ ] Execute remote commands
- [ ] Upload dan execute web shell
- [ ] Escape Docker container
- [ ] Gain root access pada host
- [ ] Establish persistence
- [ ] Document attack path

### Blue Team Success  
- [ ] Detect initial reconnaissance
- [ ] Identify SQL injection attempts
- [ ] Block command injection attacks
- [ ] Detect container escape attempts
- [ ] Prevent privilege escalation
- [ ] Maintain system availability
- [ ] Create incident response report

---

## 📚 Additional Resources

### Tools Recommendations
**Offensive**:
- nmap, masscan
- gobuster, dirb, ffuf
- sqlmap
- burp suite, OWASP ZAP
- metasploit
- docker escape tools

**Defensive**:
- fail2ban
- OSSEC/Wazuh
- Suricata/Snort
- tripwire
- rkhunter, chkrootkit
- auditd analysis tools

### Learning Resources
- OWASP Top 10
- Docker Security Best Practices
- Linux Privilege Escalation Techniques
- Incident Response Playbooks

---

**Happy Hacking & Defending! 🎉**

*Remember: Tujuan challenge ini adalah learning. Komunikasi antar tim dianjurkan untuk shared learning experience.*
