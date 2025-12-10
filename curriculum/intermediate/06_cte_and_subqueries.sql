-- 06_cte_and_subqueries.sql
-- Topic: Common Table Expressions (CTE) and subqueries — non-recursive and recursive

USE sample_hr;

-- Simple CTE to compute department counts
WITH
    dept_counts AS (
        SELECT dept_id, COUNT(*) AS cnt
        FROM employee
        GROUP BY
            dept_id
    )
SELECT d.dept_name, dc.cnt
FROM dept_counts dc
    JOIN department d ON d.dept_id = dc.dept_id;

-- Recursive CTE example: generate a sequence (or organizational hierarchy)
WITH RECURSIVE
    seq (n) AS (
        SELECT 1
        UNION ALL
        SELECT n + 1
        FROM seq
        WHERE
            n < 10
    )
SELECT *
FROM seq;

-- Exercises:
-- 1) Use a CTE to compute rolling averages over hire_date windows.
-- 2) Use a recursive CTE to traverse a manager->employee reporting table.