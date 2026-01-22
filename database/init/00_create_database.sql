-- ============================================
-- EVALIS Desktop - Database Creation Script
-- PostgreSQL 14+
-- ============================================
-- Run as postgres superuser: sudo -u postgres psql < 00_create_database.sql

-- Create database with Catalan locale support
CREATE DATABASE evalis_db
    WITH ENCODING 'UTF8'
    LC_COLLATE = 'ca_ES.UTF-8'
    LC_CTYPE = 'ca_ES.UTF-8'
    TEMPLATE = template0;

-- Create application user
CREATE USER evalis_user WITH PASSWORD 'evalis2024';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE evalis_db TO evalis_user;

\c evalis_db

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO evalis_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO evalis_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO evalis_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO evalis_user;
