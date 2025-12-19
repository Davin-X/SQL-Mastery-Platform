# Problem 01: Basic CTEs with WITH Clause - Multi-Step Query Organization

## Business Context
Complex business queries often require multiple steps of data transformation, filtering, and aggregation. CTEs (Common Table Expressions) provide a clean way to organize these multi-step processes, making queries more readable and maintainable. HR and finance departments frequently use CTEs for complex reporting requirements.

## Requirements
Write SQL queries using WITH clause (CTEs) to break down complex business logic into readable, maintainable steps. Demonstrate how CTEs can organize multi-step data transformations and calculations.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    manager_id INT
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2) NOT NULL
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT,
    budget DECIMAL(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE project_assignments (
    assignment_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    project_id INT NOT NULL,
    hours_worked DECIMAL(6, 2) NOT NULL,
    assignment_date DATE NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Insert sample data
INSERT INTO departments (dept_id, dept_name, budget) VALUES
(1, 'IT', 500000.00),
(2, 'Sales', 750000.00),
(3, 'HR', 300000.00),
(4, 'Finance', 600000.00);

INSERT INTO employees (emp_id, first_name, last_name, dept_id, salary, hire_date, manager_id) VALUES
(1, 'John', 'Doe', 1, 75000.00, '2020-01-15', NULL),
(2, 'Jane', 'Smith', 1, 80000.00, '2019-03-20', 1),
(3, 'Bob', 'Wilson', 1, 72000.00, '2021-06-10', 1),
(4, 'Alice', 'Brown', 2, 65000.00, '2018-11-05', NULL),
(5, 'Charlie', 'Davis', 2, 75000.00, '2020-08-15', 4),
(6, 'Diana', 'Evans', 2, 72000.00, '2019-12-01', 4),
(7, 'Eve', 'Foster', 3, 55000.00, '2022-02-20', NULL),
(8, 'Frank', 'Garcia', 3, 60000.00, '2021-08-10', 7),
(9, 'Grace', 'Hill', 4, 85000.00, '2017-09-10', NULL),
(10, 'Henry', 'Adams', 4, 78000.00, '2019-05-25', 9);

INSERT INTO projects (project_id, project_name, dept_id, budget, start_date, end_date, status) VALUES
(1, 'Website Redesign', 1, 100000.00, '2024-01-01', '2024-06-30', 'Active'),
(2, 'Mobile App', 1, 80000.00, '2024-02-01', '2024-08-31', 'Active'),
(3, 'CRM System', 2, 120000.00, '2023-11-01', '2024-05-31', 'Completed'),
(4, 'Data Warehouse', 4, 150000.00, '2024-01-15', '2024-12-31', 'Active'),
(5, 'Security Audit', 1, 50000.00, '2024-03-01', '2024-04-30', 'Completed'),
(6, 'Marketing Campaign', 2, 75000.00, '2024-02-15', '2024-07-15', 'Active');

INSERT INTO project_assignments (assignment_id, emp_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 1, 80.00, '2024-01-15'),
(2, 2, 1, 120.00, '2024-01-15'),
(3, 3, 2, 100.00, '2024-02-01'),
(4, 4, 3, 150.00, '2023-11-15'),
(5, 5, 3, 140.00, '2023-11-15'),
(6, 6, 3, 130.00, '2023-11-15'),
(7, 9, 4, 200.00, '2024-01-20'),
(8, 10, 4, 180.00, '2024-01-20'),
(9, 1, 5, 60.00, '2024-03-01'),
(10, 2, 5, 70.00, '2024-03-01'),
(11, 4, 6, 90.00, '2024-02-20'),
(12, 5, 6, 85.00, '2024-02-20');
```

## Query Requirements

### Query 1: Department performance summary using CTE
```sql
WITH dept_employee_summary AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        COUNT(e.emp_id) AS employee_count,
        ROUND(AVG(e.salary), 2) AS avg_salary,
        MAX(e.salary) AS max_salary,
        MIN(e.salary) AS min_salary
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    GROUP BY d.dept_id, d.dept_name
),
dept_project_summary AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        COUNT(p.project_id) AS project_count,
        SUM(p.budget) AS total_project_budget,
        COUNT(CASE WHEN p.status = 'Active' THEN 1 END) AS active_projects
    FROM departments d
    LEFT JOIN projects p ON d.dept_id = p.dept_id
    GROUP BY d.dept_id, d.dept_name
)
SELECT 
    des.dept_name,
    des.employee_count,
    des.avg_salary,
    des.max_salary,
    dps.project_count,
    dps.total_project_budget,
    dps.active_projects,
    ROUND(dps.total_project_budget / NULLIF(des.employee_count, 0), 2) AS budget_per_employee
FROM dept_employee_summary des
INNER JOIN dept_project_summary dps ON des.dept_id = dps.dept_id
ORDER BY des.avg_salary DESC;
```

**Expected Result:**
| dept_name | employee_count | avg_salary | max_salary | project_count | total_project_budget | active_projects | budget_per_employee |
|-----------|----------------|------------|------------|---------------|----------------------|-----------------|---------------------|
| Finance   | 2              | 81500.00   | 85000.00   | 1             | 150000.00            | 1               | 75000.00            |
| IT        | 3              | 75666.67   | 80000.00   | 3             | 230000.00            | 2               | 76666.67            |
| Sales     | 3              | 70666.67   | 75000.00   | 2             | 195000.00            | 1               | 65000.00            |
| HR        | 2              | 57500.00   | 60000.00   | 0             |                      | 0               |                     |

### Query 2: Employee productivity analysis using CTE
```sql
WITH employee_hours AS (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        d.dept_name,
        SUM(pa.hours_worked) AS total_hours,
        COUNT(DISTINCT pa.project_id) AS project_count
    FROM employees e
    INNER JOIN departments d ON e.dept_id = d.dept_id
    LEFT JOIN project_assignments pa ON e.emp_id = pa.emp_id
    GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
),
productivity_metrics AS (
    SELECT 
        *,
        ROUND(total_hours / NULLIF(project_count, 0), 2) AS avg_hours_per_project,
        CASE 
            WHEN total_hours > 200 THEN 'High'
            WHEN total_hours > 100 THEN 'Medium'
            ELSE 'Low'
        END AS productivity_level
    FROM employee_hours
)
SELECT 
    first_name || ' ' || last_name AS employee_name,
    dept_name,
    total_hours,
    project_count,
    avg_hours_per_project,
    productivity_level
FROM productivity_metrics
ORDER BY total_hours DESC, project_count DESC;
```

**Expected Result:**
| employee_name  | dept_name | total_hours | project_count | avg_hours_per_project | productivity_level |
|----------------|-----------|-------------|---------------|-----------------------|-------------------|
| Frank Garcia   | HR        | 0.00        | 0             |                       | Low               |
| Eve Foster     | HR        | 0.00        | 0             |                       | Low               |
| Bob Wilson     | IT        | 100.00      | 1             | 100.00                | Medium            |
| John Doe       | IT        | 140.00      | 2             | 70.00                 | Medium            |
| Jane Smith     | IT        | 190.00      | 2             | 95.00                 | Medium            |
| Alice Brown    | Sales     | 240.00      | 2             | 120.00                | High              |
| Charlie Davis  | Sales     | 225.00      | 2             | 112.50                | High              |
| Diana Evans    | Sales     | 130.00      | 1             | 130.00                | Medium            |
| Henry Adams    | Finance   | 180.00      | 1             | 180.00                | Medium            |
| Grace Hill     | Finance   | 200.00      | 1             | 200.00                | High              |

### Query 3: Project cost analysis using multiple CTEs
```sql
WITH project_costs AS (
    SELECT 
        p.project_id,
        p.project_name,
        d.dept_name,
        p.budget AS project_budget,
        p.start_date,
        p.end_date,
        p.status
    FROM projects p
    INNER JOIN departments d ON p.dept_id = d.dept_id
),
project_hours AS (
    SELECT 
        pa.project_id,
        SUM(pa.hours_worked) AS total_hours,
        COUNT(DISTINCT pa.emp_id) AS employee_count,
        ROUND(AVG(pa.hours_worked), 2) AS avg_hours_per_employee
    FROM project_assignments pa
    GROUP BY pa.project_id
),
cost_analysis AS (
    SELECT 
        pc.project_name,
        pc.dept_name,
        pc.project_budget,
        ph.total_hours,
        ph.employee_count,
        ph.avg_hours_per_employee,
        ROUND(pc.project_budget / NULLIF(ph.total_hours, 0), 2) AS cost_per_hour,
        pc.status
    FROM project_costs pc
    LEFT JOIN project_hours ph ON pc.project_id = ph.project_id
)
SELECT 
    project_name,
    dept_name,
    project_budget,
    total_hours,
    employee_count,
    cost_per_hour,
    status
