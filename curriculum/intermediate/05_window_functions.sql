-- 05_window_functions.sql
-- MASTER CLASS: Window Functions — The Secret Weapon of SQL Analytics
-- Framing, partitioning, and analytical functions for complex business queries

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- ===========================================
-- FOUNDATION: Basic Ranking & Ordering Functions
-- ===========================================

-- ROW_NUMBER: Unique sequential numbers (no gaps)
SELECT
    emp_id,
    first_name,
    last_name,
    dept_name,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY
            dept_name
        ORDER BY salary DESC, hire_date ASC
    ) AS dept_salary_rank
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY dept_name, dept_salary_rank;

-- RANK: Ranking with gaps for ties
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    RANK() OVER (
        PARTITION BY
            dept_name
        ORDER BY salary DESC
    ) AS dept_rank,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS company_rank
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY company_rank;

-- DENSE_RANK: Ranking without gaps for ties
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    RANK() OVER (
        PARTITION BY
            dept_name
        ORDER BY salary DESC
    ) AS rank_with_gaps,
    DENSE_RANK() OVER (
        PARTITION BY
            dept_name
        ORDER BY salary DESC
    ) AS rank_dense,
    ROW_NUMBER() OVER (
        PARTITION BY
            dept_name
        ORDER BY salary DESC
    ) AS row_num
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY dept_name, salary DESC;

-- ===========================================
-- NAVIGATION: LEAD & LAG Functions
-- ===========================================

-- LAG: Access previous row's value
SELECT
    emp_id,
    first_name,
    hire_date,
    salary,
    LAG(salary) OVER (
        PARTITION BY
            dept_id
        ORDER BY hire_date
    ) AS prev_employee_salary,
    salary - LAG(salary) OVER (
        PARTITION BY
            dept_id
        ORDER BY hire_date
    ) AS salary_vs_previous,
    LAG(hire_date, 2) OVER (
        PARTITION BY
            dept_id
        ORDER BY hire_date
    ) AS two_hires_ago
FROM employee
ORDER BY dept_id, hire_date;

-- LEAD: Access next/future row's value
SELECT
    emp_id,
    first_name,
    hire_date,
    LEAD(first_name) OVER (
        ORDER BY hire_date
    ) AS next_hire_name,
    LEAD(hire_date) OVER (
        ORDER BY hire_date
    ) AS next_hire_date,
    DATEDIFF(
        LEAD(hire_date) OVER (
            ORDER BY hire_date
        ),
        hire_date
    ) AS days_until_next_hire
FROM employee
ORDER BY hire_date;

-- ===========================================
-- ANALYTICAL: FIRST_VALUE & LAST_VALUE with FRAMES
-- ===========================================

-- FIRST_VALUE: First value in partition/window
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    hire_date,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY
            dept_name
        ORDER BY hire_date
    ) AS dept_first_hire,
    FIRST_VALUE(salary) OVER (
        PARTITION BY
            dept_name
        ORDER BY
            hire_date ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS dept_highest_salary,
    salary - FIRST_VALUE(salary) OVER (
        PARTITION BY
            dept_name
        ORDER BY hire_date
    ) AS salary_vs_dept_first
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- LAST_VALUE: Last value in partition/window (use with explicit frames)
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    hire_date,
    LAST_VALUE(salary) OVER (
        PARTITION BY
            dept_name
        ORDER BY
            hire_date ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
    ) AS dept_latest_salary,
    LAST_VALUE(first_name) OVER (
        PARTITION BY
            dept_name
        ORDER BY
            hire_date ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS most_recent_hire_yet
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
ORDER BY dept_name, hire_date;

-- ===========================================
-- AGGREGATES: Running Totals & Moving Averages
-- ===========================================

-- SUM: Running total of salaries by department
SELECT
    emp_id,
    first_name,
    dept_name,
    salary,
    SUM(salary) OVER (
        PARTITION BY
            dept_name
        ORDER BY hire_date ROWS UNBOUNDED PRECEDING
    ) AS cumulative_salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY
                dept_name
            ORDER BY hire_date ROWS BETWEEN 2 PRECEDING
                AND CURRENT ROW
        ),
        0
    ) AS rolling_3person_avg
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- COUNT & AVG: Rolling employee count
SELECT
    DATE_FORMAT(hire_date, '%Y-%m') AS hire_month,
    COUNT(*) AS hires_this_month,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
    ) AS cumulative_hires,
    ROUND(
        AVG(COUNT(*)) OVER (
            ORDER BY DATE_FORMAT(hire_date, '%Y-%m') ROWS BETWEEN 2 PRECEDING
                AND CURRENT ROW
        ),
        2
    ) AS rolling_3month_avg_hires
