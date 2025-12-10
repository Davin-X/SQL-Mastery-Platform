# Basics — Core SQL concepts

This folder contains concise, hands-on practice for core SQL concepts every learner should master: DDL, DML (CRUD), SELECT queries, joins, aggregation, window functions, CTEs, and transactions/DCL.

## Quick Start & Resources

**Interview preparation**: Start here for a comprehensive study plan!
- 📚 [`00_learning_path.md`](00_learning_path.md) — 8-week guided curriculum with weekly milestones and study schedule
- ✅ [`interview_checklist.md`](interview_checklist.md) — one-page checklist for during the interview
- ⏱️ [`timed_mock_problems.md`](timed_mock_problems.md) — 10 timed practice problems (easy to expert) with solutions

**Local practice setup**:
- 🌱 [`examples/seed_sample_hr.sql`](../examples/seed_sample_hr.sql) — realistic sample database with 200+ rows
- 🔧 [`examples/load_sample_data.sh`](../examples/load_sample_data.sh) — one-command loader script

**Problem solutions** (combined problem + solution format):
- [`problems/01_joins.md`](../problems/01_joins.md) — inner/left/right/full joins with row counts
- [`problems/02_conditionals.md`](../problems/02_conditionals.md) — gender counts per department
- [`problems/03_aggregation.md`](../problems/03_aggregation.md) — group and aggregate by initial letter
- [`problems/04_recursive_cte.md`](../problems/04_recursive_cte.md) — expand rows into sequences
- [`problems/05_window_functions.md`](../problems/05_window_functions.md) — partitioning and ordering
- [`problems/06_ranking.md`](../problems/06_ranking.md) — second highest salary per group
- [`problems/07_merge_update.md`](../problems/07_merge_update.md) — upsert patterns
- [`problems/08_set_operations.md`](../problems/08_set_operations.md) — anti-joins and EXCEPT
- [`problems/09_scheduling.md`](../problems/09_scheduling.md) — elapsed times and train schedules
- [`problems/10_matching_dedup.md`](../problems/10_matching_dedup.md) — unique matches and dedup
- [`problems/11_spike_detection.md`](../problems/11_spike_detection.md) — on/off activity periods
- [`problems/12_misc_interview.md`](../problems/12_misc_interview.md) — complex interview patterns

Recommended study order:
1. `01_schema_and_ddl.sql` — create/alter/drop schema objects
2. `02_crud_dml.sql` — INSERT / SELECT / UPDATE / DELETE patterns
3. `03_select_joins.sql` — joins and set operations
4. `04_aggregation_groupby.sql` — GROUP BY, HAVING, string aggregation
5. `05_window_functions.sql` — ROW_NUMBER(), RANK(), LEAD/LAG
6. `06_cte_and_subqueries.sql` — non-recursive and recursive CTEs
7. `07_transactions_dcl.sql` — transactions, commit/rollback, GRANT/REVOKE

Each file contains: a short explanation, a minimal sample dataset (CREATE/INSERT), a few worked examples, and 3–5 practice exercises with hints.

**Linked canonical problems** (each has a `.md` version with problem statement, starter schema, and solutions):

**Core Problems (Weeks 1-8):**
- `problems/01_joins.md` / `problems/01_joins.sql`
- `problems/02_conditionals.md` / `problems/02_conditionals.sql`
- `problems/03_aggregation.md` / `problems/03_aggregation.sql`
- `problems/04_recursive_cte.md` / `problems/04_recursive_cte.sql`
- `problems/05_window_functions.md` / `problems/05_window_functions.sql`
- `problems/06_ranking.md` / `problems/06_ranking.sql`
- `problems/07_merge_update.md` / `problems/07_merge_update.sql`
- `problems/08_set_operations.md` / `problems/08_set_operations.sql`
- `problems/09_scheduling.md` / `problems/09_scheduling.sql`
- `problems/10_matching_dedup.md` / `problems/10_matching_dedup.sql`
- `problems/11_spike_detection.md` / `problems/11_spike_detection.sql`
- `problems/12_misc_interview.md` / `problems/12_misc_interview.sql`

**Advanced Analytics Problems (Weeks 9-12):**
- `problems/13_advanced_analytics.md` / `problems/13_advanced_analytics.sql` — Statistical distributions and correlations
- `problems/14_ecommerce_analytics.md` — Business intelligence and customer analytics

(Read `.md` files for learning; keep `.sql` files for automated test runs.)


Run basics locally:

1. **Load sample data** (one-time setup):
```bash
cd examples/
chmod +x load_sample_data.sh
./load_sample_data.sh -u root -p your_password
```

2. **Run all curriculum files** against the sample_hr database:
```bash
chmod +x examples/run_basics.sh
./examples/run_basics.sh -u root -p your_password -d sample_hr
```

3. **Practice with the mock problems**:
   - Open `curriculum/basics/timed_mock_problems.md`
   - Set a 30–45 min timer and solve each one
   - Compare your solution to the provided answer
