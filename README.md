# SQL Interview Exercises

Purpose
- A concise, well-organized collection of SQL exercises and interview practice materials. Examples use MySQL-style syntax with notes for other dialects (PostgreSQL, SQLite).

Repository structure
- `curriculum/basics/` — Core learning path (schema & DDL, CRUD/DML, SELECT, joins, aggregation, window functions, CTEs, transactions, indexing, stored procedures). Each file contains runnable examples and exercises.
- `problems/` — Numbered interview problems with detailed explanations and runnable `.sql` versions.
- `examples/` — Sample datasets and helper scripts (e.g., `seed_sample_hr.sql`, `load_sample_data.sh`).
- `archive/` — Older or redundant material kept for reference.

What’s included
- 9 curriculum files covering beginner → advanced topics.
- 12 canonical problem sets (problem statement + solution).
- 10 timed mock-interview scenarios with starter SQL and full solutions.
- A realistic sample database (`examples/seed_sample_hr.sql`) and a loader script (`examples/load_sample_data.sh`).

Quick start
1. Clone the repository and open it in your editor (VS Code recommended).
# SQL Interview Exercises

Purpose
- A concise, well-organized collection of SQL exercises and interview practice materials. Examples use MySQL-style syntax with notes for other dialects (PostgreSQL, SQLite).

Repository structure
- `curriculum/basics/` — Core learning path (schema & DDL, CRUD/DML, SELECT, joins, aggregation, window functions, CTEs, transactions, indexing, stored procedures). Each file contains runnable examples and exercises.
- `problems/` — Numbered interview problems with detailed explanations and runnable `.sql` versions.
- `examples/` — Sample datasets and helper scripts (e.g., `seed_sample_hr.sql`, `load_sample_data.sh`).
- `archive/` — Older or redundant material kept for reference.

What’s included
- 9 curriculum files covering beginner → advanced topics.
- 12 canonical problem sets (problem statement + solution).
- 10 timed mock-interview scenarios with starter SQL and full solutions.
- A realistic sample database (`examples/seed_sample_hr.sql`) and a loader script (`examples/load_sample_data.sh`).

Quick start
1. Clone the repository and open it in your editor (VS Code recommended).
2. (Optional) Install a SQL client/extension for your editor.
3. Load the sample database (MySQL example):

```bash
# make loader executable if needed
chmod +x examples/load_sample_data.sh
./examples/load_sample_data.sh -u <user> -p <password> -h <host> -d sample_hr
```

4. Run a curriculum file against the sample DB (MySQL):

```bash
mysql -u <user> -p sample_hr < curriculum/basics/01_schema_and_ddl.sql
```

If you prefer PostgreSQL adapt the SQL dialect or use equivalents and run with `psql`:

```bash
psql -U <user> -d sample_hr -f path/to/file.sql
```

Recommended workflow
- Start with `curriculum/basics/00_learning_path.md` for a suggested 8-week roadmap.
- Work each curriculum file, then solve the matching problems in `problems/`.
- Use `curriculum/basics/timed_mock_problems.md` to simulate interviews (time yourself, then review solutions).
- Run queries against `examples/seed_sample_hr.sql` to validate results and experiment with optimizations.

Contributing
- Improve problems, add sample data, or provide alternative solutions. Keep file names consistent (e.g., `01_joins.md` / `01_joins.sql`).
- Open an issue to discuss larger changes, or submit a pull request for small improvements.

Suggested improvements (future)
- Add a formal `LICENSE` file.
- Add lightweight CI that runs smoke tests against example SQL (optional).

Contact
- Use the GitHub repository’s Issues/PRs for feedback and contributions.

Enjoy practicing — start with `curriculum/basics/00_learning_path.md`.

