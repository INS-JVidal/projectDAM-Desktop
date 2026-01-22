-- ============================================
-- EVALIS Desktop - Phase 2 Performance Indexes
-- ============================================

-- ============================================
-- STUDENTS TABLE INDEXES
-- ============================================
CREATE INDEX idx_students_nia ON students(nia);
CREATE INDEX idx_students_cycle ON students(cycle);
CREATE INDEX idx_students_group_name ON students(group_name);
CREATE INDEX idx_students_status ON students(status) WHERE status = 'Active';
CREATE INDEX idx_students_cycle_group ON students(cycle, group_name);

-- ============================================
-- SUBJECTS TABLE INDEXES
-- ============================================
CREATE INDEX idx_subjects_code ON subjects(code);
CREATE INDEX idx_subjects_cycle ON subjects(cycle);
CREATE INDEX idx_subjects_active ON subjects(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_subjects_cycle_active ON subjects(cycle, is_active);

-- ============================================
-- EVALUATION_SESSIONS TABLE INDEXES
-- ============================================
CREATE INDEX idx_eval_sessions_academic_year ON evaluation_sessions(academic_year);
CREATE INDEX idx_eval_sessions_period ON evaluation_sessions(period);
CREATE INDEX idx_eval_sessions_state ON evaluation_sessions(state);
CREATE INDEX idx_eval_sessions_academic_period_state ON evaluation_sessions(academic_year, period, state);
CREATE INDEX idx_eval_sessions_opened_by ON evaluation_sessions(opened_by);
CREATE INDEX idx_eval_sessions_closed_by ON evaluation_sessions(closed_by) WHERE closed_by IS NOT NULL;

-- ============================================
-- GRADES TABLE INDEXES
-- ============================================
CREATE INDEX idx_grades_student_id ON grades(student_id);
CREATE INDEX idx_grades_subject_id ON grades(subject_id);
CREATE INDEX idx_grades_session_id ON grades(session_id);
CREATE INDEX idx_grades_entered_by ON grades(entered_by);
CREATE INDEX idx_grades_is_draft ON grades(is_draft) WHERE is_draft = TRUE;
CREATE INDEX idx_grades_student_session ON grades(student_id, session_id);
CREATE INDEX idx_grades_subject_session ON grades(subject_id, session_id);
CREATE INDEX idx_grades_student_subject_session ON grades(student_id, subject_id, session_id);
CREATE INDEX idx_grades_modified_at ON grades(modified_at DESC);

-- ============================================
-- GRADE_AUDIT TABLE INDEXES
-- ============================================
CREATE INDEX idx_grade_audit_grade_id ON grade_audit(grade_id);
CREATE INDEX idx_grade_audit_modified_by ON grade_audit(modified_by);
CREATE INDEX idx_grade_audit_modified_at ON grade_audit(modified_at DESC);
CREATE INDEX idx_grade_audit_session_state ON grade_audit(session_state);
CREATE INDEX idx_grade_audit_grade_modified_at ON grade_audit(grade_id, modified_at DESC);

-- ============================================
-- TEACHER_SUBJECTS TABLE INDEXES
-- ============================================
CREATE INDEX idx_teacher_subjects_teacher_id ON teacher_subjects(teacher_id);
CREATE INDEX idx_teacher_subjects_subject_id ON teacher_subjects(subject_id);
CREATE INDEX idx_teacher_subjects_academic_year ON teacher_subjects(academic_year);
CREATE INDEX idx_teacher_subjects_group_name ON teacher_subjects(group_name);
CREATE INDEX idx_teacher_subjects_teacher_academic_year ON teacher_subjects(teacher_id, academic_year);
CREATE INDEX idx_teacher_subjects_subject_academic_year ON teacher_subjects(subject_id, academic_year);
CREATE INDEX idx_teacher_subjects_teacher_subject_year ON teacher_subjects(teacher_id, subject_id, academic_year);
