# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**EVALIS Desktop** is a Visual Basic .NET Windows Forms application for managing educational evaluations in Catalan educational institutions. This desktop application serves administrators, department heads, and teachers, providing tools for:

- Grade entry and evaluation management
- Evaluation period lifecycle management (OPEN → IN_SESSION → CLOSED)
- Audit trail tracking for all grade modifications
- Multi-format exports (PDF, CSV, JSON, XML)
- Academic document generation (bulletins, records, expedients)
- Faculty portrait gallery management

The application shares an external MySQL database (via XAMPP) with a companion Android mobile application.

## Build and Development Commands

### Visual Studio Solution
This is a Visual Studio VB.NET project targeting .NET 8.0 Windows:

```bash
# Open the solution
cd Evalis-Desktop
start Evalis-Desktop.sln  # Opens in Visual Studio

# Build from command line (requires .NET SDK)
dotnet build Evalis-Desktop.sln

# Run the application
dotnet run --project Evalis-Desktop.vbproj

# Clean build artifacts
dotnet clean
```

### Database Setup
The application requires MySQL database connection:

```bash
# Start XAMPP MySQL server (if using XAMPP)
# Navigate to XAMPP control panel and start MySQL

# Import database schema
mysql -u root -p evalis_db < database/schema.sql

# Import test data
mysql -u root -p evalis_db < database/test_data.sql
```

## High-Level Architecture

### Three-Tier Architecture

```
┌─────────────────────────────────────────┐
│      Presentation Layer (WinForms)      │
│  - Login Form                           │
│  - Dashboard Forms (role-specific)      │
│  - Grade Entry Grid                     │
│  - Faculty Gallery                      │
│  - Export Dialogs                       │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│      Business Logic Layer (Services)    │
│  - AuthenticationService                │
│  - GradeManagementService               │
│  - EvaluationPeriodService              │
│  - AuditTrailService                    │
│  - DocumentGenerationService            │
│  - ExportService (PDF/CSV/JSON/XML)     │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│    Data Access Layer (Repository)       │
│  - UserRepository                       │
│  - StudentRepository                    │
│  - GradeRepository                      │
│  - EvaluationRepository                 │
│  - AuditRepository                      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│      MySQL Database (XAMPP)             │
│  Shared with Android Mobile App         │
└─────────────────────────────────────────┘
```

### Key Design Patterns

**Repository Pattern**: All database access goes through repository classes, isolating SQL logic from business logic.

**Service Layer**: Business logic is encapsulated in service classes (e.g., `AuthenticationService`, `GradeManagementService`).

**Role-Based Access Control (RBAC)**: Three user roles with distinct permissions:
- **DepartmentHead**: Full access, can open/close evaluation periods, modify closed evaluations
- **Teacher**: Grade entry for assigned subjects during OPEN periods only
- **GroupTutor**: Class-level oversight, limited modification during evaluation sessions

**State Management**: Evaluation periods follow a strict state machine:
- `OPEN` → Teachers can enter/modify grades
- `IN_SESSION` → Only tutor and department head can modify (during evaluation meetings)
- `CLOSED` → Only department head can modify with audit trail

### Critical Database Tables

**evaluation_sessions**: Tracks evaluation period states (OPEN/IN_SESSION/CLOSED)
- Controls when teachers can enter grades
- Managed exclusively by department heads

**grade_audit**: Audit trail for all grade modifications
- Records: who changed, when, old value, new value, reason
- Append-only (never delete entries)

**login_audit**: Security audit log
- Tracks all login attempts (successful and failed)
- Used for compliance reporting

**document_archive**: Generated document tracking
- Stores file paths to PDF documents on file server
- Links to students and academic years

## Key Workflows

### Evaluation Period Lifecycle
1. Department head opens evaluation period → State = OPEN
2. Teachers enter grades for their assigned subjects
3. Auto-save drafts every 60 seconds
4. Department head starts evaluation session → State = IN_SESSION
5. Tutor and department head review/modify grades during meeting
6. Department head closes evaluation period → State = CLOSED
7. Grades locked for teachers
8. Only department head can modify (with mandatory reason in audit trail)

