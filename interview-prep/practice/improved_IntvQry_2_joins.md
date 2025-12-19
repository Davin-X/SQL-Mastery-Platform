# 🎯 JOIN Types Interview Question

## Question
Given two tables `table1` and `table2` with the following data:
- `table1.t1`: 1, 1, 1, NULL, NULL  
- `table2.t2`: 1, 1, 1, 1, 1

How many records will each JOIN type return when joining on `t1 = t2`?
1. INNER JOIN
2. LEFT JOIN  
3. RIGHT JOIN
4. FULL OUTER JOIN

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE tmp;
USE tmp;

CREATE TABLE table1 (t1 INT);
INSERT INTO table1 VALUES (1), (1), (1), (NULL), (NULL);

CREATE TABLE table2 (t2 INT);
INSERT INTO table2 VALUES (1), (1), (1), (1), (1);
```

## Answer 1: INNER JOIN

```sql
SELECT * FROM table1 INNER JOIN table2 ON table1.t1 = table2.t2;
```

**Result**: 15 records  
**How it works**: INNER JOIN only returns rows where the join condition matches. NULL values don't equal anything in SQL, so NULL rows are excluded. 3 rows × 5 rows = 15 matching combinations.

## Answer 2: LEFT JOIN

```sql
SELECT * FROM table1 LEFT JOIN table2 ON table1.t1 = table2.t2;
```

**Result**: 17 records  
**How it works**: LEFT JOIN returns all rows from the left table plus matching rows from the right. The 3 non-NULL left rows match 5 right rows each (15 total), plus the 2 NULL left rows with no matches (17 total).

## Answer 3: RIGHT JOIN

```sql
SELECT * FROM table1 RIGHT JOIN table2 ON table1.t1 = table2.t2;
```

**Result**: 15 records  
**How it works**: RIGHT JOIN returns all rows from the right table plus matching rows from the left. All 5 right table rows have matches with the left table's non-NULL values.

## Answer 4: FULL OUTER JOIN

```sql
-- MySQL workaround (FULL OUTER JOIN not supported)
SELECT * FROM table1 
LEFT JOIN table2 ON table1.t1 = table2.t2
UNION ALL
SELECT * FROM table1 
RIGHT JOIN table2 ON table1.t1 = table2.t2 
WHERE table1.t1 IS NULL;

-- Standard SQL (if supported)
SELECT * FROM table1 FULL OUTER JOIN table2 ON table1.t1 = table2.t2;
```

**Result**: 17 records  
**How it works**: FULL OUTER JOIN combines LEFT and RIGHT JOIN results. In MySQL, we use UNION ALL since FULL OUTER JOIN isn't supported. Returns all rows from both tables with NULLs where no matches exist.

## Key Concepts

- **INNER JOIN**: Only matching rows (NULL ≠ NULL)
- **LEFT JOIN**: All left rows + matches from right
- **RIGHT JOIN**: All right rows + matches from left  
- **FULL OUTER JOIN**: All rows from both tables
- **NULL behavior**: NULL values never match in equality comparisons

## Interview Tips

- Always clarify which database is being used (MySQL doesn't have FULL OUTER JOIN)
- Explain NULL handling explicitly
- Count Cartesian products systematically
- Consider performance implications of different JOIN types
