# EVALIS Desktop - Complete PostgreSQL Database Schema

Comprehensive educational evaluation management database for Catalan VET institutions.

**Database**: `evalis_db`
**DBMS**: PostgreSQL 14+
**Locale**: Catalan (ca_ES.UTF-8)
**Implementation Status**: Phase 1-3 Complete

## Architecture Overview

Three-phase database implementation supporting:
- **Phase 1**: Authentication, role-based access control, login auditing
- **Phase 2**: Academic core (students, subjects, grades, evaluation periods)
- **Phase 3**: Extended features (faculty profiles, document generation, archival)

## Quick Start

### Docker Setup (Recommended)

The database runs automatically in a Docker container when you start the VB.NET application:

```bash
# Option 1: Just run the VB.NET application
# It will automatically:
# - Detect Docker installation
# - Start Docker if needed
# - Initialize the PostgreSQL container
# - Set up all tables and seed data

# Option 2: Manually start the database
cd database/docker
.\start-database.ps1           # Windows PowerShell
# or
./start-database.sh            # Linux/WSL/macOS
```

For complete Docker setup guide, see [`database/docker/README.md`](docker/README.md) and [`docs/DOCKER_SETUP.md`](../docs/DOCKER_SETUP.md)

### Legacy Local Setup (if Docker unavailable)

```bash
cd database
chmod +x init.sh
./init.sh                    # Automatic setup
# OR
./init.sh --force --verbose  # Drop existing, show detailed output
```

For detailed instructions, see `SETUP_INSTRUCTIONS.md`

## Directory Structure

```
database/
├── init/                              # SQL initialization scripts
│   ├── 00_create_database.sql         # Database and user setup
│   ├── 01_create_schemas.sql          # Schema organization
│   ├── 02_create_tables.sql           # Phase 1: Authentication tables
│   ├── 03_create_indexes.sql          # Phase 1: Performance indexes
│   ├── 04_create_functions.sql        # Phase 1: Functions & triggers
│   ├── 05_seed_data.sql               # Phase 1: Demo accounts
│   ├── 06_phase2_academic_tables.sql  # Phase 2: Academic tables
│   ├── 07_phase2_indexes.sql          # Phase 2: Indexes
│   ├── 08_phase3_extended_tables.sql  # Phase 3: Faculty & documents
│   ├── 09_phase3_indexes.sql          # Phase 3: Indexes
│   ├── 10_business_logic_functions.sql# Business logic & permissions
│   ├── 11_seed_data_academic.sql      # Phase 2: Academic data (18 students, 14 subjects)
│   └── 12_seed_data_extended.sql      # Phase 3: Faculty & documents
├── init.sh                            # Automated setup script
├── setup.sh                           # Legacy setup (deprecated)
├── migrations/                        # Future schema changes
├── SETUP_INSTRUCTIONS.md              # Detailed setup guide
└── README.md                          # This file
```

## Database Tables Overview

### Phase 1: Authentication & Security ✓ COMPLETE
| Table | Purpose | Records |
|-------|---------|---------|
| `users` | User accounts with roles | 5 demo accounts |
| `login_audit` | Login attempt tracking | 5+ sample entries |
| `sessions` | Active session management | Dynamic |

### Phase 2: Academic Core ✓ COMPLETE
| Table | Purpose | Records |
|-------|---------|---------|
| `students` | Student enrollment | 18 students across 4 cycles |
| `subjects` | Course definitions | 14 subjects with credits/hours |
| `evaluation_sessions` | Evaluation period lifecycle | 4 periods (1st-Final for 2024-2025) |
| `grades` | Student subject grades | 40+ grades in various states |
| `grade_audit` | Grade modification history | 3 example audit entries |
| `teacher_subjects` | Teacher-subject assignments | 9 assignments |

### Phase 3: Extended Features ✓ COMPLETE
| Table | Purpose | Records |
|-------|---------|---------|
| `faculty` | Faculty profiles with photos | 5 faculty members |
| `documents` | Document template definitions | 4 document types |
| `document_archive` | Generated document tracking | 10 sample archived documents |

## Setup & Installation

### Prerequisites
- PostgreSQL 14 or later
- `psql` client installed
- User with superuser privileges
- Bash shell (for automated setup)

### Automatic Setup (Recommended)

```bash
cd database
./init.sh                    # Standard setup
./init.sh --force           # Drop existing database first
./init.sh --verbose         # Show detailed SQL output
```

