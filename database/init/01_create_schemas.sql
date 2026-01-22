-- ============================================
-- EVALIS Desktop - Schema Organization
-- ============================================
-- Optional: Organize database into logical schemas

-- Authentication and user management
CREATE SCHEMA IF NOT EXISTS auth;

-- Audit trail and logging
CREATE SCHEMA IF NOT EXISTS audit;

-- Note: For simplicity, all tables will use the 'public' schema
-- These schemas are available for future organization if needed
