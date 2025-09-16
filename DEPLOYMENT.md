# 🚀 SecureCorp Challenge Deployment Guide

## Deployment untuk Environment Lab

### 📋 System Requirements

**Minimum Requirements:**
- Ubuntu 20.04 LTS atau lebih baru
- 4GB RAM (8GB recommended)
- 20GB free disk space
- Root atau sudo access
- Internet connection untuk download dependencies

**Recommended Setup:**
- Ubuntu 22.04 LTS
- 8GB RAM
- 50GB disk space
- Dedicated lab network/VLAN
- No external internet access (optional for isolation)

---

## 🔧 Step-by-Step Deployment

### 1. Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install git (if not already installed)
sudo apt install -y git

# Create deployment directory
sudo mkdir -p /opt/labs
cd /opt/labs

# Clone atau copy challenge files
# (Replace with actual repository or copy files manually)
git clone <repository-url> securecorp-challenge
# OR copy challenge files to: /opt/labs/securecorp-challenge

cd securecorp-challenge
```

### 2. Host System Setup
```bash
# Make setup script executable
chmod +x host-setup.sh

# Run host environment setup (will install Docker, etc.)
sudo ./host-setup.sh

# Note: Script will prompt for confirmation during installation
# This process takes 5-10 minutes depending on internet speed
```

### 3. Start Challenge Environment
```bash
# Make startup script executable
chmod +x start-challenge.sh

# Start the challenge
./start-challenge.sh

# Wait for all services to initialize (2-3 minutes)
```

### 4. Verification
```bash
# Check status
./check-status.sh

# Manual verification
docker-compose ps
curl http://localhost:8080
curl http://localhost:9200
```

---

## 🌐 Network Configuration

### Default Port Mapping
```
Host System:
├── 22    (SSH)
├── 80    (Optional: Redirect to 8080)
├── 443   (Optional: SSL redirect)
├── 3306  (MySQL - Vulnerable exposure)
├── 5601  (Kibana Dashboard)
├── 8080  (Web Application)
└── 9200  (Elasticsearch - Vulnerable exposure)
```

### Firewall Rules (UFW)
```bash
# View current rules
sudo ufw status

# Adjust as needed for your network
# Example: Allow from specific lab network only
sudo ufw allow from 192.168.100.0/24 to any port 8080
sudo ufw allow from 192.168.100.0/24 to any port 5601

# Block external access to vulnerable services
sudo ufw deny 3306
sudo ufw deny 9200
```

---

## 👥 Multi-Team Setup

### For Multiple Teams (Recommended)
Deploy multiple instances dengan port offsets:

**Team 1**: Default ports (8080, 5601, 9200, 3306)
**Team 2**: Offset +10 (8090, 5611, 9210, 3316)
**Team 3**: Offset +20 (8100, 5621, 9220, 3326)

```bash
# Team 2 deployment
cd /opt/labs
cp -r securecorp-challenge team2-challenge
cd team2-challenge

# Edit docker-compose.yml to change ports
sed -i 's/8080:80/8090:80/g' docker-compose.yml
sed -i 's/5601:5601/5611:5601/g' docker-compose.yml
sed -i 's/9200:9200/9210:9200/g' docker-compose.yml
sed -i 's/3306:3306/3316:3306/g' docker-compose.yml

# Start team 2 environment
./start-challenge.sh
```

---

## 🔐 Security Considerations

### Isolation
```bash
# Create dedicated lab network (optional)
sudo docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  securecorp-lab

# Update docker-compose.yml to use custom network
```

### Access Control
```bash
# Restrict SSH access
sudo ufw limit ssh

# Create lab users
sudo useradd -m -s /bin/bash red-team
sudo useradd -m -s /bin/bash blue-team
echo "red-team:RedTeam2024!" | sudo chpasswd
echo "blue-team:BlueTeam2024!" | sudo chpasswd

# Grant Docker access
sudo usermod -aG docker red-team
sudo usermod -aG docker blue-team
```

### Monitoring
```bash
# Enable additional logging
sudo journalctl -f &  # System logs
sudo docker-compose logs -f &  # Container logs
sudo tcpdump -i any port 8080 &  # Network monitoring
```

---

## 🔧 Troubleshooting

### Common Issues

**1. Docker Permission Denied**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again, or use:
newgrp docker
```

**2. Port Already in Use**
```bash
# Find process using port
sudo netstat -tulpn | grep :8080
sudo lsof -i :8080

# Kill process if safe
sudo kill -9 <PID>
```

**3. Services Not Starting**
```bash
# Check Docker daemon
sudo systemctl status docker
sudo systemctl restart docker

# Check container logs
docker-compose logs securecorp_portal
docker-compose logs securecorp_db

# Restart specific service
docker-compose restart securecorp_portal
```

**4. Database Connection Issues**
```bash
# Reset database
docker-compose down -v
docker volume rm securecorp_db_data 2>/dev/null
docker-compose up -d

# Check database logs
docker logs securecorp_db
```

**5. Memory Issues**
```bash
# Check memory usage
free -h
docker stats

# Adjust Elasticsearch memory
# Edit docker-compose.yml:
# ES_JAVA_OPTS: "-Xms256m -Xmx256m"  # Reduce if needed
```

---

## 📊 Performance Tuning

### For Better Performance
```bash
# Increase Docker memory limits
sudo systemctl edit docker
# Add:
# [Service]
# LimitMEMLOCK=infinity

# Optimize system limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Disable swap if possible
sudo swapoff -a
```

### Resource Monitoring
```bash
# Monitor resource usage
htop
docker stats
df -h
```

---

## 🧹 Cleanup After Challenge

### Complete Cleanup
```bash
# Stop and remove containers
docker-compose down -v

# Remove images
docker rmi $(docker images securecorp* -q) 2>/dev/null

# Remove volumes
docker volume prune -f

# Clean system
docker system prune -af

# Remove host configurations (optional)
sudo systemctl disable monitor-service
sudo rm -f /etc/systemd/system/monitor-service.service
sudo rm -f /usr/local/bin/check_file
sudo rm -f /usr/local/bin/docker_helper
sudo rm -rf /var/challenge
```

### Reset for Next Challenge
```bash
# Quick reset (keeps images)
docker-compose down -v
docker-compose up -d

# Full reset (rebuilds everything)
docker-compose down -v
docker system prune -f
docker-compose up -d --build
```

---

## 📝 Deployment Checklist

- [ ] Ubuntu system updated and prepared
- [ ] Host setup script executed successfully
- [ ] Docker and Docker Compose installed
- [ ] All containers started and healthy
- [ ] Web application accessible (port 8080)
- [ ] Database connection working
- [ ] Kibana dashboard accessible (port 5601)
- [ ] Firewall rules configured appropriately
- [ ] Team access credentials created
- [ ] Monitoring systems active
- [ ] Challenge documentation distributed
- [ ] Backup/recovery plan prepared

---

## 🆘 Support

### Log Locations
- **Container Logs**: `docker-compose logs <service>`
- **System Logs**: `/var/log/syslog`
- **Challenge Logs**: `/var/log/challenge.log`
- **Audit Logs**: `/var/log/audit/audit.log`

### Emergency Commands
```bash
# Stop everything immediately
docker-compose down

# System emergency stop
sudo systemctl stop docker

# Network emergency isolation
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw --force enable
```

### Contact & Escalation
- Check CHALLENGE_GUIDE.md untuk detailed troubleshooting
- Review container logs untuk specific error messages
- Ensure system meets minimum requirements
- Consider increasing system resources if performance issues

---

**Deployment completed! Ready untuk SecureCorp Challenge! 🎯**
