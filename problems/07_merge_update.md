# 07 — Merge / Upsert (synchronize source into target)

Problem
- Given a `source` table and a `target` table, update existing rows in `target` with `source` values and insert new rows from `source` (UPSERT semantics).

Starter dataset / schema
```sql
CREATE TABLE source ( id INT PRIMARY KEY, value VARCHAR(50) );
CREATE TABLE target ( id INT PRIMARY KEY, value VARCHAR(50) );

INSERT INTO source (id, value) VALUES (1,'foo'),(2,'bar'),(3,'baz');
INSERT INTO target (id, value) VALUES (1,'initial value'),(4,'extra value');
```

Hints
- Use `MERGE` where supported, or `INSERT ... ON DUPLICATE KEY UPDATE` in MySQL.

### Solution
<details><summary>Show solution</summary>

MySQL-style upsert using `ON DUPLICATE KEY UPDATE`:

```sql
INSERT INTO target (id, value)
SELECT id, value FROM source
ON DUPLICATE KEY UPDATE value = VALUES(value);

-- Verify
SELECT * FROM target;
```

Notes
- For other RDBMS use `MERGE` (SQL Server / Oracle) or `INSERT ... ON CONFLICT` (Postgres).
- Wrap data-changing steps in transactions when moving large datasets.

</details>
