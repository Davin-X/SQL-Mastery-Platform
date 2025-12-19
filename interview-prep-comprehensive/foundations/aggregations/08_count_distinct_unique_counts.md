# Problem 08: COUNT DISTINCT - Unique Value Analysis

## Business Context
HR is analyzing workforce diversity and needs to understand how many unique skills or certifications employees have across departments. This helps identify skill gaps and training opportunities.

## Requirements
Write a SQL query to find how many unique departments employees work in and how many unique employees each department has.

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
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE employee_skills (
    emp_id INT NOT NULL,
    skill_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (emp_id, skill_name),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 1),
(3, 'Bob', 'Wilson', 2),
(4, 'Alice', 'Brown', 2),
(5, 'Charlie', 'Davis', 3);

INSERT INTO employee_skills (emp_id, skill_name) VALUES
(1, 'Python'), (1, 'SQL'), (1, 'Java'),
(2, 'SQL'), (2, 'Excel'), (2, 'Python'),
(3, 'Salesforce'), (3, 'Excel'), (3, 'Communication'),
(4, 'Salesforce'), (4, 'Communication'),
(5, 'HR Policies'), (5, 'Communication'), (5, 'Excel');
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 1       |
| 3      | Bob        | Wilson    | 2       |
| 4      | Alice      | Brown     | 2       |
| 5      | Charlie    | Davis     | 3       |

**employee_skills table:**
| emp_id | skill_name     |
|--------|----------------|
| 1      | Python         |
| 1      | SQL            |
| 1      | Java           |
| 2      | SQL            |
| 2      | Excel          |
| 2      | Python         |
| 3      | Salesforce    |
| 3      | Excel          |
| 3      | Communication |
| 4      | Salesforce    |
| 4      | Communication |
| 5      | HR Policies    |
| 5      | Communication |
| 5      | Excel          |

## Expected Output
| department_name | employee_count | unique_skills | avg_skills_per_employee |
|-----------------|----------------|---------------|-------------------------|
| HR             | 1              | 3             | 3.0                     |
| IT             | 2              | 4             | 2.5                     |
| Sales          | 2              | 3             | 2.0                     |

## Notes
- Count distinct skills per department
- Calculate average skills per employee
- Show both total and unique counts

## Solution
```sql
SELECT 
    d.dept_name AS department_name,
    COUNT(DISTINCT e.emp_id) AS employee_count,
    COUNT(DISTINCT es.skill_name) AS unique_skills,
    ROUND(
        COUNT(es.skill_name) * 1.0 / COUNT(DISTINCT e.emp_id), 
        1
    ) AS avg_skills_per_employee
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
LEFT JOIN employee_skills es ON e.emp_id = es.emp_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(DISTINCT e.emp_id) > 0
ORDER BY d.dept_name;
```

## Key Learning Points
- COUNT(DISTINCT) counts unique values in a group
- Multiple COUNT functions can be used together
- Arithmetic with aggregates requires careful casting
- DISTINCT affects which rows are counted

## Common Applications
- Diversity analysis (unique demographics)
- Skill gap identification
- Duplicate detection
- Uniqueness validation

## Performance Notes
- COUNT(DISTINCT) can be expensive on large datasets
- Consider indexing on columns used in DISTINCT
- Multiple DISTINCT operations compound performance impact
- Pre-aggregated tables can help for complex DISTINCT queries

## Extension Challenge
Find the most common skill in each department and how many employees have it.
