# Problem 09: Complex Aggregations with CTEs - Department Performance Metrics

## Business Context
Executives need a comprehensive performance dashboard showing department metrics including headcount, salary costs, productivity indicators, and comparative rankings. This requires multiple levels of aggregation and calculations.

## Requirements
Create a department performance report showing headcount, total salary, average salary, department ranking by salary cost, and percentage of total company salary.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Finance');

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary, hire_date) VALUES
(1, 'John', 'Doe', 1, 75000.00, '2020-01-15'),
(2, 'Jane', 'Smith', 1, 80000.00, '2019-03-20'),
(3, 'Bob', 'Wilson', 1, 72000.00, '2021-06-10'),
(4, 'Alice', 'Brown', 2, 65000.00, '2018-11-05'),
(5, 'Charlie', 'Davis', 2, 75000.00, '2020-08-15'),
(6, 'Diana', 'Evans', 2, 72000.00, '2019-12-01'),
(7, 'Eve', 'Foster', 3, 55000.00, '2022-02-20'),
(8, 'Frank', 'Garcia', 4, 85000.00, '2017-09-10');
```

**employee table:**
| emp_id | first_name | last_name | dept_id | salary    | hire_date |
|--------|------------|-----------|---------|-----------|-----------|
| 1      | John       | Doe       | 1       | 75000.00  | 2020-01-15|
| 2      | Jane       | Smith     | 1       | 80000.00  | 2019-03-20|
| 3      | Bob        | Wilson    | 1       | 72000.00  | 2021-06-10|
| 4      | Alice      | Brown     | 2       | 65000.00  | 2018-11-05|
| 5      | Charlie    | Davis     | 2       | 75000.00  | 2020-08-15|
| 6      | Diana      | Evans     | 2       | 72000.00  | 2019-12-01|
| 7      | Eve        | Foster    | 3       | 55000.00  | 2022-02-20|
| 8      | Frank      | Garcia    | 4       | 85000.00  | 2017-09-10|

## Expected Output
| department_name | headcount | total_salary | avg_salary | salary_rank | pct_of_total |
|-----------------|-----------|--------------|------------|-------------|--------------|
| Sales          | 3         | 212000.00   | 70666.67  | 1           | 32.8        |
| IT             | 3         | 227000.00   | 75666.67  | 2           | 35.1        |
| Finance       | 1         | 85000.00    | 85000.00   | 3           | 13.1        |
| HR             | 1         | 55000.00    | 55000.00   | 4           | 8.5         |

## Notes
- Calculate department metrics and company totals
- Rank departments by total salary cost
- Show percentage of total company salary
- Use CTEs for complex multi-step calculations

## Solution (Using CTEs)
```sql
WITH dept_metrics AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        COUNT(e.emp_id) AS headcount,
        SUM(e.salary) AS total_salary,
        ROUND(AVG(e.salary), 2) AS avg_salary
    FROM department d
    LEFT JOIN employee e ON d.dept_id = e.dept_id
    GROUP BY d.dept_id, d.dept_name
    HAVING COUNT(e.emp_id) > 0
),
company_total AS (
    SELECT SUM(total_salary) AS total_company_salary
    FROM dept_metrics
),
ranked_depts AS (
    SELECT 
        dm.*,
        RANK() OVER (ORDER BY dm.total_salary DESC) AS salary_rank,
        ROUND(
            (dm.total_salary * 100.0 / ct.total_company_salary), 
            1
        ) AS pct_of_total
    FROM dept_metrics dm
    CROSS JOIN company_total ct
)
SELECT 
    dept_name AS department_name,
    headcount,
    total_salary,
    avg_salary,
    salary_rank,
    pct_of_total
FROM ranked_depts
ORDER BY salary_rank;
```

## Key Learning Points
- CTEs enable complex multi-step aggregations
- Window functions (RANK) work with grouped data
- Cross joins useful for adding totals to all rows
- Multiple CTEs can reference each other

## Common Applications
- Executive dashboards
- Performance reporting
- Comparative analysis
- KPI calculations

## Performance Notes
- Multiple CTEs can be optimized by the query planner
- Window functions add computational overhead
- Consider materializing complex CTEs as temp tables for large datasets
- CROSS JOIN with single-row CTE is efficient

## Extension Challenge
Add tenure analysis (average years of service) and correlate with salary rankings.
