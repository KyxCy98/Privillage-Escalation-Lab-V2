#!/bin/bash

# ===== STAGE 1: Create users and groups =====
echo "[*] Stage 1: Creating users and groups..."

# Create user groups
groupadd -f developers 2>/dev/null
groupadd -f webusers 2>/dev/null
groupadd -f admins 2>/dev/null
groupadd -f service 2>/dev/null

# Create users with weak credentials
useradd -m -s /bin/bash -G developers player1 2>/dev/null || true
echo "player1:password123" | chpasswd

useradd -m -s /bin/bash -G webusers www-app 2>/dev/null || true
echo "www-app:webpass@2024" | chpasswd

useradd -m -s /bin/bash -G service sysadmin 2>/dev/null || true
echo "sysadmin:Admin@2024" | chpasswd

useradd -m -s /bin/bash -G admins devops 2>/dev/null || true
echo "devops:DevOps123#" | chpasswd

useradd -m -s /bin/bash -G developers jenkins 2>/dev/null || true
echo "jenkins:JenkinsCI@2024" | chpasswd

useradd -m -s /bin/bash -G webusers nginx 2>/dev/null || true
echo "nginx:nginx123" | chpasswd

useradd -m -s /bin/bash backup 2>/dev/null || true
echo "backup:BackupPass@123" | chpasswd

useradd -m -s /bin/bash -G developers,webusers www-data 2>/dev/null || true
echo "www-data:webdata123" | chpasswd

# ===== STAGE 2: Create directory structure with SUID exploits =====
echo "[*] Stage 2: Setting up vulnerable directory structures..."

mkdir -p /opt/services
mkdir -p /opt/backup
mkdir -p /var/www/html/uploads
mkdir -p /home/shared
mkdir -p /opt/vulnerable-app
mkdir -p /opt/vault

# Set permissions with vulnerabilities
chmod 777 /opt/backup
chmod 755 /opt/services
chmod 777 /home/shared
chmod 755 /opt/vulnerable-app
chmod 750 /opt/vault

# ===== STAGE 3: Create vulnerable SUID binaries =====
echo "[*] Stage 3: Creating vulnerable SUID binaries..."

# Vulnerable SUID binary #1 - PATH injection
cat > /tmp/binary1.c << 'EOF'
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    printf("Executing backup script...\n");
    system("backup-runner");
    return 0;
}
EOF

gcc -o /usr/local/bin/run-backup /tmp/binary1.c 2>/dev/null
chown root:root /usr/local/bin/run-backup
chmod 4755 /usr/local/bin/run-backup

# Vulnerable SUID binary #2 - Command injection
cat > /tmp/binary2.c << 'EOF'
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    char cmd[512];
    if (argc > 1) {
        sprintf(cmd, "echo %s | tee /tmp/log.txt", argv[1]);
        system(cmd);
    }
    return 0;
}
EOF

gcc -o /usr/local/bin/log-system /tmp/binary2.c 2>/dev/null
chown root:root /usr/local/bin/log-system
chmod 4755 /usr/local/bin/log-system

# Vulnerable SUID binary #3 - LD_PRELOAD vulnerability
cat > /tmp/binary3.c << 'EOF'
#include <stdlib.h>
#include <unistd.h>

int main() {
    setuid(0);
    system("whoami");
    return 0;
}
EOF

gcc -o /usr/local/bin/check-user /tmp/binary3.c 2>/dev/null
chown root:root /usr/local/bin/check-user
chmod 4755 /usr/local/bin/check-user

# ===== STAGE 4: Create vulnerable services =====
echo "[*] Stage 4: Setting up vulnerable services..."

# Start PostgreSQL with default credentials
service postgresql start
sudo -u postgres psql -c "CREATE USER pwner WITH PASSWORD 'password123';" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE postgres TO pwner;" 2>/dev/null
sudo -u postgres psql -c "CREATE TABLE secret_flag (flag TEXT);" 2>/dev/null
sudo -u postgres psql -c "INSERT INTO secret_flag VALUES ('FLAG{stage_4_db_access}');" 2>/dev/null

# Create vulnerable PHP application
cat > /var/www/html/index.php << 'EOF'
<?php
$db_host = "localhost";
$db_user = "pwner";
$db_pass = "password123";
$db_name = "postgres";

$conn = pg_connect("host=$db_host user=$db_user password=$db_pass dbname=$db_name");
if (!$conn) {
    die("Connection failed");
}

if (isset($_GET['cmd'])) {
    echo "Input: " . htmlspecialchars($_GET['cmd']) . "<br>";
    // Command injection vulnerability
    system($_GET['cmd']);
}

$query = "SELECT * FROM secret_flag";
$result = pg_query($conn, $query);
while ($row = pg_fetch_assoc($result)) {
    echo "Flag: " . $row['flag'] . "<br>";
}
pg_close($conn);
?>
EOF

chmod 644 /var/www/html/index.php
chown www-data:www-data /var/www/html/index.php

# ===== STAGE 5: Create cron job vulnerabilities =====
echo "[*] Stage 5: Setting up cron job vulnerabilities..."

# Create backup script with hardcoded credentials
cat > /opt/services/backup.sh << 'EOF'
#!/bin/bash
# Backup script with hardcoded password
DB_PASS="SuperSecret@2024"
DB_USER="admin"

