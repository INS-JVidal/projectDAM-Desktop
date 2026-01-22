#!/bin/bash
# EVALIS PostgreSQL Docker Start Script
# Purpose: Start the EVALIS PostgreSQL Docker container on Linux/WSL
# Usage: ./start-database.sh
#
# Requirements:
# - Docker installed and running
# - docker-compose or docker compose installed
# - Permission to run docker (add user to docker group or use sudo)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
TIMEOUT_SECONDS=120
CONTAINER_NAME="evalis-db"
CHECK_INTERVAL=2

# Helper functions
print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  EVALIS PostgreSQL Database Startup${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}► $1${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}$1${NC}"
}

# Main script

print_header

# Step 1: Check if Docker is installed
print_info "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    print_error "Docker not found!"
    echo ""
    echo "Please install Docker from: https://docs.docker.com/engine/install/"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
print_success "Docker found: $DOCKER_VERSION"

# Step 2: Check if Docker daemon is running
print_section "► Checking if Docker daemon is running..."
if ! docker ps &> /dev/null; then
    print_error "Docker daemon not running!"
    echo ""
    echo "Please start Docker and try again."
    echo "Common commands:"
    echo "  - Systemd: sudo systemctl start docker"
    echo "  - Desktop: Start Docker Desktop application"
    exit 1
fi

print_success "Docker daemon is running"

# Step 3: Check docker-compose
print_section "► Checking docker-compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    print_success "Found: docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_success "Found: docker compose (plugin)"
else
    print_error "docker-compose or docker compose plugin not found!"
    exit 1
fi

# Step 4: Navigate to script directory
print_section "► Setting up paths..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "docker-compose.yml not found at: $COMPOSE_FILE"
    exit 1
fi

print_success "Working directory: $SCRIPT_DIR"

# Step 5: Check if container is already running
print_section "► Checking container status..."
if docker ps --filter name=$CONTAINER_NAME 2>/dev/null | grep -q $CONTAINER_NAME; then
    print_success "Container $CONTAINER_NAME is already running"
    CONTAINER_RUNNING=true
else
    print_info "Container needs to be started"
    CONTAINER_RUNNING=false
fi

# Step 6: Start container if not running
if [ "$CONTAINER_RUNNING" = false ]; then
    print_section "► Starting container..."
    cd "$SCRIPT_DIR"
    if $COMPOSE_CMD up -d 2>/dev/null; then
        print_success "Container startup command executed"
    else
        print_error "Error starting container"
        exit 1
    fi
fi

# Step 7: Wait for database to be ready
print_section "► Waiting for PostgreSQL to be ready..."
echo "  (Timeout: $TIMEOUT_SECONDS seconds)"
echo ""

DB_READY=false
ELAPSED=0
START_TIME=$(date +%s)

while [ $ELAPSED -lt $TIMEOUT_SECONDS ]; do
    if docker exec $CONTAINER_NAME pg_isready -U evalis_user -d evalis_db &>/dev/null; then
        DB_READY=true
        break
    fi

    # Show progress
    PERCENT=$(( (ELAPSED * 100) / TIMEOUT_SECONDS ))
    PERCENT=$(( PERCENT < 99 ? PERCENT : 99 ))
    echo -ne "  $PERCENT% - Waiting...\r"

    sleep $CHECK_INTERVAL
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
done

echo ""
echo ""

# Step 8: Final status
if [ "$DB_READY" = true ]; then
    print_success "PostgreSQL is ready for connections!"

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  DATABASE CONNECTION DETAILS${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}  Host:     localhost${NC}"
    echo -e "${CYAN}  Port:     5432${NC}"
    echo -e "${CYAN}  Database: evalis_db${NC}"
    echo -e "${CYAN}  Username: evalis_user${NC}"
    echo -e "${CYAN}  Password: evalis2024${NC}"
    echo ""
    echo -e "${CYAN}  Connection String:${NC}"
    echo -e "${CYAN}  postgresql://evalis_user:evalis2024@localhost:5432/evalis_db${NC}"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    exit 0
else
    print_error "PostgreSQL failed to start within $TIMEOUT_SECONDS seconds"
    echo ""
    print_warning "Checking container logs for errors..."
    echo ""

    docker logs $CONTAINER_NAME --tail 30 || true

    echo ""
    print_info "Troubleshooting steps:"
    echo "  1. Verify Docker is running: docker ps"
    echo "  2. Check container status: docker ps -a | grep $CONTAINER_NAME"
    echo "  3. View full logs: docker logs $CONTAINER_NAME"
    echo "  4. Restart container: $COMPOSE_CMD down && $COMPOSE_CMD up -d"
    echo ""
    exit 1
fi
