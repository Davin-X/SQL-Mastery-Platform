# SQL Server Syntax Reference

## Quick Setup
```bash
# Install SQL Server (using Docker for simplicity)
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong!Passw0rd" \
   -p 1433:1433 --name sqlserver --hostname sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest

# Connect using sqlcmd
sqlcmd -S localhost -U SA -P 'YourStrong!Passw0rd'

# Or use Azure Data Studio / SSMS
```

## Key SQL Server Features

### Identity Auto-Increment
```sql
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100)
);

-- Custom identity seed and increment
CREATE TABLE orders (
    order_id INT IDENTITY(1000, 5) PRIMARY KEY, -- Starts at 1000, increments by 5
    customer_id INT,
    order_date DATETIME2 DEFAULT GETDATE()
);
```

### Advanced Data Types
```sql
-- NVARCHAR for Unicode support
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10, 2)
);

-- DATETIME2 for better precision
CREATE TABLE events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    event_name NVARCHAR(100),
    event_date DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- UNIQUEIDENTIFIER (GUID)
CREATE TABLE sessions (
    session_id UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    user_id INT,
    login_time DATETIME2 DEFAULT GETDATE(),
    logout_time DATETIME2 NULL
);
```

### Computed Columns
```sql
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    subtotal DECIMAL(10, 2),
    tax_rate DECIMAL(5, 4) DEFAULT 0.0825,
    tax_amount AS (subtotal * tax_rate) PERSISTED,
    total_amount AS (subtotal + (subtotal * tax_rate)) PERSISTED
);

-- Non-persisted computed column
CREATE TABLE employees (
    emp_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    full_name AS (first_name + ' ' + last_name)
);
```

### Full-Text Search
```sql
-- Create full-text catalog
CREATE FULLTEXT CATALOG ft_catalog AS DEFAULT;

-- Create table with full-text index
CREATE TABLE articles (
    article_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200),
    content NVARCHAR(MAX),
    tags NVARCHAR(500)
);

-- Create full-text index
CREATE FULLTEXT INDEX ON articles (
    title LANGUAGE English,
    content LANGUAGE English,
    tags LANGUAGE English
) KEY INDEX pk_articles
WITH CHANGE_TRACKING AUTO;

-- Full-text search queries
SELECT title,
       KEY_TBL.RANK AS relevance_score
FROM articles
INNER JOIN CONTAINSTABLE(articles, content, 'database AND optimization') AS KEY_TBL
    ON articles.article_id = KEY_TBL.[KEY]
ORDER BY KEY_TBL.RANK DESC;
```

### Advanced Indexing
```sql
-- Filtered index
CREATE NONCLUSTERED INDEX idx_active_employees
ON employees (department_id, salary)
WHERE status = 'active';

-- Included columns (covering index)
CREATE NONCLUSTERED INDEX idx_employee_lookup
ON employees (last_name, first_name)
INCLUDE (department_id, email, phone);

-- Columnstore index for analytics
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_sales_analytics
ON sales (product_id, sale_date, quantity, amount);

-- Unique index
CREATE UNIQUE NONCLUSTERED INDEX idx_unique_email
ON users (email)
WHERE email IS NOT NULL;
```

### Temporal Tables (System-Versioned)
```sql
-- Create temporal table
CREATE TABLE employees (
    emp_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    department NVARCHAR(50),
    salary DECIMAL(10, 2),
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_SysStart DEFAULT SYSUTCDATETIME(),
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_SysEnd DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
);

-- Enable system versioning
ALTER TABLE employees
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.employees_history));

-- Query historical data
SELECT * FROM employees
FOR SYSTEM_TIME AS OF '2024-01-01';

SELECT * FROM employees
FOR SYSTEM_TIME BETWEEN '2024-01-01' AND '2024-12-31';
```

### Window Functions
```sql
-- Advanced window functions
SELECT
    department,
    employee_name,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank_with_ties,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_dense_rank,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_percentile,
    CUME_DIST() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_cumulative_dist,
    NTILE(4) OVER (PARTITION BY department ORDER BY salary DESC) AS dept_quartile,
    AVG(salary) OVER (PARTITION BY department ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM employees;
```

### Common SQL Server Commands
```sqlcmd
-- Connect to SQL Server
sqlcmd -S server_name -U username -P password -d database_name

-- Show databases
SELECT name FROM sys.databases;

-- Show tables
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Describe table
EXEC sp_columns 'table_name';

-- Show running queries
SELECT * FROM sys.dm_exec_requests WHERE session_id <> @@SPID;

-- Show database size
EXEC sp_spaceused;

-- Show index fragmentation
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL);
```

## SQL Server Best Practices

### Indexing Strategy
```sql
-- Create primary key with clustered index
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    email NVARCHAR(255) UNIQUE NONCLUSTERED,
    created_date DATETIME2 DEFAULT GETDATE()
);

-- Foreign key index
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- Composite index for common query patterns
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC)
INCLUDE (total_amount, status);
```

### Query Optimization
```sql
-- Use execution plans
SET SHOWPLAN_ALL ON;
GO
SELECT * FROM users WHERE status = 'active';
GO
SET SHOWPLAN_ALL OFF;
GO

-- Query hints (use sparingly)
SELECT * FROM orders WITH (INDEX(idx_orders_customer_date))
WHERE customer_id = 123 AND order_date >= '2024-01-01';

-- Statistics update
UPDATE STATISTICS orders WITH FULLSCAN;
```

### Backup and Recovery
```sqlcmd
-- Full backup
BACKUP DATABASE sample_hr TO DISK = 'C:\backups\sample_hr_full.bak';

-- Differential backup
BACKUP DATABASE sample_hr TO DISK = 'C:\backups\sample_hr_diff.bak'
WITH DIFFERENTIAL;

-- Transaction log backup
BACKUP LOG sample_hr TO DISK = 'C:\backups\sample_hr_log.bak';

-- Restore database
RESTORE DATABASE sample_hr FROM DISK = 'C:\backups\sample_hr_full.bak'
WITH REPLACE, RECOVERY;
```

### Performance Monitoring
```sql
-- Query performance metrics
SELECT
    total_worker_time/execution_count AS avg_cpu_time,
    total_logical_reads/execution_count AS avg_logical_reads,
    total_elapsed_time/execution_count AS avg_elapsed_time,
    execution_count,
    sql_text = SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset)/2) + 1)
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_worker_time/execution_count DESC;
```

### Partitioning Strategy
```sql
-- Create partition function
CREATE PARTITION FUNCTION pf_sales_date (DATETIME2)
AS RANGE RIGHT FOR VALUES ('2024-01-01', '2024-04-01', '2024-07-01');

-- Create partition scheme
CREATE PARTITION SCHEME ps_sales_date
AS PARTITION pf_sales_date TO (fg_2023, fg_q1_2024, fg_q2_2024, fg_q3_2024, fg_future);

-- Create partitioned table
CREATE TABLE sales (
    sale_id INT IDENTITY(1,1),
    product_id INT,
    customer_id INT,
    sale_date DATETIME2,
    amount DECIMAL(10, 2)
) ON ps_sales_date(sale_date);