FROM employee
GROUP BY
    DATE_FORMAT(hire_date, '%Y-%m')
ORDER BY hire_month;

-- ===========================================
-- DISTRIBUTION: NTILE, PERCENT_RANK, CUME_DIST
-- ===========================================

-- NTILE: Divide into equal-sized buckets
SELECT
    emp_id,
    first_name,
    salary,
    NTILE(4) OVER (
        ORDER BY salary DESC
    ) AS salary_quartile,
    NTILE(10) OVER (
        ORDER BY salary DESC
    ) AS salary_decile,
    CASE
        WHEN NTILE(4) OVER (
            ORDER BY salary DESC
        ) = 1 THEN 'Top 25%'
        WHEN NTILE(4) OVER (
            ORDER BY salary DESC
        ) = 2 THEN '75-100%'
        WHEN NTILE(4) OVER (
            ORDER BY salary DESC
        ) = 3 THEN '50-75%'
        ELSE 'Bottom 25%'
    END AS salary_bracket
FROM employee;

-- PERCENT_RANK: Relative rank (0.0 to 1.0)
SELECT
    emp_id,
    first_name,
    salary,
    PERCENT_RANK() OVER (
        ORDER BY salary
    ) AS salary_percentile,
    ROUND(
        100 * PERCENT_RANK() OVER (
            ORDER BY salary
        ),
        1
    ) AS percentile_pct,
    CASE
        WHEN PERCENT_RANK() OVER (
            ORDER BY salary
        ) >= 0.9 THEN 'Top 10%'
        WHEN PERCENT_RANK() OVER (
            ORDER BY salary
        ) >= 0.75 THEN 'Top 25%'
        WHEN PERCENT_RANK() OVER (
            ORDER BY salary
        ) >= 0.5 THEN 'Above Median'
        ELSE 'Below Median'
    END AS percentile_group
FROM employee
ORDER BY salary;

-- CUME_DIST: Cumulative distribution
SELECT
    salary,
    COUNT(*) AS employee_count,
    CUME_DIST() OVER (
        ORDER BY salary
    ) AS cumulative_pct,
    ROUND(
        100 * CUME_DIST() OVER (
            ORDER BY salary
        ),
        1
    ) AS cum_pct_formatted
FROM employee
GROUP BY
    salary
ORDER BY salary;

-- ===========================================
-- ADVANCED PATTERNS: Gaps & Islands
-- ===========================================

-- Create sample activity gaps data
DROP TABLE IF EXISTS employee_activity;

CREATE TABLE employee_activity (
    emp_id INT,
    activity_date DATE,
    activity_type VARCHAR(50),
    hours_logged DECIMAL(4, 2)
);

INSERT INTO
    employee_activity
VALUES (
        3,
        '2024-01-01',
        'Development',
        8.0
    ),
    (
        3,
        '2024-01-02',
        'Development',
        7.5
    ),
    (
        3,
        '2024-01-05',
        'Meeting',
        2.0
    ), -- Gap of 2 days
    (
        3,
        '2024-01-06',
        'Development',
        8.0
    ),
    (
        6,
        '2024-01-01',
        'Planning',
        4.0
    ),
    (
        6,
        '2024-01-03',
        'Development',
        6.0
    ), -- Gap of 1 day
    (
        6,
        '2024-01-05',
        'Testing',
        5.0
    );

