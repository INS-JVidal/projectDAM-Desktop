-- ============================================
-- EVALIS Desktop - Phase 2 Seed Data
-- ============================================
-- Comprehensive test data for Phase 2 (Academic Core)

-- ============================================
-- STUDENTS DATA
-- ============================================
INSERT INTO students (nia, full_name, cycle, group_name, status, enrollment_date) VALUES
-- DAM2A (Development Cycle, Group A)
('DAM2A001', 'Albert Rodriguez i Garcia', 'DAM', 'DAM2A', 'Active', '2023-09-15'),
('DAM2A002', 'Berta Sanchez i Lopez', 'DAM', 'DAM2A', 'Active', '2023-09-15'),
('DAM2A003', 'Carlos Fernandez i Martinez', 'DAM', 'DAM2A', 'Active', '2023-09-15'),
('DAM2A004', 'Diana Puig i Font', 'DAM', 'DAM2A', 'Graduated', '2023-09-15'),
('DAM2A005', 'Enric Vila i Soler', 'DAM', 'DAM2A', 'Active', '2023-09-15'),
('DAM2A006', 'Francesca Vidal i Pujol', 'DAM', 'DAM2A', 'Withdrawn', '2023-09-15'),

-- DAM2B (Development Cycle, Group B)
('DAM2B001', 'Gemma Bosch i Martí', 'DAM', 'DAM2B', 'Active', '2023-09-15'),
('DAM2B002', 'Hilari Comsa i Ruiz', 'DAM', 'DAM2B', 'Active', '2023-09-15'),
('DAM2B003', 'Ignasi Domenech i Sala', 'DAM', 'DAM2B', 'Active', '2023-09-15'),

-- DAW1A (Web Development Cycle, Group A)
('DAW1A001', 'Joana Ribera i Carrasco', 'DAW', 'DAW1A', 'Active', '2023-09-15'),
('DAW1A002', 'Kilian Gimenez i Baez', 'DAW', 'DAW1A', 'Active', '2023-09-15'),
('DAW1A003', 'Lucia Saez i Diaz', 'DAW', 'DAW1A', 'Active', '2023-09-15'),

-- ASIX1A (Systems Administration Cycle, Group A)
('ASIX1A001', 'Miquel Ferrer i Brunet', 'ASIX', 'ASIX1A', 'Active', '2023-09-15'),
('ASIX1A002', 'Nathalia Gonzalez i Rojas', 'ASIX', 'ASIX1A', 'Active', '2023-09-15'),
('ASIX1A003', 'Oriol Navarro i Cruz', 'ASIX', 'ASIX1A', 'Active', '2023-09-15');

-- ============================================
-- SUBJECTS DATA
-- ============================================
INSERT INTO subjects (code, name, cycle, hours_per_week, credits, is_active) VALUES
-- DAM (Desarrollo de Aplicaciones Multiplataforma)
('MP06', 'Bases de Dades', 'DAM', 5, 9.00, TRUE),
('MP07', 'Acceso a Datos', 'DAM', 6, 12.00, TRUE),
('MP08', 'Desenvolvimento Interface', 'DAM', 5, 10.00, TRUE),
('MP09', 'Programacio Multimedia', 'DAM', 4, 8.00, TRUE),
('MP10', 'Desarrollo en Entorno Servidor', 'DAM', 6, 12.00, TRUE),
('MP11', 'Projecte Empresarial', 'DAM', 3, 6.00, TRUE),

-- DAW (Desarrollo de Aplicaciones Web)
('MP06W', 'Bases de Dades Web', 'DAW', 5, 9.00, TRUE),
('MP12', 'Desarrollo Web en Entorno Servidor', 'DAW', 6, 12.00, TRUE),
('MP13', 'Desarrollo Web en Entorno Cliente', 'DAW', 5, 10.00, TRUE),
('MP14', 'Projectes de Desenvolupament Web', 'DAW', 4, 8.00, TRUE),

