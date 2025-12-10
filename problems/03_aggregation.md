# 03 — Aggregation (group and concatenate by initial)

Problem
- Given a list of fruit names, group them by their first letter and return a comma-separated list per initial.

Starter dataset / schema
```sql
CREATE TABLE fruits (fruit_name VARCHAR(20));
INSERT INTO fruits VALUES
('Apple'),('Banana'),('Avacadro'),('Blueberries'),('Orange'),('Mango');
```

Hints
- Use string aggregation (`GROUP_CONCAT` in MySQL) grouped by the first character.

### Solution
<details><summary>Show solution</summary>

Final SQL
```sql
SELECT LEFT(fruit_name, 1) AS initial,
       GROUP_CONCAT(fruit_name ORDER BY fruit_name SEPARATOR ', ') AS items
FROM fruits
GROUP BY LEFT(fruit_name, 1);
```

Notes
- Ordering inside `GROUP_CONCAT` is optional but helps reproducible output. Different RDBMS use different aggregation functions (e.g., `STRING_AGG` in Postgres/SQL Server).

</details>