-- Gaps analysis: Identify activity gaps
WITH
    activity_gaps AS (
        SELECT
            emp_id,
            activity_date,
            LEAD(activity_date) OVER (
                PARTITION BY
                    emp_id
                ORDER BY activity_date
            ) AS next_activity,
            DATEDIFF(
                LEAD(activity_date) OVER (
                    PARTITION BY
                        emp_id
                    ORDER BY activity_date
                ),
                activity_date
            ) AS days_between
        FROM employee_activity
    )
SELECT
    emp_id,
    activity_date,
    next_activity,
    days_between,
    CASE
        WHEN days_between > 2 THEN 'Large Gap (>2 days)'
        WHEN days_between > 1 THEN 'Small Gap (2 days)'
        ELSE 'Consecutive'
    END AS gap_category
FROM activity_gaps
WHERE
    next_activity IS NOT NULL
ORDER BY emp_id, activity_date;

-- Islands: Identify consecutive activity periods
WITH
    island_markers AS (
        SELECT
            emp_id,
            activity_date,
            DATEDIFF(
                activity_date,
                LAG(activity_date) OVER (
                    PARTITION BY
                        emp_id
                    ORDER BY activity_date
                )
            ) AS days_diff
        FROM employee_activity
    ),
    islands AS (
        SELECT
            emp_id,
            activity_date,
            SUM(
                CASE
                    WHEN days_diff > 1
                    OR days_diff IS NULL THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY
                    emp_id
                ORDER BY activity_date
            ) AS island_id
        FROM island_markers
    )
SELECT
    emp_id,
    island_id,
    MIN(activity_date) AS island_start,
    MAX(activity_date) AS island_end,
    COUNT(*) AS activity_days,
    DATEDIFF(
        MAX(activity_date),
        MIN(activity_date)
    ) + 1 AS total_days,
    SUM(hours_logged) AS total_hours
FROM
    islands i
    JOIN employee_activity ea ON i.emp_id = ea.emp_id
    AND i.activity_date = ea.activity_date
GROUP BY
    emp_id,
    island_id
ORDER BY emp_id, island_start;

-- ===========================================
-- BUSINESS INTELLIGENCE: Time Series Analysis
-- ===========================================

-- Monthly hiring trends with seasonality analysis
SELECT
    DATE_FORMAT(hire_date, '%Y-%m') AS hire_month,
    YEAR(hire_date) AS hire_year,
    MONTH(hire_date) AS hire_month_num,
    COUNT(*) AS hires,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
    ) AS cumulative_hires,
    ROUND(
        AVG(COUNT(*)) OVER (
            ORDER BY DATE_FORMAT(hire_date, '%Y-%m') ROWS BETWEEN 11 PRECEDING
                AND CURRENT ROW
        ),
        1
    ) AS rolling_12month_avg,
    COUNT(*) - LAG(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
    ) AS month_over_month_change,
    ROUND(
        100.0 * (
            COUNT(*) - LAG(COUNT(*)) OVER (
                ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
            )
        ) / NULLIF(
            LAG(COUNT(*)) OVER (
                ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
            ),
            0
        ),
        1
    ) AS mom_growth_pct
FROM employee
GROUP BY
    DATE_FORMAT(hire_date, '%Y-%m'),
    YEAR(hire_date),
    MONTH(hire_date)
ORDER BY hire_month;

-- ===========================================
-- MASTER EXERCISES: Advanced Window Function Patterns
-- ===========================================

-- EXERCISE 1: Top-N with Ties Handling
SELECT *
FROM (
        SELECT
            dept_name, first_name, salary, ROW_NUMBER() OVER (
                PARTITION BY
                    dept_name
                ORDER BY salary DESC
            ) AS rn, RANK() OVER (
                PARTITION BY
                    dept_name
                ORDER BY salary DESC
            ) AS rank, DENSE_RANK() OVER (
                PARTITION BY
                    dept_name
                ORDER BY salary DESC
            ) AS dense_rank
        FROM employee e
            JOIN department d ON e.dept_id = d.dept_id
    ) ranked
WHERE
    dense_rank <= 3 -- Get top 3 unique ranks
ORDER BY dept_name, dense_rank, salary DESC;

