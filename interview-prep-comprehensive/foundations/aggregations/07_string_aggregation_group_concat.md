# Problem 07: String Aggregation (GROUP_CONCAT) - Employee Lists by Department

## Business Context
Management needs a quick reference showing all employees in each department as a comma-separated list. This is useful for organizational charts, email distributions, and reporting.

## Requirements
Write a SQL query to show each department with a comma-separated list of all employee names.

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
(3, 'HR');

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

## Expected Output
| department_name | employee_list              |
|-----------------|----------------------------|
| HR             | Diana Evans               |
| IT             | Jane Smith, John Doe      |
| Sales          | Alice Brown, Bob Wilson, Charlie Davis |

## Notes
- Use string aggregation to concatenate employee names
- Order employees alphabetically within each department
- Handle single employees (no trailing comma)

## Solution (PostgreSQL - Using STRING_AGG)
```sql
SELECT 
    d.dept_name AS department_name,
    STRING_AGG(
        CONCAT(e.first_name, ' ', e.last_name), 
        ', ' ORDER BY e.last_name, e.first_name
    ) AS employee_list
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## MySQL Alternative (Using GROUP_CONCAT)
```sql
SELECT 
    d.dept_name AS department_name,
    GROUP_CONCAT(
        CONCAT(e.first_name, ' ', e.last_name) 
        ORDER BY e.last_name, e.first_name 
        SEPARATOR ', '
    ) AS employee_list
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## SQL Server Alternative (Using STRING_AGG)
```sql
SELECT 
    d.dept_name AS department_name,
    STRING_AGG(
        CONCAT(e.first_name, ' ', e.last_name), 
        ', '
    ) WITHIN GROUP (ORDER BY e.last_name, e.first_name) AS employee_list
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) > 0
ORDER BY d.dept_name;
```

## Key Learning Points
- String aggregation combines multiple rows into one string
- ORDER BY within aggregation controls the sequence
- Database-specific functions (STRING_AGG, GROUP_CONCAT)
- Useful for creating summary lists and reports

## Common Applications
- Email distribution lists
- Report summaries
- Category listings
- Hierarchical displays

## Performance Notes
- String aggregation can be memory-intensive for large groups
- ORDER BY within aggregation may require sorting
- Consider length limits for concatenated strings
- Efficient for small to medium-sized groups

## Extension Challenge
Create a hierarchical employee list showing managers and their direct reports.
