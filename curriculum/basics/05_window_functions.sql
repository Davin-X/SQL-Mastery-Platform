-- 05_window_functions.sql
-- Topic: Window / analytic functions — ROW_NUMBER, RANK, DENSE_RANK, LEAD, LAG

USE sample_hr;

-- Give each employee a department-level row number ordered by hire_date
SELECT
    employee_id,
    first_name,
    department,
    hire_date,
    ROW_NUMBER() OVER (
        PARTITION BY
            department
        ORDER BY hire_date
    ) AS dept_row
FROM employee;

-- RANK example: top salaries per department
SELECT
    employee_id,
    first_name,
    department,
    salary,
    RANK() OVER (
        PARTITION BY
            department
        ORDER BY salary DESC
    ) AS dept_rank
FROM employee;

-- LEAD / LAG example: compare hire dates
SELECT
    employee_id,
    first_name,
    hire_date,
    LAG(hire_date) OVER (
        ORDER BY hire_date
    ) AS prev_hire,
    LEAD(hire_date) OVER (
        ORDER BY hire_date
    ) AS next_hire
FROM employee;

-- Exercises:
-- 1) Return the 2nd most recent hire per department.
-- 2) Identify employees whose salary increased compared to previous row (use LAG).

-- Advanced windowing patterns (merged from curriculum/advanced/03_advanced_window_patterns.sql)
-- Gaps-and-islands example: identify continuous employment streaks per employee
-- (Assumes `employment` table with `employee_id`, `start_date`, `end_date`)

-- Build an island id by comparing `start_date` to previous `end_date`
SELECT
    employee_id,
    start_date,
    end_date,
    SUM(
        CASE
            WHEN DATEADD (day, -1, start_date) <= LAG(end_date) OVER (
                PARTITION BY
                    employee_id
                ORDER BY start_date
            ) THEN 0
            ELSE 1
        END
    ) OVER (
        PARTITION BY
            employee_id
        ORDER BY start_date ROWS UNBOUNDED PRECEDING
    ) AS island_id
FROM employment;

-- Sessionization example (web events): mark session boundaries when gap > 30 minutes
-- (Assumes `events` table with `user_id`, `event_ts`)
SELECT
    user_id,
    event_ts,
    SUM(
        CASE
            WHEN EXTRACT(
                EPOCH
                FROM (
                        event_ts - LAG(event_ts) OVER (
                            PARTITION BY
                                user_id
                            ORDER BY event_ts
                        )
                    )
            ) > 1800 THEN 1
            ELSE 0
        END
    ) OVER (
        PARTITION BY
            user_id
        ORDER BY event_ts ROWS UNBOUNDED PRECEDING
    ) AS session_id
FROM events;

-- Exercises (advanced):
-- 3) Using the `employment` example, return the length (in days) of each continuous employment streak per employee.
-- 4) Using sessionization, compute total events per session and average session length.