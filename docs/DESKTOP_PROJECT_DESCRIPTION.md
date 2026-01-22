# EVALIS - Desktop Application (Visual Basic)

## Project Overview

**EVALIS Desktop** is the administrative interface for the EVALIS educational evaluation platform, designed for educational institutions across Catalonia. This Visual Basic application serves as the primary tool for **department heads**, **teachers**, and **administrative staff** to manage evaluations, enter grades, generate official documents, and maintain academic records. Unlike the mobile application which focuses on student consultation, the desktop application emphasizes data entry, evaluation workflow management, and document generation.

### Purpose
- Provide comprehensive evaluation management tools for educational staff
- Enable secure grade entry during evaluation periods
- Facilitate evaluation session/meeting workflows
- Generate official academic documents (bulletins, records, expedients)
- Export data in multiple formats (PDF, CSV, JSON, XML)
- Maintain audit trails for all grade modifications
- Manage evaluation period lifecycles (open → closed)

### Target Users
- **Department Heads (Cap d'Estudis)** - Primary administrative role with highest permissions
- **Teachers/Professors** - Grade entry and subject management
- **Group Tutors** - Class-level evaluation oversight
- **Administrative Staff** - Document generation and archival

### Key Constraints
- Must use **Visual Basic** for the desktop interface
- Must connect to same **external SQL database** as mobile app (XAMPP/MySQL)
- Must follow **Material Design principles** adapted for desktop
- Must generate multiple export formats (PDF, CSV, JSON, XML)
- Must maintain comprehensive audit trails
- Must handle evaluation period state management

---

## Technology Stack

### Development Environment
- **Visual Basic** (VB.NET or VB6, preferably VB.NET)
- **Visual Studio** as IDE
- **.NET Framework** or .NET Core (for VB.NET)

### Database Connectivity
- **SQL Database** (MySQL via XAMPP)
- **ADO.NET** or **ODBC** for database connections
- Connection string management for external database
- Transaction support for data integrity

### Document Generation Libraries
- **PDF Generation:**
  - iTextSharp (for .NET)
  - PDFSharp
  - Crystal Reports (optional)
  - Custom PDF generation for academic documents

- **CSV/Excel Export:**
  - System.IO for CSV writing
  - EPPlus, ClosedXML, or Microsoft Office Interop for Excel
  - CSV format following RFC 4180 standard

- **JSON Export:**
  - Newtonsoft.Json (JSON.NET)
  - System.Text.Json (.NET Core)
  - Structured JSON output for API consumption

- **XML Export:**
  - System.Xml namespace
  - LINQ to XML for structured data
  - Schema-compliant XML generation

### UI Framework
- **Windows Forms** or **WPF** (Windows Presentation Foundation)
- Material Design principles adapted to desktop:
  - Institutional color palette
  - Consistent typography
  - Proper spacing and elevation
  - Custom iconography

### Testing Frameworks (Advanced Level)
- **Unit Testing:**
  - NUnit or MSTest
  - Test coverage for business logic classes
  - Mock database connections for testing

- **Integration Testing:**
  - Test database operations
  - Test document generation
  - Test API endpoints if applicable

---

## Database Requirements

### Shared Database Architecture
The desktop application connects to the **same external SQL database** as the Android mobile application. This ensures data consistency and enables real-time updates across platforms.

### Database Connection
- **XAMPP Server** hosting MySQL database
- Connection via TCP/IP (not localhost only - must support network access)
- Secure connection strings (encrypted or in secure configuration)
- Connection pooling for performance
- Transaction management for data integrity

### Database Entities Used by Desktop App

All entities described in the Android app documentation apply here as well. Additional emphasis on:

#### 1. Evaluation Sessions Table
- `session_id` (primary key)
- `evaluation_period` - Trimester, UF, or RA identifier
- `group_code` - Which group is being evaluated
- `state` - OPEN, IN_SESSION, CLOSED
- `opened_by` - Department head DNI
- `opened_date` - When period was opened
- `closed_by` - Who closed the period
- `closed_date` - When period was closed
- `session_notes` - Meeting minutes or observations

#### 2. Grade Modification Audit Table
- `audit_id` (primary key)
- `evaluation_id` - Which grade was modified
- `modified_by` - User DNI who made change
- `modification_date` - Timestamp of change
- `old_value` - Previous grade value
- `new_value` - New grade value
- `reason` - Explanation for modification (required for closed evaluations)
- `approved_by` - Department head approval (for post-closure modifications)

#### 3. Login Audit Table
- `login_id` (primary key)
- `user_dni` - Who logged in
- `username` - Login username
- `login_timestamp` - When login occurred
- `ip_address` - Source IP
- `success` - Boolean (successful or failed attempt)
- `session_duration` - How long they were logged in

#### 4. Document Archive Table
- `document_id` (primary key)
- `document_type` - Bulletin, Record, Expedient
- `student_nia` - Associated student
- `generation_date` - When document was created
- `file_path` - Server location of PDF
- `generated_by` - User who generated document
- `academic_year` - Which year this covers

#### 5. Center Configuration Table
- `config_key` (primary key)
- `config_value` - Setting value
- Settings include:
  - Center name and logo
  - Institutional colors
  - Default evaluation weights
  - Academic calendar dates
  - Document templates

---

## User Roles & Permissions

### Department Head (Cap d'Estudis) - Highest Authority

**Primary Responsibilities:**
- Open and close evaluation periods
- Override grade locks on closed evaluations
- Approve post-closure modifications
- Access all groups and all subjects
- Generate official documents
- View complete audit trails
- Configure center settings

**Permissions:**
- **Full Read Access:** All students, all grades, all evaluations
- **Full Write Access:** Can modify grades even after closure (with audit)
- **Session Management:** Open/close evaluation periods
- **Document Authority:** Generate and archive official documents
- **User Management:** View login logs, manage teacher access (optional)
- **System Configuration:** Center settings, academic calendar

**Login Credentials (Demo):**
- Username: `cap_estudis`
- Password: `Test1234`
- Role: Department Head

---

### Teacher/Professor - Subject-Level Access

**Primary Responsibilities:**
- Enter grades for assigned subjects
- Add comments/observations to evaluations
- View own teaching schedule
- Generate student bulletins for own subjects
- Participate in evaluation sessions

**Permissions:**
- **Read Access:** Only students in assigned groups/subjects
- **Write Access:** Only during open evaluation periods
- **Restricted Modification:** Cannot modify grades after period closure
- **Document Generation:** Bulletins for own subjects only
- **No System Access:** Cannot access configuration or audit logs

**Login Credentials (Demo):**
- Username: `prof_test`
- Password: `Test1234`
- Role: Teacher

---

### Group Tutor - Class-Level Oversight

**Primary Responsibilities:**
- Oversee all evaluations for assigned group(s)
- Coordinate evaluation sessions
- View grades from all subjects in their group
- Generate complete bulletins for group students
- Facilitate evaluation meetings

**Permissions:**
- **Read Access:** All subjects for assigned group(s)
- **Limited Write Access:** Can suggest modifications during evaluation sessions
- **Session Participation:** Present during evaluation meetings
- **Document Generation:** Complete bulletins for group students

---

## Core Features - Basic Level

### 1. User Authentication & Authorization
**Score:** 1.0 point (combined for entire desktop frontend)

**Functionality:**
- Login screen with username and password fields
- Role-based authentication against SQL database
- Secure password hashing verification (SHA, not MD5)
- Session management with role-specific interface
- Auto-logout after inactivity period
- Login attempt logging to audit table

**UI Design:**
- Professional login form with institutional branding
- Center logo and name displayed
- Role selector dropdown (optional, can auto-detect from credentials)
- "Remember username" checkbox (NOT password)
- Clear error messages for failed attempts
- Reference image: `imatges/login.png`

**Security Requirements:**
- Password never stored in plain text locally
- Connection string encrypted or in secure config file
- Session timeout after 30 minutes of inactivity
- Log all login attempts (successful and failed) with timestamp and IP

**Post-Login Behavior:**
- Redirect to appropriate dashboard based on role
- Display user name and role in application header
- Show logout button and session timer

---

### 2. Evaluation Period Management (Department Head Only)
**Score:** Part of 1.0 point total

**Functionality:**
- Department head can open evaluation periods for specific groups
- When period is OPEN:
  - Teachers can enter and modify grades for their subjects
  - Grades are in "Draft" state
  - Validation warnings but not blocking

- When period is CLOSED:
  - Teachers **cannot** modify grades
  - Only department head can make changes (with audit trail)
  - Documents can be officially generated

**UI Components:**
- **Evaluation Period Dashboard:**
  - List all groups with current period states (Open/Closed)
  - Open button (enabled only for department head)
  - Close button (enabled only for department head)
  - Visual indicators: Green (Open), Red (Closed), Yellow (In Session)

- **Open Period Dialog:**
  - Select group(s) to open
  - Select evaluation period (Trimester 1/2/3, UF, RA)
  - Set deadline for grade entry
  - Notification option (alert teachers via email/system)
  - Confirmation prompt with period details

- **Close Period Dialog:**
  - Validation check: Ensure all grades entered (no nulls)
  - Warning if validation fails: "5 students have missing grades in Mathematics"
  - Force close option (not recommended, requires reason)
  - Generate PDF bulletin batch option
  - Confirmation prompt: "This action will lock grades for teachers"

**Business Logic:**
- Check database state before allowing modifications
- Prevent grade entry if period is closed (unless department head)
- Update session_state table when opening/closing
- Record who opened/closed and when in audit trail

**Reference Image:** `imatges/jefe1.png` (Department head screen)

---

### 3. Grade Entry Interface (Teachers)
**Score:** Part of 1.0 point total

**Functionality:**
- Teachers can enter grades only when evaluation period is OPEN
- View all students in assigned subjects
- Enter numeric grades (0-10 scale, or system-specific scale)
- Add comments/observations for each grade
- Save as draft or submit for review
- Real-time validation of grade values

**UI Design:**
- **Grade Entry Grid:**
  - Rows: Students (name, NIA)
  - Columns: Subjects assigned to logged-in teacher
  - Editable cells for grade values
  - Comments icon/button next to each grade cell
  - Color coding: Green (saved), Yellow (draft), Red (invalid)

- **Subject View:**
  - Filter by group (if teacher has multiple sections)
  - Filter by evaluation period
  - Display student count
  - Progress indicator: "12/25 grades entered"

- **Grade Entry Cell:**
  - Numeric input (0.00 - 10.00)
  - Validation: Must be between 0 and 10
  - Decimal precision: 2 decimal places
  - Pass/fail visual indicator (≥5.0 = pass)

- **Comments Dialog:**
  - Text area for teacher observations
  - Character limit: 500 characters
  - Templates for common comments (optional)
  - Timestamp of last comment update

**Business Logic:**
- Check if evaluation period is OPEN before allowing edits
- If CLOSED: Display error "Evaluation period is closed. Contact department head."
- Validate grade range and format
- Auto-save drafts every 60 seconds
- Confirmation dialog before submitting grades

**Reference Image:** `imatges/profesor.png` (Teacher grade entry screen)

---

### 4. Evaluation Meeting Simulation (Junta d'Avaluació)
**Score:** Part of 1.0 point total

**Functionality:**
- Simulate in-person evaluation session/meeting
- During meeting: State changes to "IN_SESSION"
- Only group tutor and department head can modify grades during session
- Regular teachers have read-only access during meeting
- Facilitates discussion and final grade decisions

**UI Components:**
- **Start Evaluation Session Button (Department Head):**
  - Select group and evaluation period
  - Marks session as IN_SESSION in database
  - Notification sent to group tutor

- **Session Active Screen:**
  - Large banner: "EVALUATION SESSION IN PROGRESS - Group DAM2"
  - Grade modification controls enabled for tutor and department head
  - Modification log visible in side panel
  - Timer showing session duration

- **Modification Controls:**
  - Ability to adjust grades based on team discussion
  - Reason field required for each modification
  - Real-time updates visible to all participants (if multiple users logged in)

- **End Session Button:**
  - Finalizes all grades
  - Generates session minutes (optional)
  - Changes state from IN_SESSION to CLOSED
  - Locks grades from teacher modification

**Business Logic:**
- Check user role before allowing session modifications
- Log all changes during session with timestamps
- Validate that all grades are complete before ending session
- Generate notification when session ends

**Use Case Flow:**
1. Department head clicks "Start Evaluation Session" for DAM2, Trimester 1
2. System sets state to IN_SESSION
3. Tutor and department head review grades together
4. Adjustments made with justifications entered
5. Department head clicks "End Session"
6. System validates all grades complete
7. State changes to CLOSED
8. Teachers notified that period is closed

---

### 5. Faculty Portrait Gallery (Orla de Professorat)
**Score:** Part of 1.0 point total

**Functionality:**
- Generate and display complete faculty portrait gallery
- Query all teachers from SQL database
- Display photos in professional yearbook-style layout
- Print or export gallery for institutional use

**UI Design:**
- **Gallery View:**
  - Grid layout with 4-6 columns
  - Each cell contains:
    - Teacher photo (professional headshot)
    - Full name
    - Department or specialization
    - Optional: Years at institution

- **Filters:**
  - All faculty (default)
  - Filter by department
  - Filter by active/inactive status
  - Sort alphabetically or by seniority

- **Export Options:**
  - Print preview
  - Export to PDF (full page layout)
  - Export to image (PNG/JPG)
  - High-resolution option for professional printing

**Data Source:**
- Query teachers table
- Retrieve photo_path for each teacher
- Load images from server file system
- Handle missing photos with placeholder image

**Reference Image:** `imatges/people.png` (Faculty gallery screen)

**Technical Implementation:**
- FlowLayoutPanel or DataGridView for photo grid
- PictureBox controls for images
- Custom print document for gallery printing
- PDF generation with proper layout and spacing

---

## Core Features - Intermediate Level

### 6. Evaluation Record Management (Actes d'Avaluació)
**Score:** Part of 1.0 point total

**Functionality:**
- Manage closed evaluation records (actes)
- View historical evaluation records
- Allow corrections after closure for legitimate errors or appeals
- Maintain complete history of all modifications

**UI Components:**
- **Evaluation Records List:**
  - Display all closed evaluation periods
  - Columns: Group, Period, Closure Date, Closed By
  - Status indicator: Finalized, Modified
  - Search and filter by group, date, period

- **Record Detail View:**
  - Complete grade listing for the closed period
  - All students and subjects in grid format
  - Modification history link for each grade
  - "Request Modification" button (department head only)

- **Modification Request Dialog:**
  - Select grade(s) to modify
  - Enter new grade value
  - **Required: Reason for modification** (text field, min 20 characters)
  - Examples: "Calculation error," "Student appeal approved," "Exam rescoring"
  - Approval workflow (can be auto-approved for department head)

**Business Logic:**
- Only department head can modify closed evaluations
- Every modification **must** have a reason
- Modification creates new audit trail entry
- Original grade preserved in history
- Timestamp and user recorded for accountability

**Use Case:**
- Student appeals a grade 3 days after period closure
- Department head reviews appeal and approves correction
- Opens evaluation record, clicks "Request Modification"
- Changes grade from 4.5 to 5.0
- Enters reason: "Exam rescoring after appeal - calculation error found"
- System logs modification with timestamp and user
- Updated bulletin can be regenerated

---

### 7. Audit Trail & Modification History
**Score:** Part of 1.0 point total

**Functionality:**
- Complete audit trail for all grade modifications
- Queryable database of change history
- Transparency and accountability for all changes
- Compliance with educational record-keeping requirements

**Audit Data Captured:**
- **What changed:** Grade value (old → new)
- **Who changed it:** User DNI and username
- **When changed:** Timestamp (date and time)
- **Why changed:** Reason/justification text
- **Context:** Evaluation period, subject, student

**UI Components:**
- **Audit Log Viewer:**
  - Searchable table of all modifications
  - Filters:
    - Date range
    - User (who made change)
    - Student
    - Subject
    - Group
  - Export to CSV or XML for external analysis

- **Grade History View:**
  - Per-grade modification timeline
  - Visual timeline showing all changes
  - Color coding: Green (initial entry), Yellow (draft update), Orange (post-closure modification)
  - Expandable items showing full details of each change

- **Modification Details:**
  - Before/After comparison
  - User profile of who made change
  - Timestamp with precision (DD/MM/YYYY HH:MM:SS)
  - Full reason text
  - Approval status (if required)

**Database Schema:**
```sql
CREATE TABLE grade_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_id INT,
    student_nia VARCHAR(20),
    subject_code VARCHAR(20),
    old_grade DECIMAL(4,2),
    new_grade DECIMAL(4,2),
    modified_by VARCHAR(20),
    modification_date DATETIME,
    reason TEXT,
    approved_by VARCHAR(20),
    session_state VARCHAR(20),
    FOREIGN KEY (evaluation_id) REFERENCES evaluations(evaluation_id),
    FOREIGN KEY (student_nia) REFERENCES students(nia),
    FOREIGN KEY (modified_by) REFERENCES users(dni)
);
```

**Use Cases:**
- Administrator audits all grade changes in last trimester
- Investigates suspicious pattern of grade changes by a specific teacher
- Generates report for educational inspectors
- Student questions when grade was changed and why

---

### 8. Faculty Portrait Display (Advanced View)
**Score:** Part of 1.0 point total

**Functionality:**
- Enhanced faculty portrait gallery with additional features
- Integration with database for dynamic updates
- Professional layout suitable for official publications

**Enhanced Features:**
- **Detailed Faculty Cards:**
  - Click portrait to view full teacher profile
  - Shows: Contact info, subjects taught, schedule, office location
  - Years of service at institution
  - Degrees and certifications

- **Organizational View:**
  - Group by department
  - Show department heads prominently
  - Organizational hierarchy visualization

- **Export for Printing:**
  - Professional yearbook-style layout
  - High-resolution image export
  - Customizable template (header, footer, logos)
  - Multiple layout options (2×4, 3×5, 4×6 grids)

**Reference Image:** `imatges/people.png`

---

## Core Features - Advanced Level

### 9. Academic Expedient Generation
**Score:** Part of 1.0 point total (Advanced Level)

**Functionality:**
- Generate official "Expedient Acadèmic" (Academic Transcript) when student graduates
- Calculate weighted final grade based on subject hours
- Create comprehensive PDF document
- Archive document on file server
- Clean up database after expedient generation

**Weighted Grade Calculation:**
```
Formula: Σ(Grade × Subject Hours) / Σ(Subject Hours)

Example (CFGS DAM):
- Programació (M3): 8.5 × 6h = 51
- Bases de Dades (M2): 7.0 × 5h = 35
- Entorns (M1): 9.0 × 3h = 27
- ... (all subjects)
Total: 390 / 45h = 8.67 final grade
```

**PDF Document Contents:**
- **Header:**
  - Generalitat de Catalunya logo
  - Center name and code
  - Document title: "EXPEDIENT ACADÈMIC"
  - Student NIA and full name
  - Generation date

- **Student Information:**
  - DNI
  - Date of birth
  - Enrollment dates (start and end)
  - Educational level (CFGS, CFGM, Batxillerat, ESO)

- **Grade Breakdown:**
  - Table with columns: Subject Code, Subject Name, Hours, Grade
  - All subjects with final grades
  - Trimester/UF/RA breakdown if applicable
  - FCT information for vocational programs

- **Final Grades:**
  - Weighted average calculation shown
  - Final grade (bold, large font)
  - Graduation status: "GRADUAT" or "NO GRADUAT"
  - Date of graduation

- **Signatures:**
  - Department head signature block
  - Center director signature block
  - Official stamp placeholder

**UI Components:**
- **Expedient Generation Wizard:**
  - Step 1: Select student(s) for graduation
  - Step 2: Verify all grades are complete
  - Step 3: Review weighted calculation
  - Step 4: Preview PDF document
  - Step 5: Confirm generation and archival

- **Batch Generation:**
  - Generate expedients for entire graduating class
  - Progress bar showing completion
  - Error handling for incomplete records

**File Server Archival:**
- Save PDF to designated server directory
- Naming convention: `{NIA}_{Surname}_{Cycle}_{Year}.pdf`
  - Example: `1234567890_Garcia_DAM_2026.pdf`
- Record file path in document_archive table
- Set appropriate file permissions (read-only for teachers)

**Database Cleanup:**
- **After successful expedient generation:**
  - Archive grade records (move to history table)
  - Remove from active evaluations table
  - Preserve audit trails (never delete)
  - Update student status to "Graduated"

**Business Logic:**
- Only generate if all grades are finalized (no pending evaluations)
- Verify FCT completion for vocational programs
- Validate weighted calculation accuracy
- Prevent duplicate generation (check if already exists)
- Rollback on errors (transaction management)

**Use Case Flow:**
1. Student completes all subjects in DAM2
2. Department head reviews final grades
3. Opens "Generate Expedient" tool
4. Selects student "Joan García - NIA 1234567890"
5. System calculates weighted average: 8.67
6. Previews PDF document
7. Confirms generation
8. PDF created and saved to `/arxiu/expedients/2026/1234567890_Garcia_DAM_2026.pdf`
9. Database record updated: Student status = "Graduated"
10. Active grades moved to historical archive table

---

### 10. Unit Testing & Integration Testing
**Score:** Part of 1.0 point total (Advanced Level)

**Functionality:**
- Comprehensive test suite for application classes
- Unit tests for business logic
- Integration tests for desktop module
- Automated testing framework

**Unit Testing:**

**Test Coverage Areas:**
- **Grade Calculation Logic:**
  - Test weighted average calculation
  - Test pass/fail determination
  - Test grade range validation
  - Test decimal precision handling

- **Authentication & Authorization:**
  - Test role permission checks
  - Test password hash verification
  - Test session management

- **Data Validation:**
  - Test input validation functions
  - Test database constraint checks
  - Test error message generation

**Example Unit Tests (VB.NET with NUnit):**
```vbnet
<TestFixture>
Public Class GradeCalculationTests
    <Test>
    Public Sub WeightedAverage_ValidGrades_ReturnsCorrectValue()
        ' Arrange
        Dim calculator As New GradeCalculator()
        Dim subjects As New List(Of Subject) From {
            New Subject With {.Grade = 8.5, .Hours = 6},
            New Subject With {.Grade = 7.0, .Hours = 5}
        }

        ' Act
        Dim result As Decimal = calculator.CalculateWeightedAverage(subjects)

        ' Assert
        Assert.AreEqual(7.82, result, 0.01) ' (8.5*6 + 7.0*5) / 11 = 7.82
    End Sub

    <Test>
    Public Sub ValidateGrade_OutOfRange_ThrowsException()
        ' Arrange & Act & Assert
        Assert.Throws(Of ArgumentOutOfRangeException)(
            Sub() ValidateGrade(12.5) ' Grade > 10
        )
    End Sub
End Class
```

**Integration Testing:**

**Test Scenarios:**
- **Database Operations:**
  - Test connection establishment
  - Test CRUD operations (Create, Read, Update, Delete)
  - Test transaction rollback on errors
  - Test foreign key constraint handling

- **Document Generation:**
  - Test PDF creation with sample data
  - Test CSV export formatting
  - Test JSON structure validity
  - Test XML schema compliance

- **Workflow Integration:**
  - Test complete evaluation period lifecycle (Open → Entry → Close)
  - Test grade modification with audit trail creation
  - Test expedient generation end-to-end

**Test Data:**
- Use separate test database (not production)
- Seed test data with known values
- Clean up test data after each test run
- Mock external dependencies when appropriate

**Test Reporting:**
- Generate test coverage report
- Document pass/fail rates
- Include in project documentation
- Demonstrate during presentation

---

## Data Export Capabilities

### 1. PDF Exports

**Bulletin de Notes (Grade Bulletin):**
- Official student report card
- All subjects with grades for specific period
- Teacher comments included
- Pass/fail summary
- Institution branding and signatures
- **Triggered by:** Export button in grade view
- **Reference:** `imatges/pdf.png`

**Acta d'Avaluació (Evaluation Record):**
- Complete evaluation session document
- All students in a group with all subject grades
- Official document for archival
- Signatures from department head and tutors
- **Triggered by:** Close evaluation period workflow

**Expedient Acadèmic (Academic Transcript):**
- Comprehensive transcript with weighted grades
- Generated at graduation (see Feature 9)
- Official document with legal validity

**PDF Generation Requirements:**
- Professional layout with proper margins
- Institution logo and headers
- Page numbers and document metadata
- Security: Password-protect sensitive documents (optional)
- Compliance with official document formatting standards

---

### 2. CSV Exports

**Class Student List:**
- Export complete student roster for a group
- Columns: NIA, Full Name, DNI, Email, Phone, Group, Enrollment Status
- Use case: Import into spreadsheet for attendance tracking
- **Triggered by:** "Export Class List" button in group view
- **Reference:** `imatges/csv.png`

**Grade Export for Analysis:**
- All grades for a subject or group
- Columns: Student Name, NIA, Subject, Grade, Evaluation Period, Pass/Fail
- Use case: Statistical analysis in Excel
- **Triggered by:** "Export Grades to CSV" in grade management screen

**CSV Format Requirements:**
- RFC 4180 compliance
- UTF-8 encoding for Catalan characters
- Comma delimiter (configurable to semicolon for Excel compatibility)
- Quoted fields containing commas or newlines
- Header row with column names

**Example CSV Output:**
```csv
NIA,Nom Complet,Assignatura,Nota,Període,Aprovat
1234567890,"García Martínez, Joan",Programació,8.5,Trimestre 1,Sí
1234567891,"López Fernández, Maria",Programació,6.0,Trimestre 1,Sí
1234567892,"Pérez Sánchez, Jordi",Programació,4.5,Trimestre 1,No
```

---

### 3. JSON Exports

**Faculty List Export:**
- Complete teacher roster in structured JSON format
- Use case: API consumption, data integration with other systems
- **Triggered by:** "Export Faculty to JSON" in faculty management
- **Reference:** `imatges/json.png`

**JSON Structure:**
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
      "email": "jgarcia@institutcaparrella.cat",
      "phone": "+34666123456",
      "department": "Informàtica",
      "subjects": [
        {
          "code": "M3",
          "name": "Programació",
          "hours": 6,
          "groups": ["DAM1A", "DAM1B"]
        },
        {
          "code": "M5",
          "name": "Entorns de Desenvolupament",
          "hours": 3,
          "groups": ["DAM1A"]
        }
      ],
      "photo_url": "/img/users/prof/jgarcia.jpg",
      "years_of_service": 8,
      "status": "active"
    },
    {
      "teacher_id": "PROF002",
      "dni": "23456789B",
      "full_name": "Martínez López, Maria",
      "email": "mmartinez@institutcaparrella.cat",
      "phone": "+34666234567",
      "department": "Matemàtiques",
      "subjects": [
        {
          "code": "MAT1",
          "name": "Matemàtiques I",
          "hours": 4,
          "groups": ["BATX1A", "BATX1B"]
        }
      ],
      "photo_url": "/img/users/prof/mmartinez.jpg",
      "years_of_service": 12,
      "status": "active"
    }
  ],
  "total_faculty": 25
}
```

**JSON Export Requirements:**
- Valid JSON syntax (validate before export)
- UTF-8 encoding
- Pretty-printed with indentation (human-readable)
- Proper escaping of special characters
- Metadata included (export date, center info, record count)

---

### 4. XML Exports

**Login Audit Log:**
- Complete audit trail of all login attempts
- Structured XML for security analysis and compliance
- **Triggered by:** "Export Login Log" in admin section
- **Reference:** `imatges/xml.png`

**XML Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LoginAuditLog>
  <ExportMetadata>
    <ExportDate>2026-01-22T14:30:00Z</ExportDate>
    <CenterCode>08001234</CenterCode>
    <CenterName>Institut Caparrella</CenterName>
    <DateRange>
      <StartDate>2025-09-01</StartDate>
      <EndDate>2026-01-22</EndDate>
    </DateRange>
  </ExportMetadata>

  <LoginAttempts>
    <Login>
      <LoginID>10542</LoginID>
      <Timestamp>2026-01-22T09:15:32Z</Timestamp>
      <Username>cap_estudis</Username>
      <UserDNI>12345678A</UserDNI>
      <UserRole>DepartmentHead</UserRole>
      <IPAddress>192.168.1.105</IPAddress>
      <Success>true</Success>
      <SessionDuration>02:15:43</SessionDuration>
    </Login>

    <Login>
      <LoginID>10543</LoginID>
      <Timestamp>2026-01-22T09:18:15Z</Timestamp>
      <Username>prof_invalid</Username>
      <UserDNI></UserDNI>
      <UserRole></UserRole>
      <IPAddress>192.168.1.107</IPAddress>
      <Success>false</Success>
      <FailureReason>Invalid username or password</FailureReason>
    </Login>

    <Login>
      <LoginID>10544</LoginID>
      <Timestamp>2026-01-22T10:05:21Z</Timestamp>
      <Username>prof_test</Username>
      <UserDNI>23456789B</UserDNI>
      <UserRole>Teacher</UserRole>
      <IPAddress>192.168.1.112</IPAddress>
      <Success>true</Success>
      <SessionDuration>01:45:12</SessionDuration>
    </Login>
  </LoginAttempts>

  <Statistics>
    <TotalAttempts>3</TotalAttempts>
    <SuccessfulLogins>2</SuccessfulLogins>
    <FailedLogins>1</FailedLogins>
    <UniqueUsers>2</UniqueUsers>
  </Statistics>
</LoginAuditLog>
```

