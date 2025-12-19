# Problem 02: RANK() and DENSE_RANK() - Handling Ties in Rankings

## Business Context
Performance management systems need to handle ranking scenarios where employees have identical scores or salaries. Different ranking functions (RANK vs DENSE_RANK) produce different results for tied values.

## Requirements
Write SQL queries using RANK() and DENSE_RANK() to demonstrate how they handle tied values differently, and show practical applications for each.

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
    performance_score DECIMAL(3, 1),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data with ties
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary, performance_score) VALUES
(1, 'John', 'Doe', 1, 75000.00, 4.5),
(2, 'Jane', 'Smith', 1, 80000.00, 4.8),
(3, 'Bob', 'Wilson', 1, 72000.00, 3.9),
(4, 'Alice', 'Brown', 2, 65000.00, 4.2),
(5, 'Charlie', 'Davis', 2, 75000.00, 4.2),  -- Same score as Alice
(6, 'Diana', 'Evans', 2, 72000.00, 4.7),
(7, 'Eve', 'Foster', 3, 55000.00, 4.0),
(8, 'Frank', 'Garcia', 3, 60000.00, 4.0),   -- Same score as Eve
(9, 'Grace', 'Hill', 3, 60000.00, 4.0);    -- Same score as Eve and Frank
```

## Query Requirements

### Query 1: Compare RANK() vs DENSE_RANK() with tied performance scores
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.performance_score,
    RANK() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.performance_score DESC
    ) AS rank_performance,
    DENSE_RANK() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.performance_score DESC
    ) AS dense_rank_performance
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.performance_score DESC, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | performance_score | rank_performance | dense_rank_performance |
|--------|------------|-----------|-----------|-------------------|------------------|------------------------|
| 2      | Jane       | Smith     | IT        | 4.8               | 1                | 1                      |
| 1      | John       | Doe       | IT        | 4.5               | 2                | 2                      |
| 3      | Bob        | Wilson    | IT        | 3.9               | 3                | 3                      |
| 6      | Diana      | Evans     | Sales     | 4.7               | 1                | 1                      |
| 4      | Alice      | Brown     | Sales     | 4.2               | 2                | 2                      |
| 5      | Charlie    | Davis     | Sales     | 4.2               | 2                | 2                      |
| 7      | Eve        | Foster    | HR        | 4.0               | 1                | 1                      |
| 8      | Frank      | Garcia    | HR        | 4.0               | 1                | 1                      |
| 9      | Grace      | Hill      | HR        | 4.0               | 1                | 1                      |

### Query 2: Salary ranking with ties
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    RANK() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.salary DESC
    ) AS salary_rank,
    DENSE_RANK() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.salary DESC
    ) AS salary_dense_rank,
    ROW_NUMBER() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.salary DESC
    ) AS salary_row_number
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.salary DESC, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary    | salary_rank | salary_dense_rank | salary_row_number |
|--------|------------|-----------|-----------|-----------|-------------|-------------------|-------------------|
| 2      | Jane       | Smith     | IT        | 80000.00  | 1           | 1                 | 1                 |
| 1      | John       | Doe       | IT        | 75000.00  | 2           | 2                 | 2                 |
| 3      | Bob        | Wilson    | IT        | 72000.00  | 3           | 3                 | 3                 |
| 5      | Charlie    | Davis     | Sales     | 75000.00  | 1           | 1                 | 1                 |
| 6      | Diana      | Evans     | Sales     | 72000.00  | 2           | 2                 | 2                 |
| 4      | Alice      | Brown     | Sales     | 65000.00  | 3           | 3                 | 3                 |
| 8      | Frank      | Garcia    | HR        | 60000.00  | 1           | 1                 | 1                 |
| 9      | Grace      | Hill      | HR        | 60000.00  | 1           | 1                 | 2                 |
| 7      | Eve        | Foster    | HR        | 55000.00  | 3           | 2                 | 3                 |

### Query 3: Top performers using DENSE_RANK (no gaps in ranking)
```sql
WITH ranked_employees AS (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        d.dept_name,
        e.performance_score,
        DENSE_RANK() OVER (
            PARTITION BY e.dept_id 
            ORDER BY e.performance_score DESC
        ) AS performance_rank
    FROM employee e
    INNER JOIN department d ON e.dept_id = d.dept_id
)
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_name,
    performance_score,
    performance_rank
FROM ranked_employees
WHERE performance_rank <= 2
ORDER BY dept_name, performance_rank, performance_score DESC, last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | performance_score | performance_rank |
|--------|------------|-----------|-----------|-------------------|------------------|
| 2      | Jane       | Smith     | IT        | 4.8               | 1                |
| 1      | John       | Doe       | IT        | 4.5               | 2                |
| 6      | Diana      | Evans     | Sales     | 4.7               | 1                |
| 4      | Alice      | Brown     | Sales     | 4.2               | 2                |
| 5      | Charlie    | Davis     | Sales     | 4.2               | 2                |
| 7      | Eve        | Foster    | HR        | 4.0               | 1                |
| 8      | Frank      | Garcia    | HR        | 4.0               | 1                |
| 9      | Grace      | Hill      | HR        | 4.0               | 1                |

### Query 4: Comparing ranking functions side by side
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.dept_name,
    e.performance_score,
    ROW_NUMBER() OVER (ORDER BY e.performance_score DESC) AS row_num,
    RANK() OVER (ORDER BY e.performance_score DESC) AS rank_func,
    DENSE_RANK() OVER (ORDER BY e.performance_score DESC) AS dense_rank_func
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.performance_score DESC, employee_name;
```

**Expected Result:**
| employee_name    | dept_name | performance_score | row_num | rank_func | dense_rank_func |
|------------------|-----------|-------------------|---------|-----------|-----------------|
| Jane Smith      | IT        | 4.8               | 1       | 1         | 1               |
| Diana Evans     | Sales     | 4.7               | 2       | 2         | 2               |
| John Doe        | IT        | 4.5               | 3       | 3         | 3               |
| Alice Brown     | Sales     | 4.2               | 4       | 4         | 4               |
| Charlie Davis   | Sales     | 4.2               | 5       | 4         | 4               |
| Eve Foster      | HR        | 4.0               | 6       | 6         | 5               |
| Frank Garcia    | HR        | 4.0               | 7       | 6         | 5               |
| Grace Hill      | HR        | 4.0               | 8       | 6         | 5               |
| Bob Wilson      | IT        | 3.9               | 9       | 9         | 6               |

## Key Learning Points
- **RANK()** skips numbers when there are ties (creates gaps)
- **DENSE_RANK()** never skips numbers (no gaps)
- **ROW_NUMBER()** always assigns unique sequential numbers
- Choose based on business requirements for handling ties
- All three can be partitioned and ordered independently

## When to Use Each Function
- **ROW_NUMBER()**: When you need unique identifiers or pagination
- **RANK()**: When gaps in ranking are acceptable/meaningful
- **DENSE_RANK()**: When you want consecutive rankings without gaps
- **RANK() vs DENSE_RANK()**: Depends on whether tied values should share ranks

## Performance Notes
- All ranking functions have similar performance characteristics
- Cost increases with dataset size and number of partitions
- Consider filtering data before applying window functions
- Proper indexing on partitioning and ordering columns helps

## Extension Challenge
Create a query that shows the difference between RANK() and DENSE_RANK() for each department, highlighting where they produce different results.
