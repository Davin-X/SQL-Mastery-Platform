# Problem 01: Basic Set Operations - UNION, INTERSECT, EXCEPT

## Business Context
Set operations allow combining and comparing result sets from different queries, enabling complex data analysis across multiple tables and business domains. UNION combines results, INTERSECT finds common elements, and EXCEPT identifies differences. These operations are essential for reporting, data quality checks, and comparative analysis.

## Requirements
Write SQL queries using UNION, INTERSECT, and EXCEPT to solve business problems involving combining data from multiple sources, finding overlaps, and identifying differences between datasets.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employees_q1 (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE employees_q2 (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2) NOT NULL
);

CREATE TABLE projects_q1 (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT,
    budget DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE projects_q2 (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT,
    budget DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE customers_east (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) DEFAULT 'East',
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE customers_west (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) DEFAULT 'West',
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE products_2023 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sales_2023 DECIMAL(12, 2) NOT NULL
);

CREATE TABLE products_2024 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sales_2024 DECIMAL(12, 2) NOT NULL
);

-- Insert sample data
INSERT INTO departments (dept_id, dept_name, budget) VALUES
(1, 'IT', 500000.00),
(2, 'Sales', 750000.00),
(3, 'HR', 300000.00),
(4, 'Finance', 600000.00),
(5, 'Marketing', 400000.00);

INSERT INTO employees_q1 (emp_id, first_name, last_name, dept_id, salary, hire_date) VALUES
(1, 'John', 'Doe', 1, 75000.00, '2020-01-15'),
(2, 'Jane', 'Smith', 1, 80000.00, '2019-03-20'),
(3, 'Bob', 'Wilson', 2, 65000.00, '2018-11-05'),
(4, 'Alice', 'Brown', 2, 70000.00, '2020-08-15'),
(5, 'Charlie', 'Davis', 3, 55000.00, '2022-02-20');

INSERT INTO employees_q2 (emp_id, first_name, last_name, dept_id, salary, hire_date) VALUES
(1, 'John', 'Doe', 1, 78000.00, '2020-01-15'),
(2, 'Jane', 'Smith', 1, 82000.00, '2019-03-20'),
(3, 'Bob', 'Wilson', 2, 67000.00, '2018-11-05'),
(6, 'Diana', 'Evans', 2, 72000.00, '2023-06-10'),
(7, 'Eve', 'Foster', 4, 85000.00, '2023-01-15');

INSERT INTO projects_q1 (project_id, project_name, dept_id, budget, status) VALUES
(1, 'Website Redesign', 1, 100000.00, 'Active'),
(2, 'CRM System', 2, 120000.00, 'Completed'),
(3, 'Security Audit', 1, 50000.00, 'Completed'),
(4, 'Training Program', 3, 30000.00, 'Active');

INSERT INTO projects_q2 (project_id, project_name, dept_id, budget, status) VALUES
(1, 'Website Redesign', 1, 100000.00, 'Completed'),
(2, 'CRM System', 2, 120000.00, 'Completed'),
(5, 'Mobile App', 1, 80000.00, 'Active'),
(6, 'Data Warehouse', 4, 150000.00, 'Planning'),
(7, 'Marketing Campaign', 5, 75000.00, 'Active');

INSERT INTO customers_east (customer_id, customer_name, total_orders, total_spent) VALUES
(1, 'TechCorp East', 15, 150000.00),
(2, 'DataSys East', 8, 80000.00),
(3, 'WebFlow East', 12, 120000.00),
(4, 'InnovateIT East', 6, 60000.00);

INSERT INTO customers_west (customer_id, customer_name, total_orders, total_spent) VALUES
(1, 'TechCorp West', 10, 100000.00),
(2, 'CloudNet West', 14, 140000.00),
(3, 'DataFlow West', 9, 90000.00),
(5, 'MegaCorp West', 18, 180000.00);

INSERT INTO products_2023 (product_id, product_name, category, sales_2023) VALUES
(1, 'Laptop Pro', 'Hardware', 500000.00),
(2, 'Software Suite', 'Software', 300000.00),
(3, 'Cloud Storage', 'Services', 200000.00),
(4, 'Monitor 4K', 'Hardware', 150000.00);

INSERT INTO products_2024 (product_id, product_name, category, sales_2024) VALUES
(1, 'Laptop Pro', 'Hardware', 600000.00),
(2, 'Software Suite', 'Software', 350000.00),
(5, 'Wireless Mouse', 'Hardware', 80000.00),
(6, 'Consulting Services', 'Services', 250000.00);
```

## Query Requirements

### Query 1: Combined employee list across quarters (UNION)
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_id,
    salary,
    'Q1' AS quarter
FROM employees_q1

UNION

SELECT 
    emp_id,
    first_name,
    last_name,
    dept_id,
    salary,
    'Q2' AS quarter
FROM employees_q2

ORDER BY emp_id, quarter;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_id | salary   | quarter |
|--------|------------|-----------|---------|----------|---------|
| 1      | John       | Doe       | 1       | 75000.00 | Q1      |
| 1      | John       | Doe       | 1       | 78000.00 | Q2      |
| 2      | Jane       | Smith     | 1       | 80000.00 | Q1      |
| 2      | Jane       | Smith     | 1       | 82000.00 | Q2      |
| 3      | Bob        | Wilson    | 2       | 65000.00 | Q1      |
| 3      | Bob        | Wilson    | 2       | 67000.00 | Q2      |
| 4      | Alice      | Brown     | 2       | 70000.00 | Q1      |
| 5      | Charlie    | Davis     | 3       | 55000.00 | Q1      |
| 6      | Diana      | Evans     | 2       | 72000.00 | Q2      |
| 7      | Eve        | Foster    | 4       | 85000.00 | Q2      |

### Query 2: Employees in both quarters (INTERSECT)
```sql
SELECT emp_id, first_name, last_name, dept_id
FROM employees_q1

INTERSECT

SELECT emp_id, first_name, last_name, dept_id
FROM employees_q2

ORDER BY emp_id;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 2       |

### Query 3: New employees in Q2 (EXCEPT)
```sql
SELECT emp_id, first_name, last_name, dept_id, hire_date
FROM employees_q2

EXCEPT

SELECT emp_id, first_name, last_name, dept_id, hire_date
FROM employees_q1

ORDER BY emp_id;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_id | hire_date  |
|--------|------------|-----------|---------|------------|
| 6      | Diana      | Evans     | 2       | 2023-06-10 |
| 7      | Eve        | Foster    | 4       | 2023-01-15 |

### Query 4: Combined customer list from all regions (UNION ALL)
```sql
SELECT 
    customer_id,
    customer_name,
    region,
    total_orders,
    total_spent,
    ROUND(total_spent / NULLIF(total_orders, 0), 2) AS avg_order_value
FROM customers_east

UNION ALL

SELECT 
    customer_id,
    customer_name,
    region,
    total_orders,
    total_spent,
    ROUND(total_spent / NULLIF(total_orders, 0), 2) AS avg_order_value
FROM customers_west

ORDER BY total_spent DESC;
```

**Expected Result:**
| customer_id | customer_name    | region | total_orders | total_spent | avg_order_value |
|-------------|------------------|--------|--------------|-------------|-----------------|
| 5           | MegaCorp West    | West   | 18           | 180000.00   | 10000.00        |
| 1           | TechCorp East    | East   | 15           | 150000.00   | 10000.00        |
| 2           | CloudNet West    | West   | 14           | 140000.00   | 10000.00        |
| 3           | WebFlow East     | East   | 12           | 120000.00   | 10000.00        |
| 1           | TechCorp West    | West   | 10           | 100000.00   | 10000.00        |
| 2           | DataSys East     | East   | 8            | 80000.00    | 10000.00        |
| 3           | DataFlow West    | West   | 9            | 90000.00    | 10000.00        |
| 4           | InnovateIT East  | East   | 6            | 60000.00    | 10000.00        |

### Query 5: Projects completed in both quarters (INTERSECT)
```sql
SELECT 
    project_id,
    project_name,
    dept_id,
    budget
FROM projects_q1
WHERE status = 'Completed'

INTERSECT

SELECT 
    project_id,
    project_name,
    dept_id,
    budget
FROM projects_q2
WHERE status = 'Completed'

ORDER BY project_id;
```

**Expected Result:**
| project_id | project_name | dept_id | budget   |
|------------|--------------|---------|----------|
| 2          | CRM System   | 2       | 120000.00|

### Query 6: Products that existed in 2023 but not 2024 (EXCEPT)
```sql
SELECT 
    product_id,
    product_name,
    category,
    sales_2023 AS sales
FROM products_2023

EXCEPT

SELECT 
    product_id,
    product_name,
    category,
    sales_2024 AS sales
FROM products_2024

ORDER BY product_id;
```

**Expected Result:**
| product_id | product_name | category | sales    |
|------------|--------------|----------|----------|
| 3          | Cloud Storage| Services | 200000.00|
| 4          | Monitor 4K   | Hardware | 150000.00|

### Query 7: All projects across quarters with status (UNION with aggregation)
```sql
SELECT 
    project_id,
    project_name,
    dept_id,
    budget,
    'Q1' AS quarter,
    status
FROM projects_q1

UNION

SELECT 
    project_id,
    project_name,
    dept_id,
    budget,
    'Q2' AS quarter,
    status
FROM projects_q2

ORDER BY project_id, quarter;
```

**Expected Result:**
| project_id | project_name     | dept_id | budget   | quarter | status   |
|------------|------------------|---------|----------|---------|----------|
| 1          | Website Redesign | 1       | 100000.00| Q1      | Active   |
| 1          | Website Redesign | 1       | 100000.00| Q2      | Completed|
| 2          | CRM System       | 2       | 120000.00| Q1      | Completed|
| 2          | CRM System       | 2       | 120000.00| Q2      | Completed|
| 3          | Security Audit   | 1       | 50000.00 | Q1      | Completed|
| 4          | Training Program | 3       | 30000.00 | Q1      | Active   |
| 5          | Mobile App       | 1       | 80000.00 | Q2      | Active   |
| 6          | Data Warehouse   | 4       | 150000.00| Q2      | Planning |
| 7          | Marketing Campaign| 5      | 75000.00 | Q2      | Active   |

### Query 8: Departments with projects in both quarters (INTERSECT with subqueries)
```sql
SELECT DISTINCT d.dept_id, d.dept_name
FROM departments d
WHERE d.dept_id IN (
    SELECT DISTINCT dept_id FROM projects_q1
)

INTERSECT

SELECT DISTINCT d2.dept_id, d2.dept_name
FROM departments d2
WHERE d2.dept_id IN (
    SELECT DISTINCT dept_id FROM projects_q2
)

ORDER BY dept_id;
```

**Expected Result:**
| dept_id | dept_name |
|---------|-----------|
| 1       | IT        |
| 2       | Sales     |

## Key Learning Points
- **UNION**: Combines result sets, removes duplicates
- **UNION ALL**: Combines result sets, keeps duplicates
- **INTERSECT**: Returns common rows between result sets
- **EXCEPT**: Returns rows in first set but not second
- **Column compatibility**: Same number and types required
- **ORDER BY**: Applied to final combined result

## Common Set Operation Applications
- **Data consolidation**: Combining similar data from multiple sources
- **Gap analysis**: Finding differences between datasets
- **Overlap identification**: Common elements across categories
- **Historical comparisons**: Changes between time periods
- **Data quality**: Duplicate detection and cleanup

## Performance Notes
- UNION removes duplicates (more expensive than UNION ALL)
- INTERSECT and EXCEPT can be expensive on large datasets
- Consider UNION ALL when duplicates are acceptable
- Ensure proper indexing on join columns
- Use EXPLAIN to understand execution plans

## Extension Challenge
Create a comprehensive quarterly business report that uses all set operations to analyze employee changes, project status transitions, customer growth patterns, and product portfolio evolution across two quarters.
