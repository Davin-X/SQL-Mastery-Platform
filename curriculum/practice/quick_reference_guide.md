# SQL Quick Reference Guide — Essential Syntax & Patterns

## Core SQL Concepts

### SELECT Statement Structure
```sql
SELECT [DISTINCT] column1, column2, aggregate_function(column3)
FROM table1 [alias]
[JOIN table2 [alias] ON condition]
[WHERE conditions]
[GROUP BY column1, column2]
[HAVING aggregate_conditions]
[ORDER BY column1 [ASC|DESC], column2 [ASC|DESC]]
[LIMIT n [OFFSET m]];
```

### Common Patterns
- **Filtering**: `WHERE column = value`, `WHERE column IN (val1, val2)`, `WHERE column BETWEEN min AND max`
- **Pattern matching**: `WHERE column LIKE 'pattern%'`
- **NULL handling**: `WHERE column IS NULL`, `COALESCE(column, 'default')`
- **Conditional logic**: `CASE WHEN condition THEN result ELSE default END`

---

## Joins & Relationships

| Join Type | Syntax | When to Use |
|-----------|--------|-------------|
| INNER JOIN | `FROM table1 t1 JOIN table2 t2 ON t1.id = t2.id` | Matching rows only |
| LEFT JOIN | `FROM table1 t1 LEFT JOIN table2 t2 ON t1.id = t2.id` | All rows from left, matches from right |
| RIGHT JOIN | `FROM table1 t1 RIGHT JOIN table2 t2 ON t1.id = t2.id` | All rows from right, matches from left |
| FULL JOIN | `FROM table1 t1 FULL JOIN table2 t2 ON t1.id = t2.id` | All rows from both tables |
| CROSS JOIN | `FROM table1 CROSS JOIN table2` | Cartesian product (every combination) |
| SELF JOIN | `FROM employees e1 JOIN employees e2 ON e1.manager_id = e2.id` | Same table relationships |

---

## Aggregation & Grouping

| Function | Purpose | Notes |
|----------|---------|-------|
| COUNT(*) | Row count | Includes NULLs |
| COUNT(column) | Non-null count | Excludes NULLs |
| SUM(column) | Total | NULL-safe |
| AVG(column) | Average | NULL-safe |
| MIN(column) | Minimum | NULL-safe |
| MAX(column) | Maximum | NULL-safe |
| GROUP_CONCAT(column) | Concatenated list | MySQL; STRING_AGG() in PostgreSQL |

**Advanced Aggregation:**
- `GROUP BY ROLLUP(col1, col2)` — Subtotals and grand total
- `GROUP BY CUBE(col1, col2)` — All combinations of subtotals

---

## Window Functions

| Function | Purpose | Example |
|----------|---------|---------|
| ROW_NUMBER() | Sequential row numbers | `ROW_NUMBER() OVER (ORDER BY salary DESC)` |
| RANK() | Rankings with gaps | `RANK() OVER (ORDER BY salary DESC)` |
| DENSE_RANK() | Rankings without gaps | `DENSE_RANK() OVER (ORDER BY salary DESC)` |
| NTILE(n) | Percentile groups | `NTILE(4) OVER (ORDER BY salary DESC)` — quartiles |
| PERCENT_RANK() | Relative rank (0.0-1.0) | `PERCENT_RANK() OVER (ORDER BY salary)` |
| CUME_DIST() | Cumulative distribution | `CUME_DIST() OVER (ORDER BY salary)` |
| LEAD(column) | Next row's value | `LEAD(salary, 1) OVER (ORDER BY hire_date)` |
| LAG(column) | Previous row's value | `LAG(salary, 1) OVER (ORDER BY hire_date)` |
| FIRST_VALUE(column) | First value in window | `FIRST_VALUE(salary) OVER (PARTITION BY dept ORDER BY hire_date)` |
| LAST_VALUE(column) | Last value in window | `LAST_VALUE(salary) OVER (PARTITION BY dept ORDER BY hire_date)` |

**Frame Clauses:**
- `ROWS UNBOUNDED PRECEDING` — All previous rows
- `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING` — Sliding window

---

## CTEs & Subqueries

### Common Table Expressions (CTEs)
```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table1
    WHERE condition
),
cte_name2 AS (
    SELECT *
    FROM cte_name
    WHERE another_condition
)
SELECT *
FROM cte_name2;
```

### Recursive CTEs
```sql
WITH RECURSIVE hierarchy AS (
    -- Base case: top-level records
    SELECT id, name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: child records
    SELECT e.id, e.name, e.manager_id, h.level + 1
    FROM employees e
    JOIN hierarchy h ON e.manager_id = h.id
)
SELECT * FROM hierarchy ORDER BY level, id;
```