### Manual Setup

```bash
cd database/init

# Phase 1: Authentication
sudo -u postgres psql < 00_create_database.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 01_create_schemas.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 02_create_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 03_create_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 04_create_functions.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 05_seed_data.sql

# Phase 2: Academic Core
sudo -u postgres psql -d evalis_db -U evalis_user < 06_phase2_academic_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 07_phase2_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 10_business_logic_functions.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 11_seed_data_academic.sql

# Phase 3: Extended Features
sudo -u postgres psql -d evalis_db -U evalis_user < 08_phase3_extended_tables.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 09_phase3_indexes.sql
sudo -u postgres psql -d evalis_db -U evalis_user < 12_seed_data_extended.sql
```

## Comprehensive Schema Reference

### Entity Relationship Diagram

```
USERS (1) ←──M──→ LOGIN_AUDIT
  ├─ (1) ←──M──→ SESSIONS
  ├─ (1) ←──M──→ TEACHER_SUBJECTS
  ├─ (1) ←──1──→ FACULTY
  ├─ (1) ←──M──→ GRADES (entered_by)
  └─ (1) ←──M──→ GRADE_AUDIT (modified_by)

STUDENTS (1) ←──M──→ GRADES
  └─ (1) ←──M──→ DOCUMENT_ARCHIVE

SUBJECTS (1) ←──M──→ GRADES
  └─ (1) ←──M──→ TEACHER_SUBJECTS

EVALUATION_SESSIONS (1) ←──M──→ GRADES
  └─ (1) ←──M──→ GRADE_AUDIT

GRADES (1) ←──M──→ GRADE_AUDIT

DOCUMENTS (1) ←──M──→ DOCUMENT_ARCHIVE
```

### Phase 1: Authentication Tables

#### `users`
User accounts with role-based access control.

**Roles**: DepartmentHead | Teacher | GroupTutor

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | SERIAL | PK | Primary key |
| dni | VARCHAR(9) | UNIQUE, NOT NULL | Spanish national ID |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Login username |
| password_hash | VARCHAR(64) | NOT NULL | SHA-256 hash (64 hex chars) |
| role | VARCHAR(20) | NOT NULL, CHECK | DepartmentHead/Teacher/GroupTutor |
| full_name | VARCHAR(100) | NOT NULL | User's full name |
| email | VARCHAR(100) | | Email address |
| is_active | BOOLEAN | DEFAULT TRUE | Account status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification time |

**Trigger**: `update_users_updated_at` - Auto-updates `updated_at` on modification

#### `login_audit`
Security audit log tracking all authentication attempts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| audit_id | BIGSERIAL | PK | Primary key |
| user_id | INTEGER | FK users(user_id) | User (NULL for failed attempts) |
| username | VARCHAR(50) | NOT NULL | Attempted username |
| login_time | TIMESTAMP | DEFAULT NOW() | Attempt timestamp |
| ip_address | INET | | Source IP address |
| status | VARCHAR(20) | NOT NULL, CHECK | SUCCESS \| FAILED |
| failure_reason | VARCHAR(200) | | Reason for failure |

**Indexes**: user_id, username, login_time DESC, status, (login_time DESC WHERE status='FAILED')

#### `sessions`
Active user session tracking with 30-minute inactivity timeout.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| session_id | UUID | PK | Session identifier |
| user_id | INTEGER | FK users(user_id), NOT NULL | User reference |
| login_time | TIMESTAMP | DEFAULT NOW() | Session start time |
| last_activity | TIMESTAMP | DEFAULT NOW() | Last action timestamp |
| ip_address | INET | | Client IP address |
| is_active | BOOLEAN | DEFAULT TRUE | Session status |

**Function**: `cleanup_expired_sessions()` - Deactivates sessions >30 min inactive

### Phase 2: Academic Tables

#### `students`
Student enrollment and academic records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| student_id | SERIAL | PK | Primary key |
| nia | VARCHAR(20) | UNIQUE, NOT NULL | Student ID number |
| full_name | VARCHAR(150) | NOT NULL | Student name |
| cycle | VARCHAR(10) | NOT NULL, CHECK | DAM \| DAW \| ASIX \| SMX |
| group_name | VARCHAR(10) | NOT NULL | Class group (DAM2A, DAW1B, etc.) |
| status | VARCHAR(20) | DEFAULT 'Active' | Active \| Graduated \| Withdrawn |
| enrollment_date | DATE | NOT NULL, DEFAULT TODAY | Date enrolled |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |

**Indexes**: nia, cycle, group_name, status, (cycle, group_name)

#### `subjects`
Course/module definitions with credits and hours.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| subject_id | SERIAL | PK | Primary key |
| code | VARCHAR(10) | UNIQUE, NOT NULL | Subject code (MP06, MP07, etc.) |
| name | VARCHAR(150) | NOT NULL | Subject name (Catalan) |
| cycle | VARCHAR(10) | NOT NULL, CHECK | Academic cycle |
| hours_per_week | SMALLINT | NOT NULL, CHECK >0 | Weekly instructional hours |
| credits | DECIMAL(4,2) | NOT NULL, CHECK >0 | ECTS credits |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |

**Indexes**: code, cycle, (cycle, is_active), is_active

#### `evaluation_sessions`
Evaluation periods with strict state machine (OPEN → IN_SESSION → CLOSED).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| session_id | SERIAL | PK | Primary key |
| academic_year | VARCHAR(9) | NOT NULL, CHECK regex | Year (2024-2025 format) |
| period | VARCHAR(20) | NOT NULL, CHECK | 1st \| 2nd \| 3rd \| Final |
| state | VARCHAR(20) | NOT NULL, DEFAULT 'OPEN' | OPEN \| IN_SESSION \| CLOSED |
| start_date | DATE | NOT NULL | Period start |
| end_date | DATE | NOT NULL | Period end |
| opened_by | INTEGER | NOT NULL, FK users | Department head who opened |
| closed_by | INTEGER | FK users | Department head who closed |
| closed_at | TIMESTAMP | | Closure timestamp |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |
| UNIQUE | (academic_year, period) | | One period per year |
| CHECK | start_date < end_date | | Valid date range |

**Indexes**: academic_year, period, state, (academic_year, period, state), opened_by, (closed_by WHERE NOT NULL)

#### `grades`
Student grades for subjects in evaluation periods.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| grade_id | BIGSERIAL | PK | Primary key |
| student_id | INTEGER | NOT NULL, FK students | Student reference |
| subject_id | INTEGER | NOT NULL, FK subjects | Subject reference |
| session_id | INTEGER | NOT NULL, FK eval_sessions | Evaluation period |
| grade_value | DECIMAL(4,2) | CHECK 0-10 or NULL | Numeric grade |
| is_draft | BOOLEAN | DEFAULT TRUE | Draft vs finalized status |
| entered_by | INTEGER | NOT NULL, FK users | Teacher who entered |
| entered_at | TIMESTAMP | DEFAULT NOW() | Entry timestamp |
| modified_at | TIMESTAMP | DEFAULT NOW() | Last modification |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| UNIQUE | (student_id, subject_id, session_id) | | One grade per period |

**Indexes**: student_id, subject_id, session_id, entered_by, (student_id, subject_id, session_id), (student_id, session_id), (subject_id, session_id), is_draft WHERE is_draft=TRUE, modified_at DESC

**Trigger**: `update_grades_updated_at` - Auto-updates `modified_at`

#### `grade_audit`
Append-only audit trail for post-closure grade modifications.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| audit_id | BIGSERIAL | PK | Primary key |
| grade_id | BIGINT | NOT NULL, FK grades | Modified grade |
| old_value | DECIMAL(4,2) | | Previous grade value |
| new_value | DECIMAL(4,2) | NOT NULL | New grade value |
| modified_by | INTEGER | NOT NULL, FK users | Department head who modified |
| modified_at | TIMESTAMP | DEFAULT NOW() | Modification timestamp |
| reason | TEXT | NOT NULL, CHECK >=20 chars | Mandatory modification reason |
| session_state | VARCHAR(20) | NOT NULL, CHECK | State when modified (CLOSED) |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |

**Indexes**: grade_id, modified_by, modified_at DESC, session_state, (grade_id, modified_at DESC)

**IMPORTANT**: Append-only design - never delete audit entries (compliance requirement)

#### `teacher_subjects`
Assignment of teachers to subjects by academic year and group.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| assignment_id | SERIAL | PK | Primary key |
| teacher_id | INTEGER | NOT NULL, FK users | Teacher reference |
| subject_id | INTEGER | NOT NULL, FK subjects | Subject reference |
| academic_year | VARCHAR(9) | NOT NULL, CHECK regex | Academic year |
| group_name | VARCHAR(10) | NOT NULL | Class group |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |
| UNIQUE | (teacher_id, subject_id, academic_year, group_name) | | One assignment per combo |