**XML Export Requirements:**
- Valid XML syntax with proper declaration
- UTF-8 encoding for international characters
- Schema-compliant (optional: provide XSD schema)
- Human-readable formatting with indentation
- Comprehensive metadata section
- Summary statistics included

**Use Cases:**
- Security audits and compliance reporting
- Integration with SIEM (Security Information and Event Management) systems
- Analysis of login patterns and potential security issues
- Evidence for educational authorities or inspections

---

## UI/UX Screen Specifications

### Screen 1: Login Screen
**Purpose:** Secure authentication entry point
**Components:**
- Center logo and name
- Username text field
- Password field (masked)
- "Remember username" checkbox
- Login button
- Version number footer
- Reference: `imatges/login.png`

---

### Screen 2: Main Dashboard (Role-Specific)

**Department Head Dashboard:**
- Quick stats cards: Open periods, pending closures, recent modifications
- Shortcuts: Open period, Close period, View audit log, Generate reports
- Recent activity feed
- Calendar with evaluation deadlines

**Teacher Dashboard:**
- My subjects list with grade entry progress
- Upcoming evaluation deadlines
- Recent grade entries (my activity)
- Quick access to grade entry screens

---

### Screen 3: Faculty Portrait Gallery
**Purpose:** View and manage teacher photos
**Components:**
- Search bar (by name or department)
- Filter dropdown (department, status)
- Grid of teacher portraits (4-6 columns)
- Export buttons (PDF, Print)
- Reference: `imatges/people.png`

