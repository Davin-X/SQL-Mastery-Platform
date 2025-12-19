# Problem 03: Set Operations with IN, NOT IN, and EXISTS

## Business Context
Organizations often need to filter data based on membership in specific groups or relationships. This is crucial for access control, reporting hierarchies, and business rule enforcement.

## Requirements
Write SQL queries using IN, NOT IN, and EXISTS operators to filter employees based on set membership and relationships.

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
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE project (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100) NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE assignment (
    emp_id INT NOT NULL,
    proj_id INT NOT NULL,
    role VARCHAR(50),
    PRIMARY KEY (emp_id, proj_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (proj_id) REFERENCES project(proj_id)
);

CREATE TABLE high_performers (
    emp_id INT PRIMARY KEY,
    performance_rating DECIMAL(3, 2),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Finance');

INSERT INTO employee (emp_id, first_name, last_name, dept_id, salary) VALUES
(1, 'John', 'Doe', 1, 75000.00),
(2, 'Jane', 'Smith', 1, 80000.00),
(3, 'Bob', 'Wilson', 1, 72000.00),
(4, 'Alice', 'Brown', 2, 65000.00),
(5, 'Charlie', 'Davis', 2, 75000.00),
(6, 'Diana', 'Evans', 2, 72000.00),
(7, 'Eve', 'Foster', 3, 55000.00),
(8, 'Frank', 'Garcia', 3, 60000.00),
(9, 'Grace', 'Hill', 4, 85000.00),
(10, 'Henry', 'Adams', 4, 78000.00);

INSERT INTO project (proj_id, proj_name, budget, status) VALUES
(1, 'Website Redesign', 100000.00, 'Active'),
(2, 'Mobile App', 80000.00, 'Active'),
(3, 'CRM System', 120000.00, 'Completed'),
(4, 'Data Warehouse', 150000.00, 'Active'),
(5, 'Security Audit', 50000.00, 'Planning');

INSERT INTO assignment (emp_id, proj_id, role) VALUES
(1, 1, 'Lead Developer'),
(2, 1, 'Senior Developer'),
(1, 2, 'Architect'),
(3, 2, 'Developer'),
(4, 3, 'Business Analyst'),
(5, 3, 'Project Manager'),
(2, 4, 'Data Engineer'),
(9, 4, 'Database Admin'),
(6, 5, 'Security Consultant');

INSERT INTO high_performers (emp_id, performance_rating) VALUES
(1, 4.8),
(2, 4.9),
(5, 4.7),
(9, 4.6);
```

## Query Requirements

### Query 1: Employees in IT or Sales departments (using IN)
```sql
SELECT emp_id, first_name, last_name, dept_name, salary
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.dept_id IN (1, 2)
ORDER BY d.dept_name, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary    |
|--------|------------|-----------|-----------|-----------|
| 1      | John       | Doe       | IT        | 75000.00  |
| 2      | Jane       | Smith     | IT        | 80000.00  |
| 3      | Bob        | Wilson    | IT        | 72000.00  |
| 4      | Alice      | Brown     | Sales     | 65000.00  |
| 5      | Charlie    | Davis     | Sales     | 75000.00  |
| 6      | Diana      | Evans     | Sales     | 72000.00  |

### Query 2: Employees NOT assigned to any projects (using NOT IN)
```sql
SELECT emp_id, first_name, last_name, dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE e.emp_id NOT IN (
    SELECT DISTINCT emp_id FROM assignment
)
ORDER BY d.dept_name, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name |
|--------|------------|-----------|-----------|
| 7      | Eve        | Foster    | HR        |
| 8      | Frank      | Garcia    | HR        |
| 10     | Henry      | Adams     | Finance   |

### Query 3: High performers (using EXISTS)
```sql
SELECT e.emp_id, e.first_name, e.last_name, 
       d.dept_name, e.salary, hp.performance_rating
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN high_performers hp ON e.emp_id = hp.emp_id
WHERE EXISTS (
    SELECT 1 FROM high_performers hp2 
    WHERE hp2.emp_id = e.emp_id AND hp2.performance_rating >= 4.5
)
ORDER BY hp.performance_rating DESC, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary    | performance_rating |
|--------|------------|-----------|-----------|-------------------|
| 2      | Jane       | Smith     | IT        | 80000.00  | 4.9               |
| 1      | John       | Doe       | IT        | 75000.00  | 4.8               |
| 5      | Charlie    | Davis     | Sales     | 75000.00  | 4.7               |
| 9      | Grace      | Hill      | Finance   | 85000.00  | 4.6               |

### Query 4: Employees on active projects (using EXISTS)
```sql
SELECT DISTINCT e.emp_id, e.first_name, e.last_name, d.dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
WHERE EXISTS (
    SELECT 1 FROM assignment a
    INNER JOIN project p ON a.proj_id = p.proj_id
    WHERE a.emp_id = e.emp_id AND p.status = 'Active'
)
ORDER BY d.dept_name, e.last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name |
|--------|------------|-----------|-----------|
| 1      | John       | Doe       | IT        |
| 2      | Jane       | Smith     | IT        |
| 3      | Bob        | Wilson    | IT        |
| 4      | Alice      | Brown     | Sales     |
| 5      | Charlie    | Davis     | Sales     |
| 9      | Grace      | Hill      | Finance   |

## Key Learning Points
- **IN operator** tests membership in a list of values
- **NOT IN** finds records not in a specified list
- **EXISTS** tests for the existence of related records
- **Subqueries** in WHERE clauses provide flexible filtering
- **DISTINCT** with EXISTS prevents duplicate results

## Performance Considerations
- **IN with small lists** is efficient
- **NOT IN with NULLs** can be problematic
- **EXISTS** often performs better than IN for correlated subqueries
- **Proper indexing** on foreign keys improves EXISTS performance

## Common Patterns
- **List filtering**: `WHERE dept_id IN (1, 3, 5)`
- **Exclusion**: `WHERE emp_id NOT IN (SELECT emp_id FROM terminated)`
- **Relationship checks**: `WHERE EXISTS (SELECT 1 FROM assignments WHERE ...)`
- **Complex conditions**: `WHERE emp_id IN (SELECT emp_id FROM high_performers WHERE rating > 4.5)`

## Extension Challenge
Find employees who are assigned to projects with budgets over $100,000 but are not high performers.
