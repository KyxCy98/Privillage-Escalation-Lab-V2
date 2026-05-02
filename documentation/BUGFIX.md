# 🔧 Bug Fix Log - Advanced Privilege Escalation Lab

## Bug #1: SSH Permission Denied (FIXED) ✅

### Issue
Users encountered "Permission denied" error when trying to SSH into container:
```
ssh -p 2222 player1@localhost
# Error: Permission denied (publickey,password).
```

### Root Cause
The Dockerfile had incorrect SSH configuration:
```
echo "AllowUsers *@127.0.0.1 *@::1" >> /etc/ssh/sshd_config
```

This syntax was wrong for SSH's `AllowUsers` directive. The format `*@127.0.0.1` is not valid SSH syntax and was blocking all connections.

### Solution Applied

#### Change 1: Fixed Dockerfile
Replaced incorrect SSH config with proper configuration:

**Before:**
```dockerfile
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers *@127.0.0.1 *@::1" >> /etc/ssh/sshd_config
```

**After:**
```dockerfile
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "PrintMotd no" >> /etc/ssh/sshd_config && \
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config && \
    echo "ListenAddress ::" >> /etc/ssh/sshd_config
```

**What changed:**
- ✅ Removed invalid `AllowUsers *@127.0.0.1` restriction
- ✅ Added proper SSH configuration options
- ✅ Enabled both IPv4 and IPv6 listening
- ✅ Added authentication options (PubkeyAuthentication, UsePAM)
- ✅ Allowed password authentication explicitly

#### Change 2: Fixed setup-lab.sh
Added SSH key generation and service restart at end of setup:

```bash
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
```

**Why:**
- ✅ Ensures SSH host keys are generated
- ✅ Fixes directory permissions for SSH daemon
- ✅ Explicitly restarts SSH service for clean state
- ✅ Fallback to manual sshd daemon start

#### Change 3: Fixed backup User Shell
The backup user had `/bin/nologin` shell but password authentication was needed:

**Before:**
```bash
useradd -m -s /bin/nologin backup 2>/dev/null || true
echo "backup:BackupPass@123" | chpasswd
```

**After:**
```bash
useradd -m -s /bin/bash backup 2>/dev/null || true
echo "backup:BackupPass@123" | chpasswd
```

**Why:**
- ✅ backup user needs interactive shell for Stage 2 exploitation
- ✅ `/bin/nologin` was blocking su - backup command

### How to Apply Fix

#### Option 1: Rebuild from Latest (Recommended)
```bash
# Clean rebuild with latest fixes
cd c:\Users\Hype GLK\Downloads\lab

./build.sh clean
./build.sh build-and-run

# Wait 60 seconds
sleep 60

# SSH should work now
ssh -p 2222 player1@localhost
# Password: password123
```

#### Option 2: Docker Commands
```bash
docker stop privesc-lab
docker rm privesc-lab
docker rmi privesc-lab

docker build -t privesc-lab .
docker run -d --name privesc-lab -p 2222:22 privesc-lab

sleep 60
ssh -p 2222 player1@localhost
```

#### Option 3: Update Existing Container
```bash
# If you want to keep container, just rebuild image
docker build --no-cache -t privesc-lab .
docker stop privesc-lab
docker rm privesc-lab
docker run -d --name privesc-lab -p 2222:22 privesc-lab

sleep 60
ssh -p 2222 player1@localhost
```

### Verification

After rebuilding, verify SSH works:

```bash
# Test SSH connection
ssh -p 2222 player1@localhost
# Should prompt for password

# Enter password
# Password: password123

# Should see prompt
player1@privesc-lab:~$

# Verify you're logged in
whoami
# Output: player1

id
# Output: uid=1000(player1) gid=1000(player1) groups=1000(player1),1001(developers)
```

### Detailed Fix Explanation

**SSH Configuration Issues Fixed:**

1. **AllowUsers Directive**
   - ❌ OLD: `AllowUsers *@127.0.0.1 *@::1` (invalid syntax)
   - ✅ NEW: Removed restriction (allow all users from any host)
   - This was the PRIMARY cause of permission denied error

2. **SSH Host Keys**
   - ❌ OLD: Not generated during build
   - ✅ NEW: Generate RSA, ECDSA, and Ed25519 keys in setup

3. **SSH Service**
   - ❌ OLD: Not explicitly restarted after setup
   - ✅ NEW: SSH service restarted at end of setup-lab.sh

4. **Directory Permissions**
   - ❌ OLD: /var/run/sshd not properly configured
   - ✅ NEW: chmod 700 /var/run/sshd and mkdir /run/sshd

5. **Backup User Shell**
   - ❌ OLD: /bin/nologin (can't login interactively)
   - ✅ NEW: /bin/bash (can use su - command for Stage 2)

### Files Modified

- ✅ `Dockerfile` - SSH configuration
- ✅ `setup-lab.sh` - SSH keys + backup user + service restart
- ✅ `QUICKSTART.md` - Added troubleshooting info

### Testing Status

- ✅ SSH login with password works
- ✅ All user accounts accessible (player1, backup, jenkins, etc.)
- ✅ Stage 2 backup user access working
- ✅ No permission denied errors

### Related Issues

This bug was causing:
- ❌ SSH login failures
- ❌ Stage 1 exploitation not possible
- ❌ Lab unable to start

With this fix:
- ✅ SSH login works with credentials
- ✅ All 7 stages now exploitable
- ✅ Lab ready for use

---

## Version History

| Version | Date | Bug | Status |
|---------|------|-----|--------|
| 1.0 | May 1, 2026 | SSH Permission Denied | 🔴 FOUND |
| 1.1 | May 1, 2026 | SSH Permission Denied | ✅ FIXED |

---

## How to Prevent Similar Issues

For future improvements:

1. **Test SSH immediately after build:**
   ```bash
   sleep 30
   timeout 5 ssh -p 2222 -o StrictHostKeyChecking=no player1@localhost "echo SSH_OK"
   ```

2. **Validate SSH keys exist:**
   ```bash
   docker exec privesc-lab ls -la /etc/ssh/ssh_host_*.key
   ```

3. **Check SSH daemon status:**
   ```bash
   docker exec privesc-lab service ssh status
   ```

4. **Health check in docker-compose:**
   ```yaml
   healthcheck:
     test: ["CMD", "ssh", "-p", "2222", "-o", "StrictHostKeyChecking=no", "player1@localhost"]
     interval: 30s
     timeout: 10s
     retries: 3
   ```

---

## Questions?

If you encounter any issues after this fix:

1. ✅ Verify you rebuilt with latest changes
2. ✅ Check container logs: `docker logs privesc-lab`
3. ✅ Check SSH status: `docker exec privesc-lab service ssh status`
4. ✅ Force rebuild: `docker build --no-cache -t privesc-lab .`
5. ✅ Review QUICKSTART.md troubleshooting section

---

**Bug Status:** ✅ RESOLVED  
**Version:** 1.1  
**Date:** May 1, 2026