---

### Screen 4: Grade Entry Interface (Teachers)
**Purpose:** Enter and modify grades during open periods
**Components:**
- Group selector dropdown
- Evaluation period selector
- Student-subject grid (editable cells)
- Save draft button
- Submit grades button
- Status indicators (saved, pending, error)
- Reference: `imatges/profesor.png`

---

### Screen 5: Evaluation Session Management (Department Head)
**Purpose:** Open, close, and manage evaluation periods
**Components:**
- Group list with period states
- Open period button and dialog
- Close period button with validation
- In-session indicator banner
- Quick stats per group
- Reference: `imatges/jefe1.png`

---

### Screen 6: Student Bulletin Export
**Purpose:** Generate and export student grade reports
**Components:**
- Student selector (search by name or NIA)
- Evaluation period selector
- Preview panel (PDF preview)
- Export to PDF button
- Batch export for multiple students
- Reference: `imatges/pdf.png`

---

### Screen 7: Evaluation Record Export
**Purpose:** Generate official evaluation records (actes)
**Components:**
- Group selector
- Period selector
- Record preview (all students, all subjects)
- Export to PDF button
- Modification history link
- Reference: `imatges/pdf.png`

---

### Screen 8: Class Export (CSV)
**Purpose:** Export student rosters to CSV
**Components:**
- Group selector
- Field selector (choose which columns to export)
- Format options (delimiter, encoding)
- Preview table
- Export button
- Reference: `imatges/csv.png`

