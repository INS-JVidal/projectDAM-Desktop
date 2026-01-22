# EVALIS PostgreSQL Docker Stop Script
# Purpose: Stop the EVALIS PostgreSQL Docker container on Windows
# Usage: .\stop-database.ps1

param(
    [switch]$RemoveVolumes = $false,
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
Write-Host "  EVALIS PostgreSQL Database Shutdown" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Status "► Checking if Docker is running..." "Info"
try {
    $dockerCheck = docker ps 2>$null
    Write-Status "✓ Docker is accessible" "Success"
} catch {
    Write-Status "✗ Docker is not running or not accessible" "Error"
    exit 1
}

# Navigate to docker directory
Write-Status ""
Write-Status "► Setting up paths..." "Info"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dockerComposePath = Join-Path $scriptPath "docker-compose.yml"

if (-not (Test-Path $dockerComposePath)) {
    Write-Status "✗ docker-compose.yml not found at: $dockerComposePath" "Error"
    exit 1
}

Write-Status "✓ Working directory: $scriptPath" "Success"

# Check container status
Write-Status ""
Write-Status "► Checking container status..." "Info"
try {
    $containerExists = docker ps -a --filter name=evalis-db 2>$null
    if ($containerExists -and $containerExists.Count -gt 1) {
        Write-Status "✓ Container found" "Success"
    } else {
        Write-Status "✓ Container not found (already stopped)" "Info"
        Write-Status ""
        Write-Status "No action needed - container is not running" "Success"
        exit 0
    }
} catch {
    Write-Status "Could not check container status" "Warning"
}

# Prepare shutdown command
Write-Status ""
if ($RemoveVolumes) {
    Write-Status "► Stopping container and removing volumes..." "Warning"
    Write-Status "⚠️  WARNING: This will delete all database data!" "Error"
    Write-Status ""
    $response = Read-Host "Are you sure? Type 'yes' to confirm"
    if ($response -ne "yes") {
        Write-Status "✓ Cancellation - no changes made" "Success"
        exit 0
    }
    $command = "down -v"
    $description = "container and volumes"
} else {
    Write-Status "► Stopping container (data will be preserved)..." "Info"
    $command = "down"
    $description = "container"
}

# Execute shutdown
Write-Status ""
Write-Status "Executing shutdown..." "Info"
try {
    Push-Location $scriptPath
    $output = docker-compose $command 2>&1
    Pop-Location
    Write-Status "✓ Container shutdown completed" "Success"
} catch {
    Write-Status "✗ Error during shutdown: $_" "Error"
    exit 1
}

# Verify shutdown
Write-Status ""
Write-Status "► Verifying shutdown..." "Info"
Start-Sleep -Seconds 1
try {
    $stillRunning = docker ps --filter name=evalis-db 2>$null
    if ($stillRunning -and $stillRunning.Count -gt 1) {
        Write-Status "✗ Container is still running" "Warning"
    } else {
        Write-Status "✓ Container successfully stopped" "Success"
    }
} catch {
    Write-Status "✓ Container stopped (could not verify)" "Success"
}

# Final message
Write-Status ""
if ($RemoveVolumes) {
    Write-Status "═══════════════════════════════════════════════════════════════════" "Warning"
    Write-Status "  DATABASE VOLUME DELETED" "Warning"
    Write-Status "═══════════════════════════════════════════════════════════════════" "Warning"
    Write-Status ""
    Write-Status "All database data has been permanently deleted." "Warning"
    Write-Status "Next startup will reinitialize the database from scratch." "Info"
} else {
    Write-Status "═══════════════════════════════════════════════════════════════════" "Success"
    Write-Status "  SHUTDOWN COMPLETE" "Success"
    Write-Status "═══════════════════════════════════════════════════════════════════" "Success"
    Write-Status ""
    Write-Status "Database data is preserved." "Info"
    Write-Status "Next startup will restore the database automatically." "Info"
}

Write-Status ""
Write-Status "To restart the database, run: .\start-database.ps1" "Info"
Write-Status ""

if ($Wait) {
    Write-Status "Press Enter to exit..." "Info"
    Read-Host
}
exit 0