**Indexes**: teacher_id, subject_id, academic_year, group_name, (teacher_id, academic_year), (subject_id, academic_year), (teacher_id, subject_id, academic_year)

**Trigger**: `update_teacher_subjects_updated_at`

### Phase 3: Extended Tables

#### `faculty`
Extended faculty profiles with photo gallery support.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| faculty_id | SERIAL | PK | Primary key |
| user_id | INTEGER | UNIQUE, NOT NULL, FK users | One-to-one with users |
| photo_path | VARCHAR(500) | | File server path to portrait |
| department | VARCHAR(100) | | Department name |
| phone | VARCHAR(20) | | Contact phone number |
| specialization | VARCHAR(150) | | Teaching specialization |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |

**Indexes**: user_id, department, specialization

**Trigger**: `update_faculty_updated_at`

#### `documents`
Document type definitions and template file paths.

**Types**: Bulletin | Record | Expedient | Certificate

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| document_id | SERIAL | PK | Primary key |
| document_type | VARCHAR(50) | NOT NULL, CHECK | Document category |
| template_path | VARCHAR(500) | NOT NULL | Path to PDF template |
| description | VARCHAR(500) | | Human-readable description |
| is_active | BOOLEAN | DEFAULT TRUE | Template active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last modification |
| UNIQUE | (document_type) | | One template per type |

**Indexes**: document_type, is_active WHERE is_active=TRUE

**Trigger**: `update_documents_updated_at`

#### `document_archive`
Generated document tracking and file server archival.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| archive_id | BIGSERIAL | PK | Primary key |
| document_id | INTEGER | NOT NULL, FK documents | Document type |
| student_id | INTEGER | NOT NULL, FK students | Student for whom generated |
| file_path | VARCHAR(500) | UNIQUE, NOT NULL | File server path (NIA_Name_Cycle_Year.pdf) |
| generated_by | INTEGER | NOT NULL, FK users | User who generated |
| generated_at | TIMESTAMP | DEFAULT NOW() | Generation timestamp |
| academic_year | VARCHAR(9) | NOT NULL, CHECK regex | Academic year |
| checksum | VARCHAR(64) | | SHA-256 hash for integrity |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation time |

**Indexes**: document_id, student_id, generated_by, academic_year, generated_at DESC, file_path, (student_id, document_id, academic_year)

## Key Business Rules

### Grade Modification Permissions by State

| User Role | OPEN | IN_SESSION | CLOSED |
|-----------|------|-----------|--------|
| **Teacher** | ✓ Own subjects | ✗ | ✗ |
| **GroupTutor** | ✗ | ✓ Any | ✗ |
| **DepartmentHead** | ✓ Any | ✓ Any | ✓ (with audit) |

### Weighted Grade Calculation

Final grade for evaluation period:
```
Average = Σ(Subject Grade × Subject Hours) / Σ(Subject Hours)

Example (DAM2A):
- Programació: 8.5 × 6h = 51
- Bases de Dades: 7.0 × 5h = 35
- Entorns: 9.0 × 3h = 27
- Average = (51 + 35 + 27) / (6 + 5 + 3) = 113 / 14 = 8.07
```

### Post-Closure Modifications

When session state is CLOSED, grade modifications require:
1. User must be DepartmentHead
2. Reason field minimum 20 characters
3. Creates grade_audit entry with old/new values
4. Captures session state and timestamp
5. Preserves audit trail permanently (never delete)
6. All changes are reversible via new modification

### Session Timeout

- Active sessions expire after 30 minutes of inactivity
- `last_activity` column updated on each user action
- `cleanup_expired_sessions()` deactivates expired sessions
- Should be called periodically (e.g., via cron job)

## Business Logic Functions

### Grade Calculations
- `calculate_weighted_average(student_id, session_id)` - Weighted average
- `get_subject_hours(subject_id)` - Weekly hours for subject

### Session Management
- `get_session_state(session_id)` - Current evaluation period state
- `transition_session_state(session_id, new_state, user_id)` - State machine transitions
- `cleanup_expired_sessions()` - Deactivate sessions >30 min inactive

