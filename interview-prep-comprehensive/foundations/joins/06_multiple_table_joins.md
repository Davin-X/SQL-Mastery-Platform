# Problem 06: Multiple Table JOINs - Employee Project Assignments

## Business Context
Project managers need to see which employees are assigned to which projects, including their department information. This helps with resource planning and cross-department collaboration tracking.

## Requirements
Write a SQL query to show employee names, their department names, project names, and assignment roles for all current project assignments.

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
    proj_name VARCHAR(100) NOT NULL
);

CREATE TABLE assignment (
    emp_id INT NOT NULL,
    proj_id INT NOT NULL,
    role VARCHAR(50),
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
(2, 'Jane', 'Smith', 2);

INSERT INTO project (proj_id, proj_name) VALUES
(1, 'Website Redesign'),
(2, 'Mobile App');

INSERT INTO assignment (emp_id, proj_id, role) VALUES
(1, 1, 'Lead Developer'),
(2, 1, 'QA Engineer'),
(1, 2, 'Architect');
```

**employee table:**
| emp_id | first_name | last_name | dept_id |
|--------|------------|-----------|---------|
| 1      | John       | Doe       | 1       |
| 2      | Jane       | Smith     | 2       |

**department table:**
| dept_id | dept_name    |
|---------|--------------|
| 1       | IT           |
| 2       | Sales        |

**project table:**
| proj_id | proj_name       |
|---------|-----------------|
| 1       | Website Redesign|
| 2       | Mobile App      |

**assignment table:**
| emp_id | proj_id | role          |
|--------|---------|---------------|
| 1      | 1       | Lead Developer|
| 2      | 1       | QA Engineer   |
| 1      | 2       | Architect     |

## Expected Output
| employee_name | department_name | project_name     | role           |
|---------------|-----------------|------------------|----------------|
| John Doe     | IT             | Website Redesign| Lead Developer|
| Jane Smith   | Sales          | Website Redesign| QA Engineer   |
| John Doe     | IT             | Mobile App      | Architect     |

## Notes
- Join four tables: employee, department, project, assignment
- Use appropriate JOIN types for the relationships
- Handle the many-to-many relationship through assignment table

## Solution
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name,
    p.proj_name AS project_name,
    a.role
FROM assignment a
INNER JOIN employee e ON a.emp_id = e.emp_id
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN project p ON a.proj_id = p.proj_id
ORDER BY e.last_name, p.proj_name;
```

## Key Learning Points
- Multiple JOINs require careful planning of relationships
- Assignment table resolves many-to-many relationship
- JOIN order can affect performance but not results
- Table aliases become essential for readability

## Common Patterns
- Fact table (assignment) connected to dimension tables (employee, project)
- Star schema or snowflake schema designs
- Many-to-many relationships need junction tables

## Performance Considerations
- Start JOINs from smallest tables
- Ensure proper indexing on foreign keys
- Consider the order of JOIN conditions
- Watch for Cartesian products in complex JOINs

## Alternative Approach (Different JOIN Order)
```sql
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.dept_name AS department_name,
    p.proj_name AS project_name,
    a.role
FROM employee e
INNER JOIN assignment a ON e.emp_id = a.emp_id
INNER JOIN project p ON a.proj_id = p.proj_id
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.last_name, p.proj_name;
```
