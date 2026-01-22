-- ============================================
-- EVALIS Desktop - Phase 2: Academic Core Tables
-- PostgreSQL 14+
-- ============================================
-- Creates: students, subjects, evaluation_sessions, grades, grade_audit, teacher_subjects

-- ============================================
-- STUDENTS TABLE
-- ============================================
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    nia VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    cycle VARCHAR(10) NOT NULL CHECK (cycle IN ('DAM', 'DAW', 'ASIX', 'SMX')),
    group_name VARCHAR(10) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Graduated', 'Withdrawn')),
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE students IS 'Student enrollment and academic information';
COMMENT ON COLUMN students.nia IS 'Student identification number (unique)';
COMMENT ON COLUMN students.cycle IS 'Academic cycle: DAM (Development), DAW (Web), ASIX (Systems), SMX (Microcomputers)';
COMMENT ON COLUMN students.status IS 'Active, Graduated, or Withdrawn';

-- ============================================
-- SUBJECTS TABLE
-- ============================================
CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    cycle VARCHAR(10) NOT NULL CHECK (cycle IN ('DAM', 'DAW', 'ASIX', 'SMX')),
    hours_per_week SMALLINT NOT NULL CHECK (hours_per_week > 0),
    credits DECIMAL(4,2) NOT NULL CHECK (credits > 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE subjects IS 'Course/module definitions across academic cycles';
COMMENT ON COLUMN subjects.code IS 'Subject code (e.g., MP06, M06)';
COMMENT ON COLUMN subjects.hours_per_week IS 'Weekly instructional hours';
COMMENT ON COLUMN subjects.credits IS 'ECTS credits';

-- ============================================
-- EVALUATION_SESSIONS TABLE
-- ============================================
CREATE TABLE evaluation_sessions (
    session_id SERIAL PRIMARY KEY,
    academic_year VARCHAR(9) NOT NULL CHECK (academic_year ~ '^\d{4}-\d{4}$'),
    period VARCHAR(20) NOT NULL CHECK (period IN ('1st', '2nd', '3rd', 'Final')),
    state VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (state IN ('OPEN', 'IN_SESSION', 'CLOSED')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    opened_by INTEGER NOT NULL REFERENCES users(user_id),
    closed_by INTEGER REFERENCES users(user_id),
    closed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_dates CHECK (start_date < end_date),
    CONSTRAINT unique_eval_session UNIQUE (academic_year, period)
);

COMMENT ON TABLE evaluation_sessions IS 'Evaluation period lifecycle management (OPEN → IN_SESSION → CLOSED)';
COMMENT ON COLUMN evaluation_sessions.academic_year IS 'Academic year format: 2024-2025';
COMMENT ON COLUMN evaluation_sessions.period IS '1st, 2nd, 3rd, or Final evaluation';
COMMENT ON COLUMN evaluation_sessions.state IS 'OPEN (teachers can enter), IN_SESSION (evaluation meeting), CLOSED (locked)';

-- ============================================
-- GRADES TABLE
-- ============================================
CREATE TABLE grades (
    grade_id BIGSERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(student_id),
    subject_id INTEGER NOT NULL REFERENCES subjects(subject_id),
    session_id INTEGER NOT NULL REFERENCES evaluation_sessions(session_id),
    grade_value DECIMAL(4,2) CHECK (grade_value >= 0 AND grade_value <= 10),
    is_draft BOOLEAN DEFAULT TRUE,
    entered_by INTEGER NOT NULL REFERENCES users(user_id),
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_grade UNIQUE (student_id, subject_id, session_id)
);

COMMENT ON TABLE grades IS 'Student grades for subjects in evaluation periods';
COMMENT ON COLUMN grades.grade_value IS 'Numeric grade from 0.0 to 10.0';
COMMENT ON COLUMN grades.is_draft IS 'TRUE while being edited, FALSE when finalized';
COMMENT ON COLUMN grades.entered_by IS 'User ID of the teacher who entered the grade';

-- ============================================
-- GRADE_AUDIT TABLE
-- ============================================
CREATE TABLE grade_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    grade_id BIGINT NOT NULL REFERENCES grades(grade_id),
    old_value DECIMAL(4,2),
    new_value DECIMAL(4,2) NOT NULL,
    modified_by INTEGER NOT NULL REFERENCES users(user_id),
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (length(reason) >= 20),
    session_state VARCHAR(20) NOT NULL CHECK (session_state IN ('OPEN', 'IN_SESSION', 'CLOSED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE grade_audit IS 'Audit trail for all grade modifications (append-only)';
COMMENT ON COLUMN grade_audit.reason IS 'Mandatory reason for change (minimum 20 characters)';
COMMENT ON COLUMN grade_audit.session_state IS 'Evaluation session state when modification occurred';
COMMENT ON COLUMN grade_audit.modified_by IS 'Must be DepartmentHead role';

-- ============================================
-- TEACHER_SUBJECTS TABLE
-- ============================================
CREATE TABLE teacher_subjects (
    assignment_id SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL REFERENCES users(user_id),
    subject_id INTEGER NOT NULL REFERENCES subjects(subject_id),
    academic_year VARCHAR(9) NOT NULL CHECK (academic_year ~ '^\d{4}-\d{4}$'),
    group_name VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_teacher_role CHECK (
        -- Verify teacher has Teacher role (cannot enforce cross-table constraint, app-level check required)
        teacher_id IS NOT NULL
    ),
    CONSTRAINT unique_assignment UNIQUE (teacher_id, subject_id, academic_year, group_name)
);

COMMENT ON TABLE teacher_subjects IS 'Assignment of teachers to subjects by academic year and group';
COMMENT ON COLUMN teacher_subjects.teacher_id IS 'Must reference a user with role=Teacher';
COMMENT ON COLUMN teacher_subjects.group_name IS 'Class group (e.g., DAM2A, DAW1B)';

-- ============================================
-- AUTO-UPDATE TRIGGERS FOR PHASE 2 TABLES
-- ============================================
CREATE TRIGGER update_students_updated_at
    BEFORE UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subjects_updated_at
    BEFORE UPDATE ON subjects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_sessions_updated_at
    BEFORE UPDATE ON evaluation_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grades_updated_at
    BEFORE UPDATE ON grades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teacher_subjects_updated_at
    BEFORE UPDATE ON teacher_subjects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
