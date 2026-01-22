-- ============================================
-- EVALIS Desktop - Seed Data
-- ============================================
-- Demo accounts and initial test data

-- ============================================
-- DEMO USER ACCOUNTS
-- ============================================
-- Password for all demo accounts: Test1234
-- SHA-256 hash: 07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573

INSERT INTO users (dni, username, password_hash, role, full_name, email) VALUES
('12345678A', 'cap_estudis', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 'DepartmentHead', 'Joan Puig i Garcia', 'jpuig@institut.cat'),
('87654321B', 'prof_test', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 'Teacher', 'Maria Serra i Rovira', 'mserra@institut.cat'),
('11223344C', 'tutor_dam2', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 'GroupTutor', 'Pere Martí i Soler', 'pmarti@institut.cat'),
('55667788D', 'prof_prog', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 'Teacher', 'Anna Vilaró i Font', 'avilaro@institut.cat'),
('99887766E', 'prof_bbdd', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 'Teacher', 'Carles Bosch i Pla', 'cbosch@institut.cat');

-- ============================================
-- SAMPLE LOGIN AUDIT ENTRIES
-- ============================================
INSERT INTO login_audit (user_id, username, login_time, ip_address, status) VALUES
(1, 'cap_estudis', CURRENT_TIMESTAMP - INTERVAL '2 hours', '192.168.1.100', 'SUCCESS'),
(2, 'prof_test', CURRENT_TIMESTAMP - INTERVAL '1 hour', '192.168.1.101', 'SUCCESS'),
(3, 'tutor_dam2', CURRENT_TIMESTAMP - INTERVAL '30 minutes', '192.168.1.102', 'SUCCESS');

INSERT INTO login_audit (user_id, username, login_time, ip_address, status, failure_reason) VALUES
(NULL, 'unknown_user', CURRENT_TIMESTAMP - INTERVAL '3 hours', '192.168.1.200', 'FAILED', 'User not found'),
(2, 'prof_test', CURRENT_TIMESTAMP - INTERVAL '2 hours 30 minutes', '192.168.1.101', 'FAILED', 'Invalid password');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- To verify data insertion, uncomment and run:
-- SELECT username, role, full_name FROM users ORDER BY user_id;
-- SELECT username, status, login_time FROM login_audit ORDER BY login_time DESC;
