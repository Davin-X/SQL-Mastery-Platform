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

-- String aggregation (MySQL: GROUP_CONCAT; Postgres: string_agg)
SELECT department, GROUP_CONCAT(first_name SEPARATOR ', ') AS names
FROM employee
GROUP BY
    department;

-- Exercises:
-- 1) List top 3 departments by employee count.
-- 2) For each department, show earliest hire_date.