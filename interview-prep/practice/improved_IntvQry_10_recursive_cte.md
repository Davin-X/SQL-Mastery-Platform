# 🎯 Recursive CTE - Row Expansion Interview Question

## Question
Given an input table with columns (c1, c2, c3) where c2 represents a count and c3 is a date, write a query to expand each row by the count in c2, incrementing the date by 1 day for each expansion.

**Input:**
```
c1  c2  c3
a   2   2020-01-02
b   1   2020-01-01
c   5   2020-01-05
```

**Expected Output:**
```
c1  c2  c3
a   1   2020-01-02
a   2   2020-01-03
b   1   2020-01-01
c   1   2020-01-05
c   2   2020-01-06
c   3   2020-01-07
c   4   2020-01-08
c   5   2020-01-09
```

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE input (
  c1 VARCHAR(1),
  c2 INT,
  c3 DATE
);

INSERT INTO input VALUES
('a', 2, '2020-01-02'),
('b', 1, '2020-01-01'),
('c', 5, '2020-01-05');
```

## Answer 1: Using JOIN with Number Table

```sql
SELECT t1.c1, 
       t2.n AS c2, 
       DATE_ADD(t1.c3, INTERVAL (t2.n - 1) DAY) AS c3
FROM input t1
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
      SELECT 4 UNION ALL SELECT 5) t2
ON t2.n <= t1.c2
ORDER BY t1.c1, c3;
```

**How it works**: Creates a number table (1-5) and joins it with the input table where the number is <= the count (c2). Uses DATE_ADD to increment the date by (n-1) days.

## Answer 2: Using Recursive CTE

```sql
WITH RECURSIVE temp (c1, c2, c3) AS (
  -- Base case: start with count = 1
  SELECT c1, 1, c3
  FROM input
  
  UNION ALL
  
  -- Recursive case: increment count and add 1 day
  SELECT temp.c1, temp.c2 + 1, temp.c3 + INTERVAL 1 DAY
  FROM temp
  JOIN input ON input.c1 = temp.c1 AND input.c2 > temp.c2
)
SELECT c1, c2, c3
FROM temp
ORDER BY c1, c3;
```

**How it works**: 
- **Base case**: Starts with c2=1 for each row
- **Recursive case**: Increments c2 by 1 and adds 1 day to the date, but only while c2 < the original count
- **Termination**: Recursion stops when no more rows satisfy the join condition

## Performance Comparison

### JOIN Approach:
- **Pros**: Simple, works in all SQL databases
- **Cons**: Limited by hardcoded number range (1-5 in this case)
- **Use when**: Small, known range of counts

### Recursive CTE Approach:
- **Pros**: Dynamic range, no hardcoded limits
- **Cons**: May have recursion depth limits in some databases
- **Use when**: Variable or large count ranges needed

