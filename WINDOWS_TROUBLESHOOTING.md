# 🔧 Windows Troubleshooting Guide - SecureCorp Challenge

## ❌ Problem: "Forbidden" Error pada http://127.0.0.1:8080

### 🔍 Kemungkinan Penyebab & Solusi

---

## 1. 🐳 Docker/Docker Compose Issues

### Check Docker Installation
```powershell
# Check Docker
docker --version
docker info

# Check Docker Compose
docker-compose --version
# ATAU jika menggunakan Docker Desktop yang lebih baru:
docker compose version
```

**Jika Docker tidak terinstall:**
1. Download Docker Desktop for Windows dari https://docker.com
2. Install dengan mengikuti panduan
3. Restart komputer
4. Buka Docker Desktop dan tunggu sampai status "Running"

---

## 2. 🚀 Container Status Issues

### Check Running Containers
```powershell
# Lihat container yang running
docker ps

# Lihat semua container (termasuk yang stopped)
docker ps -a

# Check logs jika container ada masalah
docker logs securecorp_portal
docker logs securecorp_db
```

### Start Challenge (Windows)
```powershell
# Jika menggunakan Docker Desktop (recommended)
docker compose up -d

# Atau jika docker-compose terinstall terpisah
docker-compose up -d
```

---

## 3. 🌐 Port & Network Issues

### Check Port Binding
```powershell
# Check apakah port 8080 digunakan process lain
netstat -ano | findstr :8080

# Jika ada conflict, kill process yang menggunakan port
taskkill /PID <PID_NUMBER> /F
```

### Alternative Port Testing
```powershell
# Test dengan curl (jika tersedia)
curl http://localhost:8080
curl http://127.0.0.1:8080

# Atau dengan PowerShell
Invoke-WebRequest -Uri http://localhost:8080
```

---

## 4. 🔧 Apache Configuration Issues

### Check Container Logs
```powershell
# Lihat logs dari web container
docker logs securecorp_portal

# Follow logs secara real-time
docker logs -f securecorp_portal
```

**Common Issues dalam Logs:**
- Permission denied errors
- PHP-FPM not running
- Database connection errors
- File not found errors

---

## 5. 🛠️ Quick Fix Solutions

### Solution 1: Complete Restart
```powershell
# Stop semua containers
docker compose down
# ATAU
docker-compose down

# Remove containers dan volumes
docker compose down -v

# Rebuild dan start ulang
docker compose up -d --build
```

### Solution 2: Check File Permissions
```powershell
# Masuk ke container untuk debug
docker exec -it securecorp_portal bash

# Dalam container, check file permissions
ls -la /var/www/html/
cat /var/log/apache2/error.log
```

### Solution 3: Manual Container Creation
```powershell
# Jika docker-compose bermasalah, coba manual
docker run -d --name test-apache -p 8080:80 php:7.4-apache

# Test akses
curl http://localhost:8080
```

---

## 6. 🐛 Common Windows-Specific Issues

### WSL2 Issues
Jika menggunakan WSL2 backend:
```powershell
# Restart WSL2
wsl --shutdown
# Kemudian restart Docker Desktop
```

### Windows Defender/Antivirus
- Whitelist folder challenge
- Whitelist Docker executable
- Temporarily disable real-time protection

### Hyper-V Issues
```powershell
# Check Hyper-V status (Run as Administrator)
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Enable jika perlu
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

---

## 7. 🔍 Debug Steps

### Step 1: Basic Connectivity Test
```powershell
# Test dengan telnet
telnet localhost 8080

# Atau dengan PowerShell
Test-NetConnection -ComputerName localhost -Port 8080
```

### Step 2: Container Investigation
```powershell
# Inspect container
docker inspect securecorp_portal

# Check container processes
docker exec securecorp_portal ps aux

# Check Apache status
docker exec securecorp_portal service apache2 status
```

### Step 3: File System Check
```powershell
# Check jika files ada dalam container
docker exec securecorp_portal ls -la /var/www/html/

# Check Apache config
docker exec securecorp_portal cat /etc/apache2/sites-available/000-default.conf
```

---

## 8. 🚨 Emergency Manual Setup

Jika semua gagal, setup manual:

### Manual PHP Server
```powershell
# Copy files ke direktori lokal
cd webapp/src

# Start PHP built-in server
php -S localhost:8080

# Access via http://localhost:8080
```

### Manual Apache dengan XAMPP
1. Install XAMPP for Windows
2. Copy `webapp/src/*` ke `C:\xampp\htdocs\securecorp\`
3. Start Apache di XAMPP Control Panel
4. Access via `http://localhost/securecorp/`

---

## 9. 📋 Checklist Troubleshooting

- [ ] Docker Desktop installed dan running
- [ ] No other process using port 8080
- [ ] Files copied correctly ke container
- [ ] Apache service running dalam container
- [ ] No firewall blocking port 8080
- [ ] Container has correct file permissions
- [ ] Database container running (untuk full functionality)

---

## 10. 🆘 Alternative Testing

### Test Individual Components
```powershell
# Test hanya database
docker run -d --name test-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=test123 mysql:5.7

# Test hanya web server
docker run -d --name test-web -p 8080:80 -v ${PWD}/webapp/src:/var/www/html php:7.4-apache
```

### Simple HTML Test
Buat file `test.html` di `webapp/src/`:
```html
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><h1>It Works!</h1></body>
</html>
```

Akses: `http://localhost:8080/test.html`

---

## 📞 Getting Help

Jika masih bermasalah, collect informasi ini:

```powershell
# System info
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# Docker info
docker version
docker info

# Port info
netstat -ano | findstr :8080

# Container logs
docker logs securecorp_portal > container_logs.txt
```

**Quick Commands untuk Screenshot/Info:**
```powershell
docker ps
docker logs securecorp_portal --tail 50
curl -I http://localhost:8080 2>&1
```

---

**🎯 Next Steps**: Setelah identify issue, refer ke specific solution di atas atau hubungi support dengan log information yang sudah dikumpulkan.