-- EXERCISE 2: Market Basket Analysis Foundation
-- Find departments with salary patterns
SELECT
    dept_name,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    PERCENT_RANK() OVER (
        ORDER BY AVG(salary)
    ) AS dept_percentile,
    NTILE(3) OVER (
        ORDER BY AVG(salary) DESC
    ) AS salary_tier,
    STDEV (salary) AS salary_variance,
    MAX(salary) - MIN(salary) AS salary_range,
    ROUND(
        MAX(salary) / NULLIF(MIN(salary), 0),
        2
    ) AS pay_ratio
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
GROUP BY
    dept_name
ORDER BY avg_salary DESC;

-- EXERCISE 3: Predictive Hiring (forecasting)
-- Use window functions for simple trend extrapolation
WITH
    hiring_history AS (
        SELECT
            DATE_FORMAT(hire_date, '%Y-%m') AS hire_month,
            COUNT(*) AS hires,
            ROW_NUMBER() OVER (
                ORDER BY DATE_FORMAT(hire_date, '%Y-%m')
            ) AS month_sequence
        FROM employee
        GROUP BY
            DATE_FORMAT(hire_date, '%Y-%m')
    ),
    trend_analysis AS (
        SELECT
            hire_month,
            hires,
            month_sequence,
            AVG(hires) OVER (
                ORDER BY
                    month_sequence ROWS BETWEEN UNBOUNDED PRECEDING
                    AND CURRENT ROW
            ) AS cumulative_avg,
            hires - LAG(hires) OVER (
                ORDER BY month_sequence
            ) AS change_from_last,
            ROUND(
                100.0 * (
                    hires - LAG(hires) OVER (
                        ORDER BY month_sequence
                    )
                ) / NULLIF(
                    LAG(hires) OVER (
                        ORDER BY month_sequence
                    ),
                    0
                ),
                2
            ) AS pct_change
        FROM hiring_history
    ),
    forecast AS (
        SELECT *, ROUND(
                cumulative_avg + AVG(change_from_last) OVER (
                    ORDER BY
                        month_sequence ROWS BETWEEN UNBOUNDED PRECEDING
                        AND CURRENT ROW
                ), 0
            ) AS forecasted_hires
        FROM trend_analysis
    )
SELECT
    hire_month,
    hires AS actual_hires,
    forecasted_hires,
    ABS(hires - forecasted_hires) AS forecast_error,
    ROUND(
        100.0 * ABS(hires - forecasted_hires) / NULLIF(hires, 0),
        2
    ) AS forecast_accuracy_pct
FROM forecast
WHERE
    hires IS NOT NULL
ORDER BY hire_month;

-- ===========================================
-- PERFORMANCE & OPTIMIZATION TIPS
-- ===========================================

/*
Key Performance Insights for Window Functions:

1. DIFFERENCE BETWEEN FUNCTIONS:
- ROW_NUMBER: Fastest, uses index efficiently, no ties handling
- RANK: Slower, must handle ties with gaps
- DENSE_RANK: Slowest, handles ties without gaps
- Use ROW_NUMBER when you can, RANK/RANK only when needed

2. FRAME SPECIFICATIONS:
- ROWS: Fast, physical row counts, great for moving averages
- RANGE: Slower, logical ranges, useful for date/age brackets
- Specify frames explicitly to avoid default behavior

3. PARTITIONING:
- Choose partition keys that match your business groupings
- Consider the number of partitions (too many = slow)
- Sometimes pre-aggregating before window functions is faster

4. COMMON INTERVIEW PATTERNS:
- Top-N per group: ROW_NUMBER() + WHERE rn <= N
- Running totals: SUM() OVER (ORDER BY...)
- Gaps analysis: LAG() + conditional logic
- Performance tiers: NTILE() or PERCENT_RANK()

5. RESOURCE INTENSIVE OPERATIONS:
- Multiple window functions on same query? Combine into one pass
- Need partition-specific calculations? Consider CTEs
- Complex ordered operations? Ensure supporting indexes
*/

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax and differences:

-- Connect to database
\c sample_hr;

-- Note: PostgreSQL supports all the same window functions as MySQL
-- Key differences are in date functions and string formatting

