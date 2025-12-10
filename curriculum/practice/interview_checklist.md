# Interview Checklist (One-page quick reference)

Use this checklist during a timed interview session to stay organized and demonstrate competence.

## Pre-interview (15 minutes before)
- [ ] Test database connection and verify query editor works
- [ ] Open reference docs if permitted (company policies vary)
- [ ] Confirm expected output format (CSV, JSON, column names, sort order)

## During problem (30–45 minutes)

### 1. Understand the problem (3–5 min)
- [ ] Read the problem statement carefully
- [ ] Restate it in one sentence
- [ ] Identify the table(s) and key join/grouping columns
- [ ] List example input rows and expected output

### 2. Ask clarifying questions (2–3 min)
- [ ] Are there NULL values? How should they be handled?
- [ ] Are there duplicates? De-duplicate or aggregate?
- [ ] What is the sort order expected?
- [ ] Which database flavor (MySQL, Postgres, SQL Server, etc.)?
- [ ] Are there performance constraints (e.g., table size)?

### 3. Design approach (3–5 min)
- [ ] Sketch pseudocode or outline in plain language (not code)
- [ ] Choose: joins, aggregation, window functions, CTE, subquery, or combo?
- [ ] Consider edge cases: empty result set, NULLs, ties, missing data

### 4. Write the query (15–25 min)
- [ ] Start with the SELECT (columns and aliases)
- [ ] Add FROM and JOINs (explicit ON clauses)
- [ ] Add WHERE (filters on base tables)
- [ ] Add GROUP BY / HAVING if aggregating
- [ ] Add ORDER BY (confirm expected sort order)

### 5. Test & validate (5–10 min)
- [ ] Run on sample data and trace through logic mentally
- [ ] Check for common pitfalls:
+  - [ ] NULLs in comparisons (use IS NULL, COALESCE)
+  - [ ] Duplicates from multiple joins (consider DISTINCT if needed)
+  - [ ] Off-by-one errors in ranking/numbering
+  - [ ] Implicit type conversion issues

### 6. Explain & optimize (5–10 min)
- [ ] Walk the interviewer through your logic step-by-step
- [ ] State the complexity class (linear scan, index seek, etc.)
- [ ] Suggest one optimization:
+  - [ ] Add an index on the join or filter column (e.g., `CREATE INDEX idx_emp_dept_id ON employee(dept_id)`)
+  - [ ] Rewrite using a CTE for readability if using many subqueries
+  - [ ] Replace NOT IN with LEFT JOIN ... IS NULL to handle NULLs safely

## Post-interview (after submission)
- [ ] Save your final query
- [ ] If rejected, ask for specific feedback (what was wrong?)
- [ ] Review the provided solution and note differences

## Common SQL Mistakes to Avoid

| Mistake | Example | Fix |
|---------|---------|-----|
| NULLs in NOT IN | `WHERE id NOT IN (SELECT id FROM t2)` | Use `LEFT JOIN ... IS NULL` |
| Unqualified column names | `SELECT name, department FROM emp JOIN dept` (which name?) | Always alias tables: `SELECT e.name, d.dept_name` |
| GROUP BY without aggregation | `SELECT employee_id, salary FROM emp GROUP BY dept` | Include `salary` in GROUP BY or use an aggregate |
| CROSS JOIN by accident | Forgot to add JOIN condition | Add explicit ON clause |
| Incorrect RANK for ties | Need 2nd highest but RANK skips numbers | Use `DENSE_RANK()` or `ROW_NUMBER()` depending on requirement |

## Interview Energy Tips
- **Stay calm**: If stuck, explain your thought process out loud
- **Ask for hints**: Interviewers often give them; use them!
- **Timeboxing**: If a solution isn't coming, pivot to a simpler approach and explain the tradeoff
- **Readability first**: Clean, readable code beats clever one-liners in an interview setting