mysqldump -u root -p$DB_PASS > /tmp/backup.sql 2>/dev/null
tar czf /opt/backup/backup-$(date +%Y%m%d).tar.gz /var/www/html/
EOF

chmod 755 /opt/services/backup.sh
chown root:root /opt/services/backup.sh

# Create cron job that runs as root
echo "*/5 * * * * /opt/services/backup.sh" | crontab -

# ===== STAGE 6: Create file permission vulnerabilities =====
echo "[*] Stage 6: Creating file permission vulnerabilities..."

# Writable /etc/passwd-like file
cat > /opt/services/users.conf << 'EOF'
admin:Admin@2024:0
root:rootpass:0
user:userpass:1000
EOF

chmod 644 /opt/services/users.conf
chown root:root /opt/services/users.conf

# Create sudo rule file (vulnerable)
cat > /etc/sudoers.d/vulnerable << 'EOF'
%developers ALL=(root) NOPASSWD: /usr/local/bin/run-backup
%webusers ALL=(root) NOPASSWD: /usr/bin/service
jenkins ALL=(devops) NOPASSWD: /usr/local/bin/check-user
EOF

chmod 440 /etc/sudoers.d/vulnerable

# ===== STAGE 7: Create exploit chain artifacts =====
echo "[*] Stage 7: Creating exploit chain artifacts..."

# Stage 1 Flag - Initial access
cat > /home/player1/.ssh/authorized_keys << 'EOF'
# SSH key storage location - check for SSH key forwarding
# Hint: Look for credentials in common locations
EOF

# Create hint file with encoded credentials
cat > /home/player1/hint.txt << 'EOF'
L2hvbWUvc2hhcmVkL2NyZWRlbnRpYWxzLnR4dA==
EOF

# Create credentials file in /home/shared
cat > /home/shared/credentials.txt << 'EOF'
Database credentials:
Host: localhost
User: pwner
Password: password123
Database: postgres

MySQL:
User: root
Pass: SuperSecret@2024
EOF

chmod 644 /home/shared/credentials.txt

# Create environment variable file with secrets
cat > /opt/vault/env.sh << 'EOF'
#!/bin/bash
export API_KEY="API_KEY_STAGE5_SECRET"
export DB_ADMIN_PASS="Admin@2024"
export MASTER_SECRET="FLAG{stage_5_env_variables}"
EOF

chmod 644 /opt/vault/env.sh

# ===== Create exploitation chain guide files =====
echo "[*] Creating exploitation chain markers..."

# Flag markers for each stage
mkdir -p /root/.flag
echo "FLAG{stage_1_initial_access}" > /tmp/.flag_s1
echo "FLAG{stage_2_user_enumeration}" > /tmp/.flag_s2
echo "FLAG{stage_3_suid_exploitation}" > /tmp/.flag_s3
echo "FLAG{stage_4_database_access}" > /tmp/.flag_s4
echo "FLAG{stage_5_env_variables}" > /tmp/.flag_s5
echo "FLAG{stage_6_sudo_misconfiguration}" > /tmp/.flag_s6
echo "FLAG{stage_7_kernel_privesc_root}" > /root/.flag_final

chmod 600 /root/.flag_final
chmod 644 /tmp/.flag_s*

# ===== Create vulnerable application =====
echo "[*] Creating vulnerable services..."

cat > /opt/vulnerable-app/app.py << 'EOF'
#!/usr/bin/env python3
import os
import pickle
import subprocess

# Vulnerable pickle deserialization
def load_config(filename):
    with open(filename, 'rb') as f:
        return pickle.load(f)

# Vulnerable subprocess call
def execute_command(user_input):
    os.system(f"echo {user_input}")

if __name__ == "__main__":
    # Create sample config
    config_path = "/tmp/app.config"
    try:
        config = load_config(config_path)
    except:
        pass
EOF

chmod 755 /opt/vulnerable-app/app.py

# ===== Setup script to be called by run-backup SUID =====
cat > /usr/local/bin/backup-runner << 'EOF'
#!/bin/bash
echo "Running backup as current user..."
cat /opt/backup/sensitive.txt 2>/dev/null
EOF

chmod 755 /usr/local/bin/backup-runner

# Create sensitive file readable only by specific users
cat > /opt/backup/sensitive.txt << 'EOF'
CRITICAL DATA: FLAG{stage_2_backup_runner}
Database Master Password: MasterPass@2024
EOF

chmod 600 /opt/backup/sensitive.txt
chown root:root /opt/backup/sensitive.txt

# ===== Create nginx vulnerable proxy =====
service nginx start 2>/dev/null || true
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:9000;
    }
    
    location /admin {
        proxy_pass http://127.0.0.1:9001;
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

# Create .htpasswd with weak credentials
echo "admin:admin123" | htpasswd -ci /etc/nginx/.htpasswd admin 2>/dev/null

# ===== SSH Configuration Fix =====
echo "[*] Configuring SSH service..."

# Fix SSH permissions
chmod 700 /var/run/sshd
mkdir -p /run/sshd

# Generate SSH keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
fi

if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
fi

# Restart SSH service
service ssh restart 2>&1 || /usr/sbin/sshd -D &

# ===== Final setup =====
echo "[*] Lab setup complete!"
echo "[*] All vulnerabilities configured"

# Clean up
rm -f /tmp/binary*.c

echo "[+] Lab is ready for exploitation!"
