# 10 — Matching & Deduplication (unique matches)

Problem
- Given a table with `name` and `id` pairs, find names that match a specific id (e.g., id = 2) but appear only once (unique name).

Starter dataset / schema
```sql
CREATE TABLE my_table (name VARCHAR(1), id INT);
INSERT INTO my_table VALUES
('A',1),('A',2),('A',3),('B',2),('C',3),('C',1);
```

Expected output
```
name | id
-----+----
B    | 2
```

Hints
- Use window functions to count occurrences per name, or aggregate with `GROUP BY` and `HAVING`.

### Solution
<details><summary>Show solution</summary>

Using a window function to compute per-name counts and filter for id = 2 and single occurrence:

```sql
CREATE TABLE result AS
SELECT name, id
FROM (
  SELECT name, id, COUNT(name) OVER (PARTITION BY name) AS name_count
  FROM my_table
) t
WHERE id = 2 AND name_count = 1;

SELECT * FROM result;
```

Alternative using aggregation:
```sql
SELECT name, MAX(id) AS id
FROM my_table
GROUP BY name
HAVING COUNT(*) = 1 AND MAX(id) = 2;
```

Notes
- Choose the approach that matches your DB feature set; window functions are handy when you need to keep row-level data while counting.

</details>
