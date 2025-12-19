# Problem 04: NULL Handling with IS NULL and IS NOT NULL

## Business Context
Many business datasets contain missing or incomplete information. HR systems often have employees without assigned managers, departments without budget allocations, or incomplete contact information. Proper NULL handling is crucial for accurate reporting and data analysis.

## Requirements
Write SQL queries to handle NULL values appropriately using IS NULL and IS NOT NULL operators, along with COALESCE and NULLIF functions.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2),
    manager_id INT
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2),
    hire_date DATE,
    manager_id INT,
    phone VARCHAR(20),
    email VARCHAR(100),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data with NULL values
INSERT INTO department (dept_id, dept_name, budget, manager_id) VALUES
(1, 'IT', 500000.00, 1),
(2, 'Sales', 750000.00, 4),
(3, 'HR', NULL, NULL),
(4, 'Finance', 600000.00, 9),
(5, 'Marketing', NULL, NULL);

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary, hire_date, manager_id, phone, email) VALUES
(1, 'John', 'Doe', 1, 75000.00, '2020-01-15', NULL, '555-0101', 'john.doe@company.com'),
(2, 'Jane', 'Smith', 1, 80000.00, '2019-03-20', 1, NULL, 'jane.smith@company.com'),
(3, 'Bob', 'Wilson', 1, NULL, '2021-06-10', 1, '555-0103', NULL),
(4, 'Alice', 'Brown', 2, 65000.00, NULL, NULL, '555-0104', 'alice.brown@company.com'),
(5, 'Charlie', 'Davis', 2, 75000.00, '2020-08-15', 4, NULL, NULL),
(6, 'Diana', 'Evans', NULL, 72000.00, '2019-12-01', NULL, '555-0106', 'diana.evans@company.com'),
(7, 'Eve', 'Foster', 3, 55000.00, '2022-02-20', NULL, NULL, NULL),
(8, 'Frank', 'Garcia', 3, NULL, '2021-08-10', NULL, '555-0108', 'frank.garcia@company.com');
```

## Query Requirements

### Query 1: Employees without assigned managers
```sql
SELECT emp_id, first_name, last_name, dept_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
WHERE e.manager_id IS NULL
ORDER BY e.last_name, e.first_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name |
|--------|------------|-----------|-----------|
| 4      | Alice      | Brown     | Sales     |
| 6      | Diana      | Evans     | NULL      |
| 7      | Eve        | Foster    | HR        |
| 1      | John       | Doe       | IT        |
| 2      | Jane       | Smith     | IT        |
| 8      | Frank      | Garcia    | HR        |

### Query 2: Departments without budget allocations
```sql
SELECT dept_id, dept_name, budget
FROM department
WHERE budget IS NULL
ORDER BY dept_name;
```

**Expected Result:**
| dept_id | dept_name | budget |
|---------|-----------|--------|
| 3       | HR        | NULL   |
| 5       | Marketing | NULL   |

### Query 3: Employees with complete contact information (using IS NOT NULL)
```sql
SELECT emp_id, first_name, last_name, phone, email
FROM employee
WHERE phone IS NOT NULL 
  AND email IS NOT NULL
ORDER BY last_name, first_name;
```

**Expected Result:**
| emp_id | first_name | last_name | phone     | email                   |
|--------|------------|-----------|-----------|-------------------------|
| 1      | John       | Doe       | 555-0101  | john.doe@company.com    |
| 4      | Alice      | Brown     | 555-0104  | alice.brown@company.com |
| 6      | Diana      | Evans     | 555-0106  | diana.evans@company.com |
| 8      | Frank      | Garcia    | 555-0108  | frank.garcia@company.com |

### Query 4: Employee salary report with NULL handling (using COALESCE)
```sql
SELECT 
    emp_id, 
    first_name, 
    last_name, 
    COALESCE(salary, 0) AS salary,
    COALESCE(phone, 'No phone') AS phone,
    COALESCE(email, 'No email') AS email
FROM employee
ORDER BY COALESCE(salary, 0) DESC, last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    | phone     | email                   |
|--------|------------|-----------|-----------|-----------|-------------------------|
| 2      | Jane       | Smith     | 80000.00  | No phone  | jane.smith@company.com  |
| 1      | John       | Doe       | 75000.00  | 555-0101  | john.doe@company.com    |
| 5      | Charlie    | Davis     | 75000.00  | No phone  | No email                |
| 6      | Diana      | Evans     | 72000.00  | 555-0106  | diana.evans@company.com |
| 4      | Alice      | Brown     | 65000.00  | 555-0104  | alice.brown@company.com |
| 7      | Eve        | Foster    | 55000.00  | No phone  | No email                |
| 8      | Frank      | Garcia    | 0.00      | 555-0108  | frank.garcia@company.com|
| 3      | Bob        | Wilson    | 0.00      | 555-0103  | No email                |

### Query 5: Department budget analysis with NULLIF
```sql
SELECT 
    dept_name,
    COALESCE(budget, 0) AS budget,
    CASE 
        WHEN budget IS NULL THEN 'Budget not set'
        WHEN budget > 500000 THEN 'High budget'
        WHEN budget > 300000 THEN 'Medium budget'
        ELSE 'Low budget'
    END AS budget_category
FROM department
ORDER BY COALESCE(budget, 0) DESC, dept_name;
```

**Expected Result:**
| dept_name | budget    | budget_category |
|-----------|-----------|-----------------|
| Sales     | 750000.00 | High budget    |
| Finance   | 600000.00 | High budget    |
| IT        | 500000.00 | Medium budget  |
| HR        | 0.00      | Budget not set |
| Marketing | 0.00      | Budget not set |

## Key Learning Points
- **IS NULL** tests for NULL values specifically
- **IS NOT NULL** finds non-null values
- **COALESCE** provides default values for NULLs
- **NULLIF** converts specific values to NULL
- NULL comparisons with `= NULL` always return false

## Common NULL Handling Patterns
- **Default values**: `COALESCE(column, 'N/A')`
- **Conditional logic**: `CASE WHEN column IS NULL THEN 'Missing' ELSE column END`
- **Filtering**: `WHERE column IS NOT NULL`
- **Calculations**: `AVG(COALESCE(salary, 0))`

## Performance Notes
- IS NULL/IS NOT NULL can use indexes
- COALESCE is efficient for single replacements
- CASE statements are flexible but slightly slower
- Consider table constraints to minimize NULLs

## Extension Challenge
Create a data quality report showing the percentage of NULL values in each column of the employee table.
