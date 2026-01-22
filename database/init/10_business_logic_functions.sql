-- ============================================
-- EVALIS Desktop - Business Logic Functions
-- ============================================

-- ============================================
-- GRADE VALIDATION FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION validate_grade_value(grade_value DECIMAL)
RETURNS BOOLEAN AS $$
BEGIN
    -- Grade must be between 0.0 and 10.0 (inclusive) or NULL
    RETURN grade_value IS NULL OR (grade_value >= 0 AND grade_value <= 10);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_grade_value(DECIMAL) IS 'Validates grade is between 0.0-10.0 or NULL';

-- ============================================
-- CALCULATE WEIGHTED AVERAGE FOR STUDENT IN SESSION
-- ============================================
CREATE OR REPLACE FUNCTION calculate_weighted_average(
    p_student_id INTEGER,
    p_session_id INTEGER
)
RETURNS DECIMAL AS $$
DECLARE
    v_weighted_sum DECIMAL(10,2);
    v_total_hours INTEGER;
    v_weighted_avg DECIMAL(4,2);
BEGIN
    -- Calculate: Σ(Grade × Hours) / Σ(Hours)
    SELECT
        COALESCE(SUM(g.grade_value * s.hours_per_week), 0),
        COALESCE(SUM(s.hours_per_week), 0)
    INTO v_weighted_sum, v_total_hours
    FROM grades g
    JOIN subjects s ON g.subject_id = s.subject_id
    WHERE g.student_id = p_student_id
      AND g.session_id = p_session_id
      AND g.grade_value IS NOT NULL
      AND g.is_draft = FALSE;

    -- Avoid division by zero
    IF v_total_hours = 0 THEN
        RETURN NULL;
    END IF;

    v_weighted_avg := v_weighted_sum / v_total_hours;

    -- Return value rounded to 2 decimals
    RETURN ROUND(v_weighted_avg, 2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_weighted_average(INTEGER, INTEGER) IS
'Calculates weighted grade average for student in evaluation session: Σ(Grade × Hours) / Σ(Hours)';

-- ============================================
-- CHECK EVALUATION SESSION STATE
-- ============================================
CREATE OR REPLACE FUNCTION get_session_state(p_session_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    v_state VARCHAR(20);
BEGIN
    SELECT state INTO v_state
    FROM evaluation_sessions
    WHERE session_id = p_session_id;

    RETURN COALESCE(v_state, 'UNKNOWN');
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_session_state(INTEGER) IS 'Returns current state of evaluation session (OPEN, IN_SESSION, CLOSED)';

-- ============================================
-- VERIFY ALL GRADES COMPLETE FOR STUDENT
-- ============================================
CREATE OR REPLACE FUNCTION all_grades_complete_for_student(
    p_student_id INTEGER,
    p_session_id INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_total_subjects INTEGER;
    v_graded_subjects INTEGER;
BEGIN
    -- Count subjects for student's cycle in the session
    SELECT COUNT(DISTINCT g.subject_id)
    INTO v_total_subjects
    FROM grades g
    JOIN subjects s ON g.subject_id = s.subject_id
    JOIN students st ON g.student_id = st.student_id
    WHERE g.student_id = p_student_id
      AND g.session_id = p_session_id
      AND s.cycle = st.cycle;

    -- Count grades with values (non-NULL, non-draft)
    SELECT COUNT(DISTINCT g.subject_id)
    INTO v_graded_subjects
    FROM grades g
    WHERE g.student_id = p_student_id
      AND g.session_id = p_session_id
      AND g.grade_value IS NOT NULL
      AND g.is_draft = FALSE;

    -- Return true if all subjects have grades
    RETURN v_total_subjects > 0 AND v_total_subjects = v_graded_subjects;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION all_grades_complete_for_student(INTEGER, INTEGER) IS
'Verifies student has all grades entered and finalized for evaluation session';

-- ============================================
-- CREATE AUDIT ENTRY FOR GRADE MODIFICATION
-- ============================================
CREATE OR REPLACE FUNCTION create_grade_audit_entry(
    p_grade_id BIGINT,
    p_old_value DECIMAL,
    p_new_value DECIMAL,
    p_modified_by INTEGER,
    p_reason TEXT
)
RETURNS BIGINT AS $$
DECLARE
    v_audit_id BIGINT;
    v_session_state VARCHAR(20);
    v_reason_length INTEGER;
BEGIN
    -- Validate reason length
    v_reason_length := length(TRIM(p_reason));
    IF v_reason_length < 20 THEN
        RAISE EXCEPTION 'Reason must be at least 20 characters (current: %)', v_reason_length;
    END IF;

    -- Get current session state for this grade
    SELECT es.state INTO v_session_state
    FROM grades g
    JOIN evaluation_sessions es ON g.session_id = es.session_id
    WHERE g.grade_id = p_grade_id;

    -- Insert audit entry
    INSERT INTO grade_audit (grade_id, old_value, new_value, modified_by, reason, session_state)
    VALUES (p_grade_id, p_old_value, p_new_value, p_modified_by, TRIM(p_reason), v_session_state)
    RETURNING audit_id INTO v_audit_id;

    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_grade_audit_entry(BIGINT, DECIMAL, DECIMAL, INTEGER, TEXT) IS
'Creates audit trail entry when grade is modified after session closure';

-- ============================================
-- GET SUBJECT HOURS FOR WEIGHTED CALCULATION
-- ============================================
CREATE OR REPLACE FUNCTION get_subject_hours(p_subject_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_hours INTEGER;
BEGIN
    SELECT hours_per_week INTO v_hours
    FROM subjects
    WHERE subject_id = p_subject_id;

    RETURN COALESCE(v_hours, 0);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_subject_hours(INTEGER) IS 'Returns weekly hours for a subject';

-- ============================================
-- CHECK IF EVALUATION SESSION CAN BE CLOSED
-- ============================================
CREATE OR REPLACE FUNCTION can_close_evaluation_session(p_session_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_session_state VARCHAR(20);
    v_total_students INTEGER;
    v_complete_students INTEGER;
BEGIN
    -- Get session state
    SELECT state INTO v_session_state
    FROM evaluation_sessions
    WHERE session_id = p_session_id;

    -- Can only close if currently IN_SESSION or OPEN
    IF v_session_state NOT IN ('OPEN', 'IN_SESSION') THEN
        RETURN FALSE;
    END IF;

    -- Count total students and those with complete grades
    SELECT COUNT(DISTINCT g.student_id)
    INTO v_total_students
    FROM grades g
    WHERE g.session_id = p_session_id;

    SELECT COUNT(DISTINCT g.student_id)
    INTO v_complete_students
    FROM grades g
    WHERE g.session_id = p_session_id
      AND g.grade_value IS NOT NULL
      AND g.is_draft = FALSE;

    -- Return true if all students have at least one grade
    RETURN v_total_students > 0 AND v_total_students = v_complete_students;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION can_close_evaluation_session(INTEGER) IS
'Checks if evaluation session can be closed (all students have complete grades)';

-- ============================================
-- TRANSITION EVALUATION SESSION STATE
-- ============================================
CREATE OR REPLACE FUNCTION transition_session_state(
    p_session_id INTEGER,
    p_new_state VARCHAR,
    p_user_id INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_state VARCHAR(20);
BEGIN
    -- Get current state
    SELECT state INTO v_current_state
    FROM evaluation_sessions
    WHERE session_id = p_session_id;

    -- Validate transition
    IF v_current_state IS NULL THEN
        RAISE EXCEPTION 'Session not found';
    END IF;

    -- State machine: OPEN → IN_SESSION → CLOSED
    IF v_current_state = 'OPEN' AND p_new_state != 'IN_SESSION' THEN
        RAISE EXCEPTION 'From OPEN state, can only transition to IN_SESSION';
    ELSIF v_current_state = 'IN_SESSION' AND p_new_state NOT IN ('OPEN', 'CLOSED') THEN
        RAISE EXCEPTION 'From IN_SESSION state, can only transition to OPEN or CLOSED';
    ELSIF v_current_state = 'CLOSED' THEN
        RAISE EXCEPTION 'Cannot transition from CLOSED state';
    END IF;

    -- Update state
    UPDATE evaluation_sessions
    SET state = p_new_state,
        closed_by = CASE WHEN p_new_state = 'CLOSED' THEN p_user_id ELSE closed_by END,
        closed_at = CASE WHEN p_new_state = 'CLOSED' THEN CURRENT_TIMESTAMP ELSE closed_at END
    WHERE session_id = p_session_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION transition_session_state(INTEGER, VARCHAR, INTEGER) IS
'Transitions evaluation session through state machine: OPEN → IN_SESSION → CLOSED';

-- ============================================
-- CHECK IF TEACHER CAN MODIFY GRADE
-- ============================================
CREATE OR REPLACE FUNCTION can_teacher_modify_grade(
    p_user_id INTEGER,
    p_grade_id BIGINT,
    p_session_id INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_role VARCHAR(20);
    v_session_state VARCHAR(20);
    v_teacher_assignment_count INTEGER;
BEGIN
    -- Get user role
    SELECT role INTO v_user_role
    FROM users
    WHERE user_id = p_user_id;

    -- Get session state
    SELECT state INTO v_session_state
    FROM evaluation_sessions
    WHERE session_id = p_session_id;

    -- Department head can always modify
    IF v_user_role = 'DepartmentHead' THEN
        RETURN TRUE;
    END IF;

    -- Teacher can only modify in OPEN state
    IF v_user_role = 'Teacher' THEN
        IF v_session_state != 'OPEN' THEN
            RETURN FALSE;
        END IF;

        -- Verify teacher has assignment for this grade's subject
        SELECT COUNT(*)
        INTO v_teacher_assignment_count
        FROM teacher_subjects ts
        JOIN grades g ON g.subject_id = ts.subject_id
        WHERE ts.teacher_id = p_user_id
          AND g.grade_id = p_grade_id;

        RETURN v_teacher_assignment_count > 0;
    END IF;

    -- GroupTutor can modify in IN_SESSION state
    IF v_user_role = 'GroupTutor' THEN
        RETURN v_session_state = 'IN_SESSION';
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION can_teacher_modify_grade(INTEGER, BIGINT, INTEGER) IS
'Checks if teacher has permission to modify grade based on role and session state';
