# Problem 01: ROW_NUMBER() - Employee Ranking by Salary

## Business Context
HR needs to create employee rankings for performance reviews and compensation planning. Each department should have its own ranking system based on salary.

## Requirements
Write SQL queries using ROW_NUMBER() to rank employees by salary within each department and across the entire company.

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

### Query 1: Department-wise salary ranking (highest to lowest)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    ROW_NUMBER() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.salary DESC
    ) AS dept_salary_rank
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, dept_salary_rank;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | dept_salary_rank |
|--------|------------|-----------|-----------|----------|------------------|
| 2      | Jane       | Smith     | IT        | 80000.00 | 1                |
| 1      | John       | Doe       | IT        | 75000.00 | 2                |
| 3      | Bob        | Wilson    | IT        | 72000.00 | 3                |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 1                |
| 6      | Diana      | Evans     | Sales     | 72000.00 | 2                |
| 4      | Alice      | Brown     | Sales     | 65000.00 | 3                |
| 8      | Frank      | Garcia    | HR        | 60000.00 | 1                |
| 7      | Eve        | Foster    | HR        | 55000.00 | 2                |
| 9      | Grace      | Hill      | Finance   | 85000.00 | 1                |
| 10     | Henry      | Adams     | Finance   | 78000.00 | 2                |

### Query 2: Company-wide salary ranking
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS company_salary_rank
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY company_salary_rank;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | company_salary_rank |
|--------|------------|-----------|-----------|----------|---------------------|
| 9      | Grace      | Hill      | Finance   | 85000.00 | 1                   |
| 2      | Jane       | Smith     | IT        | 80000.00 | 2                   |
| 10     | Henry      | Adams     | Finance   | 78000.00 | 3                   |
| 1      | John       | Doe       | IT        | 75000.00 | 4                   |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 5                   |
| 6      | Diana      | Evans     | Sales     | 72000.00 | 6                   |
| 3      | Bob        | Wilson    | IT        | 72000.00 | 7                   |
| 4      | Alice      | Brown     | Sales     | 65000.00 | 8                   |
| 8      | Frank      | Garcia    | HR        | 60000.00 | 9                   |
| 7      | Eve        | Foster    | HR        | 55000.00 | 10                  |

### Query 3: Hire date ranking within departments (most recent first)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.hire_date,
    ROW_NUMBER() OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.hire_date DESC
    ) AS dept_seniority_rank
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, dept_seniority_rank;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | hire_date  | dept_seniority_rank |
|--------|------------|-----------|-----------|------------|---------------------|
| 3      | Bob        | Wilson    | IT        | 2021-06-10 | 1                   |
| 1      | John       | Doe       | IT        | 2020-01-15 | 2                   |
| 2      | Jane       | Smith     | IT        | 2019-03-20 | 3                   |
| 5      | Charlie    | Davis     | Sales     | 2020-08-15 | 1                   |
| 6      | Diana      | Evans     | Sales     | 2019-12-01 | 2                   |
| 4      | Alice      | Brown     | Sales     | 2018-11-05 | 3                   |
| 8      | Frank      | Garcia    | HR        | 2021-08-10 | 1                   |
| 7      | Eve        | Foster    | HR        | 2022-02-20 | 2                   |
| 10     | Henry      | Adams     | Finance   | 2019-05-25 | 1                   |
| 9      | Grace      | Hill      | Finance   | 2017-09-10 | 2                   |

### Query 4: Top 2 highest paid employees per department
```sql
WITH ranked_employees AS (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        d.dept_name,
        e.salary,
        ROW_NUMBER() OVER (
            PARTITION BY e.dept_id 
            ORDER BY e.salary DESC
        ) AS dept_rank
    FROM employee e
    INNER JOIN department d ON e.dept_id = d.dept_id
)
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_name,
    salary,
    dept_rank
FROM ranked_employees
WHERE dept_rank <= 2
ORDER BY dept_name, dept_rank;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | dept_rank |
|--------|------------|-----------|-----------|----------|-----------|
| 2      | Jane       | Smith     | IT        | 80000.00 | 1         |
| 1      | John       | Doe       | IT        | 75000.00 | 2         |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 1         |
| 6      | Diana      | Evans     | Sales     | 72000.00 | 2         |
| 8      | Frank      | Garcia    | HR        | 60000.00 | 1         |
| 7      | Eve        | Foster    | HR        | 55000.00 | 2         |
| 9      | Grace      | Hill      | Finance   | 85000.00 | 1         |
| 10     | Henry      | Adams     | Finance   | 78000.00 | 2         |

## Key Learning Points
- **ROW_NUMBER()** assigns unique sequential numbers within partitions
- **PARTITION BY** creates separate ranking groups
- **ORDER BY** within OVER() clause determines ranking order
- Window functions operate on result sets, not groups like aggregate functions
- Can be used with CTEs for complex ranking scenarios

## Common ROW_NUMBER() Applications
- **Top-N queries**: Find top performers per category
- **Deduplication**: Identify duplicate records
- **Pagination**: Number results for display
- **Ranking systems**: Performance and leaderboard rankings

## Performance Notes
- ROW_NUMBER() can be expensive on large datasets
- Proper indexing on partition and order columns helps
- Consider filtering with WHERE before applying window functions
- ROW_NUMBER() always produces unique values (unlike RANK)

## Extension Challenge
Create a query that shows employees who are in the top 25% of salaries within their department.
