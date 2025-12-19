# 13 — Advanced Analytics (percentiles, correlations, distributions)

Problem
- Use NTILE, PERCENT_RANK, and CUME_DIST to analyze salary distributions, identify performance tiers, and calculate statistical measures across departments.

Starter dataset / schema
```sql
-- Use existing employee and department tables from sample_hr
-- ALTER TABLE employee ADD COLUMN performance_score DECIMAL(3,2);
```

**Assumptions:**
- Performance scores follow normal distribution (0.00 to 1.00 scale)
- Focus on departmental vs company-wide comparisons

Questions
1. Create salary quartiles by department and identify top performers
2. Calculate correlation between experience and performance score
3. Find employees in top 10% of salaries across company
4. Use CUME_DIST to show salary percentile rankings
5. Compare median salaries across departments

Hints
- NTILE(4) divides into quartiles; CUME_DIST shows cumulative distribution
- CORR function measures linear relationship between numerical columns
- PERCENT_RANK scales from 0.0 (lowest) to 1.0 (highest)

### Solution
<details><summary>Show solution</summary>

**1. Salary Quartiles with Performance Analysis:**
```sql
SELECT
    dept_name,
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (
        PARTITION BY dept_name
        ORDER BY salary DESC
    ) AS dept_salary_quartile,
    CASE
        WHEN NTILE(4) OVER (
            PARTITION BY dept_name
            ORDER BY salary DESC
        ) = 1 THEN 'Top Performer'
        WHEN NTILE(4) OVER (
            PARTITION BY dept_name
            ORDER BY salary DESC
        ) = 4 THEN 'Entry Level'
        ELSE 'Mid Level'
    END AS performance_tier
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
ORDER BY dept_name, salary DESC;
```

**2. Experience-Performance Correlation:**
```sql
WITH emp_data AS (
    SELECT
        first_name,
        last_name,
        salary,
        TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_experience,
        -- Simulate performance score based on salary and tenure
        CASE
            WHEN salary > 90000 AND TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) > 3 THEN 0.85
            WHEN salary > 70000 AND TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) > 1 THEN 0.75
            ELSE 0.65
        END AS performance_score
    FROM employee
)
SELECT
    CORR(years_experience, performance_score) AS exp_performance_corr,
    CORR(salary, performance_score) AS salary_performance_corr,
    COUNT(*) AS sample_size
FROM emp_data;
```

**3. Top 10% of Salaries Company-Wide:**
```sql
WITH ranked_salaries AS (
    SELECT
        first_name,
        last_name,
        dept_name,
        salary,
        PERCENT_RANK() OVER (ORDER BY salary DESC) AS salary_pct_rank
    FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
)
SELECT *
FROM ranked_salaries
WHERE salary_pct_rank <= 0.1
ORDER BY salary DESC;
```

**4. Cumulative Distribution Analysis:**
```sql
SELECT
    salary,
    COUNT(*) AS employee_count,
    ROUND(100 * CUME_DIST() OVER (ORDER BY salary), 2) AS salary_percentile,
    SUM(COUNT(*)) OVER (ORDER BY salary) AS cumulative_employees,
    ROUND(AVG(salary) OVER (
        ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 0) AS cumulative_avg_salary
FROM employee
GROUP BY salary
ORDER BY salary;
```

**5. Department Median Salary Comparison:**
```sql
SELECT
    dept_name,
    COUNT(*) AS dept_size,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary), 2
    ) AS median_salary,
    ROUND(
        PERCENTILE_CONT(0.75) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary), 2
    ) AS salary_iqr,
    ROUND(STDDEV_POP(salary), 2) AS salary_std_dev
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY dept_name
ORDER BY median_salary DESC;
```

</details>
