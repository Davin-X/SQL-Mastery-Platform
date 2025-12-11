-- 07_transactions_dcl.sql
-- Topic: Transactions and DCL — COMMIT, ROLLBACK, SAVEPOINT, GRANT/REVOKE

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- Transaction example: safe delete
START TRANSACTION;
-- DELETE FROM employee WHERE hire_date < '2010-01-01';
-- If results look correct: COMMIT; else: ROLLBACK;
ROLLBACK;
-- example keeps data safe

-- Savepoint example
START TRANSACTION;
-- do some updates
SAVEPOINT sp1;
-- do more changes
ROLLBACK TO SAVEPOINT sp1;

COMMIT;

-- DCL: GRANT / REVOKE (requires elevated privileges)
-- GRANT SELECT, INSERT ON sample_hr.* TO 'learner'@'localhost';
-- REVOKE INSERT ON sample_hr.* FROM 'learner'@'localhost';

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- Transaction example: safe delete
BEGIN;  -- or START TRANSACTION;
-- DELETE FROM employee WHERE hire_date < '2010-01-01';
-- If results look correct: COMMIT; else: ROLLBACK;
ROLLBACK;

-- Savepoint example
BEGIN;
-- do some updates
SAVEPOINT sp1;
-- do more changes
ROLLBACK TO SAVEPOINT sp1;
COMMIT;

-- DCL: GRANT / REVOKE (PostgreSQL syntax)
-- GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO learner;
-- REVOKE INSERT ON ALL TABLES IN SCHEMA public FROM learner;

-- PostgreSQL Notes:
-- - BEGIN; or START TRANSACTION; both work
-- - Same SAVEPOINT and ROLLBACK TO syntax
-- - GRANT/REVOKE uses schema-level permissions
-- - Role-based security model
-- - Can grant permissions on schemas, not just tables
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax:

USE sample_hr;

-- Transaction example: safe delete
BEGIN TRANSACTION;  -- or BEGIN TRAN;
-- DELETE FROM employee WHERE hire_date < '2010-01-01';
-- If results look correct: COMMIT; else: ROLLBACK;
ROLLBACK TRANSACTION;

-- Savepoint example
BEGIN TRANSACTION;
-- do some updates
SAVE TRANSACTION sp1;  -- Note: SAVE TRANSACTION, not SAVEPOINT
-- do more changes
ROLLBACK TRANSACTION sp1;  -- Note: ROLLBACK TRANSACTION savepoint_name
COMMIT TRANSACTION;

-- DCL: GRANT / REVOKE (SQL Server syntax)
-- GRANT SELECT, INSERT ON SCHEMA::dbo TO learner;
-- REVOKE INSERT ON SCHEMA::dbo FROM learner;

-- SQL Server Notes:
-- - BEGIN TRANSACTION; or BEGIN TRAN;
-- - SAVE TRANSACTION savepoint_name (not SAVEPOINT)
-- - ROLLBACK TRANSACTION savepoint_name
-- - Schema-level permissions with SCHEMA::schema_name syntax
-- - Windows Authentication or SQL Server Authentication
-- - Can grant permissions to users, roles, or Windows groups
*/

-- Exercises (all databases):
-- 1) Demonstrate rollback after an accidental update by performing an update inside a transaction and rolling back.
--    All databases: Use START TRANSACTION/BEGIN + ROLLBACK pattern

-- 2) Create a savepoint and roll back to it.
--    MySQL/PostgreSQL: SAVEPOINT name; ROLLBACK TO SAVEPOINT name;
--    SQL Server: SAVE TRANSACTION name; ROLLBACK TRANSACTION name;