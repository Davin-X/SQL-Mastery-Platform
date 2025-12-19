# 🎯 Employee Hierarchy with Recursive CTE Interview Question

## Question
Given an employee table with a manager-employee relationship, build the complete organizational hierarchy showing each employee's level in the organization and their reporting path.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(1, 'Alice (CEO)', NULL, 'Executive', 250000.00),
(2, 'Bob (VP)', 1, 'Engineering', 180000.00),
(3, 'Carol (VP)', 1, 'Sales', 175000.00),
(4, 'David (Manager)', 2, 'Engineering', 120000.00),
(5, 'Eve (Manager)', 2, 'Engineering', 115000.00),
(6, 'Frank (Senior)', 4, 'Engineering', 95000.00),
(7, 'Grace (Senior)', 4, 'Engineering', 90000.00),
(8, 'Henry (Junior)', 6, 'Engineering', 75000.00),
(9, 'Ivy (Manager)', 3, 'Sales', 110000.00),
(10, 'Jack (Senior)', 9, 'Sales', 85000.00);
```

## Answer: Complete Hierarchy with Recursive CTE

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Top-level employees (CEO)
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        department,
        salary,
        0 AS hierarchy_level,
        CAST(emp_name AS VARCHAR(1000)) AS reporting_path,
        CAST(emp_id AS VARCHAR(100)) AS path_ids
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: All other employees
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.department,
        e.salary,
        eh.hierarchy_level + 1,
        CONCAT(eh.reporting_path, ' → ', e.emp_name),
        CONCAT(eh.path_ids, ',', CAST(e.emp_id AS VARCHAR(100)))
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT 
    emp_id,
    emp_name,
    manager_id,
    department,
    salary,
    hierarchy_level,
    reporting_path
FROM employee_hierarchy
ORDER BY hierarchy_level, emp_id;
```

**How it works**:
- **Base case**: Starts with CEO (manager_id IS NULL)
- **Recursive case**: Finds all direct reports of current level employees
- **Path tracking**: Builds both name path and ID path for navigation
- **Termination**: Recursion stops when no more reports are found

## Alternative: Finding Direct Reports Count

```sql
WITH RECURSIVE hierarchy AS (
    SELECT emp_id, emp_name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT e.emp_id, e.emp_name, e.manager_id, h.level + 1
    FROM employees e
    JOIN hierarchy h ON e.manager_id = h.emp_id
)
SELECT 
    h.emp_name,
    h.level,
    COUNT(e.emp_id) AS direct_reports,
    GROUP_CONCAT(e.emp_name ORDER BY e.emp_name) AS direct_report_names
FROM hierarchy h
LEFT JOIN employees e ON h.emp_id = e.manager_id
GROUP BY h.emp_id, h.emp_name, h.level
ORDER BY h.level, h.emp_name;
```

**How it works**: Counts direct reports for each manager in the hierarchy.

## Alternative: Subordinate Count (Total under each manager)

```sql
WITH RECURSIVE subordinates AS (
    SELECT emp_id, manager_id, emp_name
    FROM employees
    
    UNION ALL
    
    SELECT s.emp_id, e.manager_id, s.emp_name
    FROM subordinates s
    JOIN employees e ON s.manager_id = e.emp_id
),
subordinate_counts AS (
    SELECT 
        manager_id,
        COUNT(*) AS total_subordinates
    FROM subordinates
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT 
    e.emp_name,
    COALESCE(sc.total_subordinates, 0) AS total_subordinates
FROM employees e
LEFT JOIN subordinate_counts sc ON e.emp_id = sc.manager_id
ORDER BY total_subordinates DESC;
```

**How it works**: Recursively builds all subordinate relationships, then counts total reports under each manager.

## Performance Considerations

- **Recursion Depth**: Most databases limit recursion depth (MySQL: 1000, others vary)
- **Large Hierarchies**: Consider iterative approaches for very deep org charts
- **Indexing**: Index on manager_id is crucial for performance
- **Memory Usage**: Recursive CTEs can consume significant memory

## Common Issues

1. **Infinite Loops**: Can occur with circular references
2. **Depth Limits**: Database-specific recursion limits
3. **Performance**: Slow on very large hierarchies
4. **Memory**: Can consume significant resources


- **Explain recursion**: "CTE calls itself until condition is met"
- **Base vs recursive**: Distinguish starting case from continuation
- **Termination**: Explain how recursion naturally ends
- **Alternatives**: Consider when iterative approaches are better
- **Performance**: Mention limitations and optimization strategies


- **Organizational Charts**: Building company hierarchy views
- **Approval Workflows**: Finding escalation paths
- **Permission Systems**: Role inheritance hierarchies
- **Project Management**: Task dependency chains
- **Category Trees**: Product catalog hierarchies

## MySQL-Specific Notes

- **Recursion Limit**: Default 1000, adjustable with `cte_max_recursion_depth`
- **Path Concatenation**: Use CONCAT() instead of string concatenation operator
- **Performance**: Consider adjacency list approaches for large datasets

## Alternative Approaches

### Adjacency List with Loops (for small hierarchies):
```sql
-- Not recommended for large datasets
SELECT * FROM employees ORDER BY 
    CASE WHEN manager_id IS NULL THEN emp_id ELSE manager_id END,
    manager_id;
```

### Nested Sets (for complex hierarchies):
```sql
-- More complex setup but better performance for reads
-- Requires additional columns: left_bound, right_bound
```

### Path Enumeration:
```sql
-- Store full path in each row
-- Fast reads, slow updates, denormalized approach
```
