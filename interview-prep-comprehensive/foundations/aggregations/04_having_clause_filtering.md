# Problem 04: HAVING Clause - Departments Above Average Size

## Business Context
Management wants to identify large departments for restructuring purposes. They need to find departments that have more employees than the company average.

## Requirements
Write a SQL query to find departments that have more employees than the average number of employees across all departments.

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
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Marketing'),
(5, 'Finance');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 1),
(3, 'Bob', 'Wilson', 1),
(4, 'Alice', 'Brown', 1),
(5, 'Charlie', 'Davis', 2),
(6, 'Diana', 'Evans', 2),
(7, 'Eve', 'Foster', 2),
(8, 'Frank', 'Garcia', 3),
(9, 'Grace', 'Hill', 4);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 1       |
| 4      | Alice      | Brown     | 1       |
| 5      | Charlie    | Davis     | 2       |
| 6      | Diana      | Evans     | 2       |
| 7      | Eve        | Foster    | 2       |
| 8      | Frank      | Garcia    | 3       |
| 9      | Grace      | Hill      | 4       |

## Expected Output
| department_name | employee_count | company_avg |
|-----------------|----------------|-------------|
| IT             | 4              | 1.8         |
| Sales          | 3              | 1.8         |

## Notes
- Calculate company-wide average employees per department
- Use HAVING to filter departments above average
- Compare each department's count to the overall average

## Solution (Using Subquery)
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND((SELECT AVG(dept_count) FROM (
        SELECT COUNT(*) as dept_count 
        FROM employee 
        GROUP BY dept_id
    ) AS dept_counts), 1) AS company_avg
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > (
    SELECT AVG(dept_count) FROM (
        SELECT COUNT(*) as dept_count 
        FROM employee 
        GROUP BY dept_id
    ) AS dept_counts
)
ORDER BY employee_count DESC;
```

## Alternative Solution (Using CTE)
```sql
WITH dept_stats AS (
    SELECT 
        dept_id,
        COUNT(*) as emp_count
    FROM employee 
    GROUP BY dept_id
),
company_avg AS (
    SELECT AVG(emp_count) as avg_count 
    FROM dept_stats
)
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND(ca.avg_count, 1) AS company_avg
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
CROSS JOIN company_avg ca
GROUP BY d.dept_id, d.dept_name, ca.avg_count
HAVING COUNT(e.emp_id) > ca.avg_count
ORDER BY employee_count DESC;
```

## Key Learning Points
- HAVING filters groups after aggregation
- Subqueries can calculate values for comparison
- CTEs provide cleaner multi-step calculations
- Aggregate functions can reference other aggregates

## Common HAVING Patterns
- Filter by count thresholds
- Compare to averages or percentiles
- Find outliers in grouped data
- Quality control on aggregated results

## Performance Considerations
- HAVING is applied after GROUP BY
- Subqueries in HAVING may execute multiple times
- Consider pre-calculating values in CTEs
- HAVING vs WHERE choice affects performance

## Extension Challenge
Find departments with employee counts in the top 25% of all departments.
