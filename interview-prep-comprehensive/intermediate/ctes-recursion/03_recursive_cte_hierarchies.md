# Problem 03: Recursive CTEs for Complex Hierarchies

## Business Context
Organizations often need to analyze hierarchical data structures like organizational charts, product categories, bill of materials (BOM), and project dependencies. Recursive CTEs provide an elegant way to traverse these tree-like or graph-like structures to calculate cumulative metrics, find paths, and perform hierarchical aggregations.

## Requirements
Write recursive SQL queries using CTEs to navigate hierarchical data structures, calculate hierarchical aggregations, and solve complex organizational and structural analysis problems.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    salary DECIMAL(10, 2) NOT NULL,
    manager_id INT,
    dept_id INT,
    hire_date DATE NOT NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    parent_dept_id INT,
    budget DECIMAL(12, 2) NOT NULL,
    manager_id INT,
    FOREIGN KEY (parent_dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    parent_project_id INT,
    budget DECIMAL(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'Planning',
    FOREIGN KEY (parent_project_id) REFERENCES projects(project_id)
);

CREATE TABLE project_resources (
    resource_id INT PRIMARY KEY,
    project_id INT NOT NULL,
    emp_id INT NOT NULL,
    allocation_percentage DECIMAL(5, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Insert sample hierarchical data
INSERT INTO departments (dept_id, dept_name, parent_dept_id, budget, manager_id) VALUES
(1, 'Executive', NULL, 1000000.00, NULL),
(2, 'Engineering', 1, 800000.00, NULL),
(3, 'Product', 1, 600000.00, NULL),
(4, 'Frontend', 2, 300000.00, NULL),
(5, 'Backend', 2, 400000.00, NULL),
(6, 'DevOps', 2, 200000.00, NULL),
(7, 'Design', 3, 250000.00, NULL),
(8, 'Research', 3, 350000.00, NULL);

INSERT INTO employees (emp_id, first_name, last_name, title, salary, manager_id, dept_id, hire_date) VALUES
(1, 'Alice', 'Johnson', 'CEO', 250000.00, NULL, 1, '2015-01-01'),
(2, 'Bob', 'Smith', 'CTO', 180000.00, 1, 2, '2016-03-15'),
(3, 'Carol', 'Davis', 'CPO', 170000.00, 1, 3, '2016-05-20'),
(4, 'David', 'Wilson', 'VP Engineering', 160000.00, 2, 2, '2017-01-10'),
(5, 'Eve', 'Brown', 'Frontend Lead', 140000.00, 4, 4, '2018-02-15'),
(6, 'Frank', 'Miller', 'Backend Lead', 145000.00, 4, 5, '2018-03-01'),
(7, 'Grace', 'Garcia', 'DevOps Lead', 135000.00, 4, 6, '2018-04-01'),
(8, 'Henry', 'Lee', 'Senior Frontend', 120000.00, 5, 4, '2019-01-15'),
(9, 'Ivy', 'Chen', 'Senior Backend', 125000.00, 6, 5, '2019-02-01'),
(10, 'Jack', 'Taylor', 'DevOps Engineer', 115000.00, 7, 6, '2019-03-01'),
(11, 'Kate', 'Anderson', 'Product Manager', 130000.00, 3, 3, '2017-06-15'),
(12, 'Liam', 'Thomas', 'UX Designer', 110000.00, 11, 7, '2019-04-01'),
(13, 'Mia', 'Jackson', 'Research Scientist', 140000.00, 3, 8, '2018-07-01'),
(14, 'Noah', 'White', 'Junior Developer', 95000.00, 8, 4, '2023-01-15'),
(15, 'Olivia', 'Harris', 'Data Analyst', 105000.00, 13, 8, '2022-09-01');

INSERT INTO projects (project_id, project_name, parent_project_id, budget, start_date, end_date, status) VALUES
(1, 'Product Launch 2024', NULL, 500000.00, '2024-01-01', '2024-12-31', 'Active'),
(2, 'Mobile App', 1, 200000.00, '2024-01-15', '2024-08-15', 'Active'),
(3, 'Web Platform', 1, 250000.00, '2024-02-01', '2024-10-31', 'Active'),
(4, 'API Development', 3, 150000.00, '2024-03-01', '2024-09-30', 'Planning'),
(5, 'Mobile UI/UX', 2, 80000.00, '2024-02-15', '2024-07-15', 'Active'),
(6, 'Backend Services', 3, 120000.00, '2024-03-15', '2024-08-31', 'Active'),
(7, 'Database Migration', 6, 60000.00, '2024-04-01', '2024-06-30', 'Planning');

INSERT INTO project_resources (resource_id, project_id, emp_id, allocation_percentage, start_date, end_date) VALUES
(1, 2, 5, 100.00, '2024-01-15', '2024-08-15'),
(2, 2, 8, 75.00, '2024-01-15', '2024-06-15'),
(3, 2, 14, 50.00, '2024-02-01', '2024-05-31'),
(4, 3, 6, 100.00, '2024-02-01', '2024-10-31'),
(5, 3, 9, 80.00, '2024-02-15', '2024-08-31'),
(6, 3, 10, 60.00, '2024-03-01', '2024-07-31'),
(7, 4, 6, 50.00, '2024-03-01', '2024-09-30'),
(8, 5, 12, 100.00, '2024-02-15', '2024-07-15'),
(9, 6, 9, 90.00, '2024-03-15', '2024-08-31'),
(10, 7, 10, 100.00, '2024-04-01', '2024-06-30');
```

## Query Requirements

### Query 1: Employee organizational hierarchy with level and path
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: Top-level employees (CEO)
    SELECT 
        emp_id,
        first_name || ' ' || last_name AS full_name,
        title,
        salary,
        manager_id,
        0 AS hierarchy_level,
        ARRAY[emp_id] AS path_to_root,
        salary AS max_salary_in_path,
        salary AS min_salary_in_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Employees with managers
    SELECT 
        e.emp_id,
        e.first_name || ' ' || e.last_name,
        e.title,
        e.salary,
        e.manager_id,
        eh.hierarchy_level + 1,
        eh.path_to_root || e.emp_id,
        GREATEST(eh.max_salary_in_path, e.salary),
        LEAST(eh.min_salary_in_path, e.salary)
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT 
    full_name,
    title,
    salary,
    hierarchy_level,
    array_length(path_to_root, 1) AS path_length,
    max_salary_in_path,
    min_salary_in_path,
    ROUND((max_salary_in_path - min_salary_in_path) / NULLIF(min_salary_in_path, 0) * 100, 2) AS salary_range_percentage
FROM employee_hierarchy
ORDER BY hierarchy_level, salary DESC;
```

**Expected Result:**
| full_name      | title              | salary   | hierarchy_level | path_length | max_salary_in_path | min_salary_in_path | salary_range_percentage |
|----------------|--------------------|----------|-----------------|-------------|-------------------|-------------------|-------------------------|
| Alice Johnson  | CEO                | 250000.00| 0               | 1           | 250000.00         | 250000.00         | 0.00                    |
| Bob Smith      | CTO                | 180000.00| 1               | 2           | 250000.00         | 180000.00         | 38.89                   |
| Carol Davis    | CPO                | 170000.00| 1               | 2           | 250000.00         | 170000.00         | 47.06                   |
| David Wilson   | VP Engineering     | 160000.00| 2               | 3           | 250000.00         | 160000.00         | 56.25                   |
| Eve Brown      | Frontend Lead      | 140000.00| 3               | 4           | 250000.00         | 140000.00         | 78.57                   |
| Frank Miller   | Backend Lead       | 145000.00| 3               | 4           | 250000.00         | 140000.00         | 78.57                   |
| Grace Garcia   | DevOps Lead        | 135000.00| 3               | 4           | 250000.00         | 135000.00         | 85.19                   |
| Henry Lee      | Senior Frontend    | 120000.00| 4               | 5           | 250000.00         | 120000.00         | 108.33                  |
| Ivy Chen       | Senior Backend     | 125000.00| 4               | 5           | 250000.00         | 120000.00         | 108.33                  |
| Jack Taylor    | DevOps Engineer    | 115000.00| 4               | 5           | 250000.00         | 115000.00         | 117.39                  |
| Noah White     | Junior Developer   | 95000.00 | 5               | 6           | 250000.00         | 95000.00          | 163.16                  |
| Kate Anderson  | Product Manager    | 130000.00| 2               | 3           | 250000.00         | 130000.00         | 92.31                   |
| Liam Thomas    | UX Designer        | 110000.00| 3               | 4           | 250000.00         | 110000.00         | 127.27                  |
| Mia Jackson    | Research Scientist | 140000.00| 2               | 3           | 250000.00         | 140000.00         | 78.57                   |
| Olivia Harris  | Data Analyst       | 105000.00| 3               | 4           | 250000.00         | 105000.00         | 138.10                  |

### Query 2: Department hierarchy with budget rollup
```sql
WITH RECURSIVE dept_hierarchy AS (
    -- Anchor: Top-level departments
    SELECT 
        dept_id,
        dept_name,
        parent_dept_id,
        budget,
        0 AS hierarchy_level,
        ARRAY[dept_id] AS path_to_root,
        budget AS total_budget_rollup
    FROM departments
    WHERE parent_dept_id IS NULL
    
    UNION ALL
    
    -- Recursive: Child departments
    SELECT 
        d.dept_id,
        d.dept_name,
        d.parent_dept_id,
        d.budget,
        dh.hierarchy_level + 1,
        dh.path_to_root || d.dept_id,
        dh.total_budget_rollup + d.budget
    FROM departments d
    INNER JOIN dept_hierarchy dh ON d.parent_dept_id = dh.dept_id
),
dept_stats AS (
    SELECT 
        dept_id,
        COUNT(e.emp_id) AS employee_count,
        SUM(e.salary) AS total_salary,
        AVG(e.salary) AS avg_salary
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    GROUP BY dept_id
)
SELECT 
    dh.dept_name,
    dh.hierarchy_level,
    dh.budget AS dept_budget,
    dh.total_budget_rollup,
    ds.employee_count,
    ds.total_salary,
    ROUND(ds.total_salary / NULLIF(ds.employee_count, 0), 2) AS avg_salary_per_employee,
    ROUND(dh.total_budget_rollup / NULLIF(ds.employee_count, 0), 2) AS budget_per_employee
FROM dept_hierarchy dh
LEFT JOIN dept_stats ds ON dh.dept_id = ds.dept_id
ORDER BY dh.hierarchy_level, dh.dept_name;
```

**Expected Result:**
| dept_name    | hierarchy_level | dept_budget | total_budget_rollup | employee_count | total_salary | avg_salary_per_employee | budget_per_employee |
|--------------|-----------------|-------------|---------------------|----------------|--------------|-------------------------|---------------------|
| Executive   | 0               | 1000000.00 | 1000000.00         | 1              | 250000.00   | 250000.00               | 1000000.00          |
| Engineering | 1               | 800000.00  | 1800000.00         | 4              | 620000.00   | 155000.00               | 450000.00           |
| Product     | 1               | 600000.00  | 1600000.00         | 4              | 485000.00   | 121250.00               | 400000.00           |
| Frontend    | 2               | 300000.00  | 2100000.00         | 3              | 355000.00   | 118333.33               | 700000.00           |
| Backend     | 2               | 400000.00  | 2200000.00         | 2              | 270000.00   | 135000.00               | 1100000.00          |
| DevOps      | 2               | 200000.00  | 2000000.00         | 2              | 250000.00   | 125000.00               | 1000000.00          |
| Design      | 2               | 250000.00  | 1850000.00         | 1              | 110000.00   | 110000.00               | 1850000.00          |
| Research    | 2               | 350000.00  | 1950000.00         | 2              | 245000.00   | 122500.00               | 975000.00           |

### Query 3: Project dependency tree with resource allocation
```sql
WITH RECURSIVE project_tree AS (
    -- Anchor: Root projects
    SELECT 
        project_id,
        project_name,
        parent_project_id,
        budget,
        status,
        0 AS tree_level,
        ARRAY[project_id] AS path_to_root,
        budget AS total_budget_rollup
    FROM projects
    WHERE parent_project_id IS NULL
    
    UNION ALL
    
    -- Recursive: Sub-projects
    SELECT 
        p.project_id,
        p.project_name,
        p.parent_project_id,
        p.budget,
        p.status,
        pt.tree_level + 1,
        pt.path_to_root || p.project_id,
        pt.total_budget_rollup + p.budget
    FROM projects p
    INNER JOIN project_tree pt ON p.parent_project_id = pt.project_id
),
project_resources_agg AS (
    SELECT 
        project_id,
        COUNT(DISTINCT emp_id) AS unique_resources,
        SUM(allocation_percentage) AS total_allocation,
        AVG(allocation_percentage) AS avg_allocation
    FROM project_resources
    GROUP BY project_id
)
SELECT 
    pt.project_name,
    pt.tree_level,
    pt.budget AS project_budget,
    pt.total_budget_rollup,
    pt.status,
    pra.unique_resources,
    pra.total_allocation,
    pra.avg_allocation,
    ROUND(pt.total_budget_rollup / NULLIF(pra.unique_resources, 0), 2) AS budget_per_resource
FROM project_tree pt
LEFT JOIN project_resources_agg pra ON pt.project_id = pra.project_id
ORDER BY pt.tree_level, pt.project_name;
```

**Expected Result:**
| project_name       | tree_level | project_budget | total_budget_rollup | status   | unique_resources | total_allocation | avg_allocation | budget_per_resource |
|--------------------|------------|----------------|---------------------|----------|------------------|------------------|----------------|---------------------|
| Product Launch 2024| 0          | 500000.00      | 500000.00           | Active   |                  |                  |                |                     |
| Mobile App         | 1          | 200000.00      | 700000.00           | Active   | 3                | 225.00          | 75.00          | 233333.33            |
| Web Platform       | 1          | 250000.00      | 750000.00           | Active   | 3                | 240.00          | 80.00          | 250000.00            |
| API Development    | 2          | 150000.00      | 900000.00           | Planning | 1                | 50.00           | 50.00          | 900000.00            |
| Mobile UI/UX       | 2          | 80000.00       | 780000.00           | Active   | 1                | 100.00          | 100.00         | 780000.00            |
| Backend Services   | 2          | 120000.00      | 870000.00           | Active   | 1                | 90.00           | 90.00          | 870000.00            |
| Database Migration | 3          | 60000.00       | 930000.00           | Planning | 1                | 100.00          | 100.00         | 930000.00            |

### Query 4: Employee span of control and reporting chain
```sql
WITH RECURSIVE reporting_chain AS (
    -- Anchor: Employees with no manager
    SELECT 
        emp_id,
        first_name || ' ' || last_name AS full_name,
        manager_id,
        0 AS reports_to_level,
        1 AS total_reports,
        ARRAY[emp_id] AS management_chain
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Direct and indirect reports
    SELECT 
        e.emp_id,
        e.first_name || ' ' || e.last_name,
        e.manager_id,
        rc.reports_to_level + 1,
        rc.total_reports + 1,
        rc.management_chain || e.emp_id
    FROM employees e
    INNER JOIN reporting_chain rc ON e.manager_id = rc.emp_id
),
span_of_control AS (
    SELECT 
        manager_id,
        COUNT(*) AS direct_reports,
        SUM(total_reports) AS total_org_size
    FROM reporting_chain
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT 
    rc.full_name,
    rc.reports_to_level,
    sc.direct_reports,
    sc.total_org_size,
    array_length(rc.management_chain, 1) AS chain_length,
    CASE 
        WHEN sc.direct_reports IS NULL THEN 'Individual Contributor'
        WHEN sc.direct_reports = 1 THEN 'First-line Manager'
        WHEN sc.direct_reports BETWEEN 2 AND 5 THEN 'Middle Manager'
        ELSE 'Senior Leader'
    END AS management_level
FROM reporting_chain rc
LEFT JOIN span_of_control sc ON rc.emp_id = sc.manager_id
ORDER BY rc.reports_to_level, sc.total_org_size DESC NULLS LAST;
```

**Expected Result:**
| full_name      | reports_to_level | direct_reports | total_org_size | chain_length | management_level     |
|----------------|------------------|----------------|----------------|--------------|----------------------|
| Alice Johnson  | 0                | 2              | 14             | 1            | Middle Manager       |
| Bob Smith      | 1                | 1              | 6              | 2            | First-line Manager   |
| Carol Davis    | 1                | 2              | 6              | 2            | Middle Manager       |
| David Wilson   | 2                | 3              | 5              | 3            | Middle Manager       |
| Kate Anderson  | 2                | 1              | 2              | 3            | First-line Manager   |
| Mia Jackson    | 2                | 1              | 2              | 3            | First-line Manager   |
| Eve Brown      | 3                | 1              | 2              | 4            | First-line Manager   |
| Frank Miller   | 3                | 1              | 2              | 4            | First-line Manager   |
| Grace Garcia   | 3                | 1              | 2              | 4            | First-line Manager   |
| Liam Thomas    | 3                |                |                | 4            | Individual Contributor|
| Olivia Harris  | 3                |                |                | 4            | Individual Contributor|
| Henry Lee      | 4                | 1              | 1              | 5            | First-line Manager   |
| Ivy Chen       | 4                |                |                | 5            | Individual Contributor|
| Jack Taylor    | 4                |                |                | 5            | Individual Contributor|
| Noah White     | 5                |                |                | 6            | Individual Contributor|

## Key Learning Points
- **WITH RECURSIVE**: Defining recursive CTEs with UNION ALL
- **Anchor member**: Base case for recursion
- **Recursive member**: Self-referencing query
- **Termination**: Automatic when no more rows found
- **ARRAY operations**: Building paths and hierarchies
- **Hierarchical aggregations**: Rolling up values through levels

## Common Recursive CTE Applications
- **Organizational charts**: Employee-manager hierarchies
- **Bill of materials**: Product component structures
- **Category trees**: Product/service classifications
- **Project dependencies**: Task predecessor relationships
- **Network analysis**: Graph traversal problems

## Performance Notes
- Recursive CTEs can be expensive with deep hierarchies
- Use proper indexing on recursive columns
- Consider depth limits to prevent infinite loops
- Monitor for performance with large datasets
- Materialized paths can be alternatives for frequently accessed hierarchies

## Extension Challenge
Create a comprehensive organizational analytics dashboard that combines employee hierarchy, department structure, and project dependencies to identify resource bottlenecks, management span of control issues, and budget allocation inefficiencies across the entire organizational structure.