### Permissions & Validation
- `can_teacher_modify_grade(user_id, grade_id, session_id)` - Grade modification rights
- `can_close_evaluation_session(session_id)` - Closure eligibility check
- `all_grades_complete_for_student(student_id, session_id)` - Completion validation
- `create_grade_audit_entry(...)` - Create modification audit trail

### Data Validation
- `validate_grade_value(grade_value)` - Range validation (0.0-10.0 or NULL)
- `is_valid_password_hash(hash)` - SHA-256 hash format (64 hex chars)

## Demo Accounts

All demo accounts use password: `Test1234` (SHA-256: `07480fb9e85...`)

| Username | DNI | Role | Full Name | Email |
|----------|-----|------|-----------|-------|
| cap_estudis | 12345678A | DepartmentHead | Joan Puig i Garcia | jpuig@institut.cat |
| prof_test | 87654321B | Teacher | Maria Serra i Rovira | mserra@institut.cat |
| tutor_dam2 | 11223344C | GroupTutor | Pere Martí i Soler | pmarti@institut.cat |
| prof_prog | 55667788D | Teacher | Anna Vilaró i Font | avilaro@institut.cat |
| prof_bbdd | 99887766E | Teacher | Carles Bosch i Pla | cbosch@institut.cat |

## Connection Configuration

### Connection String

**PostgreSQL URL Format**:
```
postgresql://evalis_user:evalis2024@localhost:5432/evalis_db
```

**VB.NET Connection String**:
```
Server=localhost;Port=5432;Database=evalis_db;User Id=evalis_user;Password=evalis2024;
```

### VB.NET Connection Example

```vbnet
Imports Npgsql

' Create and test connection
Dim connectionString As String = "Server=localhost;Port=5432;Database=evalis_db;User Id=evalis_user;Password=evalis2024;"
Using conn As New NpgsqlConnection(connectionString)
    conn.Open()
    Dim cmd As New NpgsqlCommand("SELECT user_id, username, role FROM users WHERE is_active = TRUE", conn)
    Dim reader As NpgsqlDataReader = cmd.ExecuteReader()
    While reader.Read()
        Dim userId As Integer = reader("user_id")
        Dim username As String = reader("username")
        Dim role As String = reader("role")
    End While
End Using
```

## Verification After Setup

Verify complete installation with:

```bash
psql -d evalis_db -U evalis_user << 'EOF'
-- Check all tables exist and have data
SELECT 'Users' as table_name, COUNT(*) FROM users
UNION ALL SELECT 'Students', COUNT(*) FROM students
UNION ALL SELECT 'Subjects', COUNT(*) FROM subjects
UNION ALL SELECT 'Evaluation Sessions', COUNT(*) FROM evaluation_sessions
UNION ALL SELECT 'Grades', COUNT(*) FROM grades
UNION ALL SELECT 'Grade Audit', COUNT(*) FROM grade_audit
UNION ALL SELECT 'Teacher Subjects', COUNT(*) FROM teacher_subjects
UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty
UNION ALL SELECT 'Documents', COUNT(*) FROM documents
UNION ALL SELECT 'Document Archive', COUNT(*) FROM document_archive;
EOF
```

Expected minimum counts:
- Users: 5
- Students: 18
- Subjects: 14
- Evaluation Sessions: 4
- Grades: 40+
- Grade Audit: 3
- Teacher Subjects: 9
- Faculty: 5
- Documents: 4
- Document Archive: 10

## Data Validation Queries

### Check students by cycle and status
```sql
SELECT cycle, status, COUNT(*) FROM students GROUP BY cycle, status ORDER BY cycle;
```

### Check grades in various states
```sql
SELECT
  es.period,
  es.state,
  COUNT(*) as total_grades,
  COUNT(CASE WHEN g.is_draft THEN 1 END) as draft_grades,
  COUNT(CASE WHEN g.grade_value IS NULL THEN 1 END) as incomplete
FROM grades g
JOIN evaluation_sessions es ON g.session_id = es.session_id
GROUP BY es.period, es.state;
```

### View teacher assignments
```sql
SELECT
  u.username,
  s.code,
  ts.group_name,
  ts.academic_year
FROM teacher_subjects ts
JOIN users u ON ts.teacher_id = u.user_id
JOIN subjects s ON ts.subject_id = s.subject_id
ORDER BY u.username, ts.academic_year;
```

