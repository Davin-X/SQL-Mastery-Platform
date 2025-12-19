# 05 — Window Functions (partitioning and ordering)

Problem
- Use window functions to compute department-level counts, order-aware counts, and examples such as `ROW_NUMBER`, `RANK`, `LEAD`, `LAG`.

Starter dataset / schema
```sql
CREATE TABLE emp_dept_tbl (
    ID INT,
    FIRST_NAME VARCHAR(20),
    LAST_NAME VARCHAR(20),
    DESIGNATION VARCHAR(20),
    DEPARTMENT VARCHAR(20),
    SALARY INT
);

-- (Assume data loaded into emp_dept_tbl)
```

Hints
- `COUNT(*) OVER (PARTITION BY department)` gives department size for every row.
- `LEAD`/`LAG` are useful to compare adjacent rows ordered by a column.

### Solution
<details><summary>Show solution</summary>

Examples

Count employees per department (row-level):
```sql
SELECT id, department, salary,
       COUNT(id) OVER (PARTITION BY department) AS dept_count
FROM emp_dept_tbl;
```

Order-aware count (running counts ordered by salary):
```sql
SELECT id, department, salary,
       COUNT(id) OVER (ORDER BY salary DESC) AS running_count
FROM emp_dept_tbl;
```

Partitioned order (count per department ordered by salary):
```sql
SELECT id, department, salary,
       COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC) AS dept_ordered_count
FROM emp_dept_tbl;
```

Notes
- Window functions do not collapse rows (unlike GROUP BY). Use them when you need row-level context plus aggregates.

</details>
