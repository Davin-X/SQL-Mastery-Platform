# Problem 10: Statistical Aggregations - Salary Percentiles and Distribution

## Business Context
Compensation analysts need to understand salary distribution patterns to ensure competitive pay and identify outliers. This involves calculating percentiles, standard deviations, and distribution metrics.

## Requirements
Create a salary distribution analysis showing key statistical measures: minimum, maximum, median (50th percentile), quartiles (25th and 75th percentiles), and interquartile range.

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
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary) VALUES
(1, 'John', 'Doe', 1, 75000.00),
(2, 'Jane', 'Smith', 1, 80000.00),
(3, 'Bob', 'Wilson', 1, 72000.00),
(4, 'Alice', 'Brown', 1, 85000.00),
(5, 'Charlie', 'Davis', 1, 78000.00),
(6, 'Diana', 'Evans', 2, 65000.00),
(7, 'Eve', 'Foster', 2, 75000.00),
(8, 'Frank', 'Garcia', 2, 72000.00),
(9, 'Grace', 'Hill', 2, 78000.00),
(10, 'Henry', 'Adams', 2, 70000.00),
(11, 'Ivy', 'Baker', 3, 55000.00),
(12, 'Jack', 'Clark', 3, 60000.00);
```

**employee table:**
| emp_id | first_name | last_name | dept_id | salary    |
|--------|------------|-----------|---------|-----------|
| 1      | John       | Doe       | 1       | 75000.00  |
| 2      | Jane       | Smith     | 1       | 80000.00  |
| 3      | Bob        | Wilson    | 1       | 72000.00  |
| 4      | Alice      | Brown     | 1       | 85000.00  |
| 5      | Charlie    | Davis     | 1       | 78000.00  |
| 6      | Diana      | Evans     | 2       | 65000.00  |
| 7      | Eve        | Foster    | 2       | 75000.00  |
| 8      | Frank      | Garcia    | 2       | 72000.00  |
| 9      | Grace      | Hill      | 2       | 78000.00  |
| 10     | Henry      | Adams     | 2       | 70000.00  |
| 11     | Ivy        | Baker     | 3       | 55000.00  |
| 12     | Jack       | Clark     | 3       | 60000.00  |

## Expected Output
| department_name | employee_count | min_salary | max_salary | median_salary | q1_salary | q3_salary | iqr |
|-----------------|----------------|------------|------------|---------------|-----------|-----------|-----|
| HR             | 2              | 55000.00  | 60000.00  | 57500.00     | 55000.00 | 60000.00 | 5000.00 |
| IT             | 5              | 72000.00  | 85000.00  | 78000.00     | 75000.00 | 80000.00 | 5000.00 |
| Sales          | 5              | 65000.00  | 78000.00  | 72000.00     | 70000.00 | 75000.00 | 5000.00 |

## Notes
- Calculate percentiles for salary distribution analysis
- Show quartiles and interquartile range (IQR)
- IQR = Q3 - Q1 (measures spread of middle 50%)

## Solution (PostgreSQL - Using PERCENTILE functions)
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY e.salary), 2) AS median_salary,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY e.salary), 2) AS q1_salary,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY e.salary), 2) AS q3_salary,
    ROUND(
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY e.salary) - 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY e.salary), 
        2
    ) AS iqr
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## SQL Server Alternative
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    ROUND(
        (SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) 
         FROM employee e2 WHERE e2.dept_id = d.dept_id), 
        2
    ) AS median_salary,
    ROUND(
        (SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) 
         FROM employee e2 WHERE e2.dept_id = d.dept_id), 
        2
    ) AS q1_salary,
    ROUND(
        (SELECT DISTINCT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) 
         FROM employee e2 WHERE e2.dept_id = d.dept_id), 
        2
    ) AS q3_salary,
    ROUND(
        (SELECT DISTINCT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) 
         FROM employee e2 WHERE e2.dept_id = d.dept_id) - 
        (SELECT DISTINCT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) 
         FROM employee e2 WHERE e2.dept_id = d.dept_id), 
        2
    ) AS iqr
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## Key Learning Points
- PERCENTILE functions calculate statistical distributions
- WITHIN GROUP (ORDER BY) specifies the ordering column
- Multiple percentiles can be calculated in one query
- IQR (Interquartile Range) measures data spread

## Common Applications
- Salary distribution analysis
- Performance benchmarking
- Outlier detection
- Compensation planning

## Performance Notes
- Percentile calculations can be expensive on large datasets
- Consider pre-computed statistics for frequently accessed data
- PERCENTILE_CONT gives interpolated results for continuous distributions
- PERCENTILE_DISC gives actual values from the dataset

## Extension Challenge
Identify employees whose salaries are outliers (below Q1 - 1.5*IQR or above Q3 + 1.5*IQR).
