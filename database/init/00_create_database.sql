-- ============================================
-- EVALIS Desktop - Database and User Setup
-- PostgreSQL 14+
-- ============================================
-- NOTE: Database (evalis_db) is created automatically by Docker
-- This script only creates the application user and grants privileges

-- Create application user (role) with password
-- Use error handling: psql will continue if user already exists
DO $$ BEGIN
    CREATE ROLE evalis_user WITH LOGIN PASSWORD 'evalis2024';
EXCEPTION WHEN DUPLICATE_OBJECT THEN
    -- User already exists, continue silently
    NULL;
END $$;

-- Grant privileges on database
GRANT ALL PRIVILEGES ON DATABASE evalis_db TO evalis_user;

-- Connect to the application database
\c evalis_db

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO evalis_user;

-- Set default privileges for new objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO evalis_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO evalis_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO evalis_user;
