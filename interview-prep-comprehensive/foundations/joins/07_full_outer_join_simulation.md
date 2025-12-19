# Problem 07: FULL OUTER JOIN Simulation - Complete Employee-Department Matrix

## Business Context
HR needs a complete matrix showing all employees and all departments, including those without assignments. This helps identify hiring needs and department utilization.

## Requirements
Write a SQL query to show all employees with their departments AND all departments with their employees. Include unmatched records from both sides.

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
(2, 'Sales');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', NULL);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | NULL    |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | IT           |
| 2       | Sales        |

## Expected Output
| employee_name | department_name |
|---------------|-----------------|
| John Doe     | IT             |
| Jane Smith   | NULL           |
| NULL         | Sales          |

## Notes
- MySQL doesn't support FULL OUTER JOIN
- Use UNION of LEFT JOIN and RIGHT JOIN to simulate
- Handle NULL values appropriately

## Solution (FULL OUTER JOIN Simulation)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id

UNION

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
RIGHT JOIN department d ON e.dept_id = d.dept_id
WHERE e.dept_id IS NULL;
```

## Alternative Solution (Using UNION ALL with DISTINCT)
```sql
SELECT DISTINCT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id

UNION

SELECT DISTINCT
    NULL AS employee_name,
    d.dept_name AS department_name
FROM department d
WHERE d.dept_id NOT IN (SELECT DISTINCT dept_id FROM employee WHERE dept_id IS NOT NULL);
```

## PostgreSQL Version (Native FULL OUTER JOIN)
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.dept_name AS department_name
FROM employee e
FULL OUTER JOIN department d ON e.dept_id = d.dept_id;
```

## Key Learning Points
- FULL OUTER JOIN includes all records from both tables
- UNION eliminates duplicates automatically
- Complex to simulate in databases without native support
- Useful for data reconciliation and gap analysis

## Common Applications
- Data migration validation
- Finding orphaned records
- Reconciliation reports
- Complete matrix views

## Performance Notes
- UNION operations can be expensive
- Consider using UNION ALL + DISTINCT if duplicates are possible
- FULL OUTER JOIN is more efficient when natively supported
- Be cautious with large datasets

## Real-World Use Case
```sql
-- Find employees without departments AND departments without employees
SELECT 
    CASE WHEN e.emp_id IS NOT NULL 
         THEN CONCAT(e.first_name, ' ', e.last_name) 
         ELSE 'Department Only' END AS employee_name,
    CASE WHEN d.dept_id IS NOT NULL 
         THEN d.dept_name 
         ELSE 'Unassigned Employee' END AS department_name,
    CASE WHEN e.dept_id IS NULL THEN 'Needs Assignment'
         WHEN d.dept_id IS NULL THEN 'Empty Department'
         ELSE 'Assigned' END AS status
FROM employee e
FULL OUTER JOIN department d ON e.dept_id = d.dept_id;
```
