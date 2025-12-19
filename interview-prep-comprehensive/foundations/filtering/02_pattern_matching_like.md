# Problem 02: Pattern Matching with LIKE - Name and Text Search

## Business Context
HR and management often need to search for employees by name patterns, email domains, or other text-based criteria. This is essential for communication, reporting, and administrative tasks.

## Requirements
Write SQL queries using LIKE operator to find employees based on name patterns and text matching criteria.

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
    email VARCHAR(100),
    dept_id INT,
    job_title VARCHAR(100),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Finance');

INSERT INTO employee (emp_id, first_name, last_name, email, dept_id, job_title) VALUES
(1, 'John', 'Doe', 'john.doe@company.com', 1, 'Software Engineer'),
(2, 'Jane', 'Smith', 'jane.smith@company.com', 1, 'Senior Developer'),
(3, 'Bob', 'Wilson', 'bob.wilson@company.com', 1, 'Database Administrator'),
(4, 'Alice', 'Brown', 'alice.brown@company.com', 2, 'Sales Manager'),
(5, 'Charlie', 'Davis', 'charlie.davis@company.com', 2, 'Sales Representative'),
(6, 'Diana', 'Evans', 'diana.evans@company.com', 2, 'Account Executive'),
(7, 'Eve', 'Foster', 'eve.foster@company.com', 3, 'HR Specialist'),
(8, 'Frank', 'Garcia', 'frank.garcia@company.com', 3, 'HR Manager'),
(9, 'Grace', 'Hill', 'grace.hill@company.com', 4, 'Financial Analyst'),
(10, 'Henry', 'Adams', 'henry.adams@company.com', 4, 'Senior Accountant');
```

## Query Requirements

### Query 1: Employees whose last name starts with 'D'
```sql
SELECT emp_id, first_name, last_name, email
FROM employee
WHERE last_name LIKE 'D%'
ORDER BY last_name, first_name;
```

**Expected Result:**
| emp_id | first_name | last_name | email                   |
|--------|------------|-----------|-------------------------|
| 10     | Henry      | Adams     | henry.adams@company.com |
| 5      | Charlie    | Davis     | charlie.davis@company.com |
| 1      | John       | Doe       | john.doe@company.com    |

### Query 2: Employees whose first name contains 'a'
```sql
SELECT emp_id, first_name, last_name, email
FROM employee
WHERE LOWER(first_name) LIKE '%a%'
ORDER BY first_name, last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | email                   |
|--------|------------|-----------|-------------------------|
| 10     | Henry      | Adams     | henry.adams@company.com |
| 4      | Alice      | Brown     | alice.brown@company.com |
| 5      | Charlie    | Davis     | charlie.davis@company.com |
| 6      | Diana      | Evans     | diana.evans@company.com  |
| 9      | Grace      | Hill      | grace.hill@company.com   |
| 2      | Jane       | Smith     | jane.smith@company.com   |

### Query 3: Employees with job titles containing 'Manager'
```sql
SELECT emp_id, first_name, last_name, job_title, dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.job_title LIKE '%Manager%'
ORDER BY d.dept_name, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | job_title      | dept_name |
|--------|------------|-----------|----------------|-----------|
| 8      | Frank      | Garcia    | HR Manager     | HR        |
| 4      | Alice      | Brown     | Sales Manager  | Sales     |

### Query 4: Employees whose email ends with specific domain
```sql
SELECT emp_id, first_name, last_name, email
FROM employee
WHERE email LIKE '%@company.com'
ORDER BY last_name, first_name;
```

**Expected Result:**
| emp_id | first_name | last_name | email                   |
|--------|------------|-----------|-------------------------|
| 10     | Henry      | Adams     | henry.adams@company.com |
| 4      | Alice      | Brown     | alice.brown@company.com |
| 5      | Charlie    | Davis     | charlie.davis@company.com |
| 1      | John       | Doe       | john.doe@company.com    |
| 6      | Diana      | Evans     | diana.evans@company.com  |
| 7      | Eve        | Foster    | eve.foster@company.com   |
| 8      | Frank      | Garcia    | frank.garcia@company.com |
| 9      | Grace      | Hill      | grace.hill@company.com   |
| 2      | Jane       | Smith     | jane.smith@company.com   |
| 3      | Bob        | Wilson    | bob.wilson@company.com   |

### Query 5: Employees whose last name has exactly 5 characters
```sql
SELECT emp_id, first_name, last_name, LENGTH(last_name) as name_length
FROM employee
WHERE last_name LIKE '_____'
ORDER BY last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | name_length |
|--------|------------|-----------|-------------|
| 10     | Henry      | Adams     | 5           |
| 4      | Alice      | Brown     | 5           |
| 5      | Charlie    | Davis     | 5           |
| 6      | Diana      | Evans     | 5           |
| 9      | Grace      | Hill      | 4           |
| 2      | Jane       | Smith     | 5           |

## Key Learning Points
- **LIKE operator** uses wildcards: `%` (any characters) and `_` (single character)
- **Case sensitivity**: Use LOWER() or UPPER() for case-insensitive searches
- **Pattern matching**: Useful for name searches, email validation, text filtering
- **Underscore (`_`)** matches exactly one character
- **Percent (`%`)** matches zero or more characters

## Common LIKE Patterns
- **Starts with**: `column LIKE 'prefix%'`
- **Ends with**: `column LIKE '%suffix'`
- **Contains**: `column LIKE '%text%'`
- **Fixed length**: `column LIKE '_____'` (5 underscores = 5 chars)
- **Specific position**: `column LIKE '_a%'` (second char is 'a')

## Performance Notes
- LIKE with leading `%` cannot use indexes efficiently
- Consider full-text search for complex text matching
- Leading character searches can use indexes
- Avoid LIKE when exact matches are sufficient

## Extension Challenge
Create a query that finds employees whose names contain double letters (like "Alice" with double 'l', or "Charlie" with double 'l').
