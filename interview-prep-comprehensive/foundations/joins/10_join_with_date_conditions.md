# Problem 10: JOIN with Date Conditions - Project Timeline Analysis

## Business Context
Project managers need to track employee assignments on projects that are currently active. This helps with resource planning and deadline management.

## Requirements
Write a SQL query to show employees currently assigned to active projects (projects with no end date or end date in the future).

## Sample Data
**employee table:**
| emp_id | first_name | last_name |
|--------|------------|-----------|
| 1      | John       | Doe       |
| 2      | Jane       | Smith     |

**project table:**
| proj_id | proj_name     | start_date | end_date   | status  |
|---------|---------------|------------|------------|---------|
| 1       | Website       | 2024-01-01 | 2024-06-30 | Active  |
| 2       | Mobile App    | 2024-02-01 | NULL       | Active  |
| 3       | Legacy System | 2023-01-01 | 2024-01-31 | Completed|

**assignment table:**
| emp_id | proj_id | start_date |
|--------|---------|------------|
| 1      | 1       | 2024-01-01 |
| 1      | 2       | 2024-02-01 |
| 2      | 1       | 2024-01-15 |
| 2      | 3       | 2023-06-01 |

## Expected Output
| employee_name | project_name  | project_status | assignment_start |
|---------------|---------------|----------------|------------------|
| John Doe     | Website      | Active        | 2024-01-01      |
| John Doe     | Mobile App   | Active        | 2024-02-01      |
| Jane Smith   | Website      | Active        | 2024-01-15      |

## Notes
- Join with date-based filtering
- Handle NULL end dates (ongoing projects)
- Use CURRENT_DATE or similar for current date

## Solution (MySQL)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    p.proj_name AS project_name,
    p.status AS project_status,
    a.start_date AS assignment_start
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
WHERE p.status = 'Active'
  AND (p.end_date IS NULL OR p.end_date >= CURDATE())
ORDER BY e.last_name, p.start_date;
```

## PostgreSQL Version
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    p.proj_name AS project_name,
    p.status AS project_status,
    a.start_date AS assignment_start
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
WHERE p.status = 'Active'
  AND (p.end_date IS NULL OR p.end_date >= CURRENT_DATE)
ORDER BY e.last_name, p.start_date;
```

## SQL Server Version
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    p.proj_name AS project_name,
    p.status AS project_status,
    a.start_date AS assignment_start
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
WHERE p.status = 'Active'
  AND (p.end_date IS NULL OR p.end_date >= GETDATE())
ORDER BY e.last_name, p.start_date;
```

## Key Learning Points
- Date functions vary by database
- NULL handling in date comparisons
- Combining status and date conditions
- Temporal JOIN conditions

## Common Applications
- Current assignment tracking
- Active project reporting
- Resource availability analysis
- Timeline-based analytics

## Performance Considerations
- Date functions can prevent index usage
- Consider computed columns for status
- Index on date columns when possible
- Query optimization for temporal data

## Extension Challenge
Show employees who are over-allocated (assigned to multiple active projects simultaneously).
