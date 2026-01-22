-- ============================================
-- EVALIS Desktop - Phase 3 Performance Indexes
-- ============================================

-- ============================================
-- FACULTY TABLE INDEXES
-- ============================================
CREATE INDEX idx_faculty_user_id ON faculty(user_id);
CREATE INDEX idx_faculty_department ON faculty(department);
CREATE INDEX idx_faculty_specialization ON faculty(specialization);

-- ============================================
-- DOCUMENTS TABLE INDEXES
-- ============================================
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_active ON documents(is_active) WHERE is_active = TRUE;

-- ============================================
-- DOCUMENT_ARCHIVE TABLE INDEXES
-- ============================================
CREATE INDEX idx_document_archive_document_id ON document_archive(document_id);
CREATE INDEX idx_document_archive_student_id ON document_archive(student_id);
CREATE INDEX idx_document_archive_generated_by ON document_archive(generated_by);
CREATE INDEX idx_document_archive_academic_year ON document_archive(academic_year);
CREATE INDEX idx_document_archive_generated_at ON document_archive(generated_at DESC);
CREATE INDEX idx_document_archive_student_type_year ON document_archive(student_id, document_id, academic_year);
CREATE INDEX idx_document_archive_file_path ON document_archive(file_path);
