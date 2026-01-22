#!/bin/bash
# EVALIS PostgreSQL Docker Stop Script
# Purpose: Stop the EVALIS PostgreSQL Docker container on Linux/WSL
# Usage: ./stop-database.sh [--remove-volumes]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="evalis-db"
REMOVE_VOLUMES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-volumes|-v)
            REMOVE_VOLUMES=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  EVALIS PostgreSQL Database Shutdown${NC}"
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

# Check if Docker is running
print_info "Checking if Docker is running..."
if ! docker ps &> /dev/null; then
    print_error "Docker is not running or not accessible"
    exit 1
fi

print_success "Docker is accessible"

# Navigate to script directory
print_section "► Setting up paths..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "docker-compose.yml not found at: $COMPOSE_FILE"
    exit 1
fi

print_success "Working directory: $SCRIPT_DIR"

# Check container status
print_section "► Checking container status..."
if docker ps -a --filter name=$CONTAINER_NAME 2>/dev/null | grep -q $CONTAINER_NAME; then
    print_success "Container found"
else
    print_info "Container not found (already stopped)"
    echo ""
    print_success "No action needed - container is not running"
    exit 0
fi

# Determine shutdown command
print_section "Preparing shutdown..."
if [ "$REMOVE_VOLUMES" = true ]; then
    print_warning "Stopping container and removing volumes..."
    print_error "⚠️  WARNING: This will delete all database data!"
    echo ""
    read -p "Are you sure? Type 'yes' to confirm: " response
    if [ "$response" != "yes" ]; then
        print_success "Cancellation - no changes made"
        exit 0
    fi
    COMPOSE_CMD="down -v"
else
    print_info "Stopping container (data will be preserved)..."
    COMPOSE_CMD="down"
fi

# Execute shutdown
print_section "► Executing shutdown..."
cd "$SCRIPT_DIR"

if command -v docker-compose &> /dev/null; then
    docker-compose $COMPOSE_CMD 2>/dev/null || true
elif docker compose version &> /dev/null; then
    docker compose $COMPOSE_CMD 2>/dev/null || true
else
    print_error "Could not find docker-compose or docker compose plugin"
    exit 1
fi

print_success "Container shutdown completed"

# Verify shutdown
print_section "► Verifying shutdown..."
sleep 1
if docker ps --filter name=$CONTAINER_NAME 2>/dev/null | grep -q $CONTAINER_NAME; then
    print_warning "Container is still running"
else
    print_success "Container successfully stopped"
fi

# Final message
echo ""
if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  DATABASE VOLUME DELETED${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    print_warning "All database data has been permanently deleted."
    print_info "Next startup will reinitialize the database from scratch."
else
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  SHUTDOWN COMPLETE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    print_info "Database data is preserved."
    print_info "Next startup will restore the database automatically."
fi

echo ""
print_info "To restart the database, run: ./start-database.sh"
echo ""

exit 0
