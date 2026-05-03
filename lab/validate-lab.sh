#!/bin/bash

# ========================================
# Lab Validation & Testing Script
# ========================================
# Purpose: Verify all users are properly configured
#          and can login via SSH
# ========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Lab Validation & Testing Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Configuration
DOCKER_CONTAINER="privesc-lab"
SSH_PORT="2222"
SSH_HOST="localhost"

# User list with credentials
declare -A USERS=(
    ["player1"]="password123"
    ["backup"]="BackupPass@123"
    ["www-app"]="webpass@2024"
    ["sysadmin"]="Admin@2024"
    ["devops"]="DevOps123#"
    ["jenkins"]="JenkinsCI@2024"
    ["nginx"]="nginx123"
    ["www-data"]="webdata123"
)

# ========================================
# Test 1: Check Docker Container
# ========================================
echo -e "${BLUE}[*] TEST 1: Docker Container Status${NC}"
echo ""

if docker ps | grep -q "$DOCKER_CONTAINER"; then
    echo -e "${GREEN}[✓] Container '$DOCKER_CONTAINER' is running${NC}"
else
    echo -e "${RED}[✗] Container '$DOCKER_CONTAINER' is NOT running${NC}"
    echo "     Please start the container first:"
    echo "     docker run -d --name $DOCKER_CONTAINER -p $SSH_PORT:22 privesc-lab"
    exit 1
fi
echo ""

# ========================================
# Test 2: Check SSH Service
# ========================================
echo -e "${BLUE}[*] TEST 2: SSH Service Status${NC}"
echo ""

if docker exec "$DOCKER_CONTAINER" service ssh status >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] SSH service is running${NC}"
else
    echo -e "${YELLOW}[!] SSH service status unknown, trying to start...${NC}"
    docker exec "$DOCKER_CONTAINER" service ssh start >/dev/null 2>&1
    sleep 2
    if docker exec "$DOCKER_CONTAINER" service ssh status >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] SSH service started successfully${NC}"
    else
        echo -e "${RED}[✗] Failed to start SSH service${NC}"
    fi
fi
echo ""

# ========================================
# Test 3: Check Port Binding
# ========================================
echo -e "${BLUE}[*] TEST 3: SSH Port Binding${NC}"
echo ""

if ss -tlnp 2>/dev/null | grep -q ":$SSH_PORT"; then
    echo -e "${GREEN}[✓] SSH port $SSH_PORT is bound on host${NC}"
else
    echo -e "${YELLOW}[!] SSH port $SSH_PORT might not be bound, but container SSH might work${NC}"
fi
echo ""

# ========================================
# Test 4: Verify User Accounts in Container
# ========================================
echo -e "${BLUE}[*] TEST 4: User Accounts Inside Container${NC}"
echo ""

TOTAL_USERS=${#USERS[@]}
VALID_USERS=0
INVALID_USERS=0

for user in "${!USERS[@]}"; do
    if docker exec "$DOCKER_CONTAINER" id "$user" >/dev/null 2>&1; then
        shell=$(docker exec "$DOCKER_CONTAINER" getent passwd "$user" | cut -d: -f7)
        echo -e "${GREEN}[✓] User '$user' exists (shell: $shell)${NC}"
        ((VALID_USERS++))
    else
        echo -e "${RED}[✗] User '$user' NOT found${NC}"
        ((INVALID_USERS++))
    fi
done

echo ""
echo -e "Summary: ${GREEN}$VALID_USERS${NC}/${TOTAL_USERS} users found"

if [ $INVALID_USERS -gt 0 ]; then
    echo -e "${RED}WARNING: $INVALID_USERS users missing!${NC}"
fi
echo ""

# ========================================
# Test 5: Test SSH Connectivity
# ========================================
echo -e "${BLUE}[*] TEST 5: SSH Connectivity Tests${NC}"
echo ""

SSH_SUCCESS=0
SSH_FAIL=0

for user in "${!USERS[@]}"; do
    password=${USERS[$user]}
    
    sshpass -p "$password" ssh -q -p "$SSH_PORT" \
        -o "StrictHostKeyChecking=no" \
        -o "UserKnownHostsFile=/dev/null" \
        -o "LogLevel=ERROR" \
        -o "ConnectTimeout=5" \
        "$user@$SSH_HOST" "exit 0" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] SSH login successful for '$user'${NC}"
        ((SSH_SUCCESS++))
    else
        echo -e "${RED}[✗] SSH login FAILED for '$user'${NC}"
        ((SSH_FAIL++))
    fi
done

# ========================================
# Test 6: Critical User Checks
# ========================================
echo -e "${BLUE}[*] TEST 6: Critical User Checks${NC}"
echo ""

# Check backup user specifically
echo -e "Checking 'backup' user..."
result=$(docker exec "$DOCKER_CONTAINER" su - backup -c "whoami" 2>&1)
if [ "$result" == "backup" ]; then
    echo -e "${GREEN}[✓] 'backup' user can switch with su${NC}"
else
    echo -e "${RED}[✗] 'backup' user su switch failed${NC}"
    echo "     Output: $result"
fi

# Check if any user is locked
echo -e ""
echo -e "Checking for locked users..."
for user in "${!USERS[@]}"; do
    status=$(docker exec "$DOCKER_CONTAINER" passwd -S "$user" 2>/dev/null | awk '{print $2}')
    if [ "$status" == "P" ] || [ "$status" == "PS" ]; then
        echo -e "${GREEN}[✓] User '$user' password status: Active ($status)${NC}"
    elif [ "$status" == "L" ] || [ "$status" == "NP" ]; then
        echo -e "${YELLOW}[!] User '$user' password status: $status (may be locked)${NC}"
    else
        echo -e "${BLUE}[•] User '$user' password status: $status${NC}"
    fi
done

echo ""

# ========================================
# Test 7: Test Exploitation Chain
# ========================================
echo -e "${BLUE}[*] TEST 7: Exploitation Chain Readiness${NC}"
echo ""

# Stage 1: Initial access
echo "Stage 1: Initial Access (player1 login)"
# Perbaikan: Tambahkan -q dan 2>/dev/null
result=$(sshpass -p "password123" ssh -q -p "$SSH_PORT" \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    "player1@$SSH_HOST" "whoami" 2>/dev/null | tr -d '\r')

if [[ "$result" == *"player1"* ]]; then
    echo -e "${GREEN}[✓] Stage 1 Ready: player1 login successful${NC}"
else
    echo -e "${RED}[✗] Stage 1 Failed: Cannot login as player1${NC}"
    echo "     Output: $result"
fi

# Stage 2: Backup user access
echo ""
echo "Stage 2: Backup User Access"
# Perbaikan: Tambahkan -q dan 2>/dev/null
result=$(sshpass -p "password123" ssh -q -p "$SSH_PORT" \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    "player1@$SSH_HOST" "su - backup -c whoami" 2>/dev/null | tr -d '\r')

if [[ "$result" == *"backup"* ]]; then
    echo -e "${GREEN}[✓] Stage 2 Ready: Can switch to backup user${NC}"
else
    echo -e "${RED}[✗] Stage 2 Failed: Cannot switch to backup user${NC}"
    echo "     Output: $result"
fi

# ========================================
# Test 8: File & Permission Checks
# ========================================
echo -e "${BLUE}[*] TEST 8: File & Permission Checks${NC}"
echo ""

# Check SUID binaries
echo "Checking SUID binaries..."
result=$(docker exec "$DOCKER_CONTAINER" find /usr/local/bin -perm -4000 2>/dev/null)
if [ -n "$result" ]; then
    echo -e "${GREEN}[✓] SUID binaries found:${NC}"
    while IFS= read -r line; do
        echo "   - $line"
    done <<< "$result"
else
    echo -e "${YELLOW}[!] No SUID binaries found${NC}"
fi

# Check vulnerable files
echo ""
echo "Checking vulnerable files..."
vulnerable_files=(
    "/opt/backup/sensitive.txt"
    "/home/shared/credentials.txt"
    "/tmp/backup_script.sh"
)

for file in "${vulnerable_files[@]}"; do
    if docker exec "$DOCKER_CONTAINER" [ -f "$file" ] 2>/dev/null; then
        perms=$(docker exec "$DOCKER_CONTAINER" ls -l "$file" | awk '{print $1}')
        echo -e "${GREEN}[✓] File exists: $file (permissions: $perms)${NC}"
    else
        echo -e "${YELLOW}[!] File not found: $file${NC}"
    fi
done

echo ""

# ========================================
# Test 9: Database Checks (if applicable)
# ========================================
echo -e "${BLUE}[*] TEST 9: Database Services${NC}"
echo ""

# Check MySQL
if docker exec "$DOCKER_CONTAINER" service mysql status >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] MySQL service is running${NC}"
else
    echo -e "${YELLOW}[!] MySQL service status unknown${NC}"
fi

# Check PostgreSQL
if docker exec "$DOCKER_CONTAINER" service postgresql status >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] PostgreSQL service is running${NC}"
else
    echo -e "${YELLOW}[!] PostgreSQL service status unknown${NC}"
fi

echo ""

# ========================================
# Final Summary
# ========================================
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Testing Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ $SSH_SUCCESS -eq $TOTAL_USERS ] && [ $INVALID_USERS -eq 0 ]; then
    echo -e "${GREEN}[✓] LAB IS READY FOR USE!${NC}"
    echo ""
    echo "All checks passed:"
    echo "  ✓ Container running"
    echo "  ✓ SSH service active"
    echo "  ✓ All users created"
    echo "  ✓ All users can login via SSH"
    echo "  ✓ Exploitation chain ready"
    echo ""
else
    echo -e "${RED}[!] LAB HAS ISSUES${NC}"
    echo ""
    echo "Issues found:"
    if [ $INVALID_USERS -gt 0 ]; then
        echo "  ✗ $INVALID_USERS user(s) missing"
    fi
    if [ $SSH_FAIL -gt 0 ]; then
        echo "  ✗ $SSH_FAIL user(s) cannot SSH login"
    fi
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check container logs: docker logs $DOCKER_CONTAINER"
    echo "  2. Verify container is running: docker ps"
    echo "  3. Rebuild container: docker build -t privesc-lab . && docker run -d --name $DOCKER_CONTAINER -p $SSH_PORT:22 privesc-lab"
    echo "  4. Wait 60 seconds after startup before testing"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo ""
