# Problem 01: Basic GROUP BY with COUNT - Department Employee Counts

## Business Context
HR needs a simple report showing how many employees are in each department. This is a fundamental metric for organizational planning and resource allocation.

## Requirements
Write a SQL query to count the number of employees in each department, showing only departments that have employees.

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
(4, 'Marketing');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 1),
(3, 'Bob', 'Wilson', 2),
(4, 'Alice', 'Brown', 2),
(5, 'Charlie', 'Davis', 2),
(6, 'Diana', 'Evans', 3);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 2       |
| 4      | Alice      | Brown     | 2       |
| 5      | Charlie    | Davis     | 2       |
| 6      | Diana      | Evans     | 3       |

**department table:**
| dept_id | dept_name |
|---------|-----------|
| 1       | IT        |
| 2       | Sales     |
| 3       | HR        |
| 4       | Marketing |

## Expected Output
| department_name | employee_count |
|-----------------|----------------|
| HR             | 1              |
| IT             | 2              |
| Sales          | 3              |

## Notes
- Use GROUP BY with department name
- Count employees per department
- Order by department name
- Marketing department (no employees) should not appear

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## Alternative Solution (Using INNER JOIN)
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(*) AS employee_count
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Key Learning Points
- GROUP BY groups rows by specified columns
- Aggregate functions (COUNT) operate on each group
- Non-aggregated columns must appear in GROUP BY
- HAVING filters groups (vs WHERE filters rows)
- INNER JOIN vs LEFT JOIN affects which departments appear

## Common Mistakes
- Forgetting GROUP BY when using aggregate functions
- Using WHERE instead of HAVING for group filtering
- Not including all non-aggregated columns in GROUP BY
- Using COUNT(column) vs COUNT(*) incorrectly

## Performance Notes
- GROUP BY operations can be expensive on large datasets
- Proper indexing on grouped columns improves performance
- COUNT(*) is slightly faster than COUNT(column) when no NULLs
- Consider the difference between INNER JOIN and LEFT JOIN approaches