### Grade Modification with Audit Trail
All grade changes after closure must:
1. Be performed by department head only
2. Include a reason (minimum 20 characters)
3. Create audit trail entry with timestamp
4. Preserve original grade in history
5. Be reversible if needed

### Academic Expedient Generation (Advanced Feature)
For graduating students:
1. Verify all grades complete
2. Calculate weighted average: `Σ(Grade × Hours) / Σ(Hours)`
3. Generate professional PDF with Generalitat branding
4. Archive to file server: `{NIA}_{Surname}_{Cycle}_{Year}.pdf`
5. Move grade records to history table
6. Update student status to "Graduated"

## Security Requirements

### Authentication
- **Password Storage**: SHA-256 hashing (NEVER plain text or MD5)
- **Session Management**: 30-minute timeout after inactivity
- **Login Audit**: Log all attempts (success and failure) with timestamp and IP

### SQL Injection Prevention
Always use parameterized queries:

```vbnet
' CORRECT
Dim cmd As New MySqlCommand("SELECT * FROM students WHERE nia = @nia", conn)
cmd.Parameters.AddWithValue("@nia", studentNia)

' WRONG - vulnerable to SQL injection
Dim cmd As New MySqlCommand("SELECT * FROM students WHERE nia = '" & studentNia & "'", conn)
```

### Transaction Management
For multi-step operations (e.g., grade update + audit entry):

```vbnet
Using conn As New MySqlConnection(connectionString)
    conn.Open()
    Using transaction As MySqlTransaction = conn.BeginTransaction()
        Try
            ' Update grade
            UpdateGrade(gradeData, conn, transaction)
            ' Create audit entry
            CreateAuditEntry(gradeData, conn, transaction)
            ' Commit if both succeed
            transaction.Commit()
        Catch ex As Exception
            transaction.Rollback()
            LogError(ex)
        End Try
    End Using
End Using
```

## Export Formats

