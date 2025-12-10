-- 10_advanced_analytics.sql
-- Topic: Advanced Analytics Functions — NTILE, PERCENT_RANK, CUME_DIST, MEDIAN, CORR

USE sample_hr;

-- NTILE: Divide data into percentile groups
-- Find salary quartiles per department
SELECT
    emp_id,
    first_name,
    department,
    salary,
    NTILE(4) OVER (
        PARTITION BY
            department
        ORDER BY salary
    ) AS salary_quartile,
    NTILE(10) OVER (
        ORDER BY salary
    ) AS decile_overall
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY department, salary_quartile;

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

-- MEDIAN calculation using window functions
-- (In PostgreSQL/MySQL 8+: use MEDIAN() or PERCENTILE_CONT(0.5))
SELECT
    department,
    AVG(salary) AS avg_salary,
    -- Manual median calculation
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
    department;

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

-- Exercises:
-- 1) Use NTILE to create top/middle/bottom salary tiers and analyze distribution
-- 2) Calculate percentile ranks for performance reviews
-- 3) Find departments with employees in the top 25% of salaries
-- 4) Use STRING_AGG to create department email distribution lists
-- 5) Analyze correlation between salary and project assignment count