# 🎯 Common Interview Query Patterns Collection

## Overview
This consolidated file contains essential SQL interview query patterns and techniques from multiple practice scenarios, focusing on frequently asked problems in technical interviews.

---

## 🎯 Problem 1: CASE WHEN Conditional Logic & Salary Classification

**Business Context:** Employee compensation analysis requires categorizing staff by salary brackets and performance-based bonuses.

### Requirements
Categorize employees by salary brackets and calculate bonuses based on performance ratings.

### SQL Setup
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary DECIMAL(10,2),
    performance_rating INT,
    department VARCHAR(30)
);

INSERT INTO employees VALUES
(1, 'Alice', 50000.00, 5, 'Engineering'),
(2, 'Bob', 45000.00, 4, 'Engineering'),
(3, 'Charlie', 60000.00, 3, 'Sales'),
(4, 'Diana', 35000.00, 2, 'Sales'),
(5, 'Eve', 70000.00, 5, 'HR');
```

### Solutions

#### Salary Bracket Classification with Bonuses:
```sql
SELECT 
    name,
    department,
    salary,
    performance_rating,
    CASE 
        WHEN salary >= 60000 THEN 'Executive'
        WHEN salary >= 45000 THEN 'Senior'
        WHEN salary >= 35000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS salary_bracket,
    CASE performance_rating
        WHEN 5 THEN 1.20  -- 20% bonus
        WHEN 4 THEN 1.15  -- 15% bonus
        WHEN 3 THEN 1.10  -- 10% bonus
        WHEN 2 THEN 1.05  -- 5% bonus
        ELSE 1.00         -- No bonus
    END AS bonus_multiplier,
    ROUND(salary * CASE performance_rating
        WHEN 5 THEN 1.20
        WHEN 4 THEN 1.15
        WHEN 3 THEN 1.10
        WHEN 2 THEN 1.05
        ELSE 1.00
    END, 2) AS total_compensation
FROM employees
ORDER BY salary DESC;
```

#### Department-wise Performance Analysis:
```sql
SELECT 
    department,
    COUNT(*) AS total_employees,
    AVG(salary) AS avg_salary,
    SUM(CASE WHEN performance_rating >= 4 THEN 1 ELSE 0 END) AS high_performers,
    ROUND(SUM(CASE WHEN performance_rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS high_performer_pct,
    SUM(CASE WHEN salary >= 50000 THEN salary * 0.10 ELSE 0 END) AS bonus_pool
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;
```

---

## 🎯 Problem 2: Finding Nth Highest Salary

**Business Context:** Compensation analysis and salary benchmarking require finding specific salary positions.

### Requirements
Find the 2nd highest salary and demonstrate patterns for finding any Nth highest salary.

### SQL Setup
```sql
CREATE TABLE employee_salaries (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employee_salaries VALUES
(1, 'Alice', 'Engineering', 75000.00),
(2, 'Bob', 'Engineering', 80000.00),
(3, 'Charlie', 'Sales', 70000.00),
(4, 'Diana', 'Sales', 75000.00),
(5, 'Eve', 'HR', 65000.00),
(6, 'Frank', 'Engineering', 75000.00),
(7, 'Grace', 'Sales', 80000.00);
```

### Solutions

#### Method 1: Subquery Approach:
```sql
SELECT MAX(salary) AS second_highest_salary
FROM employee_salaries
WHERE salary < (SELECT MAX(salary) FROM employee_salaries);
```

#### Method 2: ROW_NUMBER() Window Function:
```sql
SELECT salary AS second_highest_salary
FROM (
    SELECT salary, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM employee_salaries
) ranked
WHERE rn = 2;
```

#### Method 3: DENSE_RANK() for Ties:
```sql
SELECT DISTINCT salary AS second_highest_salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
    FROM employee_salaries
) ranked
WHERE dense_rnk = 2;
```

#### Generalized Nth Highest Salary:
```sql
-- Replace 3 with desired rank
SELECT salary AS nth_highest_salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employee_salaries
) ranked
WHERE rnk = 3;
```

#### MySQL LIMIT Approach:
```sql
SELECT salary AS second_highest_salary
FROM employee_salaries
ORDER BY salary DESC
LIMIT 1, 1;
```

---

## 📚 Key Interview Patterns Covered

### CASE WHEN Patterns
- **Simple CASE**: `CASE column WHEN value THEN result`
- **Searched CASE**: `CASE WHEN condition THEN result`
- **Nested CASE**: Multiple levels of conditions
- **Aggregate CASE**: Conditional sums and counts

### Ranking & Position Problems
- **Nth highest/lowest values**
- **Top N per category**
- **Percentile calculations**
- **Ranking with ties handling**

### Set Operations
- **EXCEPT/MINUS**: Finding differences
- **INTERSECT**: Finding common elements
- **UNION**: Combining results

### Date & Time Calculations
- **Date arithmetic**: Adding/subtracting days/months
- **Weekday calculations**: Finding specific days
- **Business day logic**: Excluding weekends/holidays

### Data Quality Patterns
- **Deduplication**: Removing duplicates
- **Matching**: Fuzzy and exact matching
- **Data validation**: Consistency checks

---

## 🎯 Interview Preparation Tips

### Common Question Categories:
1. **Conditional Logic**: CASE WHEN for categorization
2. **Ranking Problems**: Nth highest, top performers
3. **Set Operations**: Data comparison and reconciliation
4. **Date Calculations**: Business day logic, periods
5. **Data Cleaning**: Deduplication and validation

### Performance Considerations:
- **Index Usage**: Ensure indexed columns for WHERE/JOIN
- **Subquery vs JOIN**: Choose appropriate approach
- **Window Functions**: Modern SQL preferred over complex subqueries
- **Data Types**: Use appropriate types for dates, numbers

This collection covers the most frequently asked SQL interview patterns and provides comprehensive solutions with performance considerations and edge case handling.
