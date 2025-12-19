# Problem 09: JOIN with Aggregation - Department Project Summary

## Business Context
Management needs a summary report showing how many employees from each department are working on each project. This helps understand resource distribution across projects.

## Requirements
Write a SQL query to show department names, project names, and the count of employees from each department working on each project.

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

**project table:**
| proj_id | proj_name       |
|---------|-----------------|
| 1       | Website Redesign|
| 2       | Mobile App      |

**assignment table:**
| emp_id | proj_id |
|--------|---------|
| 1      | 1       |
| 2      | 1       |
| 1      | 2       |
| 3      | 2       |

## Expected Output
| department_name | project_name     | employee_count |
|-----------------|------------------|----------------|
| IT             | Website Redesign| 2              |
| IT             | Mobile App      | 1              |
| Sales          | Mobile App      | 1              |

## Notes
- Combine JOINs with GROUP BY and COUNT
- Group by department and project
- Count distinct employees per group

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    p.proj_name AS project_name,
    COUNT(DISTINCT e.emp_id) AS employee_count
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_name, p.proj_name, d.dept_id, p.proj_id
ORDER BY d.dept_name, p.proj_name;
```

## Alternative Solution (Simplified GROUP BY)
```sql
SELECT 
    d.dept_name AS department_name,
    p.proj_name AS project_name,
    COUNT(*) AS employee_count
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
INNER JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name, p.proj_id, p.proj_name
ORDER BY d.dept_name, p.proj_name;
```

## Key Learning Points
- JOINs work seamlessly with aggregation functions
- GROUP BY must include all non-aggregated columns
- COUNT(DISTINCT) vs COUNT(*) behavior
- Multi-table aggregations require careful column selection

## Common Patterns
- Resource allocation reports
- Department productivity analysis
- Project staffing summaries
- Cross-functional team analysis

## Performance Notes
- GROUP BY operations can be expensive
- Ensure proper indexing on join columns
- Consider if DISTINCT is necessary in COUNT
- Aggregation after JOINs can reduce result set size

## Extension Challenge
Add project budget and calculate cost per department contribution.
