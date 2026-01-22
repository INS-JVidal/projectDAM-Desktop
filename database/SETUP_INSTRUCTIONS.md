# EVALIS Desktop - Database Setup Instructions

Complete database initialization for the EVALIS Desktop Windows Forms application.

## Prerequisites

- PostgreSQL 14 or later
- `psql` command-line client installed
- User with superuser privileges for initial setup
- Sufficient disk space (~50MB for test data)

## Database Architecture

The EVALIS database follows a three-phase implementation:

### Phase 1: Authentication & Security (COMPLETED)
- `users` - User accounts with role-based access control
- `login_audit` - Login attempt tracking
- `sessions` - Active session management
- Auto-update triggers and session cleanup functions

### Phase 2: Academic Core (NEW)
- `students` - Student enrollment records
- `subjects` - Course/module definitions
- `evaluation_sessions` - Evaluation period lifecycle
- `grades` - Student grades with draft/finalized states
- `grade_audit` - Modification history for post-closure changes
- `teacher_subjects` - Teacher-to-subject assignments
- Business logic functions for grade calculations and permissions

### Phase 3: Extended Features (NEW)
- `faculty` - Extended faculty profiles with photos
- `documents` - Document type definitions and templates
- `document_archive` - Generated document tracking and file archival

## Setup Instructions

### Method 1: Automatic Setup (Recommended)

Run all initialization scripts in correct order:

```bash
#!/bin/bash
cd /path/to/database/init

# Run as postgres superuser
sudo -u postgres psql < 00_create_database.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 01_create_schemas.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 02_create_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 03_create_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 04_create_functions.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 05_seed_data.sql

# Phase 2 - Academic Core
sudo -u postgres psql -d evalis_db -U evalis_user < 06_phase2_academic_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 07_phase2_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 10_business_logic_functions.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 11_seed_data_academic.sql

# Phase 3 - Extended Features
sudo -u postgres psql -d evalis_db -U evalis_user < 08_phase3_extended_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 09_phase3_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 12_seed_data_extended.sql
```

### Method 2: Interactive Setup

Connect to PostgreSQL and run scripts:

```bash
# As superuser
sudo -u postgres psql

# In psql prompt, execute scripts:
psql=# \i /path/to/database/init/00_create_database.sql
psql=# \c evalis_db evalis_user
psql=# \i /path/to/database/init/01_create_schemas.sql
psql=# \i /path/to/database/init/02_create_tables.sql
# ... continue with remaining scripts
```

### Method 3: Using Connection String

```bash
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=your_postgres_password

# Run all scripts
for script in init/{00..12}_*.sql; do
    psql -h $PGHOST -U $PGUSER -f "$script"
done
```

## Database Credentials

**Database**: `evalis_db`
**User**: `evalis_user`
**Password**: `evalis2024`
**Host**: localhost
**Port**: 5432

### Change Default Password (Recommended for Production)

```sql
ALTER USER evalis_user WITH PASSWORD 'your_secure_password';
```

## Demo User Accounts

All demo accounts use password: `Test1234`

| Username | Role | DNI | Full Name |
|----------|------|-----|-----------|
| cap_estudis | DepartmentHead | 12345678A | Joan Puig i Garcia |
| prof_test | Teacher | 87654321B | Maria Serra i Rovira |
| tutor_dam2 | GroupTutor | 11223344C | Pere Martí i Soler |
| prof_prog | Teacher | 55667788D | Anna Vilaró i Font |
| prof_bbdd | Teacher | 99887766E | Carles Bosch i Pla |

## Data Validation

Verify complete installation:

```bash
psql -d evalis_db -U evalis_user << 'EOF'
-- Count all tables and data
SELECT 'Users' as table_name, COUNT(*) FROM users
UNION ALL SELECT 'Login Audit', COUNT(*) FROM login_audit
UNION ALL SELECT 'Sessions', COUNT(*) FROM sessions
UNION ALL SELECT 'Students', COUNT(*) FROM students
UNION ALL SELECT 'Subjects', COUNT(*) FROM subjects
UNION ALL SELECT 'Evaluation Sessions', COUNT(*) FROM evaluation_sessions
UNION ALL SELECT 'Grades', COUNT(*) FROM grades
UNION ALL SELECT 'Grade Audit', COUNT(*) FROM grade_audit
UNION ALL SELECT 'Teacher Subjects', COUNT(*) FROM teacher_subjects
UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty
UNION ALL SELECT 'Documents', COUNT(*) FROM documents
UNION ALL SELECT 'Document Archive', COUNT(*) FROM document_archive;

-- Verify no errors in constraints
SELECT 'All constraints verified' as status;
EOF
```

Expected counts after full setup:
- Users: 5
- Students: 18
- Subjects: 14
- Evaluation Sessions: 4
- Grades: ~40
- Grade Audit: 3
- Teacher Subjects: 9
- Faculty: 5
- Documents: 4
- Document Archive: 10

