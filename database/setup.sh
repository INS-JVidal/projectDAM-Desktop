#!/bin/bash
# ============================================
# EVALIS Desktop - Database Setup Script
# ============================================
# This script initializes the PostgreSQL database for EVALIS Desktop

set -e  # Exit on error

echo "============================================"
echo "EVALIS Desktop - Database Initialization"
echo "============================================"
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "ERROR: PostgreSQL is not installed."
    echo "Install with: sudo apt install postgresql-14"
    exit 1
fi

# Check if PostgreSQL is running
if ! sudo systemctl is-active --quiet postgresql; then
    echo "Starting PostgreSQL service..."
    sudo systemctl start postgresql
fi

# Navigate to init directory
cd "$(dirname "$0")/init"

echo "Running database initialization scripts..."
echo ""

# Run each script in order
for script in *.sql; do
    echo "Running $script..."

    if [ "$script" = "00_create_database.sql" ]; then
        sudo -u postgres psql < "$script" 2>&1 | grep -v "already exists" || true
    else
        sudo -u postgres psql -d evalis_db < "$script" 2>&1
    fi

    echo "✓ $script completed"
    echo ""
done

echo "============================================"
echo "Database initialization complete!"
echo "============================================"
echo ""
echo "Database: evalis_db"
echo "User: evalis_user"
echo "Password: evalis2024"
echo ""
echo "Demo accounts (password: Test1234):"
echo "  - cap_estudis (DepartmentHead)"
echo "  - prof_test (Teacher)"
echo "  - tutor_dam2 (GroupTutor)"
echo ""
echo "Connection string:"
echo "Server=localhost;Port=5432;Database=evalis_db;User Id=evalis_user;Password=evalis2024;"
echo ""
