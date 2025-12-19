# Problem 03: Numeric Functions and Math Operations - Salary Calculations

## Business Context
Finance and HR departments frequently need to perform mathematical calculations on numeric data for budgeting, compensation analysis, and financial reporting. Numeric functions are essential for calculations involving salaries, budgets, and financial metrics.

## Requirements
Write SQL queries using numeric functions to perform calculations, rounding, and mathematical operations on employee salary and financial data.

## Sample Data Setup
```sql
-- Create table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    bonus_percentage DECIMAL(5, 2),
    hours_worked DECIMAL(6, 2),
    dept_id INT
);

-- Insert sample data
INSERT INTO employee (emp_id, first_name, last_name, salary, bonus_percentage, hours_worked, dept_id) VALUES
(1, 'John', 'Doe', 75000.00, 5.50, 2080.00, 1),
(2, 'Jane', 'Smith', 80000.00, 7.25, 2120.00, 1),
(3, 'Bob', 'Wilson', 72000.00, 4.75, 2040.00, 1),
(4, 'Alice', 'Brown', 65000.00, 6.00, 2100.00, 2),
(5, 'Charlie', 'Davis', 75000.00, NULL, 2060.00, 2),
(6, 'Diana', 'Evans', 72000.00, 5.25, 2080.00, 2),
(7, 'Eve', 'Foster', 55000.00, 3.50, 2020.00, 3),
(8, 'Frank', 'Garcia', 60000.00, 4.00, 2050.00, 3),
(9, 'Grace', 'Hill', 85000.00, 8.50, 2150.00, 4),
(10, 'Henry', 'Adams', 78000.00, 6.75, 2090.00, 4);
```

## Query Requirements

### Query 1: Bonus calculations and rounding
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    bonus_percentage,
    ROUND(salary * (bonus_percentage / 100), 2) AS bonus_amount,
    ROUND(salary * (1 + bonus_percentage / 100), 2) AS total_compensation
FROM employee
ORDER BY total_compensation DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    | bonus_percentage | bonus_amount | total_compensation |
|--------|------------|-----------|-----------|------------------|--------------|-------------------|
| 9      | Grace      | Hill      | 85000.00  | 8.50            | 7225.00     | 92225.00         |
| 2      | Jane       | Smith     | 80000.00  | 7.25            | 5800.00     | 85800.00         |
| 10     | Henry      | Adams     | 78000.00  | 6.75            | 5265.00     | 83265.00         |
| 1      | John       | Doe       | 75000.00  | 5.50            | 4125.00     | 79125.00         |
| 5      | Charlie    | Davis     | 75000.00  | NULL            | NULL        | NULL             |
| 6      | Diana      | Evans     | 72000.00  | 5.25            | 3780.00     | 75780.00         |
| 3      | Bob        | Wilson    | 72000.00  | 4.75            | 3420.00     | 75420.00         |
| 4      | Alice      | Brown     | 65000.00  | 6.00            | 3900.00     | 68900.00         |
| 8      | Frank      | Garcia    | 60000.00  | 4.00            | 2400.00     | 62400.00         |
| 7      | Eve        | Foster    | 55000.00  | 3.50            | 1925.00     | 56925.00         |

### Query 2: Hourly rates and ceiling/floor functions
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    hours_worked,
    ROUND(salary / hours_worked, 2) AS hourly_rate,
    CEILING(salary / hours_worked) AS hourly_rate_ceiling,
    FLOOR(salary / hours_worked) AS hourly_rate_floor,
    ROUND(salary / hours_worked, 0) AS hourly_rate_rounded
FROM employee
ORDER BY hourly_rate DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    | hours_worked | hourly_rate | hourly_rate_ceiling | hourly_rate_floor | hourly_rate_rounded |
|--------|------------|-----------|-----------|--------------|-------------|---------------------|-------------------|-------------------|
| 9      | Grace      | Hill      | 85000.00  | 2150.00     | 39.53      | 40                  | 39                | 40                |
| 2      | Jane       | Smith     | 80000.00  | 2120.00     | 37.74      | 38                  | 37                | 38                |
| 10     | Henry      | Adams     | 78000.00  | 2090.00     | 37.32      | 38                  | 37                | 37                |
| 1      | John       | Doe       | 75000.00  | 2080.00     | 36.06      | 37                  | 36                | 36                |
| 5      | Charlie    | Davis     | 75000.00  | 2060.00     | 36.41      | 37                  | 36                | 36                |
| 6      | Diana      | Evans     | 72000.00  | 2080.00     | 34.62      | 35                  | 34                | 35                |
| 3      | Bob        | Wilson    | 72000.00  | 2040.00     | 35.29      | 36                  | 35                | 35                |
| 4      | Alice      | Brown     | 65000.00  | 2100.00     | 30.95      | 31                  | 30                | 31                |
| 8      | Frank      | Garcia    | 60000.00  | 2050.00     | 29.27      | 30                  | 29                | 29                |
| 7      | Eve        | Foster    | 55000.00  | 2020.00     | 27.23      | 28                  | 27                | 27                |

