# 🎯 CASE WHEN Conditional Logic Interview Question

## Question
Given an `employees` table with salaries, categorize employees into salary brackets and provide a bonus multiplier based on their performance rating.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary DECIMAL(10,2),
    performance_rating INT  -- 1-5 scale
);

INSERT INTO employees VALUES
(1, 'Alice', 50000.00, 5),
(2, 'Bob', 45000.00, 4),
(3, 'Charlie', 60000.00, 3),
(4, 'Diana', 35000.00, 2),
(5, 'Eve', 70000.00, 5);
```

## Answer: Salary Bracket Classification with Bonus Calculation

```sql
SELECT 
    name,
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

**How it works**: 
- First CASE uses searched format for salary ranges
- Second CASE uses simple format for exact rating matches
- Combines both for total compensation calculation

## Alternative: Searched CASE for Both Columns

```sql
SELECT 
    name,
    salary,
    performance_rating,
    CASE 
        WHEN salary >= 60000 THEN 'Executive'
        WHEN salary >= 45000 THEN 'Senior'
        WHEN salary >= 35000 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS salary_bracket,
    CASE 
        WHEN performance_rating = 5 THEN 1.20
        WHEN performance_rating = 4 THEN 1.15
        WHEN performance_rating = 3 THEN 1.10
        WHEN performance_rating = 2 THEN 1.05
        ELSE 1.00
    END AS bonus_multiplier
FROM employees;
```

**How it works**: Both CASE statements use searched format for consistency.


### Simple CASE
```sql
CASE column_name
    WHEN value1 THEN result1
    WHEN value2 THEN result2
    ELSE default_result
END
```
**Use for**: Exact value matches, cleaner when comparing same column

### Searched CASE
```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```
**Use for**: Complex conditions, ranges, different columns

## Common Patterns