### Check audit trail
```sql
SELECT
  ga.audit_id,
  u.username as modified_by,
  ga.old_value,
  ga.new_value,
  ga.reason,
  ga.modified_at
FROM grade_audit ga
JOIN users u ON ga.modified_by = u.user_id
ORDER BY ga.modified_at DESC;
```

## Maintenance Operations

### Backup Database

```bash
# Full backup with timestamps
pg_dump -d evalis_db -U evalis_user > evalis_backup_$(date +%Y%m%d_%H%M%S).sql

# Compressed backup (smaller file size)
pg_dump -d evalis_db -U evalis_user | gzip > evalis_backup_$(date +%Y%m%d).sql.gz
```

### Restore from Backup

```bash
# Drop existing database first (if needed)
sudo -u postgres psql -c "DROP DATABASE IF EXISTS evalis_db;"
sudo -u postgres psql -c "DROP USER IF EXISTS evalis_user;"

# Run database creation script
sudo -u postgres psql < init/00_create_database.sql

# Restore from backup
psql -d evalis_db -U evalis_user < evalis_backup_20260122.sql

# Or from compressed backup
gunzip -c evalis_backup_20260122.sql.gz | psql -d evalis_db -U evalis_user
```

### Routine Maintenance

```bash
# Monthly: Vacuum and analyze for query optimization
psql -d evalis_db -U evalis_user << 'EOF'
VACUUM ANALYZE;
EOF

# Check table sizes
psql -d evalis_db -U evalis_user << 'EOF'
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
WHERE schemaname != 'information_schema'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
EOF

# Monitor index usage
psql -d evalis_db -U evalis_user << 'EOF'
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
EOF
```

### Session Cleanup

```bash
# Manually deactivate expired sessions
psql -d evalis_db -U evalis_user << 'EOF'
SELECT cleanup_expired_sessions() as deactivated_sessions;
EOF

# Schedule with cron (runs every hour)
0 * * * * psql -d evalis_db -U evalis_user -c "SELECT cleanup_expired_sessions();"
```

### View Login Activity

```sql
-- Recent login attempts
SELECT username, login_time, status, ip_address, failure_reason
FROM login_audit
ORDER BY login_time DESC
LIMIT 50;

-- Failed login summary
SELECT DATE(login_time) as date, COUNT(*) as failed_attempts
FROM login_audit
WHERE status = 'FAILED'
GROUP BY DATE(login_time)
ORDER BY date DESC;

-- Suspicious activity (multiple failures per user)
SELECT username, COUNT(*) as attempts, MAX(login_time) as latest
FROM login_audit
WHERE status = 'FAILED'
  AND login_time > CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY username
HAVING COUNT(*) > 3;
```

## Security Implementation

### Password Security
- **Storage**: SHA-256 hashing only (never plain text or MD5)
- **Hash Format**: 64 hexadecimal characters
- **Validation**: `is_valid_password_hash(hash)` checks format
- **Demo Accounts**: Change passwords before production!

### SQL Injection Prevention
- **Always use parameterized queries** with bind variables
- Never concatenate user input into SQL strings
- Use Npgsql prepared statements in VB.NET

### Session Security
- **30-minute inactivity timeout** automatically deactivates sessions
- **IP address tracking** for audit purposes
- **Last activity tracking** enables timeout detection
- **Separate session table** independent of user login status

### Audit Trail Security
- **Append-only design**: Never delete audit entries
- **Immutable records**: Grade audit entries cannot be modified
- **Comprehensive tracking**: Who, when, what (old/new values), and why
- **Compliance**: Meets regulatory requirements for educational records

### Role-Based Access Control
- **Three distinct roles** with specific permissions
- **Database-level validation** enforces rules at storage layer
- **Application-level validation** must also check permissions
- **No privilege escalation** - users cannot grant themselves higher roles

### Monitoring & Alerts
```sql
-- Active sessions summary
SELECT is_active, COUNT(*) FROM sessions GROUP BY is_active;

-- Concurrent users
SELECT COUNT(DISTINCT user_id) FROM sessions WHERE is_active = TRUE;

-- Password hash validation check
SELECT COUNT(*) as invalid_hashes
FROM users
WHERE NOT is_valid_password_hash(password_hash);
```

## Troubleshooting

### "Cannot connect to database"

