# Problem 03: RIGHT JOIN - Department Occupancy Report

## Business Context
Facilities management needs to know which departments have employees and which are vacant. This helps with space planning and resource allocation decisions.

## Requirements
Write a SQL query to show all departments with their employee count. Include departments with no employees, showing 0 for the count.

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
(1, 'Administration'),
(2, 'Sales'),
(3, 'IT');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 1),
(3, 'Michael', 'Johnson', 2);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Michael    | Johnson   | 2       |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | Administration|
| 2       | Sales        |
| 3       | IT           |

## Expected Output
| department_name | employee_count |
|-----------------|----------------|
| Administration | 2              |
| Sales          | 1              |
| IT             | 0              |

## Notes
- Use RIGHT JOIN to include all departments
- Count employees per department
- Handle departments with no employees (NULL count becomes 0)

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM employee e
RIGHT JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Alternative Solution (Using LEFT JOIN)
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_name;
```

## Key Learning Points
- RIGHT JOIN includes all records from right table
- COUNT() on nullable columns gives correct results
- GROUP BY is essential when using aggregate functions
- LEFT JOIN is often preferred over RIGHT JOIN for readability

## Common Mistakes
- Forgetting GROUP BY when using COUNT()
- Using COUNT(*) instead of COUNT(column) - both work here but COUNT(column) is more explicit
- Not including all non-aggregated columns in GROUP BY

## Performance Notes
- RIGHT JOIN and LEFT JOIN have similar performance
- Ensure proper indexing on join columns
- GROUP BY operations can be expensive on large datasets
