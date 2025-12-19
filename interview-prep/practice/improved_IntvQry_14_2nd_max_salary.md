# 🎯 Finding Nth Highest Salary Interview Question

## Question
Given an employee salary table, find the 2nd highest salary. Also show how to find the Nth highest salary and handle ties properly.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(1, 'Alice', 'Engineering', 75000.00),
(2, 'Bob', 'Engineering', 80000.00),
(3, 'Charlie', 'Sales', 70000.00),
(4, 'Diana', 'Sales', 75000.00),
(5, 'Eve', 'HR', 65000.00),
(6, 'Frank', 'Engineering', 75000.00),  -- Tie with Alice
(7, 'Grace', 'Sales', 80000.00);
```

## Answer 1: Using Subquery with TOP/LIMIT

```sql
-- SQL Server/MySQL/PostgreSQL
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

**How it works**: 
- Inner query finds the absolute maximum salary
- Outer query finds the maximum salary that is less than the absolute maximum
- Simple and efficient for finding 2nd highest

## Answer 2: Using ROW_NUMBER() Window Function

```sql
SELECT salary AS second_highest_salary
FROM (
    SELECT salary, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM employees
) ranked
WHERE rn = 2;
```

**How it works**: 
- ROW_NUMBER() assigns sequential numbers ordered by salary descending
- Filter for rn = 2 to get the 2nd highest salary
- Works well with ties (each distinct salary gets a different rank)

## Answer 3: Using DENSE_RANK() for Ties

```sql
SELECT salary AS second_highest_salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
    FROM employees
) ranked
WHERE dense_rnk = 2;
```

**How it works**: 
- DENSE_RANK() gives the same rank to identical values
- If there are ties for 1st place, 2nd rank still represents the next distinct salary
- Better for handling duplicate salaries

## Answer 4: Using RANK() with Ties

```sql
SELECT DISTINCT salary AS second_highest_salary
FROM (
    SELECT salary, RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 2;
```

**How it works**: 
- RANK() skips ranks when there are ties
- If two employees tie for 1st, next employee gets rank 3
- DISTINCT ensures we don't return duplicate salaries

## Generalized: Finding Nth Highest Salary

```sql
-- Replace @N with desired rank (e.g., 3 for 3rd highest)
SELECT salary AS nth_highest_salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) ranked
WHERE rnk = 3;  -- Change this number for different ranks
```

**How it works**: Same pattern works for any Nth highest salary by changing the WHERE condition.

## Alternative: Using MIN() with TOP

```sql
-- SQL Server approach
SELECT MIN(salary) AS second_highest_salary
FROM (
    SELECT TOP 2 salary
    FROM employees
    ORDER BY salary DESC
) top_two;
```

**How it works**: 
- TOP 2 gets the two highest salaries
- MIN() of those gives the 2nd highest
- Efficient and straightforward

## MySQL Alternative with LIMIT

```sql
SELECT salary AS second_highest_salary
FROM employees
ORDER BY salary DESC
LIMIT 1, 1;  -- Skip 1, take 1 (starts from 0-based index)
```

**How it works**: 
- ORDER BY salary DESC puts highest first
- LIMIT 1, 1 skips the first row and takes the second
- Simple but only works for specific positions

## Performance Comparison

| Method | Performance | Readability | Handles Ties | Database Support |
|--------|-------------|-------------|--------------|------------------|
| Subquery | Good | Good | N/A | All |
| ROW_NUMBER | Good | Excellent | No | Modern DBs |
| DENSE_RANK | Good | Excellent | Yes | Modern DBs |
| TOP + MIN | Excellent | Good | N/A | SQL Server |
| LIMIT OFFSET | Good | Simple | N/A | MySQL/PostgreSQL |

## Common Interview Patterns

1. **Top N salaries**: Finding highest/lowest paid employees
2. **Ranking problems**: Employee performance rankings
3. **Pagination**: Getting specific positions in ordered data
4. **Median finding**: Statistical calculations on salaries

## Interview Tips

- **Clarify requirements**: Does the company want distinct salaries or all employees?
- **Consider ties**: How should duplicate salaries be handled?
- **Performance**: Different approaches have different performance characteristics
- **Edge cases**: What if there are fewer than N distinct salaries?
- **Scalability**: Consider how the solution works with millions of employees

## Real-World Applications

- **Compensation analysis**: Identifying salary bands and outliers
- **Performance reviews**: Ranking employee performance
- **Bonus calculations**: Determining eligibility based on salary percentiles
- **Market analysis**: Comparing salaries against industry standards

## Testing Edge Cases

```sql
-- Test with ties
INSERT INTO employees VALUES (8, 'Helen', 'Engineering', 75000.00);

-- Test with small dataset
SELECT salary FROM employees ORDER BY salary DESC;
-- Should handle cases where N > number of distinct salaries

-- Test performance
EXPLAIN SELECT salary FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
) ranked WHERE rnk = 2;
```

## Best Practices

1. **Choose appropriate ranking function**: ROW_NUMBER vs RANK vs DENSE_RANK
2. **Consider NULL salaries**: Add WHERE salary IS NOT NULL if needed
3. **Handle empty results**: What if N is larger than available salaries?
4. **Index salary column**: ORDER BY on indexed column improves performance
5. **Test with real data**: Verify behavior with your actual data distribution

## Alternative: Using Variables (MySQL)

```sql
SET @row_number = 0;
SELECT salary
FROM (
    SELECT salary, (@row_number:=@row_number + 1) AS rn
    FROM employees
    ORDER BY salary DESC
) numbered
WHERE rn = 2;
```

**How it works**: Uses user-defined variables to simulate ROW_NUMBER in older MySQL versions.
