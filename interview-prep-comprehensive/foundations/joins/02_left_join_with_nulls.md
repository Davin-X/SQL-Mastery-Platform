# Problem 02: LEFT JOIN with NULL Handling - All Employees Report

## Business Context
HR needs a complete employee roster that includes everyone, even employees who haven't been assigned to a department yet. This helps identify new hires who need department assignments.

## Requirements
Write a SQL query to display all employees with their department information. Include employees without department assignments, showing "Not Assigned" for their department name.

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
(2, 'Sales');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', NULL),
(3, 'Michael', 'Johnson', 2);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | NULL    |
| 3      | Michael    | Johnson   | 2       |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | Administration|
| 2       | Sales        |

## Expected Output
| employee_name    | department_name |
|------------------|-----------------|
| John Doe        | Administration |
| Jane Smith      | Not Assigned   |
| Michael Johnson | Sales          |

## Notes
- Use LEFT JOIN to include all employees
- Handle NULL department names with COALESCE or IFNULL
- This is a common pattern for "master-detail" relationships

## Solution (MySQL)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COALESCE(d.dept_name, 'Not Assigned') AS department_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
ORDER BY employee_name;
```

## Alternative Solution (Using IFNULL)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    IFNULL(d.dept_name, 'Not Assigned') AS department_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
ORDER BY employee_name;
```

## PostgreSQL Version
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(d.dept_name, 'Not Assigned') AS department_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
ORDER BY employee_name;
```

## Key Learning Points
- LEFT JOIN includes all records from left table
- NULL handling is crucial in JOIN operations
- COALESCE works across databases, IFNULL is MySQL-specific
- String concatenation syntax varies by database

## Performance Notes
- LEFT JOIN can be less efficient than INNER JOIN
- Consider indexing strategy for dept_id
- COALESCE has minimal performance impact