---

## Set Operations

| Operation | Syntax | Description |
|-----------|---------|-------------|
| UNION | `SELECT... UNION SELECT...` | Unique rows from both queries |
| UNION ALL | `SELECT... UNION ALL SELECT...` | All rows from both queries (with duplicates) |
| INTERSECT | `SELECT... INTERSECT SELECT...` | Rows in both result sets |
| EXCEPT/MINUS | `SELECT... EXCEPT SELECT...` | Rows in first set but not second |

---

## Data Modification

### INSERT Patterns
```sql
-- Single row
INSERT INTO table (col1, col2) VALUES (val1, val2);

-- Multiple rows
INSERT INTO table (col1, col2) VALUES (val1, val2), (val3, val4);

-- From SELECT
INSERT INTO table (col1, col2)
SELECT other_col1, other_col2 FROM other_table WHERE condition;
```

### UPDATE Patterns
```sql
-- Basic update
UPDATE table SET column = value WHERE condition;

-- Update based on another table
UPDATE t1 SET column = (SELECT column FROM t2 WHERE t1.id = t2.id)
WHERE EXISTS (SELECT 1 FROM t2 WHERE t1.id = t2.id);

-- MERGE/UPSERT (MySQL)
INSERT INTO table (id, column) VALUES (1, 'value')
ON DUPLICATE KEY UPDATE column = 'value';
```

### DELETE Patterns
```sql
-- Basic delete
DELETE FROM table WHERE condition;

-- Delete based on relationship
DELETE t1 FROM table1 t1
JOIN table2 t2 ON t1.id = t2.id
WHERE t2.condition;
```

---

## Advanced Analytics

### Statistical Functions
- `CORR(x, y)` — Correlation coefficient (-1 to 1)
- `COVAR_POP(x, y)` — Population covariance
- `REGR_R2(y, x)` — R-squared for linear regression
- `REGR_SLOPE(y, x)` — Slope of regression line

### Percentiles
- `PERCENTILE_CONT(0.5)` — Median (continuous)
- `PERCENTILE_DISC(0.5)` — Median (discrete)
- `PERCENTILE_CONT(0.25)` — First quartile

### String Aggregation
- MySQL: `GROUP_CONCAT(column, separator)`
- PostgreSQL: `STRING_AGG(column, separator)`
- SQL Server: `STRING_AGG(column, separator)` (2017+)

---

## Performance & Indexing

| Index Type | When to Use | Example |
|------------|-------------|---------|
| Primary Key | Unique identifier | `PRIMARY KEY (id)` |
| Unique Index | Unique constraint | `UNIQUE KEY (email)` |
| Regular Index | Fast lookups | `INDEX idx_name (last_name, first_name)` |
| Composite Index | Multi-column queries | `INDEX idx_comp (status, created_date)` |
| Full-text Index | Text search | `FULLTEXT INDEX ft_content (content)` |

### Query Optimization
- Avoid `SELECT *` — specify needed columns
- Use `EXPLAIN` to analyze execution plans
- Index foreign keys for JOINs
- Use appropriate data types
- Consider partitioning for large tables

---

## Common Interview Patterns

1. **Ranking Problems**: ROW_NUMBER(), RANK(), DENSE_RANK()
2. **Running Totals**: SUM() OVER (ORDER BY...)
3. **Gaps & Islands**: Lead/Lag with conditional logic
4. **Median/Percentiles**: PERCENTILE_CONT() or manual calculation
5. **Top N Per Group**: ROW_NUMBER() in subquery/CTE
6. **Customer Segmentation**: NTILE() for quartiles/deciles
7. **Churn Analysis**: DATEDIFF() with window functions
8. **Tree/Hierarchy Traversal**: Recursive CTEs

---

## Error Prevention Checklist

- [ ] NULL values handled (`IS NULL`, `COALESCE`, `IFNULL`)
- [ ] Data types match (`CAST()`, implicit conversion)
- [ ] JOIN conditions complete (avoid Cartesian products)
- [ ] Aggregation context correct (GROUP BY vs window functions)
- [ ] Date formatting consistent (`DATE_FORMAT`, `EXTRACT`)
- [ ] String operations handle character sets
- [ ] Division by zero prevented (`NULLIF(denominator, 0)`)
- [ ] Performance impact considered (indexes, LIMIT clauses)

---

*Keep this guide handy — SQL mastery comes from consistent practice with real data!* 💪
