# 🎯 Employee Hierarchy and Reporting Structure Analysis

## Question
Given an employee table with manager relationships, analyze the organizational hierarchy including reporting chains, management levels, and employee distribution across the organization.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    department VARCHAR(30),
    salary DECIMAL(10,2),
    hire_date DATE,
    job_title VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Alice CEO', NULL, 'Executive', 250000.00, '2020-01-01', 'Chief Executive Officer'),
(2, 'Bob CTO', 1, 'Technology', 180000.00, '2020-02-01', 'Chief Technology Officer'),
(3, 'Carol CFO', 1, 'Finance', 175000.00, '2020-03-01', 'Chief Financial Officer'),
(4, 'David VP Eng', 2, 'Engineering', 150000.00, '2021-01-15', 'VP Engineering'),
(5, 'Eve VP Sales', 3, 'Sales', 145000.00, '2021-02-01', 'VP Sales'),
(6, 'Frank Manager', 4, 'Engineering', 120000.00, '2021-06-01', 'Engineering Manager'),
(7, 'Grace Manager', 4, 'Engineering', 115000.00, '2021-07-01', 'DevOps Manager'),
(8, 'Henry Senior', 6, 'Engineering', 95000.00, '2022-01-15', 'Senior Developer'),
(9, 'Ivy Senior', 6, 'Engineering', 90000.00, '2022-02-01', 'Senior Developer'),
(10, 'Jack Analyst', 5, 'Sales', 85000.00, '2022-03-15', 'Sales Analyst'),
(11, 'Kate Rep', 5, 'Sales', 70000.00, '2022-04-01', 'Sales Representative');
```

## Answer: Complete Hierarchy Analysis

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Top-level executives (no manager)
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        department,
        salary,
        job_title,
        0 AS hierarchy_level,
        CAST(emp_name AS VARCHAR(1000)) AS management_chain,
        emp_id AS root_manager
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: All subordinates
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.department,
        e.salary,
        e.job_title,
        eh.hierarchy_level + 1,
        CONCAT(eh.management_chain, ' → ', e.emp_name),
        eh.root_manager
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
),
hierarchy_stats AS (
    SELECT 
        hierarchy_level,
        COUNT(*) AS employees_at_level,
        ROUND(AVG(salary), 2) AS avg_salary_at_level,
        MIN(salary) AS min_salary_at_level,
        MAX(salary) AS max_salary_at_level,
        COUNT(DISTINCT department) AS departments_at_level
    FROM employee_hierarchy
    GROUP BY hierarchy_level
)
SELECT 
    eh.*,
    hs.employees_at_level,
    ROUND((eh.salary / hs.avg_salary_at_level - 1) * 100, 1) AS salary_vs_level_avg_pct
FROM employee_hierarchy eh
JOIN hierarchy_stats hs ON eh.hierarchy_level = hs.hierarchy_level
ORDER BY eh.hierarchy_level, eh.emp_name;
```

**How it works**: 
- Recursive CTE builds complete organizational hierarchy
- Calculates management chains and hierarchy levels
- Provides level-wise statistics and salary comparisons

## Alternative: Direct Report Analysis

```sql
WITH direct_reports AS (
    SELECT 
        manager_id,
        COUNT(*) AS direct_reports_count,
        GROUP_CONCAT(emp_name ORDER BY emp_name) AS direct_reports_list
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
),
management_span AS (
    SELECT 
        e.emp_name AS manager_name,
        e.job_title,
        e.department,
        COALESCE(dr.direct_reports_count, 0) AS direct_reports,
        COALESCE(dr.direct_reports_list, 'No direct reports') AS direct_reports_list
    FROM employees e
    LEFT JOIN direct_reports dr ON e.emp_id = dr.manager_id
)
SELECT 
    manager_name,
    job_title,
    department,
    direct_reports,
    direct_reports_list,
    
    CASE 
        WHEN direct_reports >= 5 THEN 'Large Span of Control'
        WHEN direct_reports >= 3 THEN 'Medium Span of Control'
        WHEN direct_reports >= 1 THEN 'Small Span of Control'
        ELSE 'Individual Contributor'
    END AS management_category
    
FROM management_span
ORDER BY direct_reports DESC, manager_name;
```

**How it works**: Analyzes direct reporting relationships and management span of control.

## Department Hierarchy Analysis

```sql
WITH dept_hierarchy AS (
    SELECT 
        department,
        COUNT(*) AS total_employees,
        AVG(salary) AS avg_salary,
        MIN(salary) AS min_salary,
        MAX(salary) AS max_salary,
        COUNT(DISTINCT manager_id) AS unique_managers
    FROM employees
    GROUP BY department
),
dept_structure AS (
    SELECT 
        dh.*,
        ROW_NUMBER() OVER (ORDER BY total_employees DESC) AS size_rank,
        ROUND(avg_salary, 2) AS avg_salary_formatted,
        ROUND((max_salary - min_salary) / avg_salary * 100, 1) AS salary_range_pct
    FROM dept_hierarchy dh
)
SELECT 
    department,
    total_employees,
    size_rank,
    avg_salary_formatted,
    min_salary,
    max_salary,
    salary_range_pct,
    unique_managers,
    
    CASE 
        WHEN total_employees >= 4 THEN 'Large Department'
        WHEN total_employees >= 2 THEN 'Medium Department'
        ELSE 'Small Department'
    END AS department_size_category
    
FROM dept_structure
ORDER BY size_rank;
```

**How it works**: Analyzes departmental structure, salary distributions, and management distribution.

## Complex Reporting Chain Analysis

