#
# LoT Training Environment Setup Script for Windows
# This script checks Docker Desktop and starts the Coreflux MQTT Broker
#

# Requires running as Administrator for Docker operations
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-DockerInstalled {
    try {
        $null = Get-Command docker -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-DockerRunning {
    try {
        $null = docker info 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

# Header
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "║         LoT Training Environment Setup - Windows              ║" "Cyan"
Write-ColorOutput "║              Coreflux MQTT Broker Installation                ║" "Cyan"
Write-ColorOutput "╚═══════════════════════════════════════════════════════════════╝" "Cyan"
Write-Host ""

# Step 1: Check Docker Installation
Write-ColorOutput "Step 1: Checking Docker installation..." "Yellow"

if (Test-DockerInstalled) {
    $dockerVersion = docker --version
    Write-ColorOutput "✓ Docker is installed: $dockerVersion" "Green"
}
else {
    Write-ColorOutput "✗ Docker is not installed." "Red"
    Write-Host ""
    Write-ColorOutput "Please install Docker Desktop for Windows:" "Yellow"
    Write-Host "1. Visit: https://docs.docker.com/desktop/install/windows-install/"
    Write-Host "2. Download and install Docker Desktop"
    Write-Host "3. Restart your computer if required"
    Write-Host "4. Start Docker Desktop"
    Write-Host "5. Re-run this script"
    Write-Host ""
    Write-ColorOutput "Opening Docker Desktop download page..." "Cyan"
    Start-Process "https://docs.docker.com/desktop/install/windows-install/"
    exit 1
}

# Step 2: Check Docker is running
Write-Host ""
Write-ColorOutput "Step 2: Checking Docker daemon..." "Yellow"

if (Test-DockerRunning) {
    Write-ColorOutput "✓ Docker daemon is running" "Green"
}
else {
    Write-ColorOutput "Docker daemon is not running. Attempting to start Docker Desktop..." "Yellow"
    
    # Try to start Docker Desktop
    $dockerDesktopPath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerDesktopPath) {
        Start-Process $dockerDesktopPath
        Write-Host "Waiting for Docker Desktop to start (this may take a minute)..."
        
        $attempts = 0
        $maxAttempts = 60
        while (-not (Test-DockerRunning) -and $attempts -lt $maxAttempts) {
            Start-Sleep -Seconds 2
            $attempts++
            Write-Host "." -NoNewline
        }
        Write-Host ""
        
        if (Test-DockerRunning) {
            Write-ColorOutput "✓ Docker daemon is now running" "Green"
        }
        else {
            Write-ColorOutput "✗ Docker failed to start. Please start Docker Desktop manually and re-run this script." "Red"
            exit 1
        }
    }
    else {
        Write-ColorOutput "✗ Docker Desktop not found. Please install Docker Desktop and re-run this script." "Red"
        exit 1
    }
}

# Step 3: Pull Coreflux image
Write-Host ""
Write-ColorOutput "Step 3: Pulling Coreflux MQTT Broker image..." "Yellow"

docker pull coreflux/coreflux-mqtt-broker:latest
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✓ Coreflux image pulled successfully" "Green"
}
else {
    Write-ColorOutput "✗ Failed to pull Coreflux image" "Red"
    exit 1
}

# Step 4: Stop existing container if running
Write-Host ""
Write-ColorOutput "Step 4: Checking for existing Coreflux container..." "Yellow"

$existingContainer = docker ps -a --format '{{.Names}}' | Where-Object { $_ -eq 'coreflux_broker' }
if ($existingContainer) {
    Write-Host "Stopping and removing existing container..."
    docker stop coreflux_broker 2>$null
    docker rm coreflux_broker 2>$null
    Write-ColorOutput "✓ Existing container removed" "Green"
}
else {
    Write-Host "No existing container found"
}

# Step 5: Start Coreflux broker
Write-Host ""
Write-ColorOutput "Step 5: Starting Coreflux MQTT Broker..." "Yellow"

docker run -d `
    --name coreflux_broker `
    -p 1883:1883 `
    -p 5000:5000 `
    -p 8883:8883 `
    --restart unless-stopped `
    coreflux/coreflux-mqtt-broker:latest

if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "✓ Coreflux MQTT Broker started successfully" "Green"
}
else {
    Write-ColorOutput "✗ Failed to start Coreflux broker" "Red"
    exit 1
}

# Step 6: Verify broker is running
Write-Host ""
Write-ColorOutput "Step 6: Verifying broker status..." "Yellow"

Start-Sleep -Seconds 3

$runningContainer = docker ps --format '{{.Names}}' | Where-Object { $_ -eq 'coreflux_broker' }
if ($runningContainer) {
    Write-ColorOutput "✓ Coreflux broker is running" "Green"
}
else {
    Write-ColorOutput "✗ Broker failed to start. Check logs with: docker logs coreflux_broker" "Red"
    exit 1
}

# Print connection info
Write-Host ""
Write-ColorOutput "╔═══════════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "║                    Setup Complete!                            ║" "Cyan"
Write-ColorOutput "╠═══════════════════════════════════════════════════════════════╣" "Cyan"
Write-ColorOutput "║  MQTT Broker:     localhost:1883                              ║" "Cyan"
Write-ColorOutput "║  WebSocket:       localhost:5000                              ║" "Cyan"
Write-ColorOutput "║  MQTT TLS:        localhost:8883                              ║" "Cyan"
Write-ColorOutput "║                                                               ║" "Cyan"
Write-ColorOutput "║  Default Credentials:                                         ║" "Cyan"
Write-ColorOutput "║    Username: root                                             ║" "Cyan"
Write-ColorOutput "║    Password: coreflux (change immediately!)                   ║" "Cyan"
Write-ColorOutput "║                                                               ║" "Cyan"
Write-ColorOutput "║  Next Steps:                                                  ║" "Cyan"
Write-ColorOutput "║  1. Install VS Code extension: LoT Notebooks by Coreflux      ║" "Cyan"
Write-ColorOutput "║  2. Open index.lotnb to start learning                        ║" "Cyan"
Write-ColorOutput "║  3. Configure broker credentials in VS Code                   ║" "Cyan"
Write-ColorOutput "╚═══════════════════════════════════════════════════════════════╝" "Cyan"
Write-Host ""

# Useful commands
Write-ColorOutput "Useful Docker commands:" "Yellow"
Write-Host "  View logs:    docker logs -f coreflux_broker"
Write-Host "  Stop broker:  docker stop coreflux_broker"
Write-Host "  Start broker: docker start coreflux_broker"
Write-Host "  Remove:       docker rm -f coreflux_broker"
Write-Host ""
