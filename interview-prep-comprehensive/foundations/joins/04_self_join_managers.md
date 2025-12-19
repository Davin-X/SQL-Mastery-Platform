# Problem 04: SELF JOIN - Manager-Employee Hierarchy

## Business Context
HR needs an organizational chart showing the reporting structure. Each employee reports to a manager, and we need to show who reports to whom.

## Requirements
Write a SQL query to display each employee's name along with their manager's name. Only include employees who have a manager assigned.

## Sample Data Setup
```sql
-- Create table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employee(emp_id)
);

-- Insert sample data
INSERT INTO employee (emp_id, first_name, last_name, manager_id) VALUES
(1, 'John', 'Doe', NULL),
(2, 'Jane', 'Smith', 1),
(3, 'Michael', 'Johnson', 1),
(4, 'Sarah', 'Williams', 2);
```

**employee table:**
| emp_id | first_name | last_name | manager_id |
|--------|------------|-----------|------------|
| 1      | John       | Doe       | NULL       |
| 2      | Jane       | Smith     | 1          |
| 3      | Michael    | Johnson   | 1          |
| 4      | Sarah      | Williams  | 2          |

## Expected Output
| employee_name    | manager_name |
|------------------|--------------|
| Jane Smith      | John Doe    |
| Michael Johnson | John Doe    |
| Sarah Williams  | Jane Smith  |

## Notes
- Use SELF JOIN to link employee to manager
- Same table joined with itself using different aliases
- Only employees with managers (manager_id IS NOT NULL)

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employee e
INNER JOIN employee m ON e.manager_id = m.emp_id
ORDER BY manager_name, employee_name;
```

## Alternative Solution (Explicit INNER JOIN)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employee e, employee m
WHERE e.manager_id = m.emp_id
ORDER BY manager_name, employee_name;
```

## Key Learning Points
- SELF JOIN is used when a table references itself
- Table aliases (e, m) are crucial for clarity
- Foreign key relationships within the same table
- Common for hierarchical or tree-like data structures

## Common Applications
- Organizational hierarchies
- Category parent-child relationships
- Bill of materials
- Network/graph relationships

## Performance Notes
- SELF JOIN can be expensive on large datasets
- Ensure proper indexing on manager_id
- Consider using CTEs for complex hierarchies
- Avoid deep recursion without proper optimization

## Extension Challenge
Modify the query to show the full management chain (employee → manager → manager's manager)
