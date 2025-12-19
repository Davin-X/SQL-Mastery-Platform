# Problem 05: CROSS JOIN - All Possible Combinations

## Business Context
Marketing wants to create targeted email campaigns for all department-employee combinations. They need a matrix of all possible department-employee pairs for campaign planning.

## Requirements
Write a SQL query to show all possible combinations of employees and departments. Each employee should appear with every department.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- Insert sample data
INSERT INTO employee (emp_id, first_name, last_name) VALUES
(1, 'John', 'Doe'),
(2, 'Jane', 'Smith');

INSERT INTO department (dept_id, dept_name) VALUES
(1, 'Administration'),
(2, 'Sales');
```

**employee table:**
| emp_id | first_name | last_name |
|--------|------------|-----------|
| 1      | John       | Doe       |
| 2      | Jane       | Smith     |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | Administration|
| 2       | Sales        |

## Expected Output
| employee_name | department_name |
|---------------|-----------------|
| John Doe     | Administration |
| John Doe     | Sales          |
| Jane Smith   | Administration |
| Jane Smith   | Sales          |

## Notes
- CROSS JOIN creates Cartesian product
- Result has rows = employees × departments
- Useful for generating all possible combinations

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
CROSS JOIN department d
ORDER BY employee_name, department_name;
```

## Alternative Solution (Implicit CROSS JOIN)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e, department d
ORDER BY employee_name, department_name;
```

## Key Learning Points
- CROSS JOIN produces Cartesian product
- No ON clause needed
- Result set size = size of first table × size of second table
- Can be expensive on large datasets

## Common Applications
- Generating test data combinations
- Matrix-style reports
- Permutation calculations
- Campaign targeting (as in this example)

## Performance Warnings
- CROSS JOIN can create very large result sets
- Use only when necessary
- Consider WHERE clauses to filter results
- Be cautious with production databases

## Real-World Example
```sql
-- Generate all employee-department combinations for assignment planning
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name,
    'Potential Assignment' AS assignment_type
FROM employee e
CROSS JOIN department d
WHERE e.dept_id != d.dept_id  -- Exclude current assignments
ORDER BY e.last_name, d.dept_name;
```
