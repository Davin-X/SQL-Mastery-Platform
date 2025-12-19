# Problem 04: NTILE() - Percentile Grouping and Quartiles

## Business Context
Organizations need to categorize employees, products, or performance metrics into percentile groups for compensation planning, performance analysis, and resource allocation. NTILE() enables dividing data into equal-sized groups (quartiles, quintiles, percentiles) for statistical analysis and decision-making.

## Requirements
Write SQL queries using NTILE() to categorize data into percentile groups and quartiles for performance analysis and statistical reporting.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employee_performance (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    performance_score DECIMAL(3, 1) NOT NULL,
    tenure_years INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- Insert sample data
INSERT INTO department (dept_id, dept_name) VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR'),
(4, 'Finance');

INSERT INTO employee_performance (emp_id, first_name, last_name, dept_id, salary, performance_score, tenure_years) VALUES
(1, 'John', 'Doe', 1, 75000.00, 4.5, 3),
(2, 'Jane', 'Smith', 1, 80000.00, 4.8, 5),
(3, 'Bob', 'Wilson', 1, 72000.00, 3.9, 2),
(4, 'Alice', 'Brown', 1, 68000.00, 4.2, 4),
(5, 'Charlie', 'Davis', 2, 75000.00, 4.2, 3),
(6, 'Diana', 'Evans', 2, 72000.00, 4.7, 4),
(7, 'Eve', 'Foster', 2, 65000.00, 3.8, 2),
(8, 'Frank', 'Garcia', 2, 78000.00, 4.6, 6),
(9, 'Grace', 'Hill', 3, 55000.00, 4.0, 3),
(10, 'Henry', 'Adams', 3, 60000.00, 4.3, 4),
(11, 'Ivy', 'Clark', 3, 52000.00, 3.7, 1),
(12, 'Jack', 'Davis', 4, 85000.00, 4.9, 7),
(13, 'Kate', 'Evans', 4, 78000.00, 4.4, 5),
(14, 'Liam', 'Foster', 4, 82000.00, 4.7, 6),
(15, 'Mia', 'Garcia', 4, 79000.00, 4.5, 4);
```

## Query Requirements

### Query 1: Salary quartiles across all employees
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile
FROM employee_performance
ORDER BY salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary   | salary_quartile |
|--------|------------|-----------|----------|-----------------|
| 12     | Jack       | Davis     | 85000.00 | 1               |
| 14     | Liam       | Foster    | 82000.00 | 1               |
| 13     | Kate       | Evans     | 78000.00 | 1               |
| 15     | Mia        | Garcia    | 79000.00 | 1               |
| 2      | Jane       | Smith     | 80000.00 | 2               |
| 8      | Frank      | Garcia    | 78000.00 | 2               |
| 1      | John       | Doe       | 75000.00 | 2               |
| 5      | Charlie    | Davis     | 75000.00 | 2               |
| 6      | Diana      | Evans     | 72000.00 | 3               |
| 3      | Bob        | Wilson    | 72000.00 | 3               |
| 4      | Alice      | Brown     | 68000.00 | 3               |
| 7      | Eve        | Foster    | 65000.00 | 3               |
| 10     | Henry      | Adams     | 60000.00 | 4               |
| 9      | Grace      | Hill      | 55000.00 | 4               |
| 11     | Ivy        | Clark     | 52000.00 | 4               |

### Query 2: Performance score quintiles (5 groups)
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    performance_score,
    NTILE(5) OVER (ORDER BY performance_score DESC) AS performance_quintile
FROM employee_performance
ORDER BY performance_score DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | performance_score | performance_quintile |
|--------|------------|-----------|-------------------|----------------------|
| 12     | Jack       | Davis     | 4.9               | 1                    |
| 2      | Jane       | Smith     | 4.8               | 1                    |
| 14     | Liam       | Foster    | 4.7               | 1                    |
| 6      | Diana      | Evans     | 4.7               | 2                    |
| 8      | Frank      | Garcia    | 4.6               | 2                    |
| 1      | John       | Doe       | 4.5               | 2                    |
| 15     | Mia        | Garcia    | 4.5               | 3                    |
| 13     | Kate       | Evans     | 4.4               | 3                    |
| 10     | Henry      | Adams     | 4.3               | 3                    |
| 5      | Charlie    | Davis     | 4.2               | 4                    |
| 4      | Alice      | Brown     | 4.2               | 4                    |
| 9      | Grace      | Hill      | 4.0               | 4                    |
| 3      | Bob        | Wilson    | 3.9               | 5                    |
| 7      | Eve        | Foster    | 3.8               | 5                    |
| 11     | Ivy        | Clark     | 3.7               | 5                    |

### Query 3: Department-wise salary percentiles
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    NTILE(4) OVER (
        PARTITION BY e.dept_id 
        ORDER BY e.salary DESC
    ) AS dept_salary_percentile
FROM employee_performance e
INNER JOIN department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | dept_salary_percentile |
|--------|------------|-----------|-----------|----------|------------------------|
| 2      | Jane       | Smith     | IT        | 80000.00 | 1                      |
| 1      | John       | Doe       | IT        | 75000.00 | 1                      |
| 4      | Alice      | Brown     | IT        | 68000.00 | 2                      |
| 3      | Bob        | Wilson    | IT        | 72000.00 | 2                      |
| 8      | Frank      | Garcia    | Sales     | 78000.00 | 1                      |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 1                      |
| 6      | Diana      | Evans     | Sales     | 72000.00 | 2                      |
| 7      | Eve        | Foster    | Sales     | 65000.00 | 2                      |
| 10     | Henry      | Adams     | HR        | 60000.00 | 1                      |
| 9      | Grace      | Hill      | HR        | 55000.00 | 2                      |
| 11     | Ivy        | Clark     | HR        | 52000.00 | 3                      |
| 12     | Jack       | Davis     | Finance   | 85000.00 | 1                      |
| 14     | Liam       | Foster    | Finance   | 82000.00 | 1                      |
| 15     | Mia        | Garcia    | Finance   | 79000.00 | 2                      |
| 13     | Kate       | Evans     | Finance   | 78000.00 | 2                      |

### Query 4: Tenure-based grouping (tertiles)
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    tenure_years,
    NTILE(3) OVER (ORDER BY tenure_years DESC) AS tenure_tertile
FROM employee_performance
ORDER BY tenure_years DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | tenure_years | tenure_tertile |
|--------|------------|-----------|--------------|----------------|
| 12     | Jack       | Davis     | 7            | 1              |
| 14     | Liam       | Foster    | 6            | 1              |
| 8      | Frank      | Garcia    | 6            | 1              |
| 2      | Jane       | Smith     | 5            | 2              |
| 13     | Kate       | Evans     | 5            | 2              |
| 15     | Mia        | Garcia    | 4            | 2              |
| 6      | Diana      | Evans     | 4            | 2              |
| 10     | Henry      | Adams     | 4            | 2              |
| 1      | John       | Doe       | 3            | 3              |
| 5      | Charlie    | Davis     | 3            | 3              |
| 9      | Grace      | Hill      | 3            | 3              |
| 4      | Alice      | Brown     | 4            | 3              |
| 3      | Bob        | Wilson    | 2            | 3              |
| 7      | Eve        | Foster    | 2            | 3              |
| 11     | Ivy        | Clark     | 1            | 3              |

### Query 5: Performance analysis by percentile groups
```sql
WITH performance_groups AS (
    SELECT 
        emp_id,
        first_name,
        last_name,
        performance_score,
        salary,
        NTILE(4) OVER (ORDER BY performance_score DESC) AS performance_percentile
    FROM employee_performance
)
SELECT 
    performance_percentile,
    COUNT(*) AS employee_count,
    ROUND(AVG(performance_score), 2) AS avg_performance,
    ROUND(AVG(salary), 2) AS avg_salary
FROM performance_groups
GROUP BY performance_percentile
ORDER BY performance_percentile;
```

**Expected Result:**
| performance_percentile | employee_count | avg_performance | avg_salary  |
|------------------------|----------------|-----------------|-------------|
| 1                      | 4              | 4.75            | 81250.00    |
| 2                      | 3              | 4.60            | 74166.67    |
| 3                      | 4              | 4.40            | 78750.00    |
| 4                      | 4              | 3.95            | 57750.00    |

## Key Learning Points
- **NTILE(n)** divides data into n equal groups
- **Groups are as equal as possible** (extra rows go to first groups)
- **ORDER BY** determines how data is distributed
- **PARTITION BY** creates separate groupings per partition
- **Useful for percentiles, quartiles, and statistical analysis**

## Common NTILE() Applications
- **Performance quartiles**: Top 25%, 50%, 75%, bottom 25%
- **Salary bands**: Compensation percentile analysis
- **Customer segmentation**: RFM analysis groups
- **Quality control**: Defect rate percentiles
- **Academic grading**: Grade distribution analysis

## Performance Notes
- NTILE() is efficient for statistical grouping
- Results in equal-sized groups (as equal as mathematically possible)
- Useful for data segmentation and statistical analysis
- Can be combined with other window functions

## Extension Challenge
Create a comprehensive employee performance dashboard that shows employees in different percentile groups for salary, performance score, and tenure, then identify employees who are high performers but low earners (potential compensation adjustments).