```sql
WITH RECURSIVE reporting_chain AS (
    -- Find all possible reporting relationships
    SELECT 
        e1.emp_id AS employee_id,
        e1.emp_name AS employee_name,
        e2.emp_id AS manager_id,
        e2.emp_name AS manager_name,
        1 AS levels_between
    FROM employees e1
    JOIN employees e2 ON e1.manager_id = e2.emp_id
    
    UNION ALL
    
    -- Extend the chain
    SELECT 
        rc.employee_id,
        rc.employee_name,
        e.emp_id,
        e.emp_name,
        rc.levels_between + 1
    FROM reporting_chain rc
    JOIN employees e ON rc.manager_id = e.manager_id
    WHERE rc.levels_between < 10  -- Prevent infinite loops
),
chain_analysis AS (
    SELECT 
        employee_name,
        COUNT(DISTINCT manager_name) AS managers_above,
        MAX(levels_between) AS max_levels_to_ceo,
        GROUP_CONCAT(DISTINCT manager_name ORDER BY levels_between) AS reporting_chain_list
    FROM reporting_chain
    GROUP BY employee_id, employee_name
)
SELECT 
    ca.*,
    e.department,
    e.job_title,
    e.salary,
    
    CASE 
        WHEN max_levels_to_ceo <= 2 THEN 'Senior Leadership'
        WHEN max_levels_to_ceo <= 4 THEN 'Middle Management'
        ELSE 'Individual Contributor'
    END AS organizational_level
    
FROM chain_analysis ca
JOIN employees e ON ca.employee_name = e.emp_name
ORDER BY max_levels_to_ceo, ca.employee_name;
```

**How it works**: Analyzes complete reporting chains and organizational distance from top leadership.

## Interview Tips

- **Recursive CTEs**: Essential for hierarchy traversal
- **Self-joins**: Common for manager-employee relationships
- **Organizational design**: Understanding spans of control
- **Performance**: Recursive queries can be expensive on large hierarchies
- **Business context**: Org charts, reporting structures, succession planning

## Real-World Applications

- **Organizational charts**: Visual representation of company structure
- **Succession planning**: Identifying high-potential employees
- **Compensation analysis**: Salary distributions by level
- **Workforce planning**: Headcount and span of control analysis
- **Change management**: Impact analysis for reorganizations

## Key SQL Concepts Demonstrated

- **Recursive CTEs**: Hierarchy traversal and tree structures
- **Self-joins**: Manager-employee relationships
- **Window functions**: ROW_NUMBER for ranking
- **String aggregation**: GROUP_CONCAT for list creation
- **Complex JOINs**: Multi-level organizational analysis

## Performance Considerations

```sql
-- Indexes for hierarchy queries
CREATE INDEX idx_employees_manager ON employees(manager_id);
CREATE INDEX idx_employees_dept ON employees(department);

-- For large organizations, consider:
-- Materialized views for org structure
-- Denormalized hierarchy tables
-- Caching of frequently accessed chains
```

## Best Practices

1. **Handle cycles**: Prevent infinite recursion in CTEs
2. **Limit depth**: Use MAXRECURSION in SQL Server
3. **Index manager_id**: Critical for JOIN performance
4. **Cache results**: For frequently accessed org data
5. **Validate data**: Ensure no orphaned employees

## Common Hierarchy Patterns

### Finding All Subordinates
```sql
WITH RECURSIVE subordinates AS (
    SELECT emp_id, emp_name, manager_id
    FROM employees
    WHERE emp_id = 2  -- Specific manager
    
    UNION ALL
    
    SELECT e.emp_id, e.emp_name, e.manager_id
    FROM employees e
    JOIN subordinates s ON e.manager_id = s.emp_id
)
SELECT * FROM subordinates;
```

### Finding Management Chain
```sql
WITH RECURSIVE management_chain AS (
    SELECT emp_id, emp_name, manager_id, 1 AS level
    FROM employees
    WHERE emp_id = 8  -- Specific employee
    
    UNION ALL
    
    SELECT e.emp_id, e.emp_name, e.manager_id, mc.level + 1
    FROM employees e
    JOIN management_chain mc ON e.emp_id = mc.manager_id
)
SELECT * FROM management_chain ORDER BY level;
```

### Department Hierarchy
```sql
-- If departments have parent-child relationships
WITH RECURSIVE dept_tree AS (
    SELECT dept_id, dept_name, parent_dept_id, 0 AS level
    FROM departments
    WHERE parent_dept_id IS NULL
    
    UNION ALL
    
    SELECT d.dept_id, d.dept_name, d.parent_dept_id, dt.level + 1
    FROM departments d
    JOIN dept_tree dt ON d.parent_dept_id = dt.dept_id
)
SELECT * FROM dept_tree ORDER BY level, dept_name;
```

## Organizational Metrics

- **Span of Control**: Average direct reports per manager
- **Hierarchy Depth**: Levels from top to bottom
- **Management Density**: Percentage of employees who are managers
- **Salary Compression**: Salary differences between levels
- **Promotion Velocity**: Time between level changes

## Testing Hierarchy Queries

```sql
-- Validate no cycles
SELECT 'Cycle detected!' AS error
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.emp_id
WHERE e1.emp_id = e2.manager_id;

-- Check for orphans
SELECT 'Orphaned employees found!' AS warning
FROM employees
WHERE manager_id IS NOT NULL
AND manager_id NOT IN (SELECT emp_id FROM employees);

-- Verify hierarchy depth
WITH RECURSIVE hierarchy_depth AS (
    SELECT emp_id, 1 AS depth
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.emp_id, hd.depth + 1
    FROM employees e
    JOIN hierarchy_depth hd ON e.manager_id = hd.emp_id
)
SELECT MAX(depth) AS max_hierarchy_depth FROM hierarchy_depth;
```

**Expected Result**: Clean hierarchy validation with no errors or warnings.
