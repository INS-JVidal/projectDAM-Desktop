# EVALIS Desktop Application - Project Planning Document

**Project Name:** EVALIS Desktop Application (Visual Basic)
**Version:** 1.0
**Date:** January 22, 2026
**Institution:** Institut Caparrella
**Academic Year:** 2025-2026
**Module:** DAM2 - Desktop Development

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Scope & Objectives](#2-project-scope--objectives)
3. [Technology Stack & Architecture](#3-technology-stack--architecture)
4. [Database Architecture](#4-database-architecture)
5. [Feature Implementation Roadmap](#5-feature-implementation-roadmap)
6. [Development Phases](#6-development-phases)
7. [User Interface Design Plan](#7-user-interface-design-plan)
8. [Testing Strategy](#8-testing-strategy)
9. [Security Implementation Plan](#9-security-implementation-plan)
10. [Risk Assessment & Mitigation](#10-risk-assessment--mitigation)
11. [Resource Requirements](#11-resource-requirements)
12. [Success Criteria & Deliverables](#12-success-criteria--deliverables)
13. [Project Timeline](#13-project-timeline)

---

## 1. Executive Summary

### 1.1 Project Overview

EVALIS Desktop is the administrative interface for the EVALIS educational evaluation platform, designed for educational institutions across Catalonia. This Visual Basic application serves as the primary tool for department heads, teachers, and administrative staff to manage evaluations, enter grades, generate official documents, and maintain academic records.

### 1.2 Purpose

The desktop application complements the EVALIS mobile app by providing:
- Comprehensive evaluation management tools for educational staff
- Secure grade entry during evaluation periods
- Evaluation session/meeting workflows
- Official academic document generation (bulletins, records, expedients)
- Multi-format data export (PDF, CSV, JSON, XML)
- Complete audit trails for all grade modifications
- Evaluation period lifecycle management (open → closed)

### 1.3 Target Users

- **Department Heads (Cap d'Estudis)** - Primary administrative role with highest permissions
- **Teachers/Professors** - Grade entry and subject management
- **Group Tutors** - Class-level evaluation oversight
- **Administrative Staff** - Document generation and archival

### 1.4 Key Success Metrics

- **Functionality:** All basic level features operational (minimum passing)
- **Quality:** Professional UI with Material Design principles
- **Security:** Role-based access control with SHA-256 password hashing
- **Reliability:** Complete audit trails for all modifications
- **Performance:** Response times under specified thresholds
- **Documentation:** Comprehensive technical and user documentation
- **Score Target:** 0.85-1.0 / 1.0 (Advanced Level implementation)

---

## 2. Project Scope & Objectives

### 2.1 In Scope

#### Basic Level Features (Required for Passing)
- User authentication with role-based access control
- Evaluation period management (open/close by department head)
- Grade entry interface for teachers (restricted to open periods)
- Evaluation session simulation (in-session state management)
- Faculty portrait gallery generation from database
- Basic PDF export functionality

#### Intermediate Level Features (Target for Good Score)
- Closed evaluation record management
- Complete audit trail system with timestamps and reasons
- Modification history viewer and query interface
- Post-closure grade modification (department head only)
- Enhanced faculty portrait display with detailed information
- All export formats (PDF, CSV, JSON, XML)

#### Advanced Level Features (Target for Excellent Score)
- Academic expedient generation with weighted grade calculations
- Official PDF document generation ("Expedient Acadèmic")
- File server archival system for long-term storage
- Database cleanup after expedient generation
- Unit testing suite for business logic
- Integration testing for desktop module

### 2.2 Out of Scope

- Mobile application development (separate project)
- Web interface or browser-based access
- Real-time multi-user collaboration features
- Advanced analytics and reporting dashboards
- Parent/student access to the desktop application
- Email notification system (optional feature)
- Automated grade calculation from assessment criteria

### 2.3 Primary Objectives

1. **Implement secure, role-based authentication system**
   - SHA-256 password hashing
   - Session management with timeout
   - Login audit logging

2. **Create robust evaluation period management**
   - Open/close periods with validation
   - State management (OPEN, IN_SESSION, CLOSED)
   - Teacher grade entry restrictions based on state

3. **Build comprehensive audit trail system**
   - Log all grade modifications with timestamps
   - Require justification for post-closure changes
   - Queryable modification history

4. **Generate professional academic documents**
   - PDF bulletins with institutional branding
   - Evaluation records (actes d'avaluació)
   - Academic expedients with weighted calculations

5. **Enable multi-format data export**
   - PDF for official documents
   - CSV for spreadsheet analysis
   - JSON for API integration
   - XML for compliance reporting

---

## 3. Technology Stack & Architecture

### 3.1 Development Environment

**Primary Language:** Visual Basic .NET (VB.NET)

**IDE:** Microsoft Visual Studio 2019/2022

**Framework:** .NET Framework 4.7.2 or .NET Core 3.1+

**Rationale:**
- VB.NET provides modern features while maintaining VB syntax
- .NET Framework offers excellent Windows integration
- Visual Studio provides comprehensive debugging and design tools
- Strong library support for database, PDF, and document generation

### 3.2 Database Connectivity

**Database:** MySQL 8.0 (via XAMPP server)

**Connectivity Layer:** ADO.NET with MySQL Connector/NET

**Connection Strategy:**
- Connection string stored in encrypted configuration file
- Connection pooling for performance
- Transaction management for data integrity
- Parameterized queries to prevent SQL injection

**Example Connection Configuration:**
```vbnet
' Database connection module
Public Class DatabaseManager
    Private ReadOnly connectionString As String

    Public Sub New()
        connectionString = ConfigurationManager.ConnectionStrings("EvalDB").ConnectionString
    End Sub

    Public Function GetConnection() As MySqlConnection
        Return New MySqlConnection(connectionString)
    End Function
End Class
```

### 3.3 Document Generation Libraries

#### PDF Generation
- **Primary:** iTextSharp 5.5.13 or iText 7
- **Alternative:** PDFSharp
- **Use Cases:** Bulletins, evaluation records, academic expedients

#### CSV/Excel Export
- **Primary:** System.IO for CSV (built-in)
- **Alternative:** EPPlus 5.x or ClosedXML for Excel
- **Use Cases:** Class lists, grade exports for analysis

#### JSON Export
- **Primary:** Newtonsoft.Json (JSON.NET)
- **Alternative:** System.Text.Json (.NET Core)
- **Use Cases:** Faculty lists, API-ready data structures

#### XML Export
- **Primary:** System.Xml namespace (built-in)
- **Use Cases:** Login audit logs, compliance reporting

### 3.4 UI Framework

**Framework:** Windows Forms (WinForms)

**Design System:** Material Design principles adapted for desktop

**UI Components:**
- DataGridView for grade entry grids
- FlowLayoutPanel for faculty gallery
- Custom controls for professional appearance
- PictureBox for photos and logos

**Rationale:**
- WinForms provides rapid development for desktop applications
- Mature framework with extensive control library
- Easy integration with database and document generation
- Good performance for data-intensive applications

### 3.5 Testing Frameworks

**Unit Testing:** NUnit 3.x or MSTest

**Mocking:** Moq framework for database connection mocking

**Coverage:** OpenCover or Visual Studio Code Coverage tools

### 3.6 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EVALIS Desktop Application                │
│                       (Visual Basic .NET)                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Presentation Layer (UI)                    │   │
│  │  - Login Form                                        │   │
│  │  - Dashboard Forms (Role-specific)                   │   │
│  │  - Grade Entry Grid                                  │   │
│  │  - Faculty Gallery                                   │   │
│  │  - Export Dialogs                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↕                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        Business Logic Layer (Services)               │   │
│  │  - Authentication Service                            │   │
│  │  - Grade Management Service                          │   │
│  │  - Evaluation Period Service                         │   │
│  │  - Audit Trail Service                               │   │
│  │  - Document Generation Service                       │   │
│  │  - Export Service (PDF/CSV/JSON/XML)                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↕                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Data Access Layer (Repository)               │   │
│  │  - User Repository                                   │   │
│  │  - Student Repository                                │   │
│  │  - Grade Repository                                  │   │
│  │  - Evaluation Repository                             │   │
│  │  - Audit Repository                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↕                                    │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│            External MySQL Database (XAMPP)                   │
│  - Shared with Android Mobile Application                   │
│  - Tables: users, students, grades, evaluations,            │
│    audit_trail, evaluation_sessions, documents, etc.        │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Database Architecture

### 4.1 Shared Database Strategy

The desktop application connects to the **same external SQL database** as the Android mobile application. This ensures:
- Data consistency across platforms
- Real-time updates for all users
- Single source of truth for academic data
- Simplified data synchronization

### 4.2 Critical Database Tables

#### 4.2.1 Users Table
```sql
CREATE TABLE users (
    dni VARCHAR(20) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,  -- SHA-256 hashed
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    role ENUM('DepartmentHead', 'Teacher', 'Tutor', 'Admin') NOT NULL,
    department VARCHAR(50),
    photo_path VARCHAR(255),
    years_of_service INT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
);
```

#### 4.2.2 Evaluation Sessions Table
```sql
CREATE TABLE evaluation_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period VARCHAR(50) NOT NULL,  -- Trimester1, UF1, RA1, etc.
    group_code VARCHAR(20) NOT NULL,
    state ENUM('OPEN', 'IN_SESSION', 'CLOSED') DEFAULT 'OPEN',
    opened_by VARCHAR(20),
    opened_date DATETIME,
    closed_by VARCHAR(20),
    closed_date DATETIME,
    session_notes TEXT,
    FOREIGN KEY (opened_by) REFERENCES users(dni),
    FOREIGN KEY (closed_by) REFERENCES users(dni),
    INDEX idx_group_period (group_code, evaluation_period)
);
```

#### 4.2.3 Grade Audit Table
```sql
CREATE TABLE grade_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_id INT NOT NULL,
    student_nia VARCHAR(20) NOT NULL,
    subject_code VARCHAR(20) NOT NULL,
    old_grade DECIMAL(4,2),
    new_grade DECIMAL(4,2),
    modified_by VARCHAR(20) NOT NULL,
    modification_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    approved_by VARCHAR(20),
    session_state VARCHAR(20),
    FOREIGN KEY (modified_by) REFERENCES users(dni),
    FOREIGN KEY (approved_by) REFERENCES users(dni),
    INDEX idx_student (student_nia),
    INDEX idx_date (modification_date)
);
```

#### 4.2.4 Login Audit Table
```sql
CREATE TABLE login_audit (
    login_id INT PRIMARY KEY AUTO_INCREMENT,
    user_dni VARCHAR(20),
    username VARCHAR(50) NOT NULL,
    login_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(255),
    session_duration TIME,
    INDEX idx_timestamp (login_timestamp),
    INDEX idx_username (username)
);
```

#### 4.2.5 Document Archive Table
```sql
CREATE TABLE document_archive (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    document_type ENUM('Bulletin', 'Record', 'Expedient') NOT NULL,
    student_nia VARCHAR(20),
    generation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500) NOT NULL,
    generated_by VARCHAR(20),
    academic_year VARCHAR(10),
    FOREIGN KEY (generated_by) REFERENCES users(dni),
    INDEX idx_student (student_nia),
    INDEX idx_type (document_type)
);
```

### 4.3 Database Connection Management

**Connection Pooling Configuration:**
```vbnet
' Connection string with pooling
Private connectionString As String =
    "Server=localhost;" & _
    "Database=evalis_db;" & _
    "Uid=evalis_user;" & _
    "Pwd=encrypted_password;" & _
    "Pooling=true;" & _
    "Min Pool Size=5;" & _
    "Max Pool Size=20;" & _
    "Connection Timeout=30;"
```

**Transaction Management:**
```vbnet
Public Function ModifyGradeWithAudit(gradeData As GradeModification) As Boolean
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
                Return True
            Catch ex As Exception
                ' Rollback on any error
                transaction.Rollback()
                LogError(ex)
                Return False
            End Try
        End Using
    End Using
End Function
```

---

## 5. Feature Implementation Roadmap

### 5.1 Basic Level Features (Priority 1 - CRITICAL)

#### Feature 1: User Authentication & Authorization
**Estimated Effort:** 1 week
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Design login form with institutional branding
2. Implement password hash verification (SHA-256)
3. Create session management system
4. Build role-based access control framework
5. Implement auto-logout after inactivity
6. Log all login attempts to database

**Technical Requirements:**
- SHA-256 password hashing (NEVER MD5 or plain text)
- Session timeout: 30 minutes of inactivity
- Connection string encrypted or in secure config
- Role verification before every sensitive operation

**Testing Criteria:**
- ✓ Valid credentials → successful login
- ✓ Invalid credentials → error message
- ✓ Failed attempts logged to database
- ✓ Session expires after timeout
- ✓ Role-appropriate dashboard displayed

---

#### Feature 2: Evaluation Period Management
**Estimated Effort:** 1.5 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Create evaluation period dashboard UI
2. Implement "Open Period" workflow with validation
3. Implement "Close Period" workflow with checks
4. Build state management system (OPEN/IN_SESSION/CLOSED)
5. Add visual indicators for period states
6. Implement period state database updates

**Business Logic:**
- Only department head can open/close periods
- Validation check before closing (all grades entered)
- Warning dialog if closing with missing grades
- Force close option with required justification
- Update session_state table on all changes

**Testing Criteria:**
- ✓ Department head can open period
- ✓ Teachers cannot open/close periods
- ✓ Cannot close with incomplete grades (unless forced)
- ✓ State changes reflected in database immediately
- ✓ Teachers notified of state changes

---

#### Feature 3: Grade Entry Interface
**Estimated Effort:** 2 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Design grade entry grid (DataGridView)
2. Implement real-time validation (0.00-10.00 range)
3. Create comments/observations dialog
4. Build auto-save draft functionality
5. Add submit grades workflow
6. Implement period state checking before edits

**UI Components:**
- Student-subject grid with editable cells
- Color coding: Green (saved), Yellow (draft), Red (invalid)
- Comments icon next to each grade cell
- Progress indicator (e.g., "12/25 grades entered")
- Save draft and Submit buttons

**Business Logic:**
- Check evaluation period state before allowing edits
- If CLOSED → Display error "Period closed. Contact department head."
- Validate grade range (0.00-10.00, 2 decimal places)
- Auto-save drafts every 60 seconds
- Confirmation dialog before final submission

**Testing Criteria:**
- ✓ Teachers can enter grades during OPEN period
- ✓ Teachers cannot enter grades during CLOSED period
- ✓ Invalid grades rejected with error message
- ✓ Comments saved correctly to database
- ✓ Auto-save functionality works

---

#### Feature 4: Evaluation Meeting Simulation
**Estimated Effort:** 1 week
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Create "Start Evaluation Session" button (department head)
2. Implement IN_SESSION state transition
3. Build session active screen with banner
4. Add modification controls for tutor/department head
5. Implement "End Session" workflow
6. Record session minutes and modifications

**Session Workflow:**
1. Department head starts session for specific group/period
2. State changes to IN_SESSION
3. Only tutor and department head can modify grades
4. All modifications require justification
5. Session end validates all grades complete
6. State changes to CLOSED

**Testing Criteria:**
- ✓ Department head can start session
- ✓ Regular teachers have read-only access during session
- ✓ Tutor can modify grades with justification
- ✓ Session cannot end with incomplete grades
- ✓ All modifications logged to audit trail

---

#### Feature 5: Faculty Portrait Gallery
**Estimated Effort:** 1 week
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Design gallery grid layout (FlowLayoutPanel)
2. Query all teachers from database
3. Load photos from file system
4. Handle missing photos with placeholder
5. Implement filters (department, status)
6. Add export to PDF functionality

**UI Design:**
- 4-6 column grid layout
- Each cell: Photo, Name, Department, Years of service
- Search bar and filter dropdowns
- Export button (PDF, Print)

**Testing Criteria:**
- ✓ All teachers displayed with photos
- ✓ Missing photos show placeholder
- ✓ Filters work correctly
- ✓ PDF export creates professional layout
- ✓ Print preview shows correct formatting

---

### 5.2 Intermediate Level Features (Priority 2 - IMPORTANT)

#### Feature 6: Evaluation Record Management
**Estimated Effort:** 1.5 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Create evaluation records list view
2. Build record detail viewer
3. Implement modification request dialog
4. Add reason requirement validation
5. Create approval workflow
6. Update audit trail on modifications

**Key Requirements:**
- Only department head can modify closed evaluations
- Every modification MUST have a reason (min 20 characters)
- Original grade preserved in audit history
- Timestamp and user recorded for accountability

**Testing Criteria:**
- ✓ Department head can modify closed records
- ✓ Teachers cannot modify closed records
- ✓ Modification without reason is rejected
- ✓ Audit trail entry created for each change
- ✓ Original grade preserved in history

---

#### Feature 7: Audit Trail & Modification History
**Estimated Effort:** 2 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Design audit log viewer UI
2. Implement filtering system (date, user, student, subject)
3. Create grade history timeline view
4. Build modification details display
5. Add export to CSV/XML functionality
6. Create audit trail query service

**Audit Data Captured:**
- What changed: Grade value (old → new)
- Who changed it: User DNI and username
- When changed: Timestamp (precise to second)
- Why changed: Reason/justification text
- Context: Evaluation period, subject, student

**Testing Criteria:**
- ✓ All modifications appear in audit log
- ✓ Filters work correctly
- ✓ Timeline shows chronological history
- ✓ Export to XML creates valid document
- ✓ Search by student/teacher returns correct results

---

#### Feature 8: Enhanced Faculty Display
**Estimated Effort:** 1 week
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Add detailed faculty card view
2. Implement click-to-view-profile functionality
3. Create organizational hierarchy view
4. Add customizable export templates
5. Implement multiple layout options

**Enhanced Features:**
- Detailed teacher profile on click
- Contact information, subjects taught, schedule
- Years of service and certifications
- Department grouping view
- High-resolution export for printing

**Testing Criteria:**
- ✓ Click portrait → detailed profile appears
- ✓ All information displayed correctly
- ✓ Department hierarchy view works
- ✓ Multiple export layouts available
- ✓ High-resolution export quality suitable for printing

---

### 5.3 Advanced Level Features (Priority 3 - EXCELLENCE)

#### Feature 9: Academic Expedient Generation
**Estimated Effort:** 2.5 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Implement weighted grade calculation engine
2. Design expedient PDF template
3. Create expedient generation wizard
4. Build batch generation functionality
5. Implement file server archival system
6. Create database cleanup mechanism with safety checks

**Weighted Calculation Formula:**
```
Final Grade = Σ(Grade × Subject Hours) / Σ(Subject Hours)

Example:
- Programació (M3): 8.5 × 6h = 51
- Bases de Dades (M2): 7.0 × 5h = 35
- Entorns (M1): 9.0 × 3h = 27
Total: (51 + 35 + 27) / (6 + 5 + 3) = 113 / 14 = 8.07
```

**PDF Document Structure:**
- Header: Generalitat de Catalunya logo, center name, document title
- Student Information: NIA, DNI, enrollment dates, educational level
- Grade Breakdown: All subjects with hours and final grades
- Final Calculation: Weighted average with explanation
- Graduation Status: "GRADUAT" or "NO GRADUAT"
- Signatures: Department head and director signature blocks

**File Server Archival:**
- Naming convention: `{NIA}_{Surname}_{Cycle}_{Year}.pdf`
- Example: `1234567890_Garcia_DAM_2026.pdf`
- Directory structure: `/arxiu/expedients/2026/`
- Record file path in document_archive table

**Database Cleanup:**
- Move grade records to history table (NOT delete)
- Preserve audit trails permanently
- Update student status to "Graduated"
- Rollback on any errors (transaction management)

**Testing Criteria:**
- ✓ Weighted calculation is accurate
- ✓ PDF generated with all required information
- ✓ File saved to correct server location
- ✓ Database cleanup preserves audit trails
- ✓ Cannot regenerate existing expedient

---

#### Feature 10: Unit & Integration Testing
**Estimated Effort:** 2 weeks
**Score Impact:** Part of 1.0 point total

**Implementation Plan:**
1. Set up NUnit testing framework
2. Create unit tests for business logic
3. Implement mock database for testing
4. Create integration tests for workflows
5. Generate code coverage report
6. Document test scenarios and results

**Unit Test Coverage Areas:**
- Grade calculation logic (weighted average)
- Authentication and authorization checks
- Data validation functions
- Business rule enforcement

**Integration Test Scenarios:**
- Complete evaluation period lifecycle
- Grade modification with audit trail creation
- Document generation end-to-end
- Multi-user workflow simulation

**Example Unit Test:**
```vbnet
<TestFixture>
Public Class GradeCalculationTests
    <Test>
    Public Sub WeightedAverage_ValidGrades_ReturnsCorrectValue()
        ' Arrange
        Dim calculator As New GradeCalculator()
        Dim subjects As New List(Of Subject) From {
            New Subject With {.Grade = 8.5, .Hours = 6},
            New Subject With {.Grade = 7.0, .Hours = 5},
            New Subject With {.Grade = 9.0, .Hours = 3}
        }

        ' Act
        Dim result As Decimal = calculator.CalculateWeightedAverage(subjects)

        ' Assert
        Assert.AreEqual(8.07, result, 0.01)
    End Sub

    <Test>
    Public Sub ValidateGrade_OutOfRange_ThrowsException()
        ' Arrange & Act & Assert
        Assert.Throws(Of ArgumentOutOfRangeException)(
            Sub() ValidateGrade(12.5)
        )
    End Sub
End Class
```

**Testing Criteria:**
- ✓ All unit tests pass
- ✓ Code coverage > 70%
- ✓ Integration tests cover critical workflows
- ✓ Test report generated and documented
- ✓ Mock database used for testing (not production)

---

### 5.4 Export Capabilities (All Levels)

#### PDF Exports
**Documents:**
- Bulletin de Notes (Grade Bulletin)
- Acta d'Avaluació (Evaluation Record)
- Expedient Acadèmic (Academic Transcript)

**Requirements:**
- Professional layout with proper margins
- Institution logo and headers
- Page numbers and metadata
- Signature blocks
- Optional password protection

---

#### CSV Exports
**Data Types:**
- Class student lists
- Grade exports for analysis

**Format Requirements:**
- RFC 4180 compliance
- UTF-8 encoding for Catalan characters
- Configurable delimiter (comma or semicolon)
- Header row with column names

**Example Output:**
```csv
NIA,Nom Complet,Assignatura,Nota,Període,Aprovat
1234567890,"García Martínez, Joan",Programació,8.5,Trimestre 1,Sí
1234567891,"López Fernández, Maria",Programació,6.0,Trimestre 1,Sí
```

---

#### JSON Exports
**Data Types:**
- Faculty lists
- Structured data for API consumption

**Format Requirements:**
- Valid JSON syntax
- UTF-8 encoding
- Pretty-printed with indentation
- Metadata included (export date, record count)

**Example Structure:**
```json
{
  "export_date": "2026-01-22T14:30:00Z",
  "center_code": "08001234",
  "center_name": "Institut Caparrella",
  "faculty": [
    {
      "teacher_id": "PROF001",
      "dni": "12345678A",
      "full_name": "García Pérez, Joan",
      "department": "Informàtica",
      "subjects": [...]
    }
  ],
  "total_faculty": 25
}
```

---

#### XML Exports
**Data Types:**
- Login audit logs
- Compliance reporting data

**Format Requirements:**
- Valid XML syntax with declaration
- UTF-8 encoding
- Schema-compliant (optional XSD)
- Human-readable formatting
- Summary statistics included

**Example Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LoginAuditLog>
  <ExportMetadata>
    <ExportDate>2026-01-22T14:30:00Z</ExportDate>
    <CenterCode>08001234</CenterCode>
  </ExportMetadata>
  <LoginAttempts>
    <Login>
      <LoginID>10542</LoginID>
      <Timestamp>2026-01-22T09:15:32Z</Timestamp>
      <Username>cap_estudis</Username>
      <Success>true</Success>
    </Login>
  </LoginAttempts>
</LoginAuditLog>
```

---

## 6. Development Phases

### Phase 1: Foundation & Setup (Weeks 1-3)

**Week 1: Project Initialization**
- Set up Visual Studio project structure
- Configure .NET Framework and NuGet packages
- Install required libraries (MySQL Connector, iTextSharp, JSON.NET)
- Set up Git repository with .gitignore
- Create initial project documentation

**Week 2: Database Integration**
- Implement database connection manager
- Create repository pattern for data access
- Test database connectivity with XAMPP
- Create SQL scripts for test data
- Implement connection pooling

**Week 3: Authentication Foundation**
- Design and implement login form UI
- Create authentication service
- Implement password hash verification (SHA-256)
- Build session management system
- Add login audit logging

**Deliverables:**
- ✓ Project structure created
- ✓ Database connection working
- ✓ Login screen functional
- ✓ Basic session management implemented

---

### Phase 2: Basic Level Features (Weeks 4-7)

**Week 4: Evaluation Period Management**
- Create evaluation period dashboard UI
- Implement open period workflow
- Implement close period workflow
- Add state validation checks
- Create period state indicators

**Week 5: Grade Entry Interface**
- Design grade entry grid
- Implement real-time validation
- Create comments/observations dialog
- Add auto-save functionality
- Implement submit grades workflow

**Week 6: Evaluation Session Simulation**
- Create session management UI
- Implement IN_SESSION state logic
- Add role-based modification controls
- Create session end workflow
- Test session state transitions

**Week 7: Faculty Portrait Gallery**
- Design gallery grid layout
- Implement photo loading system
- Add filters and search
- Create basic PDF export
- Test with missing photos

**Deliverables:**
- ✓ All Basic Level features implemented
- ✓ Department head can open/close periods
- ✓ Teachers can enter grades during open periods
- ✓ Evaluation sessions functional
- ✓ Faculty gallery displays correctly

---

### Phase 3: Intermediate Level Features (Weeks 8-10)

**Week 8: Audit Trail System**
- Create grade_audit table structure
- Implement audit logging service
- Design audit log viewer UI
- Add filtering and search functionality
- Implement grade history timeline

**Week 9: Record Management & Modifications**
- Create evaluation records list view
- Build modification request dialog
- Implement reason validation
- Add approval workflow
- Test post-closure modifications

**Week 10: Enhanced Exports**
- Implement CSV export functionality
- Add JSON export for faculty
- Create XML export for audit logs
- Test all export formats
- Verify UTF-8 encoding for Catalan characters

**Deliverables:**
- ✓ Complete audit trail system operational
- ✓ Post-closure modifications working
- ✓ All 4 export formats functional (PDF, CSV, JSON, XML)
- ✓ Modification history viewer complete

---

### Phase 4: Advanced Level Features (Weeks 11-13)

**Week 11: Weighted Grade Calculation**
- Implement weighted average algorithm
- Create expedient generation wizard
- Design PDF template for expedient
- Test calculation accuracy
- Handle edge cases (missing hours, incomplete data)

**Week 12: Expedient Generation & Archival**
- Build complete PDF generation for expedients
- Implement file server archival system
- Create batch generation functionality
- Add database cleanup mechanism
- Test transaction rollback on errors

**Week 13: Testing Suite Development**
- Set up NUnit testing framework
- Write unit tests for business logic
- Create integration tests for workflows
- Generate code coverage report
- Document test scenarios and results

**Deliverables:**
- ✓ Academic expedient generation complete
- ✓ File server archival working
- ✓ Database cleanup implemented safely
- ✓ Testing suite with good coverage
- ✓ All Advanced Level features functional

---

### Phase 5: Polish, Testing & Documentation (Weeks 14-15)

**Week 14: UI/UX Refinement**
- Review all screens for Material Design compliance
- Improve error messages and user feedback
- Add loading indicators for slow operations
- Optimize performance (database queries, UI rendering)
- Fix all known bugs

**Week 15: Documentation & Preparation**
- Write technical documentation
- Create user manual with screenshots
- Prepare UML diagrams (class, sequence)
- Record video demonstration (5-8 minutes)
- Prepare presentation materials

**Deliverables:**
- ✓ All features polished and bug-free
- ✓ Performance optimized
- ✓ Complete documentation package
- ✓ Video demonstration recorded
- ✓ Presentation ready

---

## 7. User Interface Design Plan

### 7.1 Design Principles

**Material Design Adaptation for Desktop:**
- Clean, minimalist interface
- Institutional color palette (Generalitat de Catalunya)
- Consistent typography and spacing
- Proper elevation and shadows
- Professional iconography

**Color Scheme:**
- Primary: #1976D2 (Blue) - Headers, primary actions
- Secondary: #FFA726 (Orange) - Highlights, warnings
- Success: #4CAF50 (Green) - Completed, saved states
- Error: #F44336 (Red) - Errors, validation failures
- Warning: #FF9800 (Amber) - Draft, pending states
- Background: #FAFAFA (Light Gray)
- Text: #212121 (Dark Gray)

**Typography:**
- Headers: Roboto Bold, 18-24pt
- Body Text: Roboto Regular, 11-12pt
- Buttons: Roboto Medium, 12pt
- Input Fields: Roboto Regular, 11pt

### 7.2 Screen Designs

#### Screen 1: Login Screen
**Reference:** imatges/login.png

**Components:**
- Center logo (top center)
- Institution name (below logo)
- Username text field
- Password field (masked)
- "Remember username" checkbox
- Login button (primary action)
- Version number (footer)
- Error message area

**Layout:**
- Centered vertically and horizontally
- Maximum width: 400px
- Clean, professional appearance
- Clear visual hierarchy

---

#### Screen 2: Department Head Dashboard
**Reference:** imatges/jefe1.png

**Components:**
- Header with user name and role
- Quick stats cards:
  - Open evaluation periods count
  - Pending closures count
  - Recent modifications count
- Action shortcuts:
  - "Open Evaluation Period" button
  - "Close Evaluation Period" button
  - "View Audit Log" button
  - "Generate Reports" button
- Recent activity feed
- Calendar with evaluation deadlines
- Logout button

**Layout:**
- Top navigation bar with app title and user info
- Left sidebar with main navigation menu
- Main content area with dashboard cards
- Right panel with calendar and notifications

---

#### Screen 3: Teacher Grade Entry
**Reference:** imatges/profesor.png

**Components:**
- Group selector dropdown
- Evaluation period selector
- Student-subject grid (DataGridView)
  - Rows: Students (NIA, Name)
  - Columns: Subjects assigned to teacher
  - Editable grade cells
  - Comments icon next to each grade
- Progress indicator: "12/25 grades entered"
- Status legend (color meanings)
- Save draft button
- Submit grades button
- Period state indicator banner

**Layout:**
- Top toolbar with selectors and actions
- Main grid occupying most of screen
- Bottom status bar with progress
- Side panel for comments (when opened)

---

#### Screen 4: Faculty Portrait Gallery
**Reference:** imatges/people.png

**Components:**
- Search bar (by name)
- Filter dropdowns (department, status)
- Photo grid (4-6 columns)
  - Each cell: Photo, Name, Department
- Export buttons (PDF, Print)
- Zoom controls (optional)

**Layout:**
- Top toolbar with search and filters
- Scrollable grid content area
- Footer with export options

---

#### Screen 5: Audit Trail Viewer

**Components:**
- Date range selector
- User filter (dropdown)
- Student filter (search)
- Subject filter (dropdown)
- Audit log table:
  - Columns: Date/Time, User, Student, Subject, Old Grade, New Grade, Reason
- Export to XML button
- Clear filters button

**Layout:**
- Top filter bar with all selection controls
- Main table area (sortable columns)
- Bottom pagination controls
- Right panel with export options

---

#### Screen 6: Export Dialogs
**References:** imatges/pdf.png, imatges/csv.png, imatges/json.png, imatges/xml.png

**Common Components:**
- Data source selector
- Format options (specific to export type)
- Preview panel
- Export button
- Cancel button
- Progress bar (during export)

**Layout:**
- Left panel with options
- Right panel with preview
- Bottom action buttons

---

### 7.3 Navigation Structure

```
Login Screen
    ↓
Department Head Dashboard
    ├── Evaluation Period Management
    │   ├── Open Period Dialog
    │   └── Close Period Dialog
    ├── Grade Entry (View All)
    ├── Audit Trail Viewer
    ├── Faculty Gallery
    ├── Document Generation
    │   ├── Generate Bulletin (PDF)
    │   ├── Generate Record (PDF)
    │   └── Generate Expedient (PDF)
    ├── Data Export
    │   ├── CSV Export
    │   ├── JSON Export
    │   └── XML Export
    └── Center Configuration

Teacher Dashboard
    ├── Grade Entry (Own Subjects)
    ├── My Schedule
    └── Faculty Gallery (View Only)

Group Tutor Dashboard
    ├── Grade Entry (Read-Only/Limited Edit)
    ├── Evaluation Session Participation
    ├── Generate Bulletins (Own Group)
    └── Faculty Gallery (View Only)
```

---

## 8. Testing Strategy

### 8.1 Testing Approach

**Testing Pyramid:**
```
           /\
          /  \  E2E Tests (Manual Demonstration)
         /____\
        /      \  Integration Tests (NUnit)
       /        \
      /__________\  Unit Tests (NUnit, High Coverage)
```

### 8.2 Unit Testing Strategy

**Test Framework:** NUnit 3.x

**Coverage Target:** 70%+ for business logic layer

**Test Categories:**

1. **Grade Calculation Tests**
   - Weighted average calculation accuracy
   - Pass/fail determination logic
   - Grade range validation (0.00-10.00)
   - Decimal precision handling
   - Edge cases (null grades, zero hours)

2. **Authentication Tests**
   - Password hash verification
   - Role permission checks
   - Session timeout logic
   - Login attempt validation

3. **Data Validation Tests**
   - Input validation functions
   - Business rule enforcement
   - Error message generation
   - Constraint checking

4. **Audit Trail Tests**
   - Audit entry creation
   - Modification reason validation
   - Timestamp accuracy
   - User tracking

**Example Test Structure:**
```vbnet
<TestFixture>
Public Class GradeValidationTests
    Private validator As GradeValidator

    <SetUp>
    Public Sub SetUp()
        validator = New GradeValidator()
    End Sub

    <Test>
    Public Sub ValidGrade_WithinRange_ReturnsTrue()
        Dim result = validator.IsValidGrade(7.5)
        Assert.IsTrue(result)
    End Sub

    <Test>
    Public Sub InvalidGrade_AboveMax_ReturnsFalse()
        Dim result = validator.IsValidGrade(12.0)
        Assert.IsFalse(result)
    End Sub

    <Test>
    Public Sub InvalidGrade_BelowMin_ReturnsFalse()
        Dim result = validator.IsValidGrade(-1.0)
        Assert.IsFalse(result)
    End Sub
End Class
```

### 8.3 Integration Testing Strategy

**Test Scenarios:**

1. **Authentication Workflow**
   - Valid login → Dashboard navigation
   - Invalid login → Error message
   - Failed attempts → Audit log entry
   - Session timeout → Automatic logout

2. **Evaluation Period Lifecycle**
   - Department head opens period
   - Teacher enters grades during OPEN
   - Department head closes period
   - Teacher cannot modify during CLOSED
   - Audit trail records all transitions

3. **Grade Modification Workflow**
   - Enter grade during OPEN period
   - Close evaluation period
   - Modify grade with department head account
   - Verify audit trail entry created
   - Check original grade preserved

4. **Document Generation**
   - Generate PDF bulletin
   - Verify content accuracy
   - Check file creation on server
   - Validate document_archive entry

5. **Multi-Format Export**
   - Export to CSV → Valid format
   - Export to JSON → Valid syntax
   - Export to XML → Well-formed document
   - UTF-8 encoding preserved

**Integration Test Setup:**
```vbnet
<TestFixture>
Public Class EvaluationWorkflowTests
    Private testDb As TestDatabase
    Private authService As AuthenticationService
    Private evalService As EvaluationService

    <SetUp>
    Public Sub SetUp()
        ' Create test database with known data
        testDb = New TestDatabase()
        testDb.Initialize()

        authService = New AuthenticationService(testDb.Connection)
        evalService = New EvaluationService(testDb.Connection)
    End Sub

    <Test>
    Public Sub CompleteEvaluationCycle_AllSteps_Succeeds()
        ' Arrange
        Dim depHead = authService.Login("cap_estudis", "Test1234")
        Assert.IsNotNull(depHead)

        ' Act: Open period
        Dim openResult = evalService.OpenPeriod("DAM2", "Trimester1", depHead)
        Assert.IsTrue(openResult.Success)

        ' Act: Enter grade (as teacher)
        Dim teacher = authService.Login("prof_test", "Test1234")
        Dim gradeResult = evalService.EnterGrade(teacher, "1234567890", "M3", 8.5)
        Assert.IsTrue(gradeResult.Success)

        ' Act: Close period
        Dim closeResult = evalService.ClosePeriod("DAM2", "Trimester1", depHead)
        Assert.IsTrue(closeResult.Success)

        ' Assert: Teacher cannot modify
        Dim modifyResult = evalService.EnterGrade(teacher, "1234567890", "M3", 9.0)
        Assert.IsFalse(modifyResult.Success)
        Assert.AreEqual("Period is closed", modifyResult.ErrorMessage)
    End Sub

    <TearDown>
    Public Sub TearDown()
        testDb.Cleanup()
    End Sub
End Class
```

### 8.4 User Acceptance Testing (UAT)

**Test Accounts:**
- Department Head: `cap_estudis` / `Test1234`
- Teacher: `prof_test` / `Test1234`
- Group Tutor: `tutor_dam2` / `Test1234`

**Test Scenarios Document:** (To be created)
- Scenario 1: Department head opens evaluation period for DAM2
- Scenario 2: Teacher enters grades for assigned subjects
- Scenario 3: Department head closes period after review
- Scenario 4: Post-closure grade modification with justification
- Scenario 5: Generate and export student bulletin
- Scenario 6: Faculty gallery display and export
- Scenario 7: Academic expedient generation for graduate
- Scenario 8: Audit trail query and XML export

**Acceptance Criteria:**
- All test scenarios execute without errors
- User feedback is clear and helpful
- Performance meets specified thresholds
- All exports generate valid files
- UI is intuitive and professional

### 8.5 Performance Testing

**Response Time Targets:**
- Login: < 2 seconds
- Load grade entry grid (25 students): < 3 seconds
- Save grade changes: < 1 second
- Generate PDF bulletin: < 5 seconds
- Generate academic expedient: < 10 seconds
- Export large dataset to CSV (500 records): < 5 seconds

**Load Testing:**
- Support 10+ concurrent users
- Handle 1000+ students in database
- Process 10,000+ grade records without degradation

**Stress Testing:**
- Continuous operation for 8+ hours
- Multiple simultaneous PDF generations
- Large batch exports

---

## 9. Security Implementation Plan

### 9.1 Authentication Security

**Password Security:**
```vbnet
Public Class PasswordHasher
    Public Shared Function HashPassword(password As String) As String
        Using sha256 As SHA256 = SHA256.Create()
            Dim bytes As Byte() = Encoding.UTF8.GetBytes(password)
            Dim hash As Byte() = sha256.ComputeHash(bytes)
            Return Convert.ToBase64String(hash)
        End Using
    End Function

    Public Shared Function VerifyPassword(password As String, hash As String) As Boolean
        Dim computedHash As String = HashPassword(password)
        Return computedHash = hash
    End Function
End Class
```

**Session Management:**
- Session timeout: 30 minutes of inactivity
- Activity tracking on every user action
- Automatic logout with save prompt
- Session token validation before operations

**Login Attempt Tracking:**
- Log all login attempts to database
- Track IP address and timestamp
- Monitor for brute force attempts
- Consider account lockout after 5 failures

### 9.2 Database Security

**SQL Injection Prevention:**
```vbnet
' CORRECT: Parameterized query
Public Function GetStudent(nia As String) As Student
    Dim query = "SELECT * FROM students WHERE nia = @nia"
    Using conn As New MySqlConnection(connectionString)
        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@nia", nia)
            ' Execute query
        End Using
    End Using
End Function

' WRONG: String concatenation (vulnerable to SQL injection)
' Dim query = "SELECT * FROM students WHERE nia = '" & nia & "'"
```

**Connection String Security:**
```vbnet
' Store in encrypted app.config
<configuration>
  <connectionStrings>
    <add name="EvalDB"
         connectionString="Server=localhost;Database=evalis_db;Uid=evalis_user;Pwd=EncryptedPassword123;"
         providerName="MySql.Data.MySqlClient" />
  </connectionStrings>
</configuration>

' Encrypt configuration section
Dim config As Configuration = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None)
Dim section As ConnectionStringsSection = config.ConnectionStrings
If Not section.SectionInformation.IsProtected Then
    section.SectionInformation.ProtectSection("DataProtectionConfigurationProvider")
    config.Save()
End If
```

### 9.3 Role-Based Access Control

**Permission Check Before Operations:**
```vbnet
Public Function OpenEvaluationPeriod(user As User, groupCode As String, period As String) As Result
    ' Check if user has permission
    If user.Role <> UserRole.DepartmentHead Then
        Return New Result With {
            .Success = False,
            .ErrorMessage = "Only Department Head can open evaluation periods"
        }
    End If

    ' Proceed with operation
    ' ...
End Function
```

**UI Element Visibility:**
```vbnet
Private Sub LoadDashboard(user As User)
    ' Show/hide UI elements based on role
    btnOpenPeriod.Visible = (user.Role = UserRole.DepartmentHead)
    btnClosePeriod.Visible = (user.Role = UserRole.DepartmentHead)
    btnModifyClosedGrade.Visible = (user.Role = UserRole.DepartmentHead)

    ' Teachers only see grade entry for assigned subjects
    If user.Role = UserRole.Teacher Then
        LoadTeacherGradeEntry(user)
    End If
End Sub
```

### 9.4 Audit Trail Integrity

**Append-Only Audit Log:**
- Audit entries are NEVER deleted or modified
- All modifications create new audit entries
- Original data preserved in history
- Timestamp is server-generated (not client-provided)

**Audit Entry Creation:**
```vbnet
Public Sub CreateAuditEntry(modification As GradeModification, user As User)
    Dim query = "INSERT INTO grade_audit " &
                "(evaluation_id, student_nia, subject_code, old_grade, new_grade, " &
                "modified_by, modification_date, reason, session_state) " &
                "VALUES (@evalId, @nia, @subject, @oldGrade, @newGrade, " &
                "@user, NOW(), @reason, @state)"

    Using conn As New MySqlConnection(connectionString)
        Using cmd As New MySqlCommand(query, conn)
            cmd.Parameters.AddWithValue("@evalId", modification.EvaluationId)
            cmd.Parameters.AddWithValue("@nia", modification.StudentNia)
            cmd.Parameters.AddWithValue("@subject", modification.SubjectCode)
            cmd.Parameters.AddWithValue("@oldGrade", modification.OldGrade)
            cmd.Parameters.AddWithValue("@newGrade", modification.NewGrade)
            cmd.Parameters.AddWithValue("@user", user.DNI)
            cmd.Parameters.AddWithValue("@reason", modification.Reason)
            cmd.Parameters.AddWithValue("@state", modification.SessionState)

            conn.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Using
End Sub
```

### 9.5 Data Backup Strategy

**Database Backups:**
- Daily automated backups of MySQL database
- Backup stored on separate server/location
- Weekly full backups, daily incremental
- Test restore procedure monthly

**File Server Backups:**
- All generated PDFs backed up regularly
- Archival storage for academic expedients
- Version control for important documents

---

## 10. Risk Assessment & Mitigation

### 10.1 Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Database connection failures** | Medium | High | Implement connection pooling, retry logic, and offline mode for viewing (not editing) |
| **PDF generation errors** | Medium | Medium | Extensive testing with edge cases, error handling with user feedback, fallback to simpler templates |
| **Performance issues with large datasets** | Low | Medium | Database indexing, query optimization, pagination for large grids, lazy loading |
| **Concurrent modification conflicts** | Medium | High | Optimistic locking, transaction management, clear error messages to users |
| **Data corruption during export** | Low | High | Transaction rollback, validation before commit, backup before bulk operations |
| **Session timeout during long operations** | Medium | Low | Keep-alive mechanism during exports, save progress periodically, warning before timeout |

### 10.2 Development Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Scope creep** | High | High | Strictly follow feature roadmap, use phased approach, defer nice-to-have features |
| **Technology learning curve (VB.NET)** | Medium | Medium | Allocate extra time for learning, consult documentation, seek instructor help early |
| **Integration issues with shared database** | Medium | High | Early testing with mobile app data, coordinate schema changes, use transactions |
| **Underestimated complexity** | Medium | High | Build MVP first, add features incrementally, allocate buffer time in schedule |
| **Testing insufficient** | Medium | Medium | Prioritize testing in schedule, automate unit tests, create test data early |

### 10.3 User Experience Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Confusing UI for non-technical users** | High | Medium | User testing with target audience, clear labels and instructions, help documentation |
| **Unclear error messages** | Medium | Medium | User-friendly error text, avoid technical jargon, provide actionable guidance |
| **Slow response times** | Low | High | Performance testing, optimize database queries, loading indicators for slow operations |
| **Lost work due to crashes** | Low | High | Auto-save functionality, transaction rollback, clear save status indicators |

### 10.4 Security Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **SQL injection attacks** | Low | Critical | Use parameterized queries exclusively, input validation, code review |
| **Unauthorized data access** | Medium | High | Role-based access control, permission checks before operations, audit logging |
| **Password compromise** | Medium | High | SHA-256 hashing, enforce strong passwords, account lockout after failures |
| **Data breach via exports** | Low | High | Access control for export features, optional PDF encryption, secure file storage |

### 10.5 Project Management Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Missed deadlines** | Medium | High | Regular progress reviews, prioritize features by importance, cut optional features if needed |
| **Incomplete documentation** | High | Medium | Document as you develop, allocate dedicated documentation time, use templates |
| **Poor presentation** | Medium | Medium | Practice demonstration multiple times, prepare backup demo video, anticipate questions |

---

## 11. Resource Requirements

### 11.1 Development Tools

**Required Software:**
- Visual Studio 2019/2022 (Community Edition acceptable)
- XAMPP (MySQL 8.0, Apache optional)
- MySQL Workbench (database management)
- Git (version control)
- NuGet Package Manager (included with VS)

**Required Libraries:**
- MySQL.Data (MySQL Connector/NET)
- iTextSharp 5.5.13 or iText 7 (PDF generation)
- Newtonsoft.Json (JSON.NET)
- NUnit 3.x (testing framework)
- Moq (mocking framework for tests)

**Optional Tools:**
- Visual Studio Code (documentation editing)
- Draw.io or Lucidchart (UML diagrams)
- OBS Studio (video recording for demonstration)
- Postman (API testing if web services added)

### 11.2 Hardware Requirements

**Development Machine:**
- Windows 10/11 (64-bit)
- Processor: Intel i5 or equivalent
- RAM: 8GB minimum, 16GB recommended
- Storage: 50GB available space (SSD recommended)
- Display: 1920x1080 minimum resolution

**Database Server:**
- Can be same machine as development (XAMPP localhost)
- For production: Separate server with similar specs
- Network connectivity for remote database access

### 11.3 Human Resources

**Developer Role:** Student (Individual Project)

**Time Commitment:**
- Minimum: 100-120 hours over 15 weeks
- Recommended: 8-10 hours per week
- Critical periods: Weeks 7-8 (mid-project review), Weeks 14-15 (final polish)

**External Support:**
- Instructor: Technical guidance, code review, architecture advice
- Peers: Testing, feedback, collaborative problem-solving
- Online Resources: Documentation, tutorials, Stack Overflow

### 11.4 Test Data Requirements

**Database Population:**
- 10+ users (various roles)
- 50+ students (across multiple groups and levels)
- 10+ teachers with photos
- 100+ grade records (various states)
- 20+ audit trail entries
- 30+ login log entries
- 5+ evaluation sessions (open, closed, in-session)

**Test Files:**
- Teacher photos (10+ headshots, 300x300px minimum)
- Institution logo (PNG, high resolution)
- Sample documents for template testing

---

## 12. Success Criteria & Deliverables

### 12.1 Minimum Viable Product (MVP) - Passing Grade

**Score Target:** 0.50-0.65 / 1.0 points

**Required Features:**
- ✅ User authentication with SHA-256 password hashing
- ✅ Role-based access control (department head, teacher, tutor)
- ✅ Department head can open/close evaluation periods
- ✅ Teachers can enter grades only during OPEN periods
- ✅ Evaluation session simulation (IN_SESSION state)
- ✅ Faculty portrait gallery from database
- ✅ Basic PDF export (bulletins)
- ✅ Connection to external MySQL database
- ✅ Professional UI with Material Design influences
- ✅ 10+ test records in each database table
- ✅ Git commit history showing development progress

**Deliverables:**
- Source code (Visual Studio solution)
- Database SQL scripts (schema + test data)
- Basic documentation (setup guide, user manual)
- Screenshots of all screens
- Demo video (5-8 minutes)

---

### 12.2 Intermediate Implementation - Good Grade

**Score Target:** 0.65-0.85 / 1.0 points

**Required Features (All MVP + Following):**
- ✅ Complete audit trail system
- ✅ Post-closure grade modification (department head only)
- ✅ Modification history viewer with filtering
- ✅ All 4 export formats (PDF, CSV, JSON, XML)
- ✅ Enhanced faculty gallery with detailed profiles
- ✅ Robust error handling with user-friendly messages
- ✅ Professional documentation with UML diagrams

**Deliverables:**
- All MVP deliverables
- Comprehensive technical report (20-30 pages)
- UML diagrams (class diagram, sequence diagrams)
- Complete user manual with screenshots
- Test scenarios document with results
- Video demonstration showing advanced features

---

### 12.3 Advanced Implementation - Excellent Grade

**Score Target:** 0.85-1.0 / 1.0 points

**Required Features (All Intermediate + Following):**
- ✅ Academic expedient generation with weighted calculations
- ✅ File server archival system
- ✅ Database cleanup after expedient generation
- ✅ Unit testing suite (70%+ coverage)
- ✅ Integration testing for critical workflows
- ✅ Exceptional code quality and organization
- ✅ Polished presentation demonstrating all features

**Deliverables:**
- All Intermediate deliverables
- Unit test results and coverage report
- Integration test documentation
- Code quality analysis
- Professional presentation (10-15 minutes)
- Complete project portfolio

---

### 12.4 Quality Criteria

**Code Quality:**
- Consistent naming conventions (PascalCase for classes, camelCase for variables)
- Proper separation of concerns (UI, business logic, data access)
- Comprehensive error handling (Try-Catch blocks)
- Meaningful comments and documentation
- No code duplication (DRY principle)

**Documentation Quality:**
- Clear setup and installation instructions
- User manual with screenshots and step-by-step guides
- Technical architecture explanation
- Database schema with E-R diagram
- UML diagrams for key workflows

**Testing Quality:**
- All test scenarios pass successfully
- Unit tests cover critical business logic
- Integration tests validate complete workflows
- Performance meets specified thresholds
- No critical bugs in demonstration

---

## 13. Project Timeline

### 13.1 Gantt Chart Overview

```
Week | Phase                  | Key Deliverables
-----|------------------------|------------------------------------------
1    | Foundation             | Project setup, Git repo, DB connection
2    | Foundation             | Authentication system
3    | Foundation             | Session management, login audit
4    | Basic Features         | Evaluation period management
5    | Basic Features         | Grade entry interface
6    | Basic Features         | Evaluation session simulation
7    | Basic Features         | Faculty gallery, basic PDF export
     | --- MID-PROJECT REVIEW ---
8    | Intermediate Features  | Audit trail system
9    | Intermediate Features  | Record management, post-closure mods
10   | Intermediate Features  | CSV, JSON, XML exports
11   | Advanced Features      | Weighted grade calculation
12   | Advanced Features      | Expedient generation, file archival
13   | Advanced Features      | Unit and integration testing
14   | Polish & Documentation | UI refinement, bug fixing
15   | Final Preparation      | Documentation, video, presentation
     | --- FINAL PRESENTATION ---
```

### 13.2 Milestones

**Milestone 1: Foundation Complete (Week 3)**
- ✓ Project structure created
- ✓ Database connection working
- ✓ Login functional with role-based access

**Milestone 2: Basic Level Complete (Week 7)**
- ✓ All Basic Level features implemented
- ✓ Department head and teacher workflows functional
- ✓ Faculty gallery displays correctly
- ✓ Ready for mid-project review

**Milestone 3: Intermediate Level Complete (Week 10)**
- ✓ Audit trail system operational
- ✓ All export formats working
- ✓ Post-closure modifications functional

**Milestone 4: Advanced Level Complete (Week 13)**
- ✓ Academic expedient generation working
- ✓ Testing suite complete with good coverage
- ✓ All features polished and tested

**Milestone 5: Project Delivery (Week 15)**
- ✓ All documentation complete
- ✓ Video demonstration recorded
- ✓ Presentation materials ready
- ✓ Final submission prepared

### 13.3 Critical Path

**Must-Complete Items (Cannot be delayed):**
1. Database connection and authentication (Weeks 1-3)
2. Evaluation period management (Week 4)
3. Grade entry interface (Week 5)
4. Audit trail system (Week 8)
5. Testing and bug fixing (Weeks 13-14)
6. Documentation (Week 15)

**Can-Be-Deferred Items (If schedule slips):**
- Enhanced faculty gallery features
- Advanced export options (JSON, XML)
- Unit testing suite (if Basic/Intermediate level targeted)
- Academic expedient generation (if only targeting Intermediate)

---

## 14. Implementation Checklist

### 14.1 Week-by-Week Checklist

**Week 1:**
- [ ] Install Visual Studio and XAMPP
- [ ] Create Visual Studio project structure
- [ ] Initialize Git repository
- [ ] Install required NuGet packages
- [ ] Create initial documentation structure

**Week 2:**
- [ ] Implement DatabaseManager class
- [ ] Create repository pattern interfaces
- [ ] Test MySQL connection
- [ ] Create database schema SQL scripts
- [ ] Insert test data (minimum 10 rows per table)

**Week 3:**
- [ ] Design login form UI
- [ ] Implement password hash verification
- [ ] Create AuthenticationService class
- [ ] Implement session management
- [ ] Add login audit logging

**Week 4:**
- [ ] Design evaluation period dashboard
- [ ] Implement OpenPeriod workflow
- [ ] Implement ClosePeriod workflow
- [ ] Add state validation checks
- [ ] Create visual period state indicators

**Week 5:**
- [ ] Design grade entry grid (DataGridView)
- [ ] Implement real-time grade validation
- [ ] Create comments dialog
- [ ] Add auto-save functionality (60 sec)
- [ ] Implement submit grades workflow

**Week 6:**
- [ ] Create evaluation session management UI
- [ ] Implement IN_SESSION state logic
- [ ] Add role-based modification controls
- [ ] Create session end workflow
- [ ] Test all state transitions

**Week 7:**
- [ ] Design faculty gallery grid layout
- [ ] Implement photo loading from database
- [ ] Add filters (department, status)
- [ ] Create basic PDF export for gallery
- [ ] Handle missing photos with placeholder
- **MID-PROJECT REVIEW**

**Week 8:**
- [ ] Create grade_audit table structure
- [ ] Implement AuditTrailService class
- [ ] Design audit log viewer UI
- [ ] Add filtering by date/user/student
- [ ] Implement grade history timeline view

**Week 9:**
- [ ] Create evaluation records list view
- [ ] Build modification request dialog
- [ ] Implement reason validation (min 20 chars)
- [ ] Add approval workflow for modifications
- [ ] Test post-closure modification with audit

**Week 10:**
- [ ] Implement CSV export functionality
- [ ] Add JSON export for faculty lists
- [ ] Create XML export for audit logs
- [ ] Test all export formats
- [ ] Verify UTF-8 encoding for Catalan

**Week 11:**
- [ ] Implement WeightedGradeCalculator class
- [ ] Create expedient generation wizard UI
- [ ] Design PDF template for expedient
- [ ] Test weighted calculation accuracy
- [ ] Handle edge cases (missing data)

**Week 12:**
- [ ] Build complete PDF generation for expedients
- [ ] Implement file server archival system
- [ ] Create batch generation functionality
- [ ] Add database cleanup mechanism
- [ ] Test transaction rollback on errors

**Week 13:**
- [ ] Set up NUnit testing framework
- [ ] Write unit tests for business logic
- [ ] Create integration tests for workflows
- [ ] Generate code coverage report
- [ ] Document all test scenarios

**Week 14:**
- [ ] Review all screens for Material Design
- [ ] Improve error messages
- [ ] Add loading indicators
- [ ] Optimize database queries
- [ ] Fix all known bugs

**Week 15:**
- [ ] Complete technical documentation
- [ ] Write user manual with screenshots
- [ ] Create UML diagrams
- [ ] Record video demonstration
- [ ] Prepare presentation materials
- **FINAL SUBMISSION**

---

## 15. Conclusion

### 15.1 Project Summary

The EVALIS Desktop Application represents a comprehensive solution for academic evaluation management in educational institutions across Catalonia. By implementing this Visual Basic application with a focus on security, usability, and robust data management, we will deliver a professional tool that meets the needs of department heads, teachers, and administrative staff.

### 15.2 Key Success Factors

1. **Phased Implementation:** Building features incrementally from Basic to Advanced ensures a working product at each stage
2. **Quality Focus:** Emphasis on professional UI, comprehensive testing, and thorough documentation
3. **Security First:** SHA-256 password hashing, parameterized queries, and role-based access control
4. **Audit Transparency:** Complete modification history for accountability and compliance
5. **Multi-Format Exports:** PDF, CSV, JSON, and XML for maximum flexibility

### 15.3 Expected Outcomes

**For Users:**
- Streamlined evaluation period management
- Secure, role-based access to academic data
- Professional document generation
- Complete transparency through audit trails

**For the Institution:**
- Improved academic record-keeping
- Compliance with educational standards
- Reduced administrative burden
- Enhanced data integrity

**For the Developer:**
- Comprehensive understanding of desktop application development
- Experience with database integration and transaction management
- Professional portfolio piece demonstrating full-stack capabilities
- Target achievement: Advanced Level (0.85-1.0 / 1.0 points)

---

## Document Control

**Document Version:** 1.0
**Created:** January 22, 2026
**Last Updated:** January 22, 2026
**Author:** EVALIS Development Team
**Status:** Planning Phase
**Next Review:** After Week 7 (Mid-Project Review)

---

## Appendix

### A. References

- DESKTOP_PROJECT_DESCRIPTION.md - Complete project specification
- Visual Basic .NET Documentation - Microsoft Docs
- MySQL Connector/NET Documentation - MySQL Developer Guide
- iTextSharp Documentation - PDF generation library
- NUnit Documentation - Unit testing framework

### B. Contact Information

**Project Instructor:** [To be filled]
**Email:** [To be filled]
**Office Hours:** [To be filled]
**Moodle Course:** [To be filled]

### C. Glossary

- **Acta d'Avaluació:** Evaluation Record (official document)
- **Bulletin de Notes:** Grade Bulletin/Report Card
- **Cap d'Estudis:** Department Head (highest administrative role)
- **Expedient Acadèmic:** Academic Transcript (graduation document)
- **Generalitat de Catalunya:** Government of Catalonia
- **Junta d'Avaluació:** Evaluation Session/Meeting
- **NIA:** Número d'Identificació de l'Alumne (Student ID)
- **Orla de Professorat:** Faculty Portrait Gallery

---

**END OF DOCUMENT**