### Query 3: Absolute values and sign functions
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    bonus_percentage,
    ABS(bonus_percentage) AS abs_bonus_pct,
    SIGN(salary - 70000) AS salary_vs_70k,
    POWER(bonus_percentage, 2) AS bonus_squared,
    SQRT(ABS(bonus_percentage)) AS bonus_sqrt
FROM employee
WHERE bonus_percentage IS NOT NULL
ORDER BY bonus_percentage DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    | bonus_percentage | abs_bonus_pct | salary_vs_70k | bonus_squared | bonus_sqrt |
|--------|------------|-----------|-----------|------------------|---------------|---------------|--------------|------------|
| 9      | Grace      | Hill      | 85000.00  | 8.50            | 8.50         | 1            | 72.25       | 2.92      |
| 2      | Jane       | Smith     | 80000.00  | 7.25            | 7.25         | 1            | 52.56       | 2.69      |
| 10     | Henry      | Adams     | 78000.00  | 6.75            | 6.75         | 1            | 45.56       | 2.60      |
| 4      | Alice      | Brown     | 65000.00  | 6.00            | 6.00         | -1           | 36.00       | 2.45      |
| 1      | John       | Doe       | 75000.00  | 5.50            | 5.50         | 1            | 30.25       | 2.35      |
| 6      | Diana      | Evans     | 72000.00  | 5.25            | 5.25         | 1            | 27.56       | 2.29      |
| 3      | Bob        | Wilson    | 72000.00  | 4.75            | 4.75         | 1            | 22.56       | 2.18      |
| 8      | Frank      | Garcia    | 60000.00  | 4.00            | 4.00         | -1           | 16.00       | 2.00      |
| 7      | Eve        | Foster    | 55000.00  | 3.50            | 3.50         | -1           | 12.25       | 1.87      |

### Query 4: Modulo and remainder operations
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    salary,
    MOD(CAST(salary AS INTEGER), 10000) AS salary_mod_10k,
    salary - (FLOOR(salary / 10000) * 10000) AS salary_remainder_10k,
    CASE 
        WHEN MOD(CAST(salary AS INTEGER), 2) = 0 THEN 'Even'
        ELSE 'Odd'
    END AS salary_parity
FROM employee
ORDER BY salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | salary    | salary_mod_10k | salary_remainder_10k | salary_parity |
|--------|------------|-----------|-----------|----------------|----------------------|---------------|
| 9      | Grace      | Hill      | 85000.00  | 5000          | 5000                | Even         |
| 2      | Jane       | Smith     | 80000.00  | 0             | 0                    | Even         |
| 10     | Henry      | Adams     | 78000.00  | 8000          | 8000                | Even         |
| 1      | John       | Doe       | 75000.00  | 5000          | 5000                | Even         |
| 5      | Charlie    | Davis     | 75000.00  | 5000          | 5000                | Even         |
| 6      | Diana      | Evans     | 72000.00  | 2000          | 2000                | Even         |
| 3      | Bob        | Wilson    | 72000.00  | 2000          | 2000                | Even         |
| 4      | Alice      | Brown     | 65000.00  | 5000          | 5000                | Even         |
| 8      | Frank      | Garcia    | 60000.00  | 0             | 0                    | Even         |
| 7      | Eve        | Foster    | 55000.00  | 5000          | 5000                | Even         |

## Key Learning Points
- **ROUND()**: Rounds to specified decimal places
- **CEILING()/FLOOR()**: Round up/down to nearest integer
- **ABS()**: Absolute value
- **SIGN()**: Returns -1, 0, or 1 based on sign
- **POWER()/SQRT()**: Power and square root functions
- **MOD()**: Modulo (remainder) operation

## Common Numeric Functions
- **ROUND(value, decimals)**: Round to decimal places
- **CEILING/FLOOR**: Round up/down
- **ABS()**: Absolute value
- **POWER(base, exponent)**: Power function
- **SQRT()**: Square root
- **MOD(dividend, divisor)**: Modulo operation

## Performance Notes
- Numeric functions are generally efficient
- Consider data types to avoid overflow
- ROUND can be expensive with many decimal places
- Some functions may require type casting

## Extension Challenge
Create a salary grading system that assigns letter grades (A, B, C, D, F) based on salary percentiles.
