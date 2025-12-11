# Multi-Database SQL Syntax Support

This document outlines the PostgreSQL and Microsoft SQL Server syntax variations added to the SQL-Mastery-Platform repository. Each major SQL file now includes equivalent syntax for all three major databases: MySQL, PostgreSQL, and SQL Server.

## Files Updated

### 1. `curriculum/foundational/01_schema_and_ddl.sql`
**Key Differences Added:**
- **Auto-increment**: `AUTO_INCREMENT` (MySQL) vs `SERIAL` (PostgreSQL) vs `IDENTITY(1,1)` (SQL Server)
- **Database Connection**: `USE database` (MySQL/SQL Server) vs `\c database` (PostgreSQL)
- **Column Addition**: `ADD COLUMN` (MySQL/PostgreSQL) vs `ADD` (SQL Server)
- **NOT NULL Constraints**: `MODIFY column NOT NULL` (MySQL) vs `ALTER COLUMN SET NOT NULL` (PostgreSQL) vs `ALTER COLUMN NOT NULL` (SQL Server)
- **PRIMARY KEY**: Inline, table-level, and named constraints with composite key support
- **FOREIGN KEY**: Inline, table-level, and named constraints with referential actions (CASCADE, SET NULL, etc.)
- **UNIQUE**: Inline, table-level, and named constraints with composite unique keys
- **CHECK**: Inline, table-level, and named constraints with different enforcement levels
- **DEFAULT**: Inline and named constraints with varying expression support
- **Adding/Dropping Constraints**: Different ALTER TABLE syntax for each database

### 2. `curriculum/intermediate/05_window_functions.sql`
**Key Differences Added:**
- **Date Functions**: `DATE_FORMAT()` (MySQL) vs `TO_CHAR()` (PostgreSQL) vs `FORMAT()` (SQL Server)
- **Date Differences**: `DATEDIFF()` (MySQL/SQL Server) vs `EXTRACT(DAY FROM date1 - date2)` (PostgreSQL)
- **Database Connection**: `USE` vs `\c`

### 3. `curriculum/foundational/04_aggregation_groupby.sql`
**Key Differences Added:**
- **String Aggregation**: `GROUP_CONCAT()` (MySQL) vs `STRING_AGG()` (PostgreSQL/SQL Server)
- **LIMIT/OFFSET**: `LIMIT` (MySQL/PostgreSQL) vs `TOP` (SQL Server)
- **Database Connection**: `USE` vs `\c`

### 4. `problems/01_joins.sql`
**Key Differences Added:**
- **FULL OUTER JOIN**: Native support (PostgreSQL/SQL Server) vs UNION ALL workaround (MySQL)

### 5. `curriculum/advanced/11_modern_sql_features.sql`
**Key Differences Added:**
- **JSON Storage**: `JSON` (MySQL) vs `JSONB` (PostgreSQL) vs `NVARCHAR(MAX) + CHECK(ISJSON())` (SQL Server)
- **JSON Extraction**: `JSON_EXTRACT()` (MySQL) vs `->>` (PostgreSQL) vs `JSON_VALUE()` (SQL Server)
- **JSON Path Operations**: `JSON_EXTRACT()` (MySQL) vs `#>>` (PostgreSQL) vs `OPENJSON()` (SQL Server)
- **JSON Array Length**: `JSON_LENGTH()` (MySQL) vs `jsonb_array_length()` (PostgreSQL) vs `OPENJSON() + COUNT(*)` (SQL Server)

### 6. `curriculum/advanced/09_stored_procedures_triggers.sql`
**Key Differences Added:**
- **Stored Procedures**: `DELIMITER $$ ... $$` (MySQL) vs `CREATE OR REPLACE FUNCTION` (PostgreSQL) vs `CREATE PROCEDURE ... AS BEGIN ... END` (SQL Server)
- **Parameter Syntax**: No special syntax (MySQL) vs parameter names (PostgreSQL) vs `@parameter_name` (SQL Server)
- **Triggers**: `BEFORE INSERT ... SET NEW.column` (MySQL) vs `BEFORE INSERT ... EXECUTE FUNCTION` (PostgreSQL) vs `FOR INSERT ... UPDATE ... FROM inserted` (SQL Server)
- **Execution**: `CALL procedure()` (MySQL) vs `SELECT * FROM function()` (PostgreSQL) vs `EXEC procedure` (SQL Server)

