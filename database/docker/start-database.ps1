# EVALIS PostgreSQL Docker Start Script
# Purpose: Start the EVALIS PostgreSQL Docker container on Windows
# Usage: .\start-database.ps1
#
# Requirements:
# - Docker Desktop installed on Windows
# - PowerShell 5.0+ or PowerShell Core
# - Run as Administrator (usually not required, but may be needed on some systems)

param(
    [int]$TimeoutSeconds = 120,
    [switch]$Wait = $false
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
}

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $Color = $Colors[$Type]
    Write-Host $Message -ForegroundColor $Color
}

# Display header
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  EVALIS PostgreSQL Database Startup" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Docker is installed
Write-Status "► Checking if Docker is installed..." "Info"
$dockerCheck = $null
try {
    $dockerCheck = docker --version 2>$null
    if ($dockerCheck) {
        Write-Status "✓ Docker found: $dockerCheck" "Success"
    } else {
        throw "Docker command not available"
    }
} catch {
    Write-Status "✗ Docker Desktop not found!" "Error"
    Write-Status ""
    Write-Status "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" "Warning"
    Write-Status ""
    Write-Status "After installation, restart your computer and try again." "Info"
    exit 1
}

# Step 2: Check if Docker daemon is running
Write-Status ""
Write-Status "► Checking if Docker daemon is running..." "Info"
$dockerPs = $null
try {
    $dockerPs = docker ps 2>$null
    Write-Status "✓ Docker daemon is running" "Success"
} catch {
    Write-Status "✗ Docker daemon not running!" "Warning"
    Write-Status "Attempting to start Docker Desktop..." "Info"

    # Try to start Docker Desktop
    try {
        # Try common Docker Desktop installation paths
        $dockerPaths = @(
            "C:\Program Files\Docker\Docker\Docker Desktop.exe",
            "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe"
        )

        $dockerFound = $false
        foreach ($path in $dockerPaths) {
            if (Test-Path $path) {
                Write-Status "Starting: $path" "Info"
                Start-Process $path
                $dockerFound = $true
                break
            }
        }

        if (-not $dockerFound) {
            Write-Status "Could not find Docker Desktop executable" "Error"
            Write-Status "Please start Docker Desktop manually" "Warning"
            exit 1
        }

        # Wait for Docker daemon to be ready
        Write-Status "Waiting for Docker daemon to start (up to 60 seconds)..." "Warning"
        $dockerStarted = $false
        for ($i = 0; $i -lt 60; $i++) {
            Start-Sleep -Seconds 1
            if (docker ps 2>$null) {
                $dockerStarted = $true
                break
            }
            Write-Host "." -NoNewline -ForegroundColor Yellow
        }
        Write-Host "" # New line after progress dots

        if ($dockerStarted) {
            Write-Status "✓ Docker daemon started" "Success"
        } else {
            Write-Status "✗ Docker daemon failed to start within 60 seconds" "Error"
            exit 1
        }
    } catch {
        Write-Status "✗ Error starting Docker: $_" "Error"
        exit 1
    }
}

# Step 3: Navigate to the docker directory
Write-Status ""
Write-Status "► Setting up paths..." "Info"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dockerComposePath = Join-Path $scriptPath "docker-compose.yml"

if (-not (Test-Path $dockerComposePath)) {
    Write-Status "✗ docker-compose.yml not found at: $dockerComposePath" "Error"
    exit 1
}

Write-Status "✓ Working directory: $scriptPath" "Success"

# Step 4: Check if container is already running
Write-Status ""
Write-Status "► Checking container status..." "Info"
$containerRunning = $false
try {
    $containerStatus = docker ps --filter name=evalis-db 2>$null
    if ($containerStatus -and $containerStatus.Count -gt 1) {
        $containerRunning = $true
        Write-Status "✓ Container evalis-db is already running" "Success"
    } else {
        Write-Status "✓ Container needs to be started" "Info"
    }
} catch {
    Write-Status "Note: Could not check container status (may be normal)" "Warning"
}

# Step 5: Start container if not running
if (-not $containerRunning) {
    Write-Status ""
    Write-Status "► Starting container..." "Info"
    try {
        Push-Location $scriptPath
        $output = docker-compose up -d 2>&1
        Pop-Location
        Write-Status "✓ Container startup command executed" "Success"
    } catch {
        Write-Status "✗ Error starting container: $_" "Error"
        exit 1
    }
}

# Step 6: Wait for database to be ready
Write-Status ""
Write-Status "► Waiting for PostgreSQL to be ready..." "Info"
Write-Status "  (Timeout: $TimeoutSeconds seconds)" "Info"
Write-Status ""

$dbReady = $false
$elapsed = 0
$checkInterval = 2

while ($elapsed -lt $TimeoutSeconds) {
    try {
        $health = docker exec evalis-db pg_isready -U evalis_user -d evalis_db 2>$null
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            break
        }
    } catch {
        # Database not ready yet
    }

    # Show progress
    $percent = [math]::Min([math]::Round(($elapsed / $TimeoutSeconds) * 100), 99)
    Write-Host "  $percent% - Waiting..." -ForegroundColor Yellow

    Start-Sleep -Seconds $checkInterval
    $elapsed += $checkInterval
}

Write-Host ""

# Step 7: Final status check
if ($dbReady) {
    Write-Status "✓ PostgreSQL is ready for connections!" "Success"
    Write-Status ""
    Write-Status "═══════════════════════════════════════════════════════════════════" "Success"
    Write-Status "  DATABASE CONNECTION DETAILS" "Success"
    Write-Status "═══════════════════════════════════════════════════════════════════" "Success"
    Write-Status ""
    Write-Status "  Host:     localhost" "Info"
    Write-Status "  Port:     5432" "Info"
    Write-Status "  Database: evalis_db" "Info"
    Write-Status "  Username: evalis_user" "Info"
    Write-Status "  Password: evalis2024" "Info"
    Write-Status ""
    Write-Status "  Connection String:" "Info"
    Write-Status "  postgresql://evalis_user:evalis2024@localhost:5432/evalis_db" "Info"
    Write-Status ""
    Write-Status "═══════════════════════════════════════════════════════════════════" "Success"
    Write-Status ""

    if ($Wait) {
        Write-Status "Press Enter to exit..." "Info"
        Read-Host
    }
    exit 0
} else {
    Write-Status "✗ PostgreSQL failed to start within $TimeoutSeconds seconds" "Error"
    Write-Status ""
    Write-Status "Checking container logs for errors..." "Warning"
    Write-Status ""

    try {
        $logs = docker logs evalis-db --tail 30 2>&1
        Write-Host $logs
    } catch {
        Write-Status "Could not retrieve container logs" "Warning"
    }

    Write-Status ""
    Write-Status "Troubleshooting steps:" "Info"
    Write-Status "1. Verify Docker Desktop is running: docker ps" "Info"
    Write-Status "2. Check container status: docker ps -a | grep evalis-db" "Info"
    Write-Status "3. View full logs: docker logs evalis-db" "Info"
    Write-Status "4. Restart container: docker-compose down && docker-compose up -d" "Info"
    Write-Status ""
    exit 1
}
