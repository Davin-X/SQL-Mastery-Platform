# Problem 05: Multiple Grouping Levels with ROLLUP - Hierarchical Department Summary

## Business Context
Executives need a hierarchical summary showing employee counts by department and division, with subtotals and grand totals. This provides both detailed and summary views in a single report.

## Requirements
Write a SQL query that shows employee counts grouped by division and department, including subtotals for each division and a grand total.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE division (
    division_id INT PRIMARY KEY,
    division_name VARCHAR(50) NOT NULL
);

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    division_id INT,
    FOREIGN KEY (division_id) REFERENCES division(division_id)
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Insert sample data
INSERT INTO division (division_id, division_name) VALUES
(1, 'Technology'),
(2, 'Business');

INSERT INTO department (dept_id, dept_name, division_id) VALUES
(1, 'IT', 1),
(2, 'Development', 1),
(3, 'Sales', 2),
(4, 'Marketing', 2),
(5, 'HR', 2);

INSERT INTO employee (emp_id, first_name, last_name, dept_id) VALUES
(1, 'John', 'Doe', 1),
(2, 'Jane', 'Smith', 1),
(3, 'Bob', 'Wilson', 2),
(4, 'Alice', 'Brown', 2),
(5, 'Charlie', 'Davis', 3),
(6, 'Diana', 'Evans', 4),
(7, 'Eve', 'Foster', 4),
(8, 'Frank', 'Garcia', 5);
```

**division table:**
| division_id | division_name |
|-------------|---------------|
| 1           | Technology    |
| 2           | Business      |

**department table:**
| dept_id | dept_name | division_id |
|---------|-----------|-------------|
| 1       | IT        | 1           |
| 2       | Development| 1           |
| 3       | Sales     | 2           |
| 4       | Marketing | 2           |
| 5       | HR        | 2           |

## Expected Output
| division_name | department_name | employee_count |
|---------------|-----------------|----------------|
| Technology   | IT             | 2              |
| Technology   | Development    | 2              |
| Technology   | NULL           | 4              |
| Business     | Sales          | 1              |
| Business     | Marketing      | 2              |
| Business     | HR             | 1              |
| Business     | NULL           | 4              |
| NULL         | NULL           | 8              |

## Notes
- Use ROLLUP for hierarchical subtotals
- NULL values indicate subtotals and grand total
- Order by division then department

## Solution (Using ROLLUP)
```sql
SELECT 
    dv.division_name,
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM division dv
LEFT JOIN department d ON dv.division_id = d.division_id
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY dv.division_id, dv.division_name, d.dept_id, d.dept_name
WITH ROLLUP
ORDER BY dv.division_name, d.dept_name;
```

## Alternative Solution (Manual UNION approach)
```sql
-- Detailed breakdown
SELECT 
    dv.division_name,
    d.dept_name AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM division dv
LEFT JOIN department d ON dv.division_id = d.division_id
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY dv.division_id, dv.division_name, d.dept_id, d.dept_name

UNION ALL

-- Division subtotals
SELECT 
    dv.division_name,
    NULL AS department_name,
    COUNT(e.emp_id) AS employee_count
FROM division dv
LEFT JOIN department d ON dv.division_id = d.division_id
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY dv.division_id, dv.division_name

UNION ALL

-- Grand total
SELECT 
    NULL AS division_name,
    NULL AS department_name,
    COUNT(*) AS employee_count
FROM employee

ORDER BY division_name, department_name;
```

## Key Learning Points
- ROLLUP creates hierarchical subtotals automatically
- NULL values represent subtotal rows
- ORDER BY affects subtotal positioning
- Manual UNION approach provides more control

## Common Applications
- Financial reporting with subtotals
- Sales reports by region/product
- Inventory reports by category/subcategory
- Organizational charts with rollups

## Performance Notes
- ROLLUP is more efficient than manual UNIONs
- Consider CUBE for all possible combinations
- GROUPING() function can identify subtotal rows
- ROLLUP works best with hierarchical data

## Extension Challenge
Add percentage of total for each department within its division.
