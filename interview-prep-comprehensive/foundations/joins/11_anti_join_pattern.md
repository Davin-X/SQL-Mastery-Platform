# Problem 11: Anti-JOIN Pattern - Unassigned Employees

## Business Context
HR needs to identify employees who are not currently assigned to any projects. This helps with resource planning and identifying available staff for new initiatives.

## Requirements
Write a SQL query to find all employees who have no project assignments. Show their names and departments.

## Sample Data
**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 2       |

**department table:**
| dept_id | dept_name |
|---------|-----------|
| 1       | IT        |
| 2       | Sales     |

**assignment table:**
| emp_id | proj_id |
|--------|---------|
| 1      | 1       |
| 2      | 1       |

## Expected Output
| employee_name | department_name |
|---------------|-----------------|
| Bob Wilson   | Sales          |

## Notes
- Use LEFT JOIN with IS NULL to find non-matches
- This is an "anti-join" pattern
- Alternative to NOT IN or NOT EXISTS

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
LEFT JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE a.emp_id IS NULL
ORDER BY e.last_name;
```

## Alternative Solutions

**Using NOT EXISTS:**
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE NOT EXISTS (
    SELECT 1 FROM assignment a WHERE a.emp_id = e.emp_id
)
ORDER BY e.last_name;
```

**Using NOT IN:**
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.emp_id NOT IN (
    SELECT DISTINCT emp_id FROM assignment WHERE emp_id IS NOT NULL
)
ORDER BY e.last_name;
```

## Key Learning Points
- LEFT JOIN + IS NULL finds non-matching records
- Anti-join pattern is powerful for exclusion queries
- Multiple ways to achieve the same result
- Performance characteristics vary by approach

## Common Applications
- Finding unused resources
- Identifying gaps in assignments
- Data validation and cleanup
- Exception reporting

## Performance Notes
- LEFT JOIN + IS NULL can be efficient with proper indexing
- NOT EXISTS often performs well with correlated subqueries
- NOT IN can be slow with NULL values in the list
- Test different approaches on your specific data

## Extension Challenge
Find departments that have no employees assigned to any projects (departments with all unassigned employees).