---

### Screen 9: Faculty List Export (JSON)
**Purpose:** Export teacher data in JSON format
**Components:**
- Faculty list table
- Filter options (department, status)
- JSON preview panel
- Format options (pretty-print, minified)
- Export button
- Reference: `imatges/json.png`

---

### Screen 10: Login Audit Log (XML)
**Purpose:** View and export login history
**Components:**
- Date range selector
- User filter (username, role)
- Success/failure filter
- Audit log table
- Export to XML button
- Statistics summary panel
- Reference: `imatges/xml.png`

---

### Screen 11: Center Configuration
**Purpose:** System settings and customization
**Components:**
- Center information form (name, logo, colors)
- Academic calendar configuration
- Grade scale settings
- Default weights for grade calculations
- Email notification settings
- Save configuration button
- Reference: `imatges/excel.png`

---

## Scoring Breakdown

### Desktop Backend Module Score
**Total Available:** 1.0 point (out of 10 points for entire project)

Unlike the mobile app which has individual feature scores, the desktop application is evaluated holistically across three complexity levels:

#### Basic Level Requirements (Minimum for Passing)
To achieve a passing score, the application must implement:
- ✅ User authentication with role-based access
- ✅ Evaluation period management (open/close by department head)
- ✅ Grade entry interface for teachers (only during open periods)
- ✅ Evaluation session simulation (restricted modification during meetings)
- ✅ Faculty portrait gallery generation from database

