```sql
-- 08_indexing_and_performance.sql
-- Topic: Indexes, query plans, and basic performance checks

-- Example: create indexes, use EXPLAIN to inspect query plans
USE sample_hr;

-- Create an index on dept_id (if heavy joins on it)
CREATE INDEX idx_emp_deptid ON employee (dept_id);

-- Use EXPLAIN to inspect a query
EXPLAIN
SELECT e.first_name, d.dept_name
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- Exercises:
-- 1) Compare execution time (or EXPLAIN cost) before and after adding index.
-- 2) Identify a slow query and propose an indexing strategy.
```