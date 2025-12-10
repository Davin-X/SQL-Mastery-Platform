# 04 — Recursive CTEs (expand rows into sequences)

Problem
- For input rows with a count `c2` and a start date `c3`, produce `c2` rows per `c1` with incremental dates starting at `c3`. Example:

Input
```
c1 | c2 | c3
---+----+----------
a  | 2  | 2020-01-02
b  | 1  | 2020-01-01
c  | 5  | 2020-01-05
```

Output (example)
```
c1 | c2 | c3
---+----+----------
a  | 1  | 2020-01-02
a  | 2  | 2020-01-03
b  | 1  | 2020-01-01
c  | 1  | 2020-01-05
c  | 2  | 2020-01-06
... up to c=5
```

Starter dataset / schema
```sql
CREATE TABLE input ( c1 VARCHAR(1), c2 INT, c3 DATE );
INSERT INTO input VALUES ('a',2,'2020-01-02'),('b',1,'2020-01-01'),('c',5,'2020-01-05');
```

Hints
- You can use a numbers table (derived) joined against the input, or a recursive CTE if your DB supports it.

### Solution
<details><summary>Show solution</summary>

Option A — join to an inline numbers set (works in MySQL without recursion):

```sql
SELECT t1.c1, t2.n AS c2,
       DATE_ADD(t1.c3, INTERVAL (t2.n - 1) DAY) AS c3
FROM input t1
JOIN (
  SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) t2 ON t2.n <= t1.c2
ORDER BY t1.c1, c3;
```

Option B — recursive CTE (MySQL/Postgres with recursion):

```sql
WITH RECURSIVE temp (c1, c2, c3) AS (
  SELECT c1, 1, c3 FROM input
  UNION ALL
  SELECT temp.c1, temp.c2 + 1, temp.c3 + INTERVAL 1 DAY
  FROM temp JOIN input ON input.c1 = temp.c1 AND input.c2 > temp.c2
)
SELECT c1, c2, c3 FROM temp ORDER BY c1, c3;
```

Notes
- Recursive CTEs are expressive for sequence generation; ensure you have termination conditions to avoid infinite recursion.

</details>