**Score Range:** 0.50 - 0.65 points

---

#### Intermediate Level Requirements (Good Quality)
To achieve a good score, additionally implement:
- ✅ All Basic Level features
- ✅ Closed evaluation record management with modification capability
- ✅ Complete audit trail with timestamps and reasons
- ✅ Modification history queryable in database
- ✅ Enhanced faculty portrait display with full information

**Score Range:** 0.65 - 0.85 points

---

#### Advanced Level Requirements (Excellent Quality)
To achieve top score, additionally implement:
- ✅ All Basic and Intermediate Level features
- ✅ Academic expedient generation with weighted grade calculations
- ✅ Official PDF document generation ("Expedient Acadèmic")
- ✅ File server archival system for long-term storage
- ✅ Database cleanup after expedient generation (with safety checks)
- ✅ Unit testing suite for business logic classes
- ✅ Integration testing for desktop module functionality

**Score Range:** 0.85 - 1.0 points

---

### Scoring Factors

#### Positive Impact on Score:
- Clean, maintainable Visual Basic code
- Proper error handling with user-friendly messages
- Professional UI following Material Design principles
- Robust database transaction management
- Comprehensive audit trail implementation
- All export formats working correctly (PDF, CSV, JSON, XML)
- Successful unit and integration tests (advanced level)
- Complete documentation and code comments
- Smooth demonstration during presentation