-- ASIX (Administracion de Sistemas Informaticos)
('MP15', 'Implantacion de Sistemas Operativos', 'ASIX', 5, 9.00, TRUE),
('MP16', 'Xarxes Locals', 'ASIX', 6, 12.00, TRUE),
('MP17', 'Aplicacions Web', 'ASIX', 4, 8.00, TRUE),
('MP18', 'Seguretat i Alta Disponibilitat', 'ASIX', 5, 10.00, TRUE);

-- ============================================
-- EVALUATION SESSIONS
-- ============================================
INSERT INTO evaluation_sessions (academic_year, period, state, start_date, end_date, opened_by) VALUES
('2024-2025', '1st', 'CLOSED', '2024-09-16', '2024-12-20', 1),
('2024-2025', '2nd', 'IN_SESSION', '2025-01-13', '2025-04-18', 1),
('2024-2025', '3rd', 'OPEN', '2025-05-12', '2025-06-20', 1),
('2024-2025', 'Final', 'OPEN', '2025-06-23', '2025-07-18', 1);

-- ============================================
-- TEACHER SUBJECT ASSIGNMENTS
-- ============================================
INSERT INTO teacher_subjects (teacher_id, subject_id, academic_year, group_name) VALUES
-- Prof Test (User ID 2) - Teacher - Programming & Databases
(2, 1, '2024-2025', 'DAM2A'),  -- MP06 (Bases de Dades) for DAM2A
(2, 1, '2024-2025', 'DAM2B'),  -- MP06 for DAM2B
(2, 6, '2024-2025', 'DAW1A'),  -- MP06W for DAW1A

-- Prof Prog (User ID 4) - Teacher - Programming
(4, 2, '2024-2025', 'DAM2A'),  -- MP07 for DAM2A
(4, 3, '2024-2025', 'DAM2A'),  -- MP08 for DAM2A
(4, 3, '2024-2025', 'DAM2B'),  -- MP08 for DAM2B

-- Prof BBDD (User ID 5) - Teacher - Databases & Systems
(5, 2, '2024-2025', 'DAM2B'),  -- MP07 for DAM2B
(5, 10, '2024-2025', 'DAW1A'),  -- MP13 for DAW1A
(5, 13, '2024-2025', 'ASIX1A'); -- MP17 for ASIX1A

-- ============================================
-- GRADES FOR 1ST EVALUATION PERIOD (CLOSED)
-- ============================================
INSERT INTO grades (student_id, subject_id, session_id, grade_value, is_draft, entered_by, entered_at) VALUES
-- DAM2A Student 1 (Albert)
(1, 1, 1, 8.5, FALSE, 2, '2024-12-10'),  -- MP06
(1, 2, 1, 7.0, FALSE, 4, '2024-12-10'),  -- MP07
(1, 3, 1, 9.0, FALSE, 4, '2024-12-10'),  -- MP08

-- DAM2A Student 2 (Berta)
(2, 1, 1, 6.5, FALSE, 2, '2024-12-10'),  -- MP06
(2, 2, 1, 8.0, FALSE, 4, '2024-12-10'),  -- MP07
(2, 3, 1, 7.5, FALSE, 4, '2024-12-10'),  -- MP08

-- DAM2A Student 3 (Carlos)
(3, 1, 1, 9.0, FALSE, 2, '2024-12-10'),  -- MP06
(3, 2, 1, 8.5, FALSE, 4, '2024-12-10'),  -- MP07
(3, 3, 1, 8.0, FALSE, 4, '2024-12-10'),  -- MP08

-- DAM2B Student 1 (Gemma)
(7, 1, 1, 7.5, FALSE, 2, '2024-12-10'),  -- MP06
(7, 2, 1, 6.0, FALSE, 5, '2024-12-10'),  -- MP07
(7, 3, 1, 8.5, FALSE, 4, '2024-12-10'),  -- MP08