### 7. `curriculum/advanced/10_advanced_analytics.sql`
**Key Differences Added:**
- **Percentile Functions**: `PERCENTILE_CONT() WITHIN GROUP (ORDER BY col)` (MySQL/PostgreSQL) vs `PERCENTILE_CONT() OVER (PARTITION BY ...)` (SQL Server)
- **Correlation**: `CORR(col1, col2)` (MySQL/PostgreSQL) vs manual calculation or `CORR()` (SQL Server 2022+)
- **Date/Time Differences**: `TIMESTAMPDIFF()` (MySQL) vs `EXTRACT(YEAR FROM AGE())` (PostgreSQL) vs `DATEDIFF()` (SQL Server)

### 8. `curriculum/intermediate/08_indexing_and_performance.sql`
**Key Differences Added:**
- **Query Plans**: `EXPLAIN` (MySQL) vs `EXPLAIN ANALYZE` (PostgreSQL) vs `SET SHOWPLAN_ALL ON` or GUI (SQL Server)
- **Index Creation**: Same `CREATE INDEX` syntax across all databases
- **Performance Monitoring**: Execution time display vs DMVs vs GUI tools

### 9. `curriculum/intermediate/07_transactions_dcl.sql`
**Key Differences Added:**
- **Transaction Start**: `START TRANSACTION` (MySQL) vs `BEGIN` (PostgreSQL) vs `BEGIN TRANSACTION` (SQL Server)
- **Savepoints**: `SAVEPOINT name; ROLLBACK TO SAVEPOINT name` (MySQL/PostgreSQL) vs `SAVE TRANSACTION name; ROLLBACK TRANSACTION name` (SQL Server)
- **Permissions**: Table-level (MySQL) vs Schema-level (PostgreSQL/SQL Server)

### 10. `curriculum/specialized/12_cloud_data_warehousing.sql`
**Key Differences Added:**
- **Traditional RDBMS Approaches**: MySQL partitioning vs PostgreSQL table partitioning vs SQL Server partition schemes
- **Cloud-Specific Features**: BigQuery partitioning/clustering vs Snowflake time travel vs Redshift distribution keys
- **Approximate Functions**: `APPROX_COUNT_DISTINCT()` (BigQuery/Snowflake) vs manual calculations (traditional RDBMS)
- **JSON Operations**: VARIANT (Snowflake) vs SUPER (Redshift) vs traditional JSON types

### 11. `curriculum/specialized/13_time_series_financial_analytics.sql`
**Key Differences Added:**
- **Auto-increment**: `AUTO_INCREMENT` (MySQL) vs `SERIAL` (PostgreSQL) vs `IDENTITY()` (SQL Server)
- **ENUM Types**: `ENUM` (MySQL) vs `CHECK` constraints (PostgreSQL/SQL Server)
- **Date Formatting**: `DATE_FORMAT()` (MySQL) vs `TO_CHAR()` (PostgreSQL) vs `FORMAT()` (SQL Server)
- **Statistical Functions**: `MEDIAN()` (MySQL) vs `PERCENTILE_CONT()` (PostgreSQL/SQL Server)
- **Date Differences**: `TIMESTAMPDIFF()` (MySQL) vs `EXTRACT(AGE())` (PostgreSQL) vs `DATEDIFF()` (SQL Server)
- **Mathematical Functions**: `POW()` (MySQL) vs `POWER()` (PostgreSQL/SQL Server)

## Syntax Comparison Tables

### Auto-Increment Columns
| Database | Syntax | Example |
|----------|--------|---------|
| MySQL | `AUTO_INCREMENT` | `id INT PRIMARY KEY AUTO_INCREMENT` |
| PostgreSQL | `SERIAL` | `id SERIAL PRIMARY KEY` |
| SQL Server | `IDENTITY(seed, increment)` | `id INT IDENTITY(1,1) PRIMARY KEY` |

### Database Connection
| Database | Syntax | Example |
|----------|--------|---------|
| MySQL | `USE database_name;` | `USE sample_hr;` |
| PostgreSQL | `\c database_name;` | `\c sample_hr;` |
| SQL Server | `USE database_name;` | `USE sample_hr;` |