#### Negative Impact on Score:
- Application crashes or unhandled exceptions
- Data integrity issues (lost data, corrupted records)
- Security vulnerabilities (plain text passwords, SQL injection)
- Poor UI/UX (confusing navigation, unclear error messages)
- Missing or non-functional export features
- Incomplete audit trail or missing modifications
- Inadequate testing or failed test cases
- Lack of database transaction management

---

## Unique Desktop Functionalities

The following features are **exclusive to the desktop application** and not available in the mobile app:

### 1. Evaluation Period Control
- **Department head privilege:** Open and close evaluation periods
- **State management:** Control when teachers can enter grades
- **Validation enforcement:** Prevent closure with incomplete data

### 2. Local Faculty Portrait Generation
- **Complete gallery:** All teachers, not just student's teachers (mobile only shows relevant teachers)
- **Print functionality:** High-resolution export for yearbooks
- **Administrative use:** Center-wide documentation

### 3. Session-Based Evaluation Meetings
- **In-session state:** Special mode during evaluation meetings
- **Role-based modification:** Only tutor and department head can modify during sessions
- **Collaborative decision-making:** Facilitates team-based grading discussions

### 4. Audit-Tracked Record Modifications
- **Post-closure modifications:** Only desktop (department head) can modify closed evaluations
- **Mandatory justification:** Reason required for every post-closure change
- **Complete audit trail:** Every modification timestamped and logged

### 5. Multi-Format Data Export
- **PDF:** Official documents with signatures and institutional branding
- **CSV:** Data analysis and spreadsheet import
- **JSON:** API-ready structured data for integrations
- **XML:** Standards-compliant audit logs for compliance

### 6. Academic Expedient Automation
- **Weighted calculation:** Complex grade averaging based on subject hours
- **Official document generation:** Legal validity for educational records
- **File server archival:** Long-term storage with proper organization
- **Database cleanup:** Remove obsolete data after graduation

### 7. Login Audit Logging
- **Security monitoring:** Track all authentication attempts
- **Compliance reporting:** XML export for audits
- **Forensic analysis:** Investigate suspicious activity

### 8. Center Configuration Management
- **System-wide settings:** Configure institutional parameters
- **Branding control:** Logo, colors, official information
- **Academic calendar:** Set evaluation periods and deadlines

---

## Testing Requirements

### Demo Accounts

#### Department Head Account
- **Username:** `cap_estudis`
- **Password:** `Test1234`
- **Role:** Department Head
- **Permissions:** Full access to all features

#### Teacher Account (Primary Subject)
- **Username:** `prof_test`
- **Password:** `Test1234`
- **Role:** Teacher
- **Assigned:** DAM2, Programació (M3), 6 hours/week

#### Teacher Account (Secondary Subject)
- **Username:** `prof_math`
- **Password:** `Test1234`
- **Role:** Teacher
- **Assigned:** ESO2A, Matemàtiques, 4 hours/week

#### Group Tutor Account
- **Username:** `tutor_dam2`
- **Password:** `Test1234`
- **Role:** Group Tutor
- **Group:** DAM2

---

### Test Data Requirements

#### Database Population
- **Minimum 10 rows** in each table
- **Realistic data:** Real-looking names, dates, grades
- **Complete relationships:** All foreign keys properly defined
- **Test scenarios covered:**
  - Open evaluation periods
  - Closed evaluation periods
  - In-session evaluation periods
  - Grades with and without comments
  - Audit trail entries
  - Login log entries
  - Faculty with photos
  - Students across all educational levels

#### Specific Test Data:
- **3+ Open evaluation periods** (for grade entry testing)
- **5+ Closed evaluation periods** (for modification testing)
- **1+ In-session period** (for meeting simulation)
- **50+ Grade records** with various states (draft, finalized, modified)
- **10+ Audit trail entries** showing modifications
- **20+ Login log entries** (successful and failed)
- **10+ Teacher photos** (professional headshots)

---

### Testing Scenarios

#### 1. Authentication Testing
- **Valid login:** Department head → full dashboard access
- **Valid login:** Teacher → grade entry access only
- **Invalid credentials:** Error message displayed
- **Failed attempts logged:** Verify entry in login audit table
- **Session timeout:** Auto-logout after inactivity

#### 2. Evaluation Period Management Testing
- **Open period (Department Head):**
  - Select group DAM2, Trimester 1
  - Verify state changes to OPEN in database
  - Confirm teachers can now enter grades

- **Close period (Department Head):**
  - Attempt to close with incomplete grades → Validation error
  - Complete all grades → Close successfully
  - Verify teachers cannot modify grades anymore

- **Teacher attempts to open/close:**
  - Should be denied → Error message displayed

#### 3. Grade Entry Testing
- **Teacher login during OPEN period:**
  - Enter grades for assigned subjects
  - Save drafts → Verify saved to database
  - Submit grades → Change state to finalized

- **Teacher login during CLOSED period:**
  - Attempt to modify grade → Error message: "Period is closed"
  - Verify no changes saved to database

#### 4. Evaluation Session Testing
- **Start session (Department Head):**
  - Change state to IN_SESSION
  - Verify tutor can now modify grades

- **During session:**
  - Tutor modifies grade with reason
  - Verify audit trail entry created
  - Regular teacher cannot modify (error displayed)

