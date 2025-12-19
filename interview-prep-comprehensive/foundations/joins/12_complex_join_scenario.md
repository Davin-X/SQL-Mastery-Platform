# Problem 12: Complex JOIN Scenario - Cross-Department Project Collaboration

## Business Context
Senior management wants to analyze cross-department collaboration patterns. They need to identify projects that involve employees from multiple departments and calculate collaboration metrics.

## Requirements
Write a SQL query to find projects that have employees from at least 2 different departments. Show project details, department count, and employee count per project.

## Sample Data
**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 2       |
| 4      | Alice      | Brown     | 3       |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | IT           |
| 2       | Sales        |
| 3       | Marketing    |

**project table:**
| proj_id | proj_name       | budget    |
|---------|-----------------|-----------|
| 1       | Website Redesign| 100000.00 |
| 2       | Mobile App      | 80000.00  |
| 3       | CRM System      | 120000.00 |

**assignment table:**
| emp_id | proj_id |
|--------|---------|
| 1      | 1       |
| 2      | 1       |
| 3      | 1       |
| 1      | 2       |
| 4      | 2       |
| 2      | 3       |

## Expected Output
| project_name     | department_count | employee_count | total_budget |
|------------------|------------------|----------------|--------------|
| Website Redesign| 3                | 3              | 100000.00   |
| Mobile App      | 2                | 2              | 80000.00    |

## Notes
- Projects with cross-department collaboration
- Use subquery or CTE for department counting
- Filter projects with multiple departments

## Solution (Using Subquery)
```sql
SELECT 
    p.proj_name AS project_name,
    COUNT(DISTINCT e.dept_id) AS department_count,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    p.budget AS total_budget
FROM project p
INNER JOIN assignment a ON p.proj_id = a.proj_id
INNER JOIN employee e ON a.emp_id = e.emp_id
GROUP BY p.proj_id, p.proj_name, p.budget
HAVING COUNT(DISTINCT e.dept_id) >= 2
ORDER BY department_count DESC, p.proj_name;
```

## Alternative Solution (Using CTE)
```sql
WITH project_dept_counts AS (
    SELECT 
        p.proj_id,
        p.proj_name,
        p.budget,
        COUNT(DISTINCT e.dept_id) AS dept_count,
        COUNT(DISTINCT e.emp_id) AS emp_count
    FROM project p
    INNER JOIN assignment a ON p.proj_id = a.proj_id
    INNER JOIN employee e ON a.emp_id = e.emp_id
    GROUP BY p.proj_id, p.proj_name, p.budget
)
SELECT 
    proj_name AS project_name,
    dept_count AS department_count,
    emp_count AS employee_count,
    budget AS total_budget
FROM project_dept_counts
WHERE dept_count >= 2
ORDER BY dept_count DESC, proj_name;
```

## Key Learning Points
- Complex multi-table JOINs with aggregation
- HAVING clause for filtering grouped results
- COUNT(DISTINCT) for unique counts
- Subqueries and CTEs for complex analysis

## Common Applications
- Collaboration analysis
- Cross-functional project identification
- Resource diversity metrics
- Team composition analysis

## Performance Considerations
- Multiple DISTINCT operations can be expensive
- Consider indexing on frequently joined columns
- CTEs vs subqueries performance varies
- GROUP BY with HAVING needs optimization

## Extension Challenge
Calculate collaboration intensity score: (departments × employees) / project budget.