### PDF Exports
**Libraries**: iTextSharp or PDFSharp
**Use cases**:
- Student bulletins (grade reports)
- Evaluation records (actes d'avaluació)
- Academic expedients (graduation transcripts)

**Requirements**: Professional layout, institution logo, page numbers, signature blocks

### CSV Exports
**Use cases**: Student lists, grade data for spreadsheet analysis
**Format**: RFC 4180 compliant, UTF-8 encoding for Catalan characters
**Delimiter**: Configurable (comma or semicolon for Excel)

### JSON Exports
**Use cases**: Faculty lists, API-ready structured data
**Format**: Valid JSON with UTF-8 encoding, pretty-printed, includes metadata

### XML Exports
**Use cases**: Login audit logs, compliance reporting
**Format**: Valid XML with declaration, schema-compliant, includes summary statistics

## Testing Strategy

### Demo Accounts
- **Department Head**: `cap_estudis` / `Test1234`
- **Teacher**: `prof_test` / `Test1234`
- **Group Tutor**: `tutor_dam2` / `Test1234`

### Test Data Requirements
- Minimum 10 rows in each table
- Include OPEN, CLOSED, and IN_SESSION evaluation periods
- Grade records in various states (draft, finalized, modified)
- Audit trail entries showing modifications
- Login log entries (successful and failed)
- Faculty records with photos (handle missing with placeholder)

### Unit Testing (Advanced Level)
**Framework**: NUnit or MSTest
**Coverage Target**: 70%+ for business logic

Test areas:
- Grade calculation logic (weighted averages)
- Data validation functions
- Authentication and role permission checks
- Business rule enforcement

### Integration Testing (Advanced Level)
Test complete workflows:
- Full evaluation period lifecycle
- Grade modification with audit trail creation
- Document generation end-to-end
- Multi-user workflow simulation

## Code Organization Standards

### Naming Conventions
- **Classes**: PascalCase (e.g., `GradeManager`, `DatabaseConnection`)
- **Methods**: PascalCase (e.g., `CalculateWeightedAverage()`)
- **Variables**: camelCase (e.g., `studentName`, `totalHours`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_GRADE`, `DEFAULT_TIMEOUT`)

### Error Handling
- Use Try-Catch blocks for all I/O operations
- Display user-friendly error messages (not technical stack traces)
- Log errors for debugging (file or database log)
- Implement graceful degradation (don't crash the application)

### File Structure (Expected)
```
Evalis-Desktop/
├── Forms/                    # UI layer
│   ├── LoginForm.vb
│   ├── DashboardForm.vb
│   ├── GradeEntryForm.vb
│   └── FacultyGalleryForm.vb
├── Services/                 # Business logic
│   ├── AuthenticationService.vb
│   ├── GradeManagementService.vb
│   ├── EvaluationPeriodService.vb
│   └── AuditTrailService.vb
├── Repositories/             # Data access
│   ├── UserRepository.vb
│   ├── GradeRepository.vb
│   └── AuditRepository.vb
├── Models/                   # Data entities
│   ├── User.vb
│   ├── Grade.vb
│   └── EvaluationSession.vb
└── Utils/                    # Helpers
    ├── DatabaseManager.vb
    └── PasswordHasher.vb
```

## Important Constraints

### Evaluation Period State Rules
- Teachers can ONLY modify grades when period state = OPEN
- During CLOSED state, show error: "Evaluation period is closed. Contact department head."
- Department head bypasses these restrictions but creates audit entries

### Weighted Grade Calculation Formula
```
Final Grade = Σ(Subject Grade × Subject Hours) / Σ(Subject Hours)

Example:
Programació: 8.5 × 6h = 51
Bases de Dades: 7.0 × 5h = 35
Entorns: 9.0 × 3h = 27
Total: (51 + 35 + 27) / (6 + 5 + 3) = 113 / 14 = 8.07
```

### Audit Trail Requirements
Every grade modification after closure MUST include:
- Old grade value
- New grade value
- Modifier's DNI and username
- Timestamp (server-generated)
- Reason (minimum 20 characters)
- Evaluation period and session state

### Database Cleanup Safety
When generating academic expedient:
- MOVE grade records to history table (don't delete)
- PRESERVE audit trails permanently (never delete)
- Use transactions (rollback on any error)
- Verify file saved before database cleanup

## Common Development Tasks

### Adding a New Form
1. Create form class inheriting from `System.Windows.Forms.Form`
2. Implement role-based access check in Form_Load
3. Add navigation from dashboard or menu
4. Follow Material Design color scheme (see project documentation)

### Adding a New Repository Method
1. Create method in appropriate repository class
2. Use parameterized queries (prevent SQL injection)
3. Return strongly-typed objects (not DataTable)
4. Handle connection disposal with Using statement

### Implementing New Export Format
1. Create export method in ExportService
2. Follow format specifications (UTF-8 encoding, proper headers)
3. Handle file I/O errors gracefully
4. Add export button to relevant form

## Project Documentation

Comprehensive documentation available in:
- `desktop_evalis_PPD.md` - Complete project planning document (2000+ lines)
- `docs/DESKTOP_PROJECT_DESCRIPTION.md` - Project specification

Key sections:
- Technology Stack & Architecture (Section 3)
- Database Architecture (Section 4)
- Feature Implementation Roadmap (Section 5)
- Testing Strategy (Section 8)
- Security Implementation Plan (Section 9)

## Scoring Criteria

**Basic Level** (0.50-0.65 / 1.0): Authentication, evaluation period management, grade entry, faculty gallery, basic PDF export

**Intermediate Level** (0.65-0.85 / 1.0): + Audit trail, post-closure modifications, all 4 export formats

**Advanced Level** (0.85-1.0 / 1.0): + Academic expedient generation, file server archival, unit/integration testing