- **End session:**
  - Finalize grades
  - State changes to CLOSED
  - Grades locked for teachers

#### 5. Audit Trail Testing
- **Post-closure modification (Department Head):**
  - Modify closed evaluation grade
  - Enter reason: "Student appeal approved"
  - Verify audit entry created with timestamp, user, reason
  - View modification history → Entry appears

- **Audit log query:**
  - Search by date range → Results displayed
  - Search by user → Results filtered
  - Export to XML → Valid XML generated

#### 6. Export Testing
- **PDF Generation:**
  - Generate bulletin for student → PDF created successfully
  - Verify content: All grades, comments, formatting correct
  - Generate evaluation record → PDF includes all students

- **CSV Export:**
  - Export class list → CSV file created
  - Open in Excel → Proper formatting, UTF-8 characters display correctly
  - Verify columns and data accuracy

- **JSON Export:**
  - Export faculty list → JSON file created
  - Validate JSON syntax → Valid structure
  - Verify all faculty included with correct data

- **XML Export:**
  - Export login audit log → XML file created
  - Validate XML syntax → Well-formed document
  - Verify all login entries included

#### 7. Academic Expedient Generation Testing
- **Preparation:**
  - Select graduated student with complete grades
  - Verify all subjects have final grades

- **Generation:**
  - Calculate weighted average → Verify correct calculation
  - Generate PDF expedient → Document created successfully
  - Archive to file server → File saved at correct path
  - Database cleanup → Grade records moved to history (not deleted)

- **Validation:**
  - Open PDF → All information correct, professional formatting
  - Verify student status updated to "Graduated"
  - Attempt to regenerate → Warning: Already exists

#### 8. Faculty Gallery Testing
- **Display gallery:**
  - All 10+ teachers displayed with photos
  - Photos load correctly (handle missing photos with placeholder)

- **Filters:**
  - Filter by department → Only relevant teachers shown
  - Sort alphabetically → Correct order

- **Export:**
  - Export to PDF → Professional yearbook layout
  - Print preview → Correct formatting for printing

---

### Performance Testing

#### Response Times
- **Login:** < 2 seconds
- **Load grade entry grid (25 students):** < 3 seconds
- **Save grade changes:** < 1 second
- **Generate PDF bulletin:** < 5 seconds
- **Generate academic expedient:** < 10 seconds
- **Export large dataset to CSV (500 records):** < 5 seconds

#### Stability
- **Continuous operation:** Application should run for 8+ hours without crashes
- **Concurrent users:** Support 10+ simultaneous users (database connection pooling)
- **Large datasets:** Handle 1000+ students, 10000+ grade records without performance degradation

---

### Evidence Collection

#### Screenshots Required
Capture screenshots for project documentation:
1. Login screen (`login.png`)
2. Department head dashboard showing period management (`jefe1.png`)
3. Teacher grade entry grid (`profesor.png`)
4. Faculty portrait gallery (`people.png`)
5. Bulletin PDF export preview (`pdf.png`)
6. Class list CSV export dialog (`csv.png`)
7. Faculty JSON export interface (`json.png`)
8. Login audit XML export screen (`xml.png`)
9. Center configuration screen (`excel.png`)
10. Audit trail viewer showing modifications
11. Academic expedient PDF preview
12. Evaluation session in-progress screen

#### Video Demonstration
- **Duration:** 5-8 minutes
- **Content:**
  - Login as department head
  - Open evaluation period
  - Login as teacher, enter grades
  - Return as department head, close period
  - Modify closed grade with audit trail
  - Generate and export documents (PDF, CSV, JSON, XML)
  - Show academic expedient generation
  - Display faculty gallery

#### Code Quality Evidence
- **Well-organized project structure:**
  - Separate modules for UI, business logic, data access
  - Consistent naming conventions
  - Proper use of classes and objects

- **Version control:**
  - Git repository with regular commits
  - Meaningful commit messages
  - Commit history showing progress over time

- **Testing documentation:**
  - Unit test results (if implemented)
  - Integration test scenarios and outcomes
  - Test coverage report

---

## Additional Requirements

### Security Considerations

#### Authentication Security
- **Password storage:** SHA-256 hashed (NEVER plain text or MD5)
- **Connection strings:** Encrypted or in secure configuration file
- **Session management:** Timeout after 30 minutes inactivity
- **Login attempts:** Track failed attempts, consider lockout after 5 failures

#### Data Security
- **SQL Injection prevention:** Use parameterized queries, NEVER string concatenation
- **Role-based access control:** Verify permissions before every sensitive operation
- **Audit trail integrity:** Append-only audit table, modifications logged
- **Document security:** Password-protect sensitive PDFs (optional)

#### Network Security
- **Database connection:** Secure connection string, consider TLS/SSL
- **File server access:** Proper permissions, prevent unauthorized access
- **Backup strategy:** Regular database backups, file server backups

---

### Code Quality Standards

#### Visual Basic Best Practices
- **Naming conventions:**
  - Classes: PascalCase (e.g., `GradeManager`, `DatabaseConnection`)
  - Methods: PascalCase (e.g., `CalculateWeightedAverage()`)
  - Variables: camelCase (e.g., `studentName`, `totalHours`)
  - Constants: UPPER_SNAKE_CASE (e.g., `MAX_GRADE`, `DEFAULT_TIMEOUT`)

- **Code organization:**
  - Separate concerns: UI code, business logic, data access
  - Use classes and objects (OOP principles)
  - Avoid code duplication (DRY principle)
  - Keep methods focused and concise

