# Problem 08: JOIN with Complex Conditions - Department Transfer Candidates

## Business Context
HR is planning department reorganizations and needs to identify employees who could potentially transfer to other departments based on their skills and current assignments.

## Requirements
Write a SQL query to find employees who are NOT in the IT department but have worked on IT projects. Show their current department and the IT projects they've worked on.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT NOT NULL
);

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE project (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100) NOT NULL,
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE assignment (
    emp_id INT NOT NULL,
    proj_id INT NOT NULL,
    PRIMARY KEY (emp_id, proj_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (proj_id) REFERENCES project(proj_id)
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales');

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 2),
(3, 'Bob', 'Wilson', 2);

INSERT INTO project (proj_id, proj_name, dept_id) VALUES
(1, 'Website Redesign', 1),
(2, 'CRM System', 1),
(3, 'Sales Portal', 2);

INSERT INTO assignment (emp_id, proj_id) VALUES
(1, 1),
(2, 1),
(2, 2),
(3, 3);
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 2       |
| 3      | Bob        | Wilson    | 2       |

**department table:**
| dept_id | dept_name |
|---------|-----------|
| 1       | IT        |
| 2       | Sales     |

**project table:**
| proj_id | proj_name       | dept_id |
|---------|-----------------|---------|
| 1       | Website Redesign| 1       |
| 2       | CRM System     | 1       |
| 3       | Sales Portal   | 2       |

**assignment table:**
| emp_id | proj_id |
|--------|---------|
| 1      | 1       |
| 2      | 1       |
| 2      | 2       |
| 3      | 3       |

## Expected Output
| employee_name | current_dept | project_name     |
|---------------|--------------|------------------|
| Jane Smith   | Sales       | Website Redesign|
| Jane Smith   | Sales       | CRM System      |

## Notes
- Join multiple tables with complex filtering
- Exclude IT department employees from results
- Only show employees who worked on IT projects

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS current_dept,
    p.proj_name AS project_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
WHERE d.dept_name != 'IT'           -- Not in IT department
  AND p.dept_id = 1                 -- Worked on IT projects
ORDER BY e.last_name, p.proj_name;
```

## Alternative Solution (Using Subquery)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS current_dept,
    p.proj_name AS project_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
WHERE e.dept_id != 1                -- Not in IT (assuming dept_id 1 = IT)
  AND a.proj_id IN (
      SELECT proj_id FROM project WHERE dept_id = 1  -- IT projects
  )
ORDER BY e.last_name, p.proj_name;
```

## Key Learning Points
- JOINs can include complex WHERE conditions
- Multiple JOINs with different purposes
- Filtering on joined tables
- Business logic embedded in query conditions

## Common Patterns
- Cross-department collaboration analysis
- Skill-based employee identification
- Transfer candidate identification
- Resource allocation optimization

## Performance Considerations
- Multiple JOINs can be expensive
- Consider indexing on frequently joined columns
- WHERE conditions on joined tables may require careful optimization
- Subquery vs JOIN performance depends on data distribution

## Extension Challenge
Modify to show employees with skills in multiple departments and rank them by versatility.
