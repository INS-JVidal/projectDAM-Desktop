#!/bin/bash

# ============================================
# EVALIS Desktop - Database Initialization Script
# ============================================
# Automatically sets up the complete EVALIS database
# with all phases (Authentication, Academic Core, Extended Features)
#
# Usage: ./init.sh [OPTIONS]
# Options:
#   --force     Drop existing database and reinitialize
#   --verbose   Show detailed output from SQL scripts
#   --help      Show this help message

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_DIR="$SCRIPT_DIR/init"
POSTGRES_USER="postgres"
DB_NAME="evalis_db"
DB_USER="evalis_user"
DB_PASSWORD="evalis2024"

# Options
FORCE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            grep "^#" "$0" | head -20
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# Check if PostgreSQL is running
check_postgres() {
    log_info "Checking PostgreSQL connection..."
    if ! sudo -u $POSTGRES_USER psql -c "SELECT 1" > /dev/null 2>&1; then
        log_error "Cannot connect to PostgreSQL. Is it running?"
        echo "Try: sudo systemctl start postgresql"
        exit 1
    fi
    log_info "PostgreSQL is running ✓"
}

# Check if database exists
db_exists() {
    sudo -u $POSTGRES_USER psql -tc "SELECT 1 FROM pg_database WHERE datname = '$1'" | grep -q 1
}

# Drop existing database if --force is specified
handle_existing_db() {
    if db_exists "$DB_NAME"; then
        if [ "$FORCE" = true ]; then
            log_warn "Dropping existing database '$DB_NAME'..."
            sudo -u $POSTGRES_USER psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
            log_info "Database dropped ✓"
        else
            log_error "Database '$DB_NAME' already exists!"
            echo "Use --force to drop and reinitialize"
            exit 1
        fi
    fi
}

# Run SQL script
run_script() {
    local script="$1"
    local description="$2"

    if [ ! -f "$script" ]; then
        log_error "Script not found: $script"
        exit 1
    fi

    log_info "Running: $(basename "$script")"

    if [ "$VERBOSE" = true ]; then
        sudo -u $POSTGRES_USER psql -f "$script" 2>&1
    else
        sudo -u $POSTGRES_USER psql -f "$script" > /dev/null 2>&1
    fi

    log_info "$description ✓"
}

# Run script as evalis_user
run_script_as_user() {
    local script="$1"
    local description="$2"

    if [ ! -f "$script" ]; then
        log_error "Script not found: $script"
        exit 1
    fi

    log_info "Running: $(basename "$script")"

    if [ "$VERBOSE" = true ]; then
        psql -h localhost -d $DB_NAME -U $DB_USER -f "$script" 2>&1
    else
        psql -h localhost -d $DB_NAME -U $DB_USER -f "$script" > /dev/null 2>&1
    fi

    log_info "$description ✓"
}

# Verify installation
verify_installation() {
    log_step "Verifying Installation"

    local counts=$(psql -h localhost -d $DB_NAME -U $DB_USER -t << 'EOF'
SELECT
    (SELECT COUNT(*) FROM users) ||','||
    (SELECT COUNT(*) FROM login_audit) ||','||
    (SELECT COUNT(*) FROM sessions) ||','||
    (SELECT COUNT(*) FROM students) ||','||
    (SELECT COUNT(*) FROM subjects) ||','||
    (SELECT COUNT(*) FROM evaluation_sessions) ||','||
    (SELECT COUNT(*) FROM grades) ||','||
    (SELECT COUNT(*) FROM grade_audit) ||','||
    (SELECT COUNT(*) FROM teacher_subjects) ||','||
    (SELECT COUNT(*) FROM faculty) ||','||
    (SELECT COUNT(*) FROM documents) ||','||
    (SELECT COUNT(*) FROM document_archive)
EOF
    )

    IFS=',' read -r users login_audit sessions students subjects eval_sessions grades grade_audit teacher_subj faculty docs doc_archive <<< "$counts"

    echo "Table Record Counts:"
    echo "  Users: $users"
    echo "  Login Audit: $login_audit"
    echo "  Sessions: $sessions"
    echo "  Students: $students"
    echo "  Subjects: $subjects"
    echo "  Evaluation Sessions: $eval_sessions"
    echo "  Grades: $grades"
    echo "  Grade Audit: $grade_audit"
    echo "  Teacher Subjects: $teacher_subj"
    echo "  Faculty: $faculty"
    echo "  Documents: $docs"
    echo "  Document Archive: $doc_archive"

    # Check minimum expected data
    if (( users >= 5 && students >= 10 && grades >= 20 )); then
        log_info "Installation verified successfully! ✓"
        return 0
    else
        log_warn "Installation completed but some expected data may be missing"
        return 0
    fi
}

# Main execution
main() {
    log_step "EVALIS Desktop - Database Initialization"

    # Pre-flight checks
    check_postgres
    handle_existing_db

    # Phase 1: Authentication & Security
    log_step "Phase 1: Authentication & Security"
    run_script "$INIT_DIR/00_create_database.sql" "Database created"
    run_script "$INIT_DIR/01_create_schemas.sql" "Schemas created"
    run_script_as_user "$INIT_DIR/02_create_tables.sql" "Authentication tables created"
    run_script_as_user "$INIT_DIR/03_create_indexes.sql" "Authentication indexes created"
    run_script_as_user "$INIT_DIR/04_create_functions.sql" "Authentication functions created"
    run_script_as_user "$INIT_DIR/05_seed_data.sql" "Demo accounts seeded"

    # Phase 2: Academic Core
    log_step "Phase 2: Academic Core"
    run_script_as_user "$INIT_DIR/06_phase2_academic_tables.sql" "Academic tables created"
    run_script_as_user "$INIT_DIR/07_phase2_indexes.sql" "Academic indexes created"
    run_script_as_user "$INIT_DIR/10_business_logic_functions.sql" "Business logic functions created"
    run_script_as_user "$INIT_DIR/11_seed_data_academic.sql" "Academic data seeded"

    # Phase 3: Extended Features
    log_step "Phase 3: Extended Features"
    run_script_as_user "$INIT_DIR/08_phase3_extended_tables.sql" "Extended tables created"
    run_script_as_user "$INIT_DIR/09_phase3_indexes.sql" "Extended indexes created"
    run_script_as_user "$INIT_DIR/12_seed_data_extended.sql" "Extended data seeded"

    # Verify
    verify_installation

    # Final message
    log_step "Installation Complete!"
    echo ""
    echo "Database: $DB_NAME"
    echo "User: $DB_USER"
    echo "Password: $DB_PASSWORD (CHANGE IN PRODUCTION)"
    echo ""
    echo "Demo Accounts (password: Test1234):"
    echo "  - cap_estudis (Department Head)"
    echo "  - prof_test (Teacher)"
    echo "  - tutor_dam2 (Group Tutor)"
    echo "  - prof_prog (Teacher)"
    echo "  - prof_bbdd (Teacher)"
    echo ""
    echo "Connection string for applications:"
    echo "  postgresql://evalis_user:evalis2024@localhost/evalis_db"
    echo ""
    log_info "For setup details, see: $SCRIPT_DIR/SETUP_INSTRUCTIONS.md"
}

# Run main function
main "$@"