-- Date formatting differences:
-- MySQL: DATE_FORMAT(hire_date, '%Y-%m')
-- PostgreSQL: TO_CHAR(hire_date, 'YYYY-MM')

-- Date difference:
-- MySQL: DATEDIFF(date1, date2)
-- PostgreSQL: date1 - date2 (returns interval) or EXTRACT(DAY FROM date1 - date2)

-- LEAD/LAG date difference example:
SELECT
employee_id,
first_name,
hire_date,
LEAD(first_name) OVER (ORDER BY hire_date) AS next_hire_name,
LEAD(hire_date) OVER (ORDER BY hire_date) AS next_hire_date,
EXTRACT(DAY FROM LEAD(hire_date) OVER (ORDER BY hire_date) - hire_date) AS days_until_next_hire
FROM employee
ORDER BY hire_date;

-- Monthly hiring trends (PostgreSQL version):
SELECT
TO_CHAR(hire_date, 'YYYY-MM') AS hire_month,
EXTRACT(YEAR FROM hire_date) AS hire_year,
EXTRACT(MONTH FROM hire_date) AS hire_month_num,
COUNT(*) AS hires,
SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(hire_date, 'YYYY-MM')) AS cumulative_hires,
ROUND(
AVG(COUNT(*)) OVER (
ORDER BY TO_CHAR(hire_date, 'YYYY-MM') ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
),
1
) AS rolling_12month_avg,
COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY TO_CHAR(hire_date, 'YYYY-MM')) AS month_over_month_change,
ROUND(
100.0 * (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY TO_CHAR(hire_date, 'YYYY-MM'))) /
NULLIF(LAG(COUNT(*)) OVER (ORDER BY TO_CHAR(hire_date, 'YYYY-MM')), 0),
1
) AS mom_growth_pct
FROM employee
GROUP BY TO_CHAR(hire_date, 'YYYY-MM'), EXTRACT(YEAR FROM hire_date), EXTRACT(MONTH FROM hire_date)
ORDER BY hire_month;

-- Gaps analysis (PostgreSQL date difference):
WITH activity_gaps AS (
SELECT
emp_id,
activity_date,
LEAD(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date) AS next_activity,
EXTRACT(DAY FROM LEAD(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date) - activity_date) AS days_between
FROM employee_activity
)
SELECT
emp_id,
activity_date,
next_activity,
days_between,
CASE
WHEN days_between > 2 THEN 'Large Gap (>2 days)'
WHEN days_between > 1 THEN 'Small Gap (2 days)'
ELSE 'Consecutive'
END AS gap_category
FROM activity_gaps
WHERE next_activity IS NOT NULL
ORDER BY emp_id, activity_date;

-- Islands analysis (PostgreSQL date difference):
WITH island_markers AS (
SELECT
emp_id,
activity_date,
EXTRACT(DAY FROM activity_date - LAG(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date)) AS days_diff
FROM employee_activity
),
islands AS (
SELECT
emp_id,
activity_date,
SUM(CASE WHEN days_diff > 1 OR days_diff IS NULL THEN 1 ELSE 0 END)
OVER (PARTITION BY emp_id ORDER BY activity_date) AS island_id
FROM island_markers
)
SELECT
emp_id,
island_id,
MIN(activity_date) AS island_start,
MAX(activity_date) AS island_end,
COUNT(*) AS activity_days,
EXTRACT(DAY FROM MAX(activity_date) - MIN(activity_date)) + 1 AS total_days,
SUM(hours_logged) AS total_hours
FROM islands i
JOIN employee_activity ea ON i.emp_id = ea.emp_id AND i.activity_date = ea.activity_date
GROUP BY emp_id, island_id
ORDER BY emp_id, island_start;

-- PostgreSQL Notes:
-- - Same window function syntax as MySQL
-- - DATE_FORMAT() → TO_CHAR()
-- - DATEDIFF() → EXTRACT(DAY FROM date1 - date2)
-- - Use \c to connect to database
-- - INTERVAL operations: date + INTERVAL '1 day'
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax and differences:

-- Use database
USE sample_hr;

-- Note: SQL Server supports all the same window functions
-- Key differences in date functions and some syntax

