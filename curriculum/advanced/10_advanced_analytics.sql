-- 10_advanced_analytics.sql
-- Topic: Advanced Analytics Functions — NTILE, PERCENT_RANK, CUME_DIST, MEDIAN, CORR

USE sample_hr;

-- NTILE: Divide data into percentile groups
-- Find salary quartiles per department
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    NTILE(4) OVER (
        PARTITION BY
            dept_name
        ORDER BY salary
    ) AS salary_quartile,
    NTILE(10) OVER (
        ORDER BY salary
    ) AS decile_overall
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY dept_name, salary_quartile;

-- PERCENT_RANK: Relative rank (0 to 1 scale)
SELECT
    emp_id,
    first_name,
    salary,
    PERCENT_RANK() OVER (
        ORDER BY salary
    ) AS percent_rank,
    ROUND(
        100 * PERCENT_RANK() OVER (
            ORDER BY salary
        ),
        2
    ) AS percent_rank_pct
FROM employee;

-- CUME_DIST: Cumulative distribution
SELECT salary, COUNT(*) AS freq, ROUND(
        100 * CUME_DIST() OVER (
            ORDER BY salary
        ), 2
    ) AS cumulative_pct
FROM employee
GROUP BY
    salary
ORDER BY salary;

-- ===========================================
-- MYSQL VERSION - MEDIAN & PERCENTILES
-- ===========================================

USE sample_hr;

-- MEDIAN calculation using window functions
-- (MySQL 8.0+: PERCENTILE_CONT within GROUP BY)
SELECT
    dept_name,
    AVG(salary) AS avg_salary,
    -- Manual median calculation for older MySQL versions
    PERCENTILE_CONT (0.5) WITHIN GROUP (
        ORDER BY salary
    ) AS median_salary,
    PERCENTILE_CONT (0.25) WITHIN GROUP (
        ORDER BY salary
    ) AS q1_salary,
    PERCENTILE_CONT (0.75) WITHIN GROUP (
        ORDER BY salary
    ) AS q3_salary
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    dept_name;

-- ===========================================
-- POSTGRESQL VERSION - MEDIAN & PERCENTILES
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- PostgreSQL percentile functions (same as MySQL 8.0+)
SELECT
dept_name,
AVG(salary) AS avg_salary,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary,
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS q1_salary,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS q3_salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY dept_name;

-- Alternative: Use window functions for manual calculation
SELECT DISTINCT
department,
AVG(salary) OVER (PARTITION BY department) AS avg_salary,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) AS median_salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;
*/

-- ===========================================
-- SQL SERVER VERSION - MEDIAN & PERCENTILES
-- ===========================================

/*
-- SQL Server equivalent syntax:

USE sample_hr;

-- SQL Server percentile functions (2012+)
SELECT
dept_name,
AVG(salary) AS avg_salary,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY dept_name) AS median_salary,
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY dept_name) AS q1_salary,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY dept_name) AS q3_salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;

-- Alternative manual calculation for older versions:
-- Use ROW_NUMBER and subqueries for median calculation
WITH ranked_salaries AS (
SELECT
dept_name,
salary,
ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary) AS rn,
COUNT(*) OVER (PARTITION BY dept_name) AS cnt
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
)
SELECT
dept_name,
AVG(CASE WHEN rn IN ((cnt + 1)/2, (cnt + 2)/2) THEN salary END) AS median_salary
FROM ranked_salaries
GROUP BY dept_name;
*/

-- STRING_AGG for concatenated lists (useful for reporting)
SELECT
    dept_name,
    STRING_AGG (
        CONCAT(first_name, ' ', last_name),
        '; '
    ) AS employee_list,
    COUNT(*) AS team_size,
    SUM(salary) AS total_payroll
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    dept_name;

-- ===========================================
-- MYSQL VERSION - CORRELATION
-- ===========================================

-- CORR: Correlation coefficient between salary and experience years
-- (Assumes hire_date exists; calculating experience years)
WITH
    employee_experience AS (
        SELECT
            emp_id,
            first_name,
            salary,
            TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_experience
        FROM employee
    )
SELECT
    CORR (salary, years_experience) AS salary_exp_correlation,
    COUNT(*) AS sample_size
FROM employee_experience;

-- ===========================================
-- POSTGRESQL VERSION - CORRELATION
-- ===========================================

/*
-- PostgreSQL correlation function:

\c sample_hr;

WITH employee_experience AS (
SELECT
emp_id,
first_name,
salary,
EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_experience
FROM employee
)
SELECT
CORR(salary, years_experience) AS salary_exp_correlation,
COUNT(*) AS sample_size
FROM employee_experience;

-- PostgreSQL Notes:
-- - EXTRACT(YEAR FROM AGE(end_date, start_date)) instead of TIMESTAMPDIFF
-- - AGE() returns interval, EXTRACT gets years
-- - CORR() function works the same way
*/

-- ===========================================
-- SQL SERVER VERSION - CORRELATION
-- ===========================================

/*
-- SQL Server correlation calculation:

USE sample_hr;

WITH employee_experience AS (
SELECT
emp_id,
first_name,
salary,
DATEDIFF(YEAR, hire_date, GETDATE()) AS years_experience
FROM employee
)
SELECT
-- Manual correlation calculation for older SQL Server versions
(AVG(salary * years_experience) - AVG(salary) * AVG(years_experience)) /
(STDEV(salary) * STDEV(years_experience)) AS salary_exp_correlation,
COUNT(*) AS sample_size
FROM employee_experience;

-- Alternative: Use built-in CORR function in SQL Server 2022+
-- SELECT CORR(salary, years_experience) AS salary_exp_correlation FROM employee_experience;

-- SQL Server Notes:
-- - DATEDIFF(YEAR, start_date, end_date) instead of TIMESTAMPDIFF
-- - GETDATE() instead of CURDATE()
-- - CORR() function available in SQL Server 2022+
-- - Manual calculation using STDEV() for older versions
*/

-- Exercises:
-- 1) Use NTILE to create top/middle/bottom salary tiers and analyze distribution
-- 2) Calculate percentile ranks for performance reviews
-- 3) Find departments with employees in the top 25% of salaries
-- 4) Use STRING_AGG to create department email distribution lists
-- 5) Analyze correlation between salary and project assignment count