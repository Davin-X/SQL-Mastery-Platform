# Problem 01: Basic WHERE Conditions - Employee Filtering

## Business Context
HR needs to generate targeted reports for specific employee groups based on salary ranges and departments. This is a common requirement for compensation analysis and workforce planning.

## Requirements
Write SQL queries to filter employees based on different criteria. Create separate queries for each requirement.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Finance');

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary, hire_date) VALUES
(1, 'John', 'Doe', 1, 75000.00, '2020-01-15'),
(2, 'Jane', 'Smith', 1, 80000.00, '2019-03-20'),
(3, 'Bob', 'Wilson', 1, 72000.00, '2021-06-10'),
(4, 'Alice', 'Brown', 2, 65000.00, '2018-11-05'),
(5, 'Charlie', 'Davis', 2, 75000.00, '2020-08-15'),
(6, 'Diana', 'Evans', 2, 72000.00, '2019-12-01'),
(7, 'Eve', 'Foster', 3, 55000.00, '2022-02-20'),
(8, 'Frank', 'Garcia', 3, 60000.00, '2021-08-10'),
(9, 'Grace', 'Hill', 4, 85000.00, '2017-09-10'),
(10, 'Henry', 'Adams', 4, 78000.00, '2019-05-25');
```

## Query Requirements

### Query 1: Employees with salary > 70,000
```sql
SELECT emp_id, first_name, last_name, salary
FROM employee
WHERE salary > 70000.00
ORDER BY salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    |
|--------|------------|-----------|-----------|
| 9      | Grace      | Hill      | 85000.00  |
| 2      | Jane       | Smith     | 80000.00  |
| 10     | Henry      | Adams     | 78000.00  |
| 1      | John       | Doe       | 75000.00  |
| 5      | Charlie    | Davis     | 75000.00  |
| 6      | Diana      | Evans     | 72000.00  |
| 3      | Bob        | Wilson    | 72000.00  |

### Query 2: IT department employees (dept_id = 1)
```sql
SELECT emp_id, first_name, last_name, dept_name, salary
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.dept_id = 1
ORDER BY e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary    |
|--------|------------|-----------|-----------|-----------|
| 1      | John       | Doe       | IT        | 75000.00  |
| 2      | Jane       | Smith     | IT        | 80000.00  |
| 3      | Bob        | Wilson    | IT        | 72000.00  |

### Query 3: Employees hired after 2020
```sql
SELECT emp_id, first_name, last_name, hire_date, salary
FROM employee
WHERE hire_date > '2020-01-01'
ORDER BY hire_date;
```

**Expected Result:**
| emp_id | first_name | last_name | hire_date  | salary    |
|--------|------------|-----------|------------|-----------|
| 1      | John       | Doe       | 2020-01-15 | 75000.00  |
| 5      | Charlie    | Davis     | 2020-08-15 | 75000.00  |
| 3      | Bob        | Wilson    | 2021-06-10 | 72000.00  |
| 8      | Frank      | Garcia    | 2021-08-10 | 60000.00  |
| 7      | Eve        | Foster    | 2022-02-20 | 55000.00  |

### Query 4: Employees with salary between 60,000 and 80,000
```sql
SELECT emp_id, first_name, last_name, salary
FROM employee
WHERE salary BETWEEN 60000.00 AND 80000.00
ORDER BY salary DESC, last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    |
|--------|------------|-----------|-----------|
| 2      | Jane       | Smith     | 80000.00  |
| 10     | Henry      | Adams     | 78000.00  |
| 1      | John       | Doe       | 75000.00  |
| 5      | Charlie    | Davis     | 75000.00  |
| 6      | Diana      | Evans     | 72000.00  |
| 3      | Bob        | Wilson    | 72000.00  |
| 8      | Frank      | Garcia    | 60000.00  |

## Key Learning Points
- **WHERE clause** filters rows before they are returned
- **Comparison operators**: `>`, `<`, `=`, `>=`, `<=`
- **BETWEEN** operator for range filtering (inclusive)
- **Date comparisons** work with standard date formats
- **JOIN + WHERE** allows filtering on joined tables

## Common WHERE Patterns
- **Numeric comparisons**: `salary > 50000`
- **Date filtering**: `hire_date >= '2020-01-01'`
- **Range filtering**: `salary BETWEEN 30000 AND 70000`
- **Category filtering**: `dept_id IN (1, 3, 5)`

## Performance Notes
- WHERE conditions can use indexes for fast filtering
- Place the most selective conditions first
- Avoid functions on columns in WHERE clauses when possible
- Consider computed columns for complex date calculations

## Extension Challenge
Create a query that finds employees who earn more than the average salary in their department.
