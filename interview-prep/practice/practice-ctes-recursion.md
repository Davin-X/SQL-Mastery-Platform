# 🎯 CTEs & Recursion Practice Collection

## Overview
This consolidated file contains Common Table Expression (CTE) and recursive query techniques from multiple practice scenarios, including hierarchical data processing and row expansion patterns.

---

## 🎯 Problem 1: Employee Hierarchy with Recursive CTE

**Business Context:** Organizational management requires understanding reporting structures and hierarchy levels for decision-making and resource allocation.

### Requirements
Build the complete organizational hierarchy showing each employee's level and reporting path.

### SQL Setup
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

### Solutions

#### Complete Hierarchy with Reporting Paths:
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Top-level employees
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

#### Direct Reports Count:
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

#### Total Subordinates Count:
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

---

## 🎯 Problem 2: Row Expansion with Recursive CTE

**Business Context:** Data transformation requirements often need to expand single rows into multiple rows based on count fields, such as generating schedule entries or expanding budget allocations.

### Requirements
Expand each row by the count in c2, incrementing the date by 1 day for each expansion.

### SQL Setup
```sql
CREATE TABLE input (
  c1 VARCHAR(1),
  c2 INT,
  c3 DATE
);

INSERT INTO input VALUES
('a', 2, '2020-01-02'),
('b', 1, '2020-01-01'),
('c', 5, '2020-01-05');
```

### Solutions

#### Using JOIN with Number Table:
```sql
SELECT t1.c1, 
       t2.n AS c2, 
       DATE_ADD(t1.c3, INTERVAL (t2.n - 1) DAY) AS c3
FROM input t1
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
      SELECT 4 UNION ALL SELECT 5) t2
ON t2.n <= t1.c2
ORDER BY t1.c1, c3;
```

#### Using Recursive CTE:
```sql
WITH RECURSIVE temp (c1, c2, c3) AS (
  -- Base case: start with count = 1
  SELECT c1, 1, c3
  FROM input
  
  UNION ALL
  
  -- Recursive case: increment count and add 1 day
  SELECT temp.c1, temp.c2 + 1, temp.c3 + INTERVAL 1 DAY
  FROM temp
  JOIN input ON input.c1 = temp.c1 AND input.c2 > temp.c2
)
SELECT c1, c2, c3
FROM temp
ORDER BY c1, c3;
```

---

## 📚 Key Concepts Covered

### Recursive CTE Structure
- **Base Case**: Starting point (non-recursive SELECT)
- **UNION ALL**: Combines base and recursive results
- **Recursive Case**: References the CTE itself
- **Termination**: Natural termination when no more rows

### Common Patterns
- **Hierarchical Data**: Organization charts, category trees
- **Sequential Expansion**: Generating series, date ranges
- **Path Finding**: Reporting chains, dependency trees
- **Cumulative Calculations**: Running totals with complex logic

### Performance Considerations
- **Recursion Depth**: Database-specific limits (MySQL: 1000 default)
- **Memory Usage**: Can consume significant resources
- **Indexing**: Critical for join conditions in recursive steps
- **Alternatives**: Consider iterative approaches for very large datasets

---

## 🎯 Interview-Ready Patterns

### Pattern 1: Organizational Analysis
Building hierarchy reports, span of control analysis, reporting chains.

### Pattern 2: Data Expansion
Converting summary data to detailed records, schedule generation, allocation expansion.

### Pattern 3: Path Finding
Finding relationships, dependency chains, approval workflows.

### Pattern 4: Sequential Processing
Date range generation, numbered sequences, iterative calculations.

---

## 🔧 Database-Specific Notes

### MySQL:
- Recursion limit: Default 1000, adjustable with `cte_max_recursion_depth`
- Date functions: DATE_ADD() with INTERVAL
- String concatenation: CONCAT() function

### PostgreSQL:
- Higher recursion limits, more flexible
- Interval syntax: c3 + INTERVAL '1 day'
- Better performance for complex recursions

### SQL Server:
- WITH RECURSIVE syntax supported
- DATEADD() function for date arithmetic
- Good performance with proper indexing