```bash
# Check PostgreSQL service status
sudo systemctl status postgresql

# Start PostgreSQL if stopped
sudo systemctl start postgresql

# Check if database exists
sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w evalis_db

# Check user privileges
sudo -u postgres psql -c "\du+ evalis_user"
```

### "Permission denied" on tables/functions

```bash
# Restore user privileges
sudo -u postgres psql << 'EOF'
\c evalis_db
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO evalis_user;
GRANT USAGE ON SCHEMA public TO evalis_user;
EOF
```

### Character encoding issues with Catalan text

```bash
# Check database encoding
sudo -u postgres psql -c "SELECT datname, pg_encoding_to_char(encoding) FROM pg_database WHERE datname = 'evalis_db';"

# If not UTF-8, recreate with correct encoding
sudo -u postgres psql << 'EOF'
DROP DATABASE IF EXISTS evalis_db;
CREATE DATABASE evalis_db
  WITH ENCODING 'UTF8'
  LC_COLLATE 'ca_ES.UTF-8'
  LC_CTYPE 'ca_ES.UTF-8';
EOF
```

### Slow query performance

```bash
# Enable query logging
psql -d evalis_db -U evalis_user << 'EOF'
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Log queries >1 second
SELECT pg_reload_conf();
EOF

# Check slow log
sudo tail -f /var/log/postgresql/postgresql.log
```

### Database corruption (rare)

```bash
# Run integrity checks
psql -d evalis_db -U evalis_user << 'EOF'
-- Check for constraint violations
SELECT * FROM users WHERE password_hash !~ '^[a-fA-F0-9]{64}$';
SELECT * FROM grades WHERE grade_value < 0 OR grade_value > 10;
SELECT * FROM login_audit WHERE login_time > CURRENT_TIMESTAMP;
EOF

# If found, restore from backup
```

## File Structure

```
database/
├── init/
│   ├── 00_create_database.sql
│   ├── 01_create_schemas.sql
│   ├── 02_create_tables.sql
│   ├── 03_create_indexes.sql
│   ├── 04_create_functions.sql
│   ├── 05_seed_data.sql
│   ├── 06_phase2_academic_tables.sql
│   ├── 07_phase2_indexes.sql
│   ├── 08_phase3_extended_tables.sql
│   ├── 09_phase3_indexes.sql
│   ├── 10_business_logic_functions.sql
│   ├── 11_seed_data_academic.sql
│   └── 12_seed_data_extended.sql
├── migrations/
│   └── (Future schema changes)
├── init.sh
├── setup.sh (legacy)
├── SETUP_INSTRUCTIONS.md
└── README.md (this file)
```

## Important Notes

### Before Production Deployment
1. **Change all default passwords** (evalis_user and demo accounts)
2. **Configure PostgreSQL security** (pg_hba.conf, SSL/TLS)
3. **Set up automated backups** (daily with retention)
4. **Enable connection pooling** (PgBouncer recommended)
5. **Configure monitoring** (alerts for disk space, failed logins)
6. **Test disaster recovery** (restore backups to verify)
7. **Document custom modifications** (keep SETUP_INSTRUCTIONS updated)

### Database Tuning for Production
```bash
# Edit /etc/postgresql/14/main/postgresql.conf
shared_buffers = 256MB           # 25% of system RAM
effective_cache_size = 1GB       # 50-75% of system RAM
maintenance_work_mem = 64MB
work_mem = 16MB
random_page_cost = 1.1           # For SSD storage
max_connections = 200
```

### High Availability Options
- **Replication**: Set up streaming replication for failover
- **Backup Strategy**: WAL archiving for point-in-time recovery
- **Load Balancing**: Use connection pool with multiple servers
- **Monitoring**: pg_stat_statements, pgAdmin, custom dashboards

## Support & Documentation

- **SETUP_INSTRUCTIONS.md**: Detailed setup guide
- **CLAUDE.md**: Project architecture and guidelines
- **docs/DESKTOP_PROJECT_DESCRIPTION.md**: Complete specification
- **docs/desktop_evalis_PPD.md**: Detailed planning document

## Version History

| Version | Date | Phase | Changes |
|---------|------|-------|---------|
| 1.0 | 2025-01-22 | Complete | Phase 1-3: Authentication, Academic Core, Extended Features |

---

**Database Version**: 1.0
**PostgreSQL**: 14+
**Locale**: ca_ES.UTF-8 (Catalan)
**Status**: ✓ PRODUCTION READY (with security review)
