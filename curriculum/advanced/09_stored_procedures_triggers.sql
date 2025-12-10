```sql
-- 09_stored_procedures_triggers.sql
-- Topic: Stored procedures, functions, and triggers (syntax + examples)

USE sample_hr;

-- Simple stored procedure (MySQL syntax)
DELIMITER $$

CREATE PROCEDURE sp_get_employees_by_dept(IN in_dept VARCHAR(50))
BEGIN
  SELECT employee_id, first_name, last_name FROM employee WHERE department = in_dept;
END$$

DELIMITER;

-- Trigger example: set created_at automatically (MySQL)
-- ALTER TABLE employee ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
-- CREATE TRIGGER trg_employee_insert BEFORE INSERT ON employee FOR EACH ROW SET NEW.created_at = NOW();

-- Exercises:
-- 1) Create a stored function that returns full name.
-- 2) Create a trigger to log deletions into an audit table.
```