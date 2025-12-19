# 01 — Joins (counts and behaviors)

Problem
- Given two tables `table1` and `table2` with the following rows:

- `table1.t1`: 1,1,1,NULL,NULL
- `table2.t2`: 1,1,1,1,1

Questions
- How many rows will you get from each join type when joining on `t1 = t2`?
  1) INNER JOIN
  2) LEFT JOIN
  3) RIGHT JOIN
  4) FULL OUTER JOIN

Starter dataset / schema
```sql
CREATE DATABASE IF NOT EXISTS tmp;
USE tmp;

CREATE TABLE table1 ( t1 INT );
INSERT INTO table1 VALUES (1),(1),(1),(NULL),(NULL);

CREATE TABLE table2 ( t2 INT );
INSERT INTO table2 VALUES (1),(1),(1),(1),(1);
```

Hints
- Remember how NULL behaves in equality comparisons. Consider the Cartesian product and then the predicate.

### Solution
<details><summary>Show solution</summary>

Reasoning
- `INNER JOIN` returns pairs where `t1 = t2`. Only rows where `t1` is 1 match values 1 in `table2`. There are 3 rows in `table1` with value 1 and 5 rows in `table2` with value 1, producing 3 * 5 = 15 rows.
- `LEFT JOIN` returns all rows from `table1` (5 rows) plus matching `table2` rows; the three non-NULL `t1` rows each match 5 rows from `table2` (15 rows), and the two NULL `t1` rows match none (NULLs), so total rows = 15 + 2 = 17.
- `RIGHT JOIN` symmetric to `LEFT JOIN` with sides swapped: all rows from `table2` (5) plus matches; the three non-NULL `t1` rows each match 5 `table2` rows (15), but counting is equivalent to INNER + unmatched right rows (none, since all right rows have matches), so total = 15.
- `FULL OUTER JOIN` returns all rows from both sides, combining left-only and right-only rows. In this case, since right values all match left non-null entries, and left has two null-only rows, the total will be 17 (same as left join here). Some engines need UNION of left and right outer joins to emulate full outer join.

Final (example queries)
```sql
-- inner join
SELECT * FROM table1 INNER JOIN table2 ON table1.t1 = table2.t2;

-- left join
SELECT * FROM table1 LEFT JOIN table2 ON table1.t1 = table2.t2;

-- right join
SELECT * FROM table1 RIGHT JOIN table2 ON table1.t1 = table2.t2;

-- full join (MySQL emulation)
SELECT * FROM table1 LEFT JOIN table2 ON table1.t1 = table2.t2
UNION ALL
SELECT * FROM table1 RIGHT JOIN table2 ON table1.t1 = table2.t2;
```

</details>
