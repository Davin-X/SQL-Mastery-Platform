# Problem 01: Date Functions Basics - Employee Tenure and Hire Analysis

## Business Context
HR needs to analyze employee tenure, hiring patterns, and time-based metrics for workforce planning and compensation reviews. Date functions are essential for temporal analysis in business intelligence.

## Requirements
Write SQL queries using basic date functions to analyze employee hire dates, calculate tenure, and filter by date ranges.

## Sample Data Setup
```sql
-- Create table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    birth_date DATE,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT
);

-- Insert sample data
INSERT INTO employee (emp_id, first_name, last_name, hire_date, birth_date, salary, dept_id) VALUES
(1, 'John', 'Doe', '2020-01-15', '1985-03-20', 75000.00, 1),
(2, 'Jane', 'Smith', '2019-03-20', '1988-07-15', 80000.00, 1),
(3, 'Bob', 'Wilson', '2021-06-10', '1990-11-05', 72000.00, 1),
(4, 'Alice', 'Brown', '2018-11-05', '1982-09-12', 65000.00, 2),
(5, 'Charlie', 'Davis', '2020-08-15', '1987-01-30', 75000.00, 2),
(6, 'Diana', 'Evans', '2019-12-01', '1984-05-22', 72000.00, 2),
(7, 'Eve', 'Foster', '2022-02-20', '1992-12-08', 55000.00, 3),
(8, 'Frank', 'Garcia', '2021-08-10', '1989-04-18', 60000.00, 3),
(9, 'Grace', 'Hill', '2017-09-10', '1980-06-25', 85000.00, 4),
(10, 'Henry', 'Adams', '2019-05-25', '1986-08-14', 78000.00, 4);
```

## Query Requirements

### Query 1: Current date and basic date extraction
```sql
SELECT 
    CURRENT_DATE AS today_date,
    EXTRACT(YEAR FROM CURRENT_DATE) AS current_year,
    EXTRACT(MONTH FROM CURRENT_DATE) AS current_month,
    EXTRACT(DAY FROM CURRENT_DATE) AS current_day;
```

### Query 2: Employee hire year and month
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    hire_date,
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month,
    EXTRACT(DAY FROM hire_date) AS hire_day
FROM employee
ORDER BY hire_date;
```

**Expected Result:**
| emp_id | first_name | last_name | hire_date  | hire_year | hire_month | hire_day |
|--------|------------|-----------|------------|-----------|------------|----------|
| 9      | Grace      | Hill      | 2017-09-10 | 2017      | 9          | 10       |
| 4      | Alice      | Brown     | 2018-11-05 | 2018      | 11         | 5        |
| 2      | Jane       | Smith     | 2019-03-20 | 2019      | 3          | 20       |
| 10     | Henry      | Adams     | 2019-05-25 | 2019      | 5          | 25       |
| 6      | Diana      | Evans     | 2019-12-01 | 2019      | 12         | 1        |
| 1      | John       | Doe       | 2020-01-15 | 2020      | 1          | 15       |
| 5      | Charlie    | Davis     | 2020-08-15 | 2020      | 8          | 15       |
| 8      | Frank      | Garcia    | 2021-08-10 | 2021      | 8          | 10       |
| 3      | Bob        | Wilson    | 2021-06-10 | 2021      | 6          | 10       |
| 7      | Eve        | Foster    | 2022-02-20 | 2022      | 2          | 20       |

### Query 3: Employee tenure in years
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    hire_date,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM hire_date) AS tenure_years,
    ROUND(
        (CURRENT_DATE - hire_date) / 365.25, 
        1
    ) AS tenure_years_decimal
FROM employee
ORDER BY tenure_years DESC, hire_date;
```

### Query 4: Employees hired in specific date ranges
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    hire_date,
    EXTRACT(YEAR FROM hire_date) AS hire_year
FROM employee
WHERE hire_date BETWEEN '2019-01-01' AND '2020-12-31'
ORDER BY hire_date;
```

**Expected Result:**
| emp_id | first_name | last_name | hire_date  | hire_year |
|--------|------------|-----------|------------|-----------|
| 2      | Jane       | Smith     | 2019-03-20 | 2019      |
| 10     | Henry      | Adams     | 2019-05-25 | 2019      |
| 6      | Diana      | Evans     | 2019-12-01 | 2019      |
| 1      | John       | Doe       | 2020-01-15 | 2020      |
| 5      | Charlie    | Davis     | 2020-08-15 | 2020      |

## Key Learning Points
- **CURRENT_DATE**: Gets the current system date
- **EXTRACT()**: Extracts specific date parts (YEAR, MONTH, DAY)
- **Date arithmetic**: Can subtract dates to get intervals
- **BETWEEN**: Works with date ranges
- **Date formatting**: Standard YYYY-MM-DD format

## Common Date Functions
- **CURRENT_DATE**: Today's date
- **EXTRACT(field FROM date)**: Extract date components
- **DATE_TRUNC**: Truncate to specific precision
- **AGE()**: Calculate age/duration
- **Date arithmetic**: date + interval, date - date

## Performance Notes
- Date functions can prevent index usage when used in WHERE clauses
- Consider computed columns for frequently accessed date parts
- Use appropriate date types (DATE, TIMESTAMP, TIMESTAMPTZ)
- Be aware of timezone considerations

## Extension Challenge
Calculate employee age and identify those eligible for retirement (assuming retirement age 65).