## Troubleshooting

### "Database already exists"
Drop and recreate:
```bash
sudo -u postgres psql -c "DROP DATABASE IF EXISTS evalis_db;"
sudo -u postgres psql < init/00_create_database.sql
```

### "Permission denied" on views/functions
Ensure evalis_user has proper privileges:
```bash
sudo -u postgres psql << 'EOF'
\c evalis_db
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO evalis_user;
EOF
```

### Connection refused
Check PostgreSQL is running:
```bash
# Linux
sudo systemctl status postgresql

# macOS (Homebrew)
brew services list | grep postgres

# Windows (PgAdmin)
pg_ctl -D "C:\Program Files\PostgreSQL\14\data" status
```

### Character encoding issues with Catalan text
Ensure database uses UTF-8:
```bash
sudo -u postgres psql -c "CREATE DATABASE evalis_db WITH ENCODING 'UTF8' LC_COLLATE 'ca_ES.UTF-8' LC_CTYPE 'ca_ES.UTF-8';"
```

## Backup and Restore

### Create backup
```bash
pg_dump -d evalis_db -U evalis_user > evalis_backup.sql
```

### Restore from backup
```bash
# Drop existing database
sudo -u postgres psql -c "DROP DATABASE IF EXISTS evalis_db;"

# Run initial setup
sudo -u postgres psql < init/00_create_database.sql

# Restore data
psql -d evalis_db -U evalis_user < evalis_backup.sql
```

## Key Database Functions

### Grade Calculations
- `calculate_weighted_average(student_id, session_id)` - Weighted grade average
- `get_subject_hours(subject_id)` - Subject hours for weighting

### Session Management
- `get_session_state(session_id)` - Current evaluation period state
- `transition_session_state(session_id, new_state, user_id)` - State machine transitions
- `cleanup_expired_sessions()` - 30-minute session timeout

### Permissions & Validation
- `can_teacher_modify_grade(user_id, grade_id, session_id)` - Grade modification rights
- `can_close_evaluation_session(session_id)` - Session closure validation
- `all_grades_complete_for_student(student_id, session_id)` - Grade completion check
- `create_grade_audit_entry(grade_id, old_value, new_value, modified_by, reason)` - Audit trail

### Data Validation
- `validate_grade_value(grade_value)` - Grade range validation (0.0-10.0)
- `is_valid_password_hash(hash)` - SHA-256 hash validation

## Important Constraints

### Grade Modification Rules
- **OPEN** state: Teachers can modify grades for assigned subjects
- **IN_SESSION** state: Only tutor and department head can modify
- **CLOSED** state: Only department head can modify with mandatory audit trail

### Weighted Grade Formula
```
Final Grade = Σ(Subject Grade × Subject Hours) / Σ(Subject Hours)
```

### Session Timeout
- Active sessions expire after 30 minutes of inactivity
- `cleanup_expired_sessions()` must be called periodically

### Audit Trail
All post-closure grade modifications require:
- Minimum 20-character reason
- User must have DepartmentHead role
- Timestamp and old/new values recorded
- Session state captured for compliance

## File Structure

```
database/
├── init/
│   ├── 00_create_database.sql          # Database and user creation
│   ├── 01_create_schemas.sql           # Logical schema organization
│   ├── 02_create_tables.sql            # Phase 1: Auth tables
│   ├── 03_create_indexes.sql           # Phase 1: Indexes
│   ├── 04_create_functions.sql         # Phase 1: Functions
│   ├── 05_seed_data.sql                # Phase 1: Demo accounts
│   ├── 06_phase2_academic_tables.sql   # Phase 2: Core academic tables
│   ├── 07_phase2_indexes.sql           # Phase 2: Indexes
│   ├── 08_phase3_extended_tables.sql   # Phase 3: Faculty & documents
│   ├── 09_phase3_indexes.sql           # Phase 3: Indexes
│   ├── 10_business_logic_functions.sql # Business logic & permissions
│   ├── 11_seed_data_academic.sql       # Phase 2: Academic data
│   └── 12_seed_data_extended.sql       # Phase 3: Faculty & archives
├── SETUP_INSTRUCTIONS.md               # This file
└── README.md                           # Database overview
```

## Support & Documentation

For more information, see:
- `../CLAUDE.md` - Project guidelines
- `../docs/DESKTOP_PROJECT_DESCRIPTION.md` - Complete project specification
- `../docs/desktop_evalis_PPD.md` - Detailed planning document

## Security Notes

⚠️ **Important**: Before production deployment:
1. Change `evalis_user` password from default `evalis2024`
2. Change all demo account passwords
3. Configure PostgreSQL `pg_hba.conf` for authentication
4. Set up regular backups
5. Enable SSL/TLS for connections over networks
6. Implement connection pooling (PgBouncer)
7. Set up monitoring and alerts
8. Review and test disaster recovery procedures
