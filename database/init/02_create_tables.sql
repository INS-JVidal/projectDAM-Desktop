-- ============================================
-- EVALIS Desktop - Core Tables
-- PostgreSQL 14+
-- ============================================

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL, -- SHA-256 hash
    role VARCHAR(20) NOT NULL CHECK (role IN ('DepartmentHead', 'Teacher', 'GroupTutor')),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS 'Application users with role-based access control';
COMMENT ON COLUMN users.dni IS 'Spanish national ID (DNI/NIE)';
COMMENT ON COLUMN users.password_hash IS 'SHA-256 hash of password (64 hex characters)';
COMMENT ON COLUMN users.role IS 'User role: DepartmentHead, Teacher, or GroupTutor';

-- ============================================
-- LOGIN AUDIT TABLE
-- ============================================
CREATE TABLE login_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    username VARCHAR(50) NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    status VARCHAR(20) NOT NULL CHECK (status IN ('SUCCESS', 'FAILED')),
    failure_reason VARCHAR(200)
);

COMMENT ON TABLE login_audit IS 'Security audit log for all login attempts';
COMMENT ON COLUMN login_audit.status IS 'SUCCESS or FAILED';
COMMENT ON COLUMN login_audit.failure_reason IS 'Description of failure (wrong password, account locked, etc.)';

-- ============================================
-- SESSIONS TABLE
-- ============================================
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    is_active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE sessions IS 'Active user sessions with 30-minute timeout tracking';
COMMENT ON COLUMN sessions.last_activity IS 'Updated on each user action for timeout detection';