- **Error handling:**
  - Try-Catch blocks for all I/O operations
  - User-friendly error messages (not technical stack traces)
  - Log errors for debugging (file or database log)
  - Graceful degradation (don't crash the application)

- **Comments and documentation:**
  - XML documentation for public methods and classes
  - Inline comments for complex logic
  - TODO comments for future improvements
  - README.md with setup and usage instructions

#### Database Best Practices
- **Transactions:** Use for multi-step operations (rollback on error)
- **Parameterized queries:** Prevent SQL injection
- **Connection management:** Close connections properly (Using statement)
- **Indexes:** Proper indexing for performance
- **Foreign keys:** Enforce referential integrity

---

### Documentation Requirements

#### Project Documentation
1. **Technical Report (PDF):**
   - Project overview and objectives
   - System architecture diagram
   - Database schema with E-R diagram
   - Feature list with implementation details
   - Testing results and evidence
   - Known issues and limitations
   - Installation and setup guide
   - User manual

2. **UML Diagrams:**
   - **Class Diagram:** Show all classes, properties, methods, relationships
   - **Sequence Diagrams:** For key workflows:
     - User login and authentication
     - Grade entry process
     - Evaluation period open/close lifecycle
     - Post-closure grade modification with audit
     - Academic expedient generation

3. **Database Documentation:**
   - E-R diagram with all entities and relationships
   - Table schemas with field descriptions
   - SQL scripts for table creation
   - SQL scripts for test data insertion
   - Explanation of design decisions

4. **Code Documentation:**
   - Inline comments explaining complex logic
   - XML doc comments for public APIs
   - README files in each module/folder
   - Dependency list and version information

---

### Version Control Requirements

#### Git Repository
- **Regular commits:** Minimum 30-40 commits showing progress over time
- **Commit messages:** Clear, descriptive (e.g., "feat: Add audit trail viewer" not "changes")
- **Branch strategy:** (Optional) Feature branches for major features
- **`.gitignore`:** Exclude binary files, build artifacts, connection strings with passwords

#### Commit Guidelines
- **Atomic commits:** One logical change per commit
- **Meaningful history:** Show development progression
- **Tag releases:** Tag major milestones (v1.0, v2.0)

---

## Project Submission

### Deliverables

1. **Source Code:**
   - Complete Visual Basic project (`.vbproj` or `.sln` solution)
   - All source files organized in logical folders
   - Configuration files (without sensitive passwords)
   - Third-party libraries (or dependency list)

2. **Database:**
   - SQL scripts for schema creation
   - SQL scripts for test data insertion
   - Database export (.sql dump file)
   - E-R diagram (PDF or image)

3. **Documentation:**
   - Technical report (PDF, 20-40 pages)
   - User manual (PDF, 10-20 pages)
   - UML diagrams (PDF or embedded in report)
   - Installation guide
   - API documentation (if applicable)

4. **Testing:**
   - Demo account credentials list
   - Test scenarios document
   - Test results (unit test reports, integration test outcomes)
   - Known bugs and workarounds

5. **Media:**
   - Screenshots of all required screens
   - Video demonstration (5-8 minutes)
   - Promotional materials (optional)

---

### Presentation Requirements

#### Live Demonstration (10-15 minutes)
1. **Introduction (2 minutes):**
   - Project overview and objectives
   - Technology stack and architecture

2. **Core Features Demo (8-10 minutes):**
   - Login as department head
   - Open evaluation period
   - Switch to teacher account, enter grades
   - Return to department head, close period
   - Demonstrate post-closure modification with audit trail
   - Show faculty portrait gallery
   - Export data in all formats (PDF, CSV, JSON, XML)
   - Generate academic expedient (if time permits)

3. **Technical Discussion (2-3 minutes):**
   - Explain architecture and design decisions
   - Discuss challenges encountered and solutions
   - Mention future improvements

4. **Q&A (5 minutes):**
   - Answer questions from instructors/peers

#### Questions to Prepare For
- Why Visual Basic instead of a modern language?
- How is data consistency ensured between mobile and desktop apps?
- Explain your audit trail implementation
- How do you prevent SQL injection attacks?
- What happens if multiple users modify the same grade simultaneously?
- How does the weighted grade calculation work?
- What testing approach did you use?
- What would you do differently with more time?

---

## Success Criteria

### Minimum Viable Product (MVP)
To pass this module (0.50+ / 1.0 points), the application must:
- ✅ Authenticate users with role-based access (SHA hashing)
- ✅ Allow department head to open/close evaluation periods
- ✅ Enable teacher grade entry only during open periods
- ✅ Prevent teacher modifications after period closure
- ✅ Display faculty portrait gallery from database
- ✅ Generate at least one export format (PDF bulletins)
- ✅ Connect to external SQL database (shared with mobile app)
- ✅ Have professional UI with Material Design influences
- ✅ Show consistent Git commit history
- ✅ Include 10+ test records in each database table

---

### Good Implementation (Intermediate Level)
For a good score (0.65-0.85 / 1.0 points), additionally include:
- ✅ All MVP features fully functional
- ✅ Complete audit trail with timestamp and reason logging
- ✅ Post-closure grade modification capability (department head only)
- ✅ Modification history viewer and query interface
- ✅ All 4 export formats working (PDF, CSV, JSON, XML)
- ✅ Enhanced faculty gallery with detailed profiles
- ✅ Robust error handling with user-friendly messages
- ✅ Professional documentation and user manual

---

### Excellent Implementation (Advanced Level)
For top score (0.85-1.0 / 1.0 points), additionally include:
- ✅ All MVP and Intermediate features fully functional
- ✅ Academic expedient generation with weighted calculations
- ✅ File server archival system with proper organization
- ✅ Database cleanup after expedient generation (with safety)
- ✅ Unit testing suite with good code coverage
- ✅ Integration testing for critical workflows
- ✅ Exceptional code quality and organization
- ✅ Comprehensive documentation with UML diagrams
- ✅ Polished presentation demonstrating all features

---

## Development Timeline Recommendations

### Phase 1: Foundation (Weeks 1-3)
- Set up Visual Basic project structure
- Implement database connection module
- Create authentication system with login screen
- Set up role-based access control framework
- Design main UI layout and navigation

### Phase 2: Basic Level Features (Weeks 4-7)
- Evaluation period management (open/close)
- Grade entry interface for teachers
- Evaluation session simulation (in-session mode)
- Faculty portrait gallery generation
- Basic PDF export (bulletins)

### Phase 3: Intermediate Level Features (Weeks 8-10)
- Audit trail system (database table and logging logic)
- Post-closure modification capability
- Modification history viewer
- Additional export formats (CSV, JSON, XML)
- Enhanced error handling

### Phase 4: Advanced Level Features (Weeks 11-13)
- Academic expedient generation with weighted calculations
- File server archival system
- Database cleanup mechanism
- Unit testing suite
- Integration testing

### Phase 5: Polish & Testing (Weeks 14-15)
- UI/UX refinement
- Comprehensive testing with demo accounts
- Bug fixing and optimization
- Documentation writing
- Presentation preparation

---

## Resources & References

### Official Documentation
- [Visual Basic .NET Documentation](https://docs.microsoft.com/en-us/dotnet/visual-basic/)
- [ADO.NET Documentation](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/)
- [MySQL Connector/NET](https://dev.mysql.com/doc/connector-net/en/)

### Recommended Libraries
- **PDF Generation:** iTextSharp, PDFSharp
- **Excel/CSV:** EPPlus, ClosedXML
- **JSON:** Newtonsoft.Json
- **Testing:** NUnit, MSTest

### Learning Resources
- Visual Basic OOP principles and best practices
- SQL transaction management and optimization
- Material Design guidelines adapted for desktop
- Unit testing fundamentals

---

## Contact & Support

For questions about this project specification:
- Review original project documents in `docs/split_output/markdown_output/`
- Consult with project instructors
- Refer to course Moodle for updates and clarifications

---

**Document Version:** 1.0
**Last Updated:** 2026-01-22
**Project:** EVALIS - Plataforma Educativa Integral
**Module:** Desktop Application - Visual Basic (DAM2)
**Institution:** Institut Caparrella
**Academic Year:** 2025-2026
