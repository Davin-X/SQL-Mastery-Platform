# Problem 03: MIN and MAX Functions - Salary Ranges by Department

## Business Context
HR wants to understand salary ranges within each department to identify compensation disparities and ensure fair pay practices. This helps with salary planning and equity analysis.

## Requirements
Write a SQL query to find the minimum and maximum salaries for each department, along with the salary range (difference between max and min).

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
(4, 'Alice', 'Brown', 2, 65000.00),
(5, 'Charlie', 'Davis', 2, 75000.00),
(6, 'Diana', 'Evans', 3, 55000.00);
```

**employee table:**
| emp_id | first_name | last_name | dept_id | salary    |
|--------|------------|-----------|---------|-----------|
| 1      | John       | Doe       | 1       | 75000.00  |
| 2      | Jane       | Smith     | 1       | 80000.00  |
| 3      | Bob        | Wilson    | 1       | 72000.00  |
| 4      | Alice      | Brown     | 2       | 65000.00  |
| 5      | Charlie    | Davis     | 2       | 75000.00  |
| 6      | Diana      | Evans     | 3       | 55000.00  |

## Expected Output
| department_name | min_salary  | max_salary  | salary_range |
|-----------------|-------------|-------------|--------------|
| HR             | 55000.00   | 55000.00   | 0.00        |
| IT             | 72000.00   | 80000.00   | 8000.00     |
| Sales          | 65000.00   | 75000.00   | 10000.00    |

## Notes
- Use MIN and MAX functions
- Calculate range as MAX - MIN
- Handle departments with single employee (range = 0)

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    MAX(e.salary) - MIN(e.salary) AS salary_range
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Key Learning Points
- MIN returns the smallest value in a group
- MAX returns the largest value in a group
- Can perform arithmetic on aggregate results
- Useful for range analysis and outlier detection

## Common Applications
- Price ranges in e-commerce
- Age ranges in demographics
- Performance ranges in analytics
- Geographic boundaries

## Performance Notes
- MIN/MAX are very efficient (can use indexes)
- Arithmetic on aggregates is computed after grouping
- Consider indexing on the aggregated column for better performance

## Extension Challenge
Add employee names for the highest and lowest paid in each department.