-- DAW1A Student 1 (Joana)
(10, 6, 1, 8.0, FALSE, 2, '2024-12-10'),  -- MP06W
(10, 10, 1, 7.5, FALSE, 5, '2024-12-10'), -- MP13

-- ASIX1A Student 1 (Miquel)
(13, 13, 1, 7.0, FALSE, 5, '2024-12-10'); -- MP17

-- ============================================
-- GRADES FOR 2ND EVALUATION PERIOD (IN_SESSION)
-- ============================================
INSERT INTO grades (student_id, subject_id, session_id, grade_value, is_draft, entered_by, entered_at) VALUES
-- DAM2A Student 1 (Albert) - Mix of draft and finalized
(1, 1, 2, 8.0, FALSE, 2, '2025-04-10'),  -- MP06 - finalized
(1, 2, 2, 7.5, TRUE, 4, '2025-04-10'),   -- MP07 - draft
(1, 3, 2, 8.5, FALSE, 4, '2025-04-10'),  -- MP08 - finalized

-- DAM2A Student 2 (Berta) - All drafts
(2, 1, 2, 7.0, TRUE, 2, '2025-04-10'),   -- MP06 - draft
(2, 2, 2, 8.5, TRUE, 4, '2025-04-10'),   -- MP07 - draft
(2, 3, 2, 7.0, TRUE, 4, '2025-04-10'),   -- MP08 - draft

-- DAM2A Student 3 (Carlos) - Some entered
(3, 1, 2, 8.5, FALSE, 2, '2025-04-10'),  -- MP06 - finalized
(3, 2, 2, NULL, FALSE, 4, '2025-04-10'), -- MP07 - no grade yet
(3, 3, 2, 8.0, FALSE, 4, '2025-04-10');  -- MP08 - finalized

-- ============================================
-- GRADES FOR 3RD EVALUATION PERIOD (OPEN)
-- ============================================
INSERT INTO grades (student_id, subject_id, session_id, grade_value, is_draft, entered_by, entered_at) VALUES
-- DAM2A Students - early drafts (teachers still entering)
(1, 1, 3, 7.5, TRUE, 2, '2025-05-15'),
(2, 1, 3, 8.5, TRUE, 2, '2025-05-15'),
(3, 1, 3, 8.0, TRUE, 2, '2025-05-15');

-- ============================================
-- GRADE_AUDIT ENTRIES (from 1st period modifications in 2nd period)
-- ============================================
INSERT INTO grade_audit (grade_id, old_value, new_value, modified_by, reason, session_state) VALUES
-- Example: Albert's MP06 grade was updated during 2nd period (IN_SESSION)
-- First, we need to find the grade_id values, so we'll use subqueries
((SELECT grade_id FROM grades WHERE student_id = 1 AND subject_id = 1 AND session_id = 1), 8.5, 8.7, 1, 'Correction after evaluation session review meeting', 'CLOSED'),
((SELECT grade_id FROM grades WHERE student_id = 2 AND subject_id = 1 AND session_id = 1), 6.5, 7.0, 1, 'Student appeal resolved with documentation', 'CLOSED'),
((SELECT grade_id FROM grades WHERE student_id = 3 AND subject_id = 2 AND session_id = 1), 8.5, 8.3, 1, 'Grade rounding correction to match evaluation rubric', 'CLOSED');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- SELECT COUNT(*) as total_students FROM students;
-- SELECT COUNT(*) as total_subjects FROM subjects;
-- SELECT COUNT(*) as total_sessions FROM evaluation_sessions;
-- SELECT COUNT(*) as total_grades FROM grades;
-- SELECT COUNT(*) as total_audit_entries FROM grade_audit;
-- SELECT s.full_name, sub.name, g.grade_value, g.is_draft
--   FROM grades g
--   JOIN students s ON g.student_id = s.student_id
--   JOIN subjects sub ON g.subject_id = sub.subject_id
--   ORDER BY s.full_name;
