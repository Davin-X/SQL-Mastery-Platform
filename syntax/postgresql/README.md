# PostgreSQL Syntax Reference

## Quick Setup
```bash
# Install PostgreSQL
brew install postgresql

# Start PostgreSQL service
brew services start postgresql

# Create database
createdb sample_hr
psql sample_hr

# Or connect directly
psql -d sample_hr
```

## Key PostgreSQL Features

### Serial Auto-Increment
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- Custom sequence
CREATE SEQUENCE user_id_seq START 1000;
CREATE TABLE users (
    id INTEGER DEFAULT nextval('user_id_seq') PRIMARY KEY,
    name VARCHAR(100)
);
```

### Advanced Data Types
```sql
-- Arrays
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    skills TEXT[],
    phone_numbers TEXT[]
);

-- JSONB (binary JSON, indexed)
CREATE TABLE user_profiles (
    user_id INTEGER PRIMARY KEY,
    preferences JSONB,
    settings JSONB
);

-- UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TABLE sessions (
    session_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ENUM
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    status user_status DEFAULT 'active'
);
```

### Advanced Indexing
```sql
-- GIN index for JSONB
CREATE INDEX idx_user_preferences ON user_profiles USING GIN (preferences);

-- Partial index
CREATE INDEX idx_active_users ON users (name) WHERE status = 'active';

-- Expression index
CREATE INDEX idx_lower_email ON users (LOWER(email));

-- Full-text search
CREATE INDEX idx_content_fts ON articles USING GIN (to_tsvector('english', content));
```

### Full-Text Search
```sql
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,
    search_vector TSVECTOR
);

-- Update search vector
UPDATE articles SET search_vector = to_tsvector('english', title || ' ' || content);

-- Search query
SELECT title, ts_rank(search_vector, plainto_tsquery('english', 'database optimization')) as rank
FROM articles
WHERE search_vector @@ plainto_tsquery('english', 'database optimization')
ORDER BY rank DESC;
```

### Window Functions & CTEs
```sql
-- Advanced window functions
SELECT
    department,
    employee_name,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) as median_salary
FROM employees;

-- Recursive CTE
WITH RECURSIVE employee_hierarchy AS (
    SELECT id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy ORDER BY level, name;
```

### Common PostgreSQL Commands
```bash
# Connect to database
psql -d database_name

# List databases
\l

# List tables
\dt

# Describe table
\d table_name

# Show running queries
SELECT * FROM pg_stat_activity;

# Show table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## PostgreSQL Best Practices

### Schema Management
```sql
-- Use schemas for organization
CREATE SCHEMA hr;
CREATE SCHEMA reporting;

-- Set search path
SET search_path TO hr, public;

-- Create objects in schemas
CREATE TABLE hr.employees (...);
CREATE TABLE reporting.monthly_reports (...);
```

### Performance Optimization
```sql
-- Analyze table statistics
ANALYZE employees;

-- Vacuum table (reclaim space, update statistics)
VACUUM ANALYZE employees;

-- Cluster table on index
CLUSTER employees USING idx_employee_name;

-- Create partial index
CREATE INDEX idx_active_employees ON employees (name, department)
WHERE status = 'active';
```

### Backup and Recovery
```bash
# Logical backup
pg_dump sample_hr > backup.sql

# Restore from backup
psql sample_hr < backup.sql

# Physical backup (requires stopping PostgreSQL)
tar -czf backup.tar.gz /usr/local/var/postgres/

# Point-in-time recovery
# Configure WAL archiving and recovery.conf
```

### Extensions
```sql
-- Useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- Query statistics
CREATE EXTENSION IF NOT EXISTS "pg_buffercache"; -- Buffer cache inspection
CREATE EXTENSION IF NOT EXISTS "tablefunc";      -- Pivot tables
CREATE EXTENSION IF NOT EXISTS "intarray";       -- Integer array operations
