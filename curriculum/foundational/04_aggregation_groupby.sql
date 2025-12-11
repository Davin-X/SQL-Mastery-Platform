-- 04_aggregation_groupby.sql
-- Topic: Aggregation — GROUP BY, HAVING, COUNT, SUM, AVG, string aggregation

USE sample_hr;

-- Basic aggregation
SELECT
    department,
    COUNT(*) AS employees,
    AVG(salary) AS avg_salary
FROM employee
GROUP BY
    department;

-- HAVING example: departments with more than 2 employees
SELECT department, COUNT(*) AS employees
FROM employee
GROUP BY
    department
HAVING
    COUNT(*) > 2;

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- Basic aggregation
SELECT
    department,
    COUNT(*) AS employees,
    AVG(salary) AS avg_salary
FROM employee
GROUP BY
    department;

-- HAVING example: departments with more than 2 employees
SELECT department, COUNT(*) AS employees
FROM employee
GROUP BY
    department
HAVING
    COUNT(*) > 2;

-- String aggregation (MySQL: GROUP_CONCAT)
SELECT department, GROUP_CONCAT(first_name SEPARATOR ', ') AS names
FROM employee
GROUP BY
    department;

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- Basic aggregation (same as MySQL)
SELECT
department,
COUNT(*) AS employees,
AVG(salary) AS avg_salary
FROM employee
GROUP BY
department;

-- HAVING example (same as MySQL)
SELECT department, COUNT(*) AS employees
FROM employee
GROUP BY
department
HAVING
COUNT(*) > 2;

-- String aggregation (PostgreSQL: STRING_AGG)
SELECT department, STRING_AGG(first_name, ', ') AS names
FROM employee
GROUP BY
department;

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

-- Basic aggregation (same as MySQL)
SELECT
department,
COUNT(*) AS employees,
AVG(salary) AS avg_salary
FROM employee
GROUP BY
department;

-- HAVING example (same as MySQL)
SELECT department, COUNT(*) AS employees
FROM employee
GROUP BY
department
HAVING
COUNT(*) > 2;

-- String aggregation (SQL Server: STRING_AGG - SQL Server 2017+)
SELECT department, STRING_AGG(first_name, ', ') AS names
FROM employee
GROUP BY
department;

-- Alternative for older SQL Server versions (before 2017):
-- Uses XML PATH or FOR XML for string concatenation
SELECT department,
STUFF((SELECT ', ' + first_name
FROM employee e2
WHERE e2.department = e1.department
FOR XML PATH('')), 1, 2, '') AS names
FROM employee e1
GROUP BY department;

-- SQL Server Notes:
-- - GROUP_CONCAT() → STRING_AGG(column, separator) (2017+)
-- - Older versions use XML PATH workaround
-- - Same USE syntax as MySQL
-- - Same aggregation functions otherwise
*/

-- Exercises (all databases):
-- 1) List top 3 departments by employee count.
--    Solution: SELECT department, COUNT(*) as cnt FROM employee
--              GROUP BY department ORDER BY cnt DESC LIMIT 3; (MySQL/PostgreSQL)
--              -- or: SELECT TOP 3 department, COUNT(*) as cnt FROM employee
--                     GROUP BY department ORDER BY cnt DESC; (SQL Server)

-- 2) For each department, show earliest hire_date.
--    Solution: SELECT department, MIN(hire_date) as earliest_hire
--              FROM employee GROUP BY department;