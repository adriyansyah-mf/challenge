# Challenge: Corporate Breach
## Attack & Defense Lab untuk Magang

### Skenario
**SecureCorp** adalah perusahaan teknologi yang baru saja meluncurkan portal karyawan internal. Tim Red (Offense) bertugas sebagai penetration tester yang diminta untuk menguji keamanan sistem. Tim Blue (Defense) bertugas sebagai SOC analyst yang harus mempertahankan sistem dan mendeteksi serangan.

### Objektif

#### Tim Red (Offense - 3 orang)
1. **Web Application Testing**: Temukan dan eksploitasi vulnerability di web portal
2. **Remote Code Execution**: Dapatkan akses ke sistem melalui RCE
3. **Container Escape**: Keluar dari Docker container
4. **Privilege Escalation**: Escalate privilege hingga mendapat root access
5. **Persistence**: Maintain access dan plant backdoor

#### Tim Blue (Defense - 3 orang)
1. **Monitoring**: Setup dan monitor sistem untuk aktivitas mencurigakan
2. **Detection**: Detect dan analyze attack patterns
3. **Response**: Respond terhadap serangan dan mitigate threats
4. **Forensics**: Analyze logs dan identify attack vectors
5. **Remediation**: Patch vulnerabilities yang ditemukan

### Infrastruktur
- **1 Server**: Ubuntu 20.04 LTS
- **Web Application**: PHP/MySQL vulnerable web portal
- **Containerization**: Docker untuk isolasi aplikasi
- **Monitoring**: ELK Stack untuk logging
- **Network**: Isolated network environment

### Timeline Challenge
- **Setup**: 30 menit
- **Reconnaissance**: 45 menit
- **Initial Access**: 60 menit
- **Escalation**: 60 menit
- **Defense Response**: Throughout the challenge
- **Debrief**: 30 menit

### Scoring
- **Red Team**: Points untuk setiap tahap yang berhasil dilalui
- **Blue Team**: Points untuk detection dan successful mitigation
