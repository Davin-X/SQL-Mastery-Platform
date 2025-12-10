# 06 — Ranking (second highest salary per group)

Problem
- For an `employee_dept` table (id, name, department, salary) return the second highest salary per department. If a department has fewer than 2 employees, return the highest salary.

Starter dataset / schema
```sql
CREATE TABLE employee_dept (
    id INT,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employee_dept VALUES
(1,'John','Sales',5000),(2,'Jane','Marketing',6000),(3,'Bob','Sales',4000),
(4,'Alice','Marketing',5500),(5,'David','Sales',4500),(6,'Carol','Marketing',7000),
(7,'Tom','HR',3000),(8,'Mary','HR',3500),(9,'Bill','HR',3200);
```

Hints
- Use `ROW_NUMBER()`/`RANK()` or a window expression to find the nth highest per partition, or use a correlated subquery.

### Solution
<details><summary>Show solution</summary>

Using window functions (returns NULL for second when not present; adapt with `COALESCE`):

```sql
SELECT DISTINCT department,
  CASE
    WHEN COUNT(*) >= 2 THEN MAX(salary) OVER (PARTITION BY department ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
    ELSE MAX(salary) OVER (PARTITION BY department)
  END AS second_highest_salary
FROM employee_dept
GROUP BY department, salary;
```

Alternative using `ROW_NUMBER()`:

```sql
SELECT department, salary AS second_highest_salary
FROM (
  SELECT department, salary,
         ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn,
         COUNT(*) OVER (PARTITION BY department) AS dept_count
  FROM employee_dept
) t
WHERE (rn = 2) OR (dept_count = 1 AND rn = 1);
```

Notes
- `RANK()` handles ties differently (`RANK()` may skip numbers when ties occur). Choose `DENSE_RANK` if you want consecutive ranks.

</details>
