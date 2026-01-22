-- ============================================
-- EVALIS Desktop - Phase 3 Seed Data
-- ============================================
-- Comprehensive test data for Phase 3 (Extended Features)

-- ============================================
-- FACULTY INFORMATION
-- ============================================
INSERT INTO faculty (user_id, photo_path, department, phone, specialization) VALUES
-- Joan Puig i Garcia (Department Head)
(1, '/photos/faculty/12345678A_puig_joan.jpg', 'Management', '+34-932-555-001', 'Educational Administration'),

-- Maria Serra i Rovira (Teacher)
(2, '/photos/faculty/87654321B_serra_maria.jpg', 'Computing', '+34-932-555-002', 'Databases and SQL'),

-- Pere Martí i Soler (Group Tutor)
(3, '/photos/faculty/11223344C_marti_pere.jpg', 'Computing', '+34-932-555-003', 'Mobile Development'),

-- Anna Vilaró i Font (Teacher - Programming)
(4, '/photos/faculty/55667788D_vilaro_anna.jpg', 'Computing', '+34-932-555-004', 'Object-Oriented Programming'),

-- Carles Bosch i Pla (Teacher - Databases)
(5, '/photos/faculty/99887766E_bosch_carles.jpg', 'Computing', '+34-932-555-005', 'Data Architecture and Design');

-- ============================================
-- DOCUMENT TYPES
-- ============================================
INSERT INTO documents (document_type, template_path, description, is_active) VALUES
('Bulletin', '/templates/bulletin_template.pdf', 'Student grade report (bulletí de qualificacions)', TRUE),
('Record', '/templates/evaluation_record_template.pdf', 'Official evaluation record (acte d''avaluació)', TRUE),
('Expedient', '/templates/academic_expedient_template.pdf', 'Academic expedient for graduation (expedient acadèmic)', TRUE),
('Certificate', '/templates/completion_certificate_template.pdf', 'Course completion certificate (certificat de finalització)', TRUE);

-- ============================================
-- DOCUMENT ARCHIVE - Sample Generated Documents
-- ============================================
INSERT INTO document_archive (document_id, student_id, file_path, generated_by, academic_year, checksum) VALUES
-- First evaluation period bulletins (1st period)
(1, 1, '/documents/2024-2025/DAM2A001_Rodriguez_Albert_DAM_1st.pdf', 1, '2024-2025', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(1, 2, '/documents/2024-2025/DAM2A002_Sanchez_Berta_DAM_1st.pdf', 1, '2024-2025', 'f3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(1, 3, '/documents/2024-2025/DAM2A003_Fernandez_Carlos_DAM_1st.pdf', 1, '2024-2025', 'a3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),

-- Second evaluation period bulletins (2nd period)
(1, 1, '/documents/2024-2025/DAM2A001_Rodriguez_Albert_DAM_2nd.pdf', 1, '2024-2025', 'b3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(1, 2, '/documents/2024-2025/DAM2A002_Sanchez_Berta_DAM_2nd.pdf', 1, '2024-2025', 'c3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(1, 7, '/documents/2024-2025/DAM2B001_Bosch_Gemma_DAM_2nd.pdf', 1, '2024-2025', 'd3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),

-- Evaluation records (official records)
(2, 1, '/documents/2024-2025/DAM2A001_Rodriguez_Albert_RECORD_1st.pdf', 1, '2024-2025', 'e4b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(2, 2, '/documents/2024-2025/DAM2A002_Sanchez_Berta_RECORD_1st.pdf', 1, '2024-2025', 'f4b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
(2, 3, '/documents/2024-2025/DAM2A003_Fernandez_Carlos_RECORD_1st.pdf', 1, '2024-2025', 'a4b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),

-- Academic expedient for graduated student (Albert - graduated in previous cycle simulation)
-- Note: DAM2A004 (Diana) is marked as Graduated, simulating a past graduation
(3, 4, '/documents/2023-2024/DAM1A001_Puig_Diana_EXPEDIENT_FINAL.pdf', 1, '2023-2024', 'b4b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');

-- ============================================
-- DATA STATISTICS VERIFICATION QUERIES
-- ============================================
-- Total counts:
-- SELECT 'Faculty Members' as metric, COUNT(*) as count FROM faculty
-- UNION ALL
-- SELECT 'Document Types', COUNT(*) FROM documents
-- UNION ALL
-- SELECT 'Archived Documents', COUNT(*) FROM document_archive
-- UNION ALL
-- SELECT 'Students', COUNT(*) FROM students
-- UNION ALL
-- SELECT 'Active Students', COUNT(*) FROM students WHERE status = 'Active'
-- UNION ALL
-- SELECT 'Graduated Students', COUNT(*) FROM students WHERE status = 'Graduated';

-- Faculty details with roles:
-- SELECT u.username, u.full_name, u.role, f.department, f.specialization, f.photo_path
--   FROM users u
--   LEFT JOIN faculty f ON u.user_id = f.user_id
--   ORDER BY u.user_id;

-- Document archive summary:
-- SELECT
--   d.document_type,
--   COUNT(da.archive_id) as generated_count,
--   MAX(da.generated_at) as last_generated
-- FROM document_archive da
-- JOIN documents d ON da.document_id = d.document_id
-- GROUP BY d.document_type
-- ORDER BY d.document_id;

-- Student grades distribution:
-- SELECT
--   s.full_name,
--   s.cycle,
--   s.group_name,
--   COUNT(g.grade_id) as total_grades,
--   COUNT(CASE WHEN g.grade_value IS NOT NULL THEN 1 END) as completed_grades,
--   COUNT(CASE WHEN g.is_draft THEN 1 END) as draft_grades
-- FROM students s
-- LEFT JOIN grades g ON s.student_id = g.student_id
-- GROUP BY s.student_id, s.full_name, s.cycle, s.group_name
-- ORDER BY s.full_name;
