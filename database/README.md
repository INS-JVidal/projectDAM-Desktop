# EVALIS Desktop - PostgreSQL Database

## Overview

This directory contains the PostgreSQL database schema and initialization scripts for the EVALIS Desktop application.

**Database**: `evalis_db`
**Version**: PostgreSQL 14+
**Locale**: Catalan (ca_ES.UTF-8)

## Directory Structure

```
database/
├── init/                     # Initial database setup scripts
│   ├── 00_create_database.sql  # Database and user creation
│   ├── 01_create_schemas.sql   # Schema organization
│   ├── 02_create_tables.sql    # Core tables (users, login_audit, sessions)
│   ├── 03_create_indexes.sql   # Performance indexes
│   ├── 04_create_functions.sql # Functions and triggers
│   └── 05_seed_data.sql        # Demo accounts and test data
├── migrations/               # Future schema changes
└── README.md                # This file
```

## Initial Setup

### Prerequisites

- PostgreSQL 14 or higher installed
- Superuser access to PostgreSQL

### Installation Steps

```bash
# 1. Install PostgreSQL (Ubuntu/Debian)
sudo apt update
sudo apt install postgresql-14 postgresql-contrib

# 2. Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 3. Navigate to database init directory
cd database/init

# 4. Run initialization scripts in order
sudo -u postgres psql < 00_create_database.sql
sudo -u postgres psql -d evalis_db < 01_create_schemas.sql
sudo -u postgres psql -d evalis_db < 02_create_tables.sql
sudo -u postgres psql -d evalis_db < 03_create_indexes.sql
sudo -u postgres psql -d evalis_db < 04_create_functions.sql
sudo -u postgres psql -d evalis_db < 05_seed_data.sql
```

### Quick Setup (All-in-One)

```bash
cd database/init
for script in *.sql; do
    if [ "$script" = "00_create_database.sql" ]; then
        sudo -u postgres psql < "$script"
    else
        sudo -u postgres psql -d evalis_db < "$script"
    fi
done
```

## Database Schema

### Core Tables

#### `users`
User accounts with role-based access control.

| Column | Type | Description |
|--------|------|-------------|
| user_id | SERIAL | Primary key |
| dni | VARCHAR(9) | Spanish national ID (unique) |
| username | VARCHAR(50) | Login username (unique) |
| password_hash | VARCHAR(64) | SHA-256 password hash |
| role | VARCHAR(20) | DepartmentHead, Teacher, or GroupTutor |
| full_name | VARCHAR(100) | Full name |
| email | VARCHAR(100) | Email address |
| is_active | BOOLEAN | Account status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

#### `login_audit`
Security audit log for authentication attempts.

| Column | Type | Description |
|--------|------|-------------|
| audit_id | BIGSERIAL | Primary key |
| user_id | INTEGER | User reference (NULL for failed logins) |
| username | VARCHAR(50) | Attempted username |
| login_time | TIMESTAMP | Login attempt time |
| ip_address | INET | Source IP address |
| status | VARCHAR(20) | SUCCESS or FAILED |
| failure_reason | VARCHAR(200) | Reason for failure |

#### `sessions`
Active user session tracking with 30-minute timeout.

| Column | Type | Description |
|--------|------|-------------|
| session_id | UUID | Primary key |
| user_id | INTEGER | User reference |
| login_time | TIMESTAMP | Session start time |
| last_activity | TIMESTAMP | Last user action |
| ip_address | INET | Client IP address |
| is_active | BOOLEAN | Session status |

## Demo Accounts

All demo accounts use password: `Test1234`

| Username | DNI | Role | Full Name |
|----------|-----|------|-----------|
| cap_estudis | 12345678A | DepartmentHead | Joan Puig i Garcia |
| prof_test | 87654321B | Teacher | Maria Serra i Rovira |
| tutor_dam2 | 11223344C | GroupTutor | Pere Martí i Soler |
| prof_prog | 55667788D | Teacher | Anna Vilaró i Font |
| prof_bbdd | 99887766E | Teacher | Carles Bosch i Pla |

## Database Connection

### Connection String Format

```
Server=localhost;Port=5432;Database=evalis_db;User Id=evalis_user;Password=evalis2024;
```

### VB.NET Connection Example

```vbnet
Imports Npgsql

Dim connectionString As String = "Server=localhost;Port=5432;Database=evalis_db;User Id=evalis_user;Password=evalis2024;"
Using conn As New NpgsqlConnection(connectionString)
    conn.Open()
    ' Execute queries...
End Using
```

## Database Functions

### `update_updated_at_column()`
Auto-updates the `updated_at` timestamp on row modifications.

### `cleanup_expired_sessions()`
Deactivates sessions inactive for more than 30 minutes.

**Usage:**
```sql
SELECT cleanup_expired_sessions(); -- Returns count of deactivated sessions
```

### `is_valid_password_hash(hash VARCHAR)`
Validates SHA-256 hash format (64 hexadecimal characters).

**Usage:**
```sql
SELECT is_valid_password_hash('07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573');
-- Returns: true
```

## Maintenance

### Backup Database

```bash
pg_dump -U evalis_user evalis_db > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
psql -U evalis_user evalis_db < backup_20260122.sql
```

### Clean Expired Sessions

```sql
SELECT cleanup_expired_sessions();
```

### View Login Failures

```sql
SELECT username, login_time, ip_address, failure_reason
FROM login_audit
WHERE status = 'FAILED'
ORDER BY login_time DESC
LIMIT 20;
```

## Security Notes

- **Password Storage**: Always use SHA-256 hashing (NEVER plain text)
- **SQL Injection**: Use parameterized queries with Npgsql
- **Session Timeout**: 30 minutes of inactivity
- **Audit Trail**: All login attempts are logged
- **Database User**: `evalis_user` has limited privileges (no superuser access)

## Migrations

Future schema changes should be placed in `database/migrations/` with naming convention:

```
YYYY-MM-DD_description.sql
```

Example: `2026-01-22_add_students_table.sql`

## Troubleshooting

### Cannot connect to database

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check if database exists
sudo -u postgres psql -l | grep evalis_db
```

### Reset database

```bash
sudo -u postgres psql -c "DROP DATABASE IF EXISTS evalis_db;"
sudo -u postgres psql -c "DROP USER IF EXISTS evalis_user;"
# Then re-run all init scripts
```

### Check table structure

```bash
sudo -u postgres psql -d evalis_db -c "\d+ users"
```

## Next Steps

After database setup:

1. Configure connection string in `Evalis-Desktop/Config/database.config`
2. Install Npgsql NuGet package in VB.NET project
3. Implement `DatabaseManager` class for connection handling
4. Create `UserRepository` for authentication queries
5. Test login with demo accounts
