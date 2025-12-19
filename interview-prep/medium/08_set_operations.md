# 08 — Set Operations and Anti-joins

Problem
- Return rows present in `t1` but not in `t2` (anti-join). Discuss alternatives across databases.

Starter dataset / schema
```sql
CREATE TABLE t1 (id INT);
CREATE TABLE t2 (id INT);

INSERT INTO t1 (id) VALUES (10),(20),(30),(40),(50);
INSERT INTO t2 (id) VALUES (10),(30),(50);
```

Hints
- In MySQL use `NOT IN` or `LEFT JOIN ... WHERE t2.id IS NULL`. In Postgres use `EXCEPT`.

### Solution
<details><summary>Show solution</summary>

Anti-join using `NOT IN` (watch out for NULLs in `t2`):
```sql
SELECT * FROM t1 WHERE id NOT IN (SELECT id FROM t2);
```

Safer anti-join using `LEFT JOIN`:
```sql
SELECT t1.*
FROM t1 LEFT JOIN t2 ON t1.id = t2.id
WHERE t2.id IS NULL;
```

Set-operation form (Postgres/SQL Server / Oracle):
```sql
SELECT * FROM t1
EXCEPT
SELECT * FROM t2;
```

Notes
- `NOT IN` fails when the subquery returns NULLs; prefer `LEFT JOIN ... IS NULL` or `NOT EXISTS` pattern.

</details>
