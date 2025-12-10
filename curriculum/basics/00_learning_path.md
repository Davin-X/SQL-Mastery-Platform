# SQL Interview Learning Path — Curriculum (Concise Roadmap)

This document presents a focused, practical learning path that prepares a learner to crack SQL interview questions. It pairs core concepts with hands-on exercises from this repository, gives a weekly study plan, and includes mock-interview checkpoints.

Goal: Be able to read a prompt, design correct SQL (including edge cases), explain complexity and performance, and optimize queries confidently under interview conditions.

How to use this path:
- Follow the weekly milestones sequentially.
- For each milestone, read the topic file in `curriculum/basics/`, run the examples locally, then solve the mapped `problems/` files.
- After each week, do 2–3 timed mock problems (30–45 minutes) and review solutions.

Core timeline (8 weeks — adaptable to 4–12 weeks):

- Week 1 — Schema & CRUD fundamentals
  - Read: `01_schema_and_ddl.sql`, `02_crud_dml.sql`
  - Practice: `problems/01_joins.sql` (data modeling + simple joins), small exercises from files
  - Outcomes: Create tables, understand constraints, insert/update/delete safely, and write basic selects

- Week 2 — SELECT & Joins (inner/outer/cross/self)
  - Read: `03_select_joins.sql`
  - Practice: `problems/01_joins.sql`, additional join variants
  - Outcomes: Master join strategies and when to use each type; reason about nulls and join ordering

- Week 3 — Aggregation & GROUP BY
  - Read: `04_aggregation_groupby.sql`
  - Practice: `problems/03_aggregation.sql`
  - Outcomes: Aggregations, HAVING, grouping sets, rollups, and string aggregation

- Week 4 — Window / Analytic functions
  - Read: `05_window_functions.sql`
  - Practice: `problems/05_window_functions.sql`, `problems/06_ranking.sql`
  - Outcomes: ROW_NUMBER/RANK/LEAD/LAG, sessionization, gaps-and-islands patterns

- Week 5 — CTEs, recursive queries, subqueries
  - Read: `06_cte_and_subqueries.sql`
  - Practice: `problems/04_recursive_cte.sql`, `problems/12_misc_interview.sql`
  - Outcomes: Build readable queries with CTEs, implement recursive solutions

- Week 6 — Merge, update patterns, set operations
  - Read: `07_transactions_dcl.sql` (transactions) and relevant problem files
  - Practice: `problems/07_merge_update.sql`, `problems/08_set_operations.sql`
  - Outcomes: Upserts, MERGE semantics, set operations, and safe updates with transactions

- Week 7 — Scheduling, matching, deduping, spike detection
  - Read: `curriculum/basics/*` as needed and `08_indexing_and_performance.sql` for performance basics
  - Practice: `problems/09_scheduling.sql`, `problems/10_matching_dedup.sql`, `problems/11_spike_detection.sql`
  - Outcomes: Time-based reasoning, deduplication techniques, anomaly detection patterns

- Week 8 — Advanced: Indexing, stored procedures, optimization, and mock interviews
  - Read: `08_indexing_and_performance.sql`, `09_stored_procedures_triggers.sql`
  - Practice: Pick 3 complex problems from `problems/*` (timed), and run a full mock interview
  - Outcomes: Explain indexes and query plans, justify optimizations, use stored routines where appropriate

Practice format & timing suggestions:
- Learn the concept (20–40 min). Run worked examples (20–30 min). Solve 2–4 practice problems (60–90 min).
- Timed mock problem: 30–45 minutes. Write the query, test mentally (or with sample data), and explain tradeoffs.

Mapping: Curriculum → Canonical problems
- `01_schema_and_ddl.sql` → schema design tasks in problems
- `02_crud_dml.sql` → data mutation practice (add/update/delete patterns)
- `03_select_joins.sql` → `problems/01_joins.sql`
- `04_aggregation_groupby.sql` → `problems/03_aggregation.sql`
- `05_window_functions.sql` → `problems/05_window_functions.sql`, `problems/06_ranking.sql`
- `06_cte_and_subqueries.sql` → `problems/04_recursive_cte.sql`
- `07_transactions_dcl.sql` → `problems/07_merge_update.sql` and any update-heavy problems
- `08_indexing_and_performance.sql` → performance tuning for your solved problems

Mock interview checklist (30–45 minute problem):
1. Read problem carefully; restate it in one sentence.
2. Ask clarifying questions (expected nulls, duplicates, desired sort order, DB flavor).
3. Propose a sample dataset and expected output.
4. Outline approach with pseudocode/steps (1–3 lines).
5. Write the query; handle edge cases (NULLs, ties, empty sets).
6. Explain complexity and possible optimizations (indexes, rewriting with joins/CTE, limits).
7. Run through a small example to verify correctness.

Common interview tips & pitfalls:
- Always consider NULLs and duplicates explicitly.
- Be ready to explain why you chose a window function vs aggregation/join.
- Time complexity: be able to identify scans vs index seeks conceptually.
- If asked to optimize, propose concrete index(s) and explain why (covering index, column order).
- For recursive/graph problems, clarify termination conditions and performance concerns.

Resources (recommended):
- SQLBolt — interactive tutorials
- Mode SQL Tutorials — applied data analysis examples
- LeetCode / HackerRank SQL problems — timed practice
-