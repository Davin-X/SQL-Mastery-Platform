# Problem 06: Conditional Aggregation with CASE - Department Salary Bands

## Business Context
HR needs to analyze salary distributions across departments using predefined salary bands. This helps understand compensation patterns and identify departments with different pay structures.

## Requirements
Write a SQL query to count employees in each department by salary bands: Low (< 60000), Medium (60000-80000), High (> 80000).

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
(2, 'Jane', 'Smith', 1, 85000.00),
(3, 'Bob', 'Wilson', 1, 55000.00),
(4, 'Alice', 'Brown', 2, 65000.00),
(5, 'Charlie', 'Davis', 2, 95000.00),
(6, 'Diana', 'Evans', 2, 72000.00),
(7, 'Eve', 'Foster', 3, 58000.00),
(8, 'Frank', 'Garcia', 3, 62000.00);
```

**employee table:**
| emp_id | first_name | last_name | dept_id | salary    |
|--------|------------|-----------|---------|-----------|
| 1      | John       | Doe       | 1       | 75000.00  |
| 2      | Jane       | Smith     | 1       | 85000.00  |
| 3      | Bob        | Wilson    | 1       | 55000.00  |
| 4      | Alice      | Brown     | 2       | 65000.00  |
| 5      | Charlie    | Davis     | 2       | 95000.00  |
| 6      | Diana      | Evans     | 2       | 72000.00  |
| 7      | Eve        | Foster    | 3       | 58000.00  |
| 8      | Frank      | Garcia    | 3       | 62000.00  |

## Expected Output
| department_name | low_salary_count | medium_salary_count | high_salary_count |
|-----------------|------------------|---------------------|-------------------|
| HR             | 1                | 1                   | 0                 |
| IT             | 1                | 1                   | 1                 |
| Sales          | 0                | 2                   | 1                 |

## Notes
- Use CASE statements within aggregate functions
- Create salary bands with conditional counting
- SUM(CASE WHEN...) pattern for conditional aggregation

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    SUM(CASE WHEN e.salary < 60000 THEN 1 ELSE 0 END) AS low_salary_count,
    SUM(CASE WHEN e.salary BETWEEN 60000 AND 80000 THEN 1 ELSE 0 END) AS medium_salary_count,
    SUM(CASE WHEN e.salary > 80000 THEN 1 ELSE 0 END) AS high_salary_count
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Alternative Solution (Using COUNT with CASE)
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(CASE WHEN e.salary < 60000 THEN 1 END) AS low_salary_count,
    COUNT(CASE WHEN e.salary BETWEEN 60000 AND 80000 THEN 1 END) AS medium_salary_count,
    COUNT(CASE WHEN e.salary > 80000 THEN 1 END) AS high_salary_count
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Key Learning Points
- CASE statements can be used inside aggregate functions
- SUM(CASE...) creates conditional counting
- COUNT(CASE...) ignores NULL results from CASE
- Useful for creating crosstab/pivot reports

## Common Applications
- Survey response categorization
- Age group analysis
- Performance band reporting
- Status-based counting

## Performance Notes
- CASE in aggregates is efficient
- Consider indexing on the conditional column
- Multiple CASE statements can be combined
- Good alternative to complex subqueries

## Extension Challenge
Add percentage distribution for each salary band within departments.
