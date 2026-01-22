-- ============================================
-- EVALIS Desktop - Database Functions & Triggers
-- ============================================

-- ============================================
-- AUTO-UPDATE TIMESTAMP TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Auto-updates updated_at column on row modification';

-- Apply trigger to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SESSION CLEANUP FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    rows_deleted INTEGER;
BEGIN
    -- Deactivate sessions inactive for more than 30 minutes
    UPDATE sessions
    SET is_active = FALSE
    WHERE is_active = TRUE
      AND last_activity < (CURRENT_TIMESTAMP - INTERVAL '30 minutes');

    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    RETURN rows_deleted;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_expired_sessions() IS 'Deactivates sessions inactive for >30 minutes';

-- ============================================
-- PASSWORD VALIDATION FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION is_valid_password_hash(hash VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    -- SHA-256 hash must be exactly 64 hexadecimal characters
    RETURN hash ~ '^[a-fA-F0-9]{64}$';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION is_valid_password_hash(VARCHAR) IS 'Validates SHA-256 hash format (64 hex chars)';