FROM cost_analysis
ORDER BY project_budget DESC, total_hours DESC;
```

**Expected Result:**
| project_name    | dept_name | project_budget | total_hours | employee_count | cost_per_hour | status   |
|-----------------|-----------|----------------|-------------|----------------|---------------|----------|
| Data Warehouse  | Finance   | 150000.00      | 380.00      | 2              | 394.74        | Active   |
| CRM System      | Sales     | 120000.00      | 420.00      | 3              | 285.71        | Completed|
| Website Redesign| IT        | 100000.00      | 200.00      | 2              | 500.00        | Active   |
| Marketing Campaign| Sales    | 75000.00       | 175.00      | 2              | 428.57        | Active   |
| Mobile App      | IT        | 80000.00       | 100.00      | 1              | 800.00        | Active   |
| Security Audit  | IT        | 50000.00       | 130.00      | 2              | 384.62        | Completed|

### Query 4: Hierarchical employee structure using CTE
```sql
WITH employee_hierarchy AS (
    SELECT 
        emp_id,
        first_name,
        last_name,
        manager_id,
        salary,
        0 AS hierarchy_level,
        first_name || ' ' || last_name AS full_name
    FROM employees 
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        e.salary,
        eh.hierarchy_level + 1,
        e.first_name || ' ' || last_name
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT 
    full_name,
    salary,
    hierarchy_level,
    CASE 
        WHEN hierarchy_level = 0 THEN 'Manager'
        WHEN hierarchy_level = 1 THEN 'Employee'
        ELSE 'Individual Contributor'
    END AS role_type
FROM employee_hierarchy
ORDER BY hierarchy_level, salary DESC;
```

**Expected Result:**
| full_name     | salary   | hierarchy_level | role_type             |
|---------------|----------|-----------------|-----------------------|
| John Doe      | 75000.00 | 0               | Manager               |
| Alice Brown   | 65000.00 | 0               | Manager               |
| Eve Foster    | 55000.00 | 0               | Manager               |
| Grace Hill    | 85000.00 | 0               | Manager               |
| Jane Smith    | 80000.00 | 1               | Employee              |
| Charlie Davis | 75000.00 | 1               | Employee              |
| Frank Garcia  | 60000.00 | 1               | Employee              |
| Henry Adams   | 78000.00 | 1               | Employee              |
| Bob Wilson    | 72000.00 | 1               | Employee              |
| Diana Evans   | 72000.00 | 1               | Employee              |

## Key Learning Points
- **WITH clause**: Defines CTEs (Common Table Expressions)
- **Multiple CTEs**: Can define multiple CTEs in one query
- **CTEs as subqueries**: CTEs can reference each other
- **Readability**: Break complex logic into manageable steps
- **Reusability**: CTEs can be referenced multiple times
- **Recursion**: CTEs support recursive queries

## Common CTE Applications
- **Complex aggregations**: Multi-step calculations
- **Data transformation**: Step-by-step processing
- **Recursive hierarchies**: Organizational charts, bill of materials
- **Temporary result sets**: Intermediate query results
- **Query organization**: Breaking down complex logic

## Performance Notes
- CTEs are generally not materialized (except recursive ones)
- Multiple CTEs in one query are optimized together
- Can improve readability without performance penalty
- Consider temp tables for very large datasets

## Extension Challenge
Create a comprehensive department performance dashboard that uses multiple CTEs to calculate employee productivity metrics, project success rates, budget utilization, and department rankings across multiple dimensions.
