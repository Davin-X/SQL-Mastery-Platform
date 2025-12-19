# Problem 01: Basic INNER JOIN - Employee Department Information

## Business Context
As an HR analyst, you need to generate a report showing employee names along with their department information. This is a fundamental report that helps management understand team composition across departments.

## Requirements
Write a SQL query to display each employee's full name (first_name + last_name) and their department name. Only include employees who are currently assigned to a department.

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
| employee_name    | department_name |
|------------------|-----------------|
| John Doe        | Administration |
| Jane Smith      | Administration |
| Michael Johnson | Sales          |

## Notes
- Use INNER JOIN to combine employee and department tables
- Concatenate first_name and last_name with a space
- Order results by employee_name for consistent output
- Only employees with valid dept_id should appear (INNER JOIN behavior)

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY employee_name;
```

## Alternative Solution (Using JOIN keyword)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
ORDER BY employee_name;
```

## Performance Notes
- INNER JOIN is the most efficient for this requirement
- Ensure proper indexing on dept_id columns
- CONCAT function performance varies by database (MySQL, PostgreSQL, SQL Server)
