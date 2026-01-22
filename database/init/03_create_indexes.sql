-- ============================================
-- EVALIS Desktop - Performance Indexes
-- ============================================

-- ============================================
-- USERS TABLE INDEXES
-- ============================================
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_dni ON users(dni);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = TRUE;

-- ============================================
-- LOGIN AUDIT TABLE INDEXES
-- ============================================
CREATE INDEX idx_login_audit_user ON login_audit(user_id);
CREATE INDEX idx_login_audit_username ON login_audit(username);
CREATE INDEX idx_login_audit_time ON login_audit(login_time DESC);
CREATE INDEX idx_login_audit_status ON login_audit(status);
CREATE INDEX idx_login_audit_failed ON login_audit(login_time DESC) WHERE status = 'FAILED';

-- ============================================
-- SESSIONS TABLE INDEXES
-- ============================================
CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_active ON sessions(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_sessions_last_activity ON sessions(last_activity DESC);
