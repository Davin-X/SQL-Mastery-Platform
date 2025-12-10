-- 07_transactions_dcl.sql
-- Topic: Transactions and DCL — COMMIT, ROLLBACK, SAVEPOINT, GRANT/REVOKE

-- Use the sample_hr database used by basics
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

-- Exercises:
-- 1) Demonstrate rollback after an accidental update by performing an update inside a transaction and rolling back.
-- 2) Create a savepoint and roll back to it.