-- 04_aggregation_groupby.sql
-- Topic: Aggregation — GROUP BY, HAVING, COUNT, SUM, AVG, string aggregation

USE sample_hr;

-- Basic aggregation with JOIN
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employees,
    AVG(e.salary) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name;

-- HAVING example: departments with more than 2 employees
SELECT d.dept_name, COUNT(e.emp_id) AS employees
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name
HAVING
    COUNT(e.emp_id) > 2;

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- Basic aggregation with JOIN
SELECT d.dept_name, COUNT(e.emp_id) AS employees, AVG(e.salary) AS avg_salary
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name;

-- HAVING example: departments with more than 2 employees
SELECT d.dept_name, COUNT(e.emp_id) AS employees
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name
HAVING
    COUNT(e.emp_id) > 2;

-- String aggregation (MySQL: GROUP_CONCAT)
SELECT d.dept_name, GROUP_CONCAT(e.first_name SEPARATOR ', ') AS names
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name;

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- Basic aggregation with JOIN (same as MySQL)
SELECT
d.dept_name,
COUNT(e.emp_id) AS employees,
AVG(e.salary) AS avg_salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name;

-- HAVING example (same as MySQL)
SELECT d.dept_name, COUNT(e.emp_id) AS employees
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name
HAVING
COUNT(e.emp_id) > 2;

-- String aggregation (PostgreSQL: STRING_AGG)
SELECT d.dept_name, STRING_AGG(e.first_name, ', ') AS names
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name;

-- PostgreSQL Notes:
-- - GROUP_CONCAT() → STRING_AGG(column, separator)
-- - Use \c to connect to database
-- - Same aggregation functions otherwise
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax:

USE sample_hr;

-- Basic aggregation with JOIN (same as MySQL)
SELECT
d.dept_name,
COUNT(e.emp_id) AS employees,
AVG(e.salary) AS avg_salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name;

-- HAVING example (same as MySQL)
SELECT d.dept_name, COUNT(e.emp_id) AS employees
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name
HAVING
COUNT(e.emp_id) > 2;

-- String aggregation (SQL Server: STRING_AGG - SQL Server 2017+)
SELECT d.dept_name, STRING_AGG(e.first_name, ', ') AS names
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY
d.dept_name;

-- Alternative for older SQL Server versions (before 2017):
-- Uses XML PATH or FOR XML for string concatenation
SELECT d.dept_name,
STUFF((SELECT ', ' + e2.first_name
FROM employee e2
JOIN department d2 ON e2.dept_id = d2.dept_id
WHERE d2.dept_name = d1.dept_name
FOR XML PATH('')), 1, 2, '') AS names
FROM department d1
GROUP BY d1.dept_name;

-- SQL Server Notes:
-- - GROUP_CONCAT() → STRING_AGG(column, separator) (2017+)
-- - Older versions use XML PATH workaround
-- - Same USE syntax as MySQL
-- - Same aggregation functions otherwise
*/

-- Exercises (all databases):
-- 1) List top 3 departments by employee count.
--    Solution: SELECT d.dept_name, COUNT(e.emp_id) as cnt FROM employee e
--              JOIN department d ON e.dept_id = d.dept_id
--              GROUP BY d.dept_name ORDER BY cnt DESC LIMIT 3; (MySQL/PostgreSQL)
--              -- or: SELECT TOP 3 d.dept_name, COUNT(e.emp_id) as cnt FROM employee e
--                     JOIN department d ON e.dept_id = d.dept_id
--                     GROUP BY d.dept_name ORDER BY cnt DESC; (SQL Server)

-- 2) For each department, show earliest hire_date.
--    Solution: SELECT d.dept_name, MIN(e.hire_date) as earliest_hire
--              FROM employee e JOIN department d ON e.dept_id = d.dept_id
--              GROUP BY d.dept_name;