#!/bin/bash

# Build and Run Script for Privilege Escalation Lab

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Advanced Privilege Escalation Lab Launcher${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker is not installed!${NC}"
    exit 1
fi

# Check if Docker daemon is running
if ! docker ps &> /dev/null; then
    echo -e "${RED}[!] Docker daemon is not running!${NC}"
    exit 1
fi

# Parse arguments
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}[*] No argument provided. Using default: build-and-run${NC}"
    ACTION="build-and-run"
else
    ACTION=$1
fi

case $ACTION in
    build)
        echo -e "${YELLOW}[*] Building Docker image...${NC}"
        docker build -t privesc-lab .
        echo -e "${GREEN}[+] Build complete!${NC}"
        ;;
    
    run)
        echo -e "${YELLOW}[*] Checking if container exists...${NC}"
        
        if docker ps -a --format '{{.Names}}' | grep -q '^privesc-lab$'; then
            echo -e "${YELLOW}[*] Container exists. Checking if running...${NC}"
            if docker ps --format '{{.Names}}' | grep -q '^privesc-lab$'; then
                echo -e "${YELLOW}[*] Container is already running!${NC}"
            else
                echo -e "${YELLOW}[*] Starting existing container...${NC}"
                docker start privesc-lab
            fi
        else
            echo -e "${YELLOW}[*] Creating new container...${NC}"
            docker run -d --name privesc-lab -p 2222:22 privesc-lab
        fi
        
        echo -e "${GREEN}[+] Lab is running on port 2222${NC}"
        echo -e "${BLUE}[*] SSH Connection:${NC}"
        echo -e "    ssh -p 2222 player1@localhost"
        echo -e "    Password: password123"
        ;;
    
    stop)
        echo -e "${YELLOW}[*] Stopping container...${NC}"
        docker stop privesc-lab || true
        echo -e "${GREEN}[+] Container stopped${NC}"
        ;;
    
    remove)
        echo -e "${YELLOW}[*] Stopping and removing container...${NC}"
        docker stop privesc-lab 2>/dev/null || true
        docker rm privesc-lab 2>/dev/null || true
        echo -e "${GREEN}[+] Container removed${NC}"
        ;;
    
    clean)
        echo -e "${YELLOW}[*] Full cleanup...${NC}"
        echo -e "${YELLOW}[*] Removing container...${NC}"
        docker stop privesc-lab 2>/dev/null || true
        docker rm privesc-lab 2>/dev/null || true
        
        echo -e "${YELLOW}[*] Removing image...${NC}"
        docker rmi privesc-lab 2>/dev/null || true
        
        echo -e "${YELLOW}[*] Removing volumes...${NC}"
        docker volume prune -f 2>/dev/null || true
        
        echo -e "${GREEN}[+] Cleanup complete!${NC}"
        ;;
    
    build-and-run)
        echo -e "${YELLOW}[*] Full build and run...${NC}"
        
        # Clean up old container if exists
        docker stop privesc-lab 2>/dev/null || true
        docker rm privesc-lab 2>/dev/null || true
        
        # Build
        echo -e "${YELLOW}[*] Building image...${NC}"
        docker build -t privesc-lab .
        
        # Run
        echo -e "${YELLOW}[*] Starting container...${NC}"
        docker run -d --name privesc-lab -p 2222:22 privesc-lab
        
        # Wait for SSH to be ready
        echo -e "${YELLOW}[*] Waiting for SSH to be ready...${NC}"
        for i in {1..30}; do
            if ssh -o StrictHostKeyChecking=no -p 2222 player1@localhost -o ConnectTimeout=1 "echo 'SSH ready'" 2>/dev/null; then
                echo -e "${GREEN}[+] SSH is ready!${NC}"
                break
            fi
            echo -n "."
            sleep 1
        done
        
        echo ""
        echo -e "${GREEN}[+] Lab is ready!${NC}"
        echo ""
        echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║           Lab Information                  ${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        echo -e "${BLUE}[*] SSH Connection Details:${NC}"
        echo -e "    Host: localhost"
        echo -e "    Port: 2222"
        echo -e "    User: player1"
        echo -e "    Password: password123"
        echo ""
        echo -e "${BLUE}[*] Quick Access:${NC}"
        echo -e "    ssh -p 2222 player1@localhost"
        echo ""
        echo -e "${BLUE}[*] Documentation:${NC}"
        echo -e "    - README.md - Lab overview and stage details"
        echo -e "    - SOLUTION.md - Complete solution guide"
        echo ""
        ;;
    
    status)
        echo -e "${YELLOW}[*] Checking status...${NC}"
        
        if docker ps --format '{{.Names}}' | grep -q '^privesc-lab$'; then
            echo -e "${GREEN}[+] Container is RUNNING${NC}"
            docker ps --filter "name=privesc-lab" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        else
            echo -e "${RED}[!] Container is NOT running${NC}"
            if docker ps -a --format '{{.Names}}' | grep -q '^privesc-lab$'; then
                echo -e "${YELLOW}[*] But container exists. Use './build.sh run' to start it.${NC}"
            else
                echo -e "${YELLOW}[*] Container does not exist. Use './build.sh build-and-run' to create it.${NC}"
            fi
        fi
        ;;
    
    logs)
        echo -e "${YELLOW}[*] Showing container logs...${NC}"
        docker logs -f privesc-lab
        ;;
    
    shell)
        echo -e "${YELLOW}[*] Connecting to container...${NC}"
        docker exec -it privesc-lab /bin/bash
        ;;
    
    ssh)
        echo -e "${YELLOW}[*] SSH to container...${NC}"
        ssh -p 2222 -o StrictHostKeyChecking=no player1@localhost
        ;;
    
    validate)
        echo -e "${YELLOW}[*] Running validation tests...${NC}"
        if [ -f "../validate-lab.sh" ]; then
            bash ../validate-lab.sh
        elif [ -f "./validate-lab.sh" ]; then
            bash ./validate-lab.sh
        else
            echo -e "${RED}[!] validate-lab.sh not found${NC}"
            echo -e "${YELLOW}[*] Please ensure validate-lab.sh exists in the parent directory or current directory${NC}"
            exit 1
        fi
        ;;
    
    docker-compose-up)
        echo -e "${YELLOW}[*] Starting with docker-compose...${NC}"
        docker-compose up -d
        echo -e "${GREEN}[+] Started with docker-compose${NC}"
        ;;
    
    docker-compose-down)
        echo -e "${YELLOW}[*] Stopping docker-compose...${NC}"
        docker-compose down
        echo -e "${GREEN}[+] Stopped docker-compose${NC}"
        ;;
    
    help|--help|-h)
        cat << 'EOF'
Usage: ./build.sh [COMMAND]

Commands:
  build                  Build Docker image only
  run                    Run container (or start if exists)
  stop                   Stop the container
  remove                 Remove the container
  clean                  Full cleanup (container, image, volumes)
  build-and-run          Build image and run container (DEFAULT)
  status                 Show container status
  logs                   Show container logs (follow mode)
  shell                  Open shell in container (docker exec)
  ssh                    SSH into container as player1
  validate               Run comprehensive lab validation tests
  docker-compose-up      Start with docker-compose
  docker-compose-down    Stop docker-compose
  help                   Show this help message

Quick Start:
  ./build.sh                    # Build and run
  ssh -p 2222 player1@localhost # Connect (password: password123)
  ./build.sh validate           # Test all users and exploits

Examples:
  ./build.sh build              # Just build image
  ./build.sh stop               # Stop running lab
  ./build.sh logs               # View container logs
  ./build.sh clean              # Clean everything
  ./build.sh validate           # Run validation tests

EOF
        ;;
    
    *)
        echo -e "${RED}[!] Unknown command: $ACTION${NC}"
        echo -e "${YELLOW}[*] Use './build.sh help' for available commands${NC}"
        exit 1
        ;;
esac
