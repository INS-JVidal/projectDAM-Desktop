-- ============================================
-- EVALIS Desktop - Phase 3: Extended Features Tables
-- PostgreSQL 14+
-- ============================================
-- Creates: faculty, documents, document_archive

-- ============================================
-- FACULTY TABLE
-- ============================================
CREATE TABLE faculty (
    faculty_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id),
    photo_path VARCHAR(500),
    department VARCHAR(100),
    phone VARCHAR(20),
    specialization VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE faculty IS 'Extended faculty information and portrait gallery';
COMMENT ON COLUMN faculty.user_id IS 'One-to-one relationship with users table';
COMMENT ON COLUMN faculty.photo_path IS 'File server path to faculty portrait (e.g., /photos/faculty/dni_name.jpg)';
COMMENT ON COLUMN faculty.department IS 'Department or section name';
COMMENT ON COLUMN faculty.specialization IS 'Teaching specialization or expertise area';

-- ============================================
-- DOCUMENTS TABLE
-- ============================================
CREATE TABLE documents (
    document_id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('Bulletin', 'Record', 'Expedient', 'Certificate')),
    template_path VARCHAR(500) NOT NULL,
    description VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_document_type UNIQUE (document_type)
);

COMMENT ON TABLE documents IS 'Document type definitions and templates';
COMMENT ON COLUMN documents.document_type IS 'Bulletin (grades), Record (evaluation), Expedient (graduation), Certificate';
COMMENT ON COLUMN documents.template_path IS 'File server path to PDF template';
COMMENT ON COLUMN documents.description IS 'Human-readable description of the document type';

-- ============================================
-- DOCUMENT_ARCHIVE TABLE
-- ============================================
CREATE TABLE document_archive (
    archive_id BIGSERIAL PRIMARY KEY,
    document_id INTEGER NOT NULL REFERENCES documents(document_id),
    student_id INTEGER NOT NULL REFERENCES students(student_id),
    file_path VARCHAR(500) NOT NULL,
    generated_by INTEGER NOT NULL REFERENCES users(user_id),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    academic_year VARCHAR(9) NOT NULL CHECK (academic_year ~ '^\d{4}-\d{4}$'),
    checksum VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_archive_path UNIQUE (file_path)
);

COMMENT ON TABLE document_archive IS 'Generated document tracking and file server archival';
COMMENT ON COLUMN document_archive.file_path IS 'Absolute path on file server: /documents/{NIA}_{Surname}_{Cycle}_{Year}.pdf';
COMMENT ON COLUMN document_archive.checksum IS 'SHA-256 hash of generated PDF for integrity verification';
COMMENT ON COLUMN document_archive.academic_year IS 'Academic year when document was generated';

-- ============================================
-- AUTO-UPDATE TRIGGERS FOR PHASE 3 TABLES
-- ============================================
CREATE TRIGGER update_faculty_updated_at
    BEFORE UPDATE ON faculty
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
