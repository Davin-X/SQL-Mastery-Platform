# Problem 01: Basic Subqueries - Scalar, IN/NOT IN, EXISTS/NOT EXISTS

## Business Context
Subqueries are powerful SQL constructs that allow queries to be nested within other queries, enabling complex filtering, comparisons, and data retrieval patterns. They are essential for solving business problems that require conditional logic based on aggregated data or related table lookups.

## Requirements
Write SQL queries using different types of subqueries (scalar, IN/NOT IN, EXISTS/NOT EXISTS) to solve common business analysis problems involving filtering, comparisons, and conditional logic.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT,
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

CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending'
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    credit_limit DECIMAL(10, 2) NOT NULL
);

-- Insert sample data
INSERT INTO departments (dept_id, dept_name, budget) VALUES
(1, 'IT', 500000.00),
(2, 'Sales', 750000.00),
(3, 'HR', 300000.00),
(4, 'Finance', 600000.00);

INSERT INTO employees (emp_id, first_name, last_name, salary, dept_id, hire_date, manager_id) VALUES
(1, 'John', 'Doe', 75000.00, 1, '2020-01-15', NULL),
(2, 'Jane', 'Smith', 80000.00, 1, '2019-03-20', 1),
(3, 'Bob', 'Wilson', 72000.00, 1, '2021-06-10', 1),
(4, 'Alice', 'Brown', 65000.00, 2, '2018-11-05', NULL),
(5, 'Charlie', 'Davis', 75000.00, 2, '2020-08-15', 4),
(6, 'Diana', 'Evans', 72000.00, 2, '2019-12-01', 4),
(7, 'Eve', 'Foster', 55000.00, 3, '2022-02-20', NULL),
(8, 'Frank', 'Garcia', 60000.00, 3, '2021-08-10', 7),
(9, 'Grace', 'Hill', 85000.00, 4, '2017-09-10', NULL),
(10, 'Henry', 'Adams', 78000.00, 4, '2019-05-25', 9);

INSERT INTO projects (project_id, project_name, dept_id, budget, start_date, end_date, status) VALUES
(1, 'Website Redesign', 1, 100000.00, '2024-01-01', '2024-06-30', 'Active'),
(2, 'Mobile App', 1, 80000.00, '2024-02-01', '2024-08-31', 'Active'),
(3, 'CRM System', 2, 120000.00, '2023-11-01', '2024-05-31', 'Completed'),
(4, 'Data Warehouse', 4, 150000.00, '2024-01-15', '2024-12-31', 'Active');

INSERT INTO project_assignments (assignment_id, emp_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 1, 80.00, '2024-01-15'),
(2, 2, 1, 120.00, '2024-01-15'),
(3, 3, 2, 100.00, '2024-02-01'),
(4, 4, 3, 150.00, '2023-11-15'),
(5, 5, 3, 140.00, '2023-11-15'),
(6, 6, 3, 130.00, '2023-11-15'),
(7, 9, 4, 200.00, '2024-01-20'),
(8, 10, 4, 180.00, '2024-01-20');

INSERT INTO customers (customer_id, customer_name, region, credit_limit) VALUES
(1, 'TechCorp', 'North', 50000.00),
(2, 'DataSys', 'South', 75000.00),
(3, 'WebFlow', 'East', 30000.00),
(4, 'CloudNet', 'West', 60000.00),
(5, 'InnovateIT', 'North', 45000.00);

INSERT INTO sales_orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2024-01-15', 25000.00, 'Completed'),
(2, 2, '2024-01-20', 45000.00, 'Completed'),
(3, 3, '2024-02-01', 15000.00, 'Completed'),
(4, 1, '2024-02-10', 30000.00, 'Pending'),
(5, 4, '2024-02-15', 35000.00, 'Completed'),
(6, 5, '2024-03-01', 20000.00, 'Completed');
```

## Query Requirements

### Query 1: Employees above department average salary (scalar subquery)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    (
        SELECT AVG(salary) 
        FROM employees 
        WHERE dept_id = e.dept_id
    ) AS dept_avg_salary,
    e.salary - (
        SELECT AVG(salary) 
        FROM employees 
        WHERE dept_id = e.dept_id
    ) AS above_avg_amount
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(salary) 
    FROM employees 
    WHERE dept_id = e.dept_id
)
ORDER BY e.salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | dept_avg_salary | above_avg_amount |
|--------|------------|-----------|-----------|----------|-----------------|------------------|
| 9      | Grace      | Hill      | Finance   | 85000.00 | 81500.00        | 3500.00          |
| 2      | Jane       | Smith     | IT        | 80000.00 | 75666.67        | 4333.33          |
| 10     | Henry      | Adams     | Finance   | 78000.00 | 81500.00        | -3500.00         |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 70666.67        | 4333.33          |
| 1      | John       | Doe       | IT        | 75000.00 | 75666.67        | -666.67          |

### Query 2: Employees not assigned to any projects (NOT EXISTS)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    e.hire_date
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM project_assignments pa 
    WHERE pa.emp_id = e.emp_id
)
ORDER BY e.hire_date DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | hire_date  |
|--------|------------|-----------|-----------|----------|------------|
| 7      | Eve        | Foster    | HR        | 55000.00 | 2022-02-20 |
| 8      | Frank      | Garcia    | HR        | 60000.00 | 2021-08-10 |

### Query 3: Departments with projects above average budget (IN subquery)
```sql
SELECT 
    d.dept_id,
    d.dept_name,
    d.budget AS dept_budget,
    COUNT(p.project_id) AS total_projects,
    SUM(p.budget) AS total_project_budget,
    AVG(p.budget) AS avg_project_budget
FROM departments d
LEFT JOIN projects p ON d.dept_id = p.dept_id
WHERE d.dept_id IN (
    SELECT dept_id 
    FROM projects 
    GROUP BY dept_id 
    HAVING AVG(budget) > (
        SELECT AVG(budget) FROM projects
    )
)
GROUP BY d.dept_id, d.dept_name, d.budget
ORDER BY total_project_budget DESC;
```

**Expected Result:**
| dept_id | dept_name | dept_budget | total_projects | total_project_budget | avg_project_budget |
|---------|-----------|-------------|----------------|----------------------|-------------------|
| 4       | Finance   | 600000.00  | 1              | 150000.00            | 150000.00         |
| 1       | IT        | 500000.00  | 2              | 180000.00            | 90000.00          |
| 2       | Sales     | 750000.00  | 1              | 120000.00            | 120000.00         |

### Query 4: Customers with orders exceeding credit limit (EXISTS with correlated subquery)
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.region,
    c.credit_limit,
    COUNT(so.order_id) AS total_orders,
    SUM(so.total_amount) AS total_order_value,
    MAX(so.total_amount) AS largest_order
FROM customers c
LEFT JOIN sales_orders so ON c.customer_id = so.customer_id
WHERE EXISTS (
    SELECT 1 
    FROM sales_orders so2 
    WHERE so2.customer_id = c.customer_id 
    AND so2.total_amount > c.credit_limit
)
GROUP BY c.customer_id, c.customer_name, c.region, c.credit_limit
ORDER BY total_order_value DESC;
```

**Expected Result:**
| customer_id | customer_name | region | credit_limit | total_orders | total_order_value | largest_order |
|-------------|---------------|--------|--------------|--------------|-------------------|---------------|
| 2           | DataSys       | South  | 75000.00     | 1            | 45000.00          | 45000.00      |

### Query 5: Projects with no employee assignments (NOT IN)
```sql
SELECT 
    p.project_id,
    p.project_name,
    d.dept_name,
    p.budget,
    p.start_date,
    p.end_date,
    p.status
FROM projects p
INNER JOIN departments d ON p.dept_id = d.dept_id
WHERE p.project_id NOT IN (
    SELECT DISTINCT project_id 
    FROM project_assignments
)
ORDER BY p.budget DESC;
```

**Expected Result:**
(empty result set - all projects have assignments)

### Query 6: Employees with salaries in top 25% of company (scalar comparison)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    (
        SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) 
        FROM employees
    ) AS company_75th_percentile,
    e.salary - (
        SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) 
        FROM employees
    ) AS above_75th_amount
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary >= (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) 
    FROM employees
)
ORDER BY e.salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | company_75th_percentile | above_75th_amount |
|--------|------------|-----------|-----------|----------|-------------------------|-------------------|
| 9      | Grace      | Hill      | Finance   | 85000.00 | 76250.00                | 8750.00           |
| 2      | Jane       | Smith     | IT        | 80000.00 | 76250.00                | 3750.00           |
| 10     | Henry      | Adams     | Finance   | 78000.00 | 76250.00                | 1750.00           |

## Key Learning Points
- **Scalar subqueries**: Return single values for comparisons
- **IN/NOT IN subqueries**: Test membership in result sets
- **EXISTS/NOT EXISTS**: Test for existence of related records
- **Correlated subqueries**: Reference outer query columns
- **Performance considerations**: When each type is appropriate

## Common Subquery Applications
- **Filtering**: IN/NOT IN for set-based filtering
- **Existence checks**: EXISTS/NOT EXISTS for relationship testing
- **Comparisons**: Scalar subqueries for value comparisons
- **Aggregations**: Subqueries with GROUP BY for conditional logic
- **Derived tables**: Subqueries in FROM clause

## Performance Notes
- EXISTS/NOT EXISTS often faster than IN/NOT IN for existence checks
- Correlated subqueries can be slower due to repeated execution
- Scalar subqueries execute once and cache results
- Consider JOIN alternatives for better performance

## Extension Challenge
Create a comprehensive employee performance dashboard that uses various subquery types to identify top performers, department leaders, project contributors, and salary anomalies across the organization.