-- Date formatting differences:
-- MySQL: DATE_FORMAT(hire_date, '%Y-%m')
-- SQL Server: FORMAT(hire_date, 'yyyy-MM') or CONVERT(VARCHAR(7), hire_date, 120)

-- Date difference:
-- MySQL: DATEDIFF(date1, date2)
-- SQL Server: DATEDIFF(DAY, date2, date1)

-- LEAD/LAG date difference example:
SELECT
employee_id,
first_name,
hire_date,
LEAD(first_name) OVER (ORDER BY hire_date) AS next_hire_name,
LEAD(hire_date) OVER (ORDER BY hire_date) AS next_hire_date,
DATEDIFF(DAY, hire_date, LEAD(hire_date) OVER (ORDER BY hire_date)) AS days_until_next_hire
FROM employee
ORDER BY hire_date;

-- Monthly hiring trends (SQL Server version):
SELECT
FORMAT(hire_date, 'yyyy-MM') AS hire_month,
YEAR(hire_date) AS hire_year,
MONTH(hire_date) AS hire_month_num,
COUNT(*) AS hires,
SUM(COUNT(*)) OVER (ORDER BY FORMAT(hire_date, 'yyyy-MM')) AS cumulative_hires,
ROUND(
AVG(COUNT(*)) OVER (
ORDER BY FORMAT(hire_date, 'yyyy-MM') ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
),
1
) AS rolling_12month_avg,
COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY FORMAT(hire_date, 'yyyy-MM')) AS month_over_month_change,
ROUND(
100.0 * (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY FORMAT(hire_date, 'yyyy-MM'))) /
NULLIF(LAG(COUNT(*)) OVER (ORDER BY FORMAT(hire_date, 'yyyy-MM')), 0),
1
) AS mom_growth_pct
FROM employee
GROUP BY FORMAT(hire_date, 'yyyy-MM'), YEAR(hire_date), MONTH(hire_date)
ORDER BY hire_month;

-- Gaps analysis (SQL Server date difference):
WITH activity_gaps AS (
SELECT
emp_id,
activity_date,
LEAD(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date) AS next_activity,
DATEDIFF(DAY, activity_date, LEAD(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date)) AS days_between
FROM employee_activity
)
SELECT
emp_id,
activity_date,
next_activity,
days_between,
CASE
WHEN days_between > 2 THEN 'Large Gap (>2 days)'
WHEN days_between > 1 THEN 'Small Gap (2 days)'
ELSE 'Consecutive'
END AS gap_category
FROM activity_gaps
WHERE next_activity IS NOT NULL
ORDER BY emp_id, activity_date;

-- Islands analysis (SQL Server date difference):
WITH island_markers AS (
SELECT
emp_id,
activity_date,
DATEDIFF(DAY, LAG(activity_date) OVER (PARTITION BY emp_id ORDER BY activity_date), activity_date) AS days_diff
FROM employee_activity
),
islands AS (
SELECT
emp_id,
activity_date,
SUM(CASE WHEN days_diff > 1 OR days_diff IS NULL THEN 1 ELSE 0 END)
OVER (PARTITION BY emp_id ORDER BY activity_date) AS island_id
FROM island_markers
)
SELECT
emp_id,
island_id,
MIN(activity_date) AS island_start,
MAX(activity_date) AS island_end,
COUNT(*) AS activity_days,
DATEDIFF(DAY, MIN(activity_date), MAX(activity_date)) + 1 AS total_days,
SUM(hours_logged) AS total_hours
FROM islands i
JOIN employee_activity ea ON i.emp_id = ea.emp_id AND i.activity_date = ea.activity_date
GROUP BY emp_id, island_id
ORDER BY emp_id, island_start;

-- SQL Server Notes:
-- - Same window function syntax as MySQL
-- - DATE_FORMAT() → FORMAT() or CONVERT()
-- - DATEDIFF() has different parameter order: DATEDIFF(unit, start_date, end_date)
-- - Same USE syntax as MySQL
-- - DATEADD() for date arithmetic: DATEADD(DAY, 1, date)
-- - GETDATE() instead of NOW()
*/