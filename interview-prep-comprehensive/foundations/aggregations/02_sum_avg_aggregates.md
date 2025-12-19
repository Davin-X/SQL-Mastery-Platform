# Problem 02: SUM and AVG Aggregate Functions - Department Salary Analysis

## Business Context
Finance needs to analyze salary distributions across departments to understand compensation costs and budget planning. This includes total salaries and average salaries per department.

## Requirements
Write a SQL query to calculate the total salary and average salary for each department that has employees.

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
(3, 'Bob', 'Wilson', 2, 65000.00),
(4, 'Alice', 'Brown', 2, 70000.00),
(5, 'Charlie', 'Davis', 2, 72000.00),
(6, 'Diana', 'Evans', 3, 55000.00);
```

**employee table:**
| emp_id | first_name | last_name | dept_id | salary    |
|--------|------------|-----------|---------|-----------|
| 1      | John       | Doe       | 1       | 75000.00  |
| 2      | Jane       | Smith     | 1       | 80000.00  |
| 3      | Bob        | Wilson    | 2       | 65000.00  |
| 4      | Alice      | Brown     | 2       | 70000.00  |
| 5      | Charlie    | Davis     | 2       | 72000.00  |
| 6      | Diana      | Evans     | 3       | 55000.00  |

## Expected Output
| department_name | total_salary | avg_salary  |
|-----------------|--------------|-------------|
| HR             | 55000.00    | 55000.00   |
| IT             | 155000.00   | 77500.00   |
| Sales          | 207000.00   | 69000.00   |

## Notes
- Calculate both SUM and AVG of salaries
- Group by department
- Round averages to 2 decimal places
- Order by department name

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    SUM(e.salary) AS total_salary,
    ROUND(AVG(e.salary), 2) AS avg_salary
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Alternative Solution (Using CAST for rounding)
```sql
SELECT 
    d.dept_name AS department_name,
    SUM(e.salary) AS total_salary,
    CAST(AVG(e.salary) AS DECIMAL(10, 2)) AS avg_salary
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Key Learning Points
- SUM adds all values in a group
- AVG calculates the arithmetic mean
- ROUND function for decimal precision
- Multiple aggregate functions in same query
- All aggregate functions ignore NULL values

## Common Aggregate Functions
- **COUNT()**: Count rows or non-null values
- **SUM()**: Sum of numeric values
- **AVG()**: Average of numeric values
- **MIN()**: Minimum value
- **MAX()**: Maximum value

## Performance Notes
- Aggregate functions are generally efficient
- ROUND operations have minimal performance impact
- Consider data types when using SUM (overflow risk)
- AVG requires division, slightly more expensive than SUM

## Extension Challenge
Add employee count and calculate salary ranges (MAX - MIN) per department.