### Date Formatting
| Database | Syntax | Example |
|----------|--------|---------|
| MySQL | `DATE_FORMAT(date, 'format')` | `DATE_FORMAT(hire_date, '%Y-%m')` |
| PostgreSQL | `TO_CHAR(date, 'format')` | `TO_CHAR(hire_date, 'YYYY-MM')` |
| SQL Server | `FORMAT(date, 'format')` | `FORMAT(hire_date, 'yyyy-MM')` |

### Date Differences
| Database | Syntax | Example |
|----------|--------|---------|
| MySQL | `DATEDIFF(date1, date2)` | `DATEDIFF(end_date, start_date)` |
| PostgreSQL | `EXTRACT(unit FROM date1 - date2)` | `EXTRACT(DAY FROM end_date - start_date)` |
| SQL Server | `DATEDIFF(unit, date2, date1)` | `DATEDIFF(DAY, start_date, end_date)` |

### String Aggregation
| Database | Syntax | Example |
|----------|--------|---------|
| MySQL | `GROUP_CONCAT(column SEPARATOR 'sep')` | `GROUP_CONCAT(name SEPARATOR ', ')` |
| PostgreSQL | `STRING_AGG(column, 'sep')` | `STRING_AGG(name, ', ')` |
| SQL Server | `STRING_AGG(column, 'sep')` | `STRING_AGG(name, ', ')` |

### JSON Operations
| Operation | MySQL 8.0+ | PostgreSQL | SQL Server 2016+ |
|-----------|------------|------------|------------------|
| Extract Value | `JSON_EXTRACT(col, '$.path')` | `col->>'path'` | `JSON_VALUE(col, '$.path')` |
| Extract Object | `JSON_EXTRACT(col, '$.path')` | `col->'path'` | `JSON_QUERY(col, '$.path')` |
| Array Length | `JSON_LENGTH(col->'array')` | `jsonb_array_length(col)` | `(SELECT COUNT(*) FROM OPENJSON(col, '$.array'))` |
| Path Exists | `JSON_CONTAINS_PATH(col, 'one', '$.path')` | `col ? 'key'` | `JSON_PATH_EXISTS(col, '$.path')` |
| Modification | `JSON_SET/JSON_REPLACE` | `jsonb_set()` | `JSON_MODIFY()` |

### FULL OUTER JOIN
| Database | Native Support | Workaround |
|----------|---------------|------------|
| MySQL | ❌ No | `LEFT JOIN ... UNION ALL ... RIGHT JOIN ... WHERE ... IS NULL` |
| PostgreSQL | ✅ Yes | `FULL OUTER JOIN` |
| SQL Server | ✅ Yes | `FULL OUTER JOIN` |

## Usage Notes

### PostgreSQL Specific
- Use `\c database_name` in psql to switch databases
- JSONB is preferred over JSON for better performance
- Use `->` for JSON extraction (returns JSON) and `->>` for text extraction
- Array operations use `jsonb_array_length()`, `jsonb_agg()`, etc.

### SQL Server Specific
- JSON columns should use `NVARCHAR(MAX)` with `CHECK(ISJSON(column) = 1)` constraint
- Use `OPENJSON()` to parse JSON arrays into relational format
- `JSON_VALUE()` extracts single values, `JSON_QUERY()` extracts objects/arrays
- Date functions like `GETDATE()` instead of `NOW()`

### MySQL Specific
- JSON support requires MySQL 8.0+
- `JSON_EXTRACT()` is the primary JSON function
- `GROUP_CONCAT()` has a default 1024 character limit (configurable)
- `FULL OUTER JOIN` requires UNION ALL workaround

## Best Practices

1. **Test on Target Database**: Always test queries on the specific database you'll use in production
2. **Performance Considerations**: Different databases optimize different query patterns
3. **Data Type Compatibility**: Be aware of data type differences (e.g., VARCHAR vs TEXT limits)
4. **Indexing Strategies**: JSON indexing approaches vary significantly between databases
5. **Transaction Behavior**: Isolation levels and locking behavior differ between databases

## Learning Path Integration

The multi-database syntax examples are integrated throughout the curriculum:
- **Foundational**: DDL, aggregation, basic operations
- **Intermediate**: Window functions, date operations
- **Advanced**: JSON operations, full-text search

Each file contains commented sections showing equivalent syntax for all three databases, allowing learners to understand both the common SQL concepts and database-specific implementations.

---

*Last updated: December 2025 | Added comprehensive multi-database syntax support*
