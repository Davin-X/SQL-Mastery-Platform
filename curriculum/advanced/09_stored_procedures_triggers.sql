```sql
-- 09_stored_procedures_triggers.sql
-- Topic: Stored procedures, functions, and triggers (syntax + examples)

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- Simple stored procedure (MySQL syntax)
DELIMITER $$

CREATE PROCEDURE sp_get_employees_by_dept(IN in_dept VARCHAR(50))
BEGIN
  SELECT emp_id, first_name, last_name FROM employee e
  JOIN department d ON e.dept_id = d.dept_id
  WHERE d.dept_name = in_dept;
END$$

DELIMITER ;

-- Trigger example: set created_at automatically (MySQL)
-- ALTER TABLE employee ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
-- CREATE TRIGGER trg_employee_insert BEFORE INSERT ON employee FOR EACH ROW SET NEW.created_at = NOW();

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- PostgreSQL stored procedure (using functions)
CREATE OR REPLACE FUNCTION fn_get_employees_by_dept(in_dept VARCHAR(50))
RETURNS TABLE(emp_id INTEGER, first_name VARCHAR, last_name VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT e.emp_id, e.first_name, e.last_name
               FROM employee e JOIN department d ON e.dept_id = d.dept_id
               WHERE d.dept_name = in_dept;
END;
$$ LANGUAGE plpgsql;

-- Call the function
SELECT * FROM fn_get_employees_by_dept('Engineering');

-- PostgreSQL trigger example
-- CREATE OR REPLACE FUNCTION trg_employee_insert() RETURNS TRIGGER AS $$
-- BEGIN
--   NEW.created_at = CURRENT_TIMESTAMP;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER trg_employee_insert
--   BEFORE INSERT ON employee
--   FOR EACH ROW EXECUTE FUNCTION trg_employee_insert();

-- PostgreSQL Notes:
-- - Uses functions instead of procedures for returning data
-- - LANGUAGE plpgsql for procedural logic
-- - RETURN QUERY for returning result sets
-- - CURRENT_TIMESTAMP instead of NOW()
-- - EXECUTE FUNCTION instead of FOR EACH ROW SET
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax:

USE sample_hr;

-- SQL Server stored procedure
CREATE PROCEDURE sp_get_employees_by_dept
  @in_dept VARCHAR(50)
AS
BEGIN
  SELECT e.emp_id, e.first_name, e.last_name
  FROM employee e
  JOIN department d ON e.dept_id = d.dept_id
  WHERE d.dept_name = @in_dept;
END;

-- Execute the procedure
EXEC sp_get_employees_by_dept @in_dept = 'Engineering';

-- SQL Server trigger example
-- ALTER TABLE employee ADD created_at DATETIME2;
-- CREATE TRIGGER trg_employee_insert
--   ON employee
--   FOR INSERT
-- AS
-- BEGIN
--   UPDATE employee
--   SET created_at = GETDATE()
--   FROM employee e
--   INNER JOIN inserted i ON e.emp_id = i.emp_id;
-- END;

-- SQL Server Notes:
-- - Uses @parameter_name for parameters
-- - AS BEGIN ... END structure
-- - EXEC or EXECUTE to call procedures
-- - FOR INSERT instead of BEFORE INSERT
-- - Uses 'inserted' virtual table in triggers
-- - GETDATE() instead of NOW()
-- - UPDATE ... FROM ... JOIN syntax for trigger updates
*/

-- Exercises (all databases):
-- 1) Create a stored function/procedure that returns full name.
--    MySQL: CREATE FUNCTION get_full_name(id INT) RETURNS VARCHAR(100) RETURN CONCAT(first_name, ' ', last_name);
--    PostgreSQL: CREATE FUNCTION get_full_name(id INT) RETURNS VARCHAR AS $$ ... RETURN CONCAT(...) $$;
--    SQL Server: CREATE FUNCTION get_full_name(@id INT) RETURNS VARCHAR(100) AS BEGIN RETURN ... END;

-- 2) Create a trigger to log deletions into an audit table.
--    All databases support CREATE TRIGGER syntax but with different implementations.
```