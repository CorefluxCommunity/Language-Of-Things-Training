#!/bin/bash
#
# LoT Training Environment Setup Script for Linux/macOS
# This script installs Docker (if needed) and starts the Coreflux MQTT Broker
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       LoT Training Environment Setup - Linux/macOS           ║"
echo "║              Coreflux MQTT Broker Installation               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo -e "${BLUE}Detected OS: ${OS}${NC}"

# Step 1: Check/Install Docker
echo -e "\n${YELLOW}Step 1: Checking Docker installation...${NC}"

if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker is already installed: ${DOCKER_VERSION}${NC}"
else
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    
    case $OS in
        debian)
            echo "Installing Docker on Debian/Ubuntu..."
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo usermod -aG docker $USER
            echo -e "${GREEN}✓ Docker installed successfully${NC}"
            echo -e "${YELLOW}Note: You may need to log out and back in for group changes to take effect${NC}"
            ;;
        redhat)
            echo "Installing Docker on RHEL/CentOS/Fedora..."
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            echo -e "${GREEN}✓ Docker installed successfully${NC}"
            ;;
        macos)
            echo -e "${YELLOW}Please install Docker Desktop for macOS:${NC}"
            echo "1. Visit: https://docs.docker.com/desktop/install/mac-install/"
            echo "2. Download and install Docker Desktop"
            echo "3. Start Docker Desktop"
            echo "4. Re-run this script"
            exit 1
            ;;
        *)
            echo -e "${RED}Unsupported OS. Please install Docker manually:${NC}"
            echo "https://docs.docker.com/get-docker/"
            exit 1
            ;;
    esac
fi

# Check if Docker daemon is running
echo -e "\n${YELLOW}Step 2: Checking Docker daemon...${NC}"
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker daemon is running${NC}"
else
    echo -e "${YELLOW}Starting Docker daemon...${NC}"
    if [[ "$OS" == "macos" ]]; then
        open -a Docker
        echo "Waiting for Docker Desktop to start..."
        sleep 10
    else
        sudo systemctl start docker
    fi
    
    # Wait for Docker to be ready
    for i in {1..30}; do
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Docker daemon is now running${NC}"
            break
        fi
        sleep 1
    done
fi

# Step 3: Pull Coreflux image
echo -e "\n${YELLOW}Step 3: Pulling Coreflux MQTT Broker image...${NC}"
docker pull coreflux/coreflux-mqtt-broker:latest
echo -e "${GREEN}✓ Coreflux image pulled successfully${NC}"

# Step 4: Stop existing container if running
echo -e "\n${YELLOW}Step 4: Checking for existing Coreflux container...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q '^coreflux_broker$'; then
    echo "Stopping and removing existing container..."
    docker stop coreflux_broker 2>/dev/null || true
    docker rm coreflux_broker 2>/dev/null || true
    echo -e "${GREEN}✓ Existing container removed${NC}"
fi

# Step 5: Start Coreflux broker
echo -e "\n${YELLOW}Step 5: Starting Coreflux MQTT Broker...${NC}"
docker run -d \
    --name coreflux_broker \
    -p 1883:1883 \
    -p 5000:5000 \
    -p 8883:8883 \
    --restart unless-stopped \
    coreflux/coreflux-mqtt-broker:latest

echo -e "${GREEN}✓ Coreflux MQTT Broker started successfully${NC}"

# Step 6: Verify broker is running
echo -e "\n${YELLOW}Step 6: Verifying broker status...${NC}"
sleep 3

if docker ps --format '{{.Names}}' | grep -q '^coreflux_broker$'; then
    echo -e "${GREEN}✓ Coreflux broker is running${NC}"
else
    echo -e "${RED}✗ Broker failed to start. Check logs with: docker logs coreflux_broker${NC}"
    exit 1
fi

# Print connection info
echo -e "\n${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete!                            ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  MQTT Broker:     localhost:1883                              ║"
echo "║  WebSocket:       localhost:5000                              ║"
echo "║  MQTT TLS:        localhost:8883                              ║"
echo "║                                                               ║"
echo "║  Default Credentials:                                         ║"
echo "║    Username: root                                             ║"
echo "║    Password: coreflux (change immediately!)                   ║"
echo "║                                                               ║"
echo "║  Next Steps:                                                  ║"
echo "║  1. Install VS Code extension: LoT Notebooks by Coreflux      ║"
echo "║  2. Open index.lotnb to start learning                        ║"
echo "║  3. Configure broker credentials in VS Code                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Useful commands
echo -e "${YELLOW}Useful Docker commands:${NC}"
echo "  View logs:    docker logs -f coreflux_broker"
echo "  Stop broker:  docker stop coreflux_broker"
echo "  Start broker: docker start coreflux_broker"
echo "  Remove:       docker rm -f coreflux_broker"
echo ""
