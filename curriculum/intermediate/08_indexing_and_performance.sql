-- 08_indexing_and_performance.sql
-- Topic: Indexes, query plans, and basic performance checks

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- Create an index on dept_id (if heavy joins on it)
CREATE INDEX idx_emp_deptid ON employee (dept_id);

-- Use EXPLAIN to inspect a query
EXPLAIN
SELECT e.first_name, d.dept_name
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

\c sample_hr;

-- Create an index on dept_id
CREATE INDEX idx_emp_deptid ON employee (dept_id);

-- Use EXPLAIN to inspect a query (with ANALYZE for actual execution)
EXPLAIN ANALYZE
SELECT e.first_name, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;

-- PostgreSQL Notes:
-- - EXPLAIN ANALYZE shows actual execution time and row counts
-- - EXPLAIN (without ANALYZE) shows only the plan
-- - Same CREATE INDEX syntax
-- - Additional options: EXPLAIN (FORMAT JSON), EXPLAIN (BUFFERS), etc.
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax:

USE sample_hr;

-- Create an index on dept_id
CREATE INDEX idx_emp_deptid ON employee (dept_id);

-- Use execution plan to inspect a query
-- Method 1: Include Actual Execution Plan (GUI)
-- Method 2: Use SET commands
SET SHOWPLAN_ALL ON;
GO
SELECT e.first_name, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;
GO
SET SHOWPLAN_ALL OFF;
GO

-- Method 3: Use sys.dm_exec_query_plan (for actual plans)
SELECT
qs.execution_count,
qs.total_logical_reads,
qs.total_logical_writes,
qs.total_worker_time/1000 AS total_cpu_time_ms,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qp.query_plan.exist('declare namespace
qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
//qplan:QueryPlan') = 1;

-- SQL Server Notes:
-- - SET SHOWPLAN_ALL/Text/XML ON shows estimated plans
-- - SET STATISTICS IO ON shows I/O statistics
-- - SET STATISTICS TIME ON shows timing information
-- - GUI execution plans are most commonly used
-- - sys.dm_exec_* DMVs provide detailed runtime statistics
*/

-- Exercises (all databases):
-- 1) Compare execution time (or EXPLAIN cost) before and after adding index.
--    MySQL: Use EXPLAIN with execution time
--    PostgreSQL: Use EXPLAIN ANALYZE
--    SQL Server: Use SET STATISTICS TIME ON and execution plans

-- 2) Identify a slow query and propose an indexing strategy.
--    All databases: Look for table scans, high I/O, missing indexes in execution plans