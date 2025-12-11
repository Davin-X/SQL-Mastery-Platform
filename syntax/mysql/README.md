# MySQL Syntax Reference

## Quick Setup
```bash
# Install MySQL
brew install mysql

# Start MySQL service
brew services start mysql

# Create database
mysql -u root -p
CREATE DATABASE sample_hr;
USE sample_hr;
```

## Key MySQL Features

### Auto-Increment
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);
```

### Storage Engines
```sql
-- InnoDB (default, ACID compliant)
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance DECIMAL(10,2)
) ENGINE=InnoDB;

-- MyISAM (fast reads, table-level locking)
CREATE TABLE logs (
    id INT PRIMARY KEY,
    message TEXT
) ENGINE=MyISAM;
```

### Full-Text Search
```sql
CREATE TABLE articles (
    id INT PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,
    FULLTEXT(title, content)
);

SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('database optimization');
```

### JSON Functions
```sql
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    preferences JSON
);

-- Extract JSON values
SELECT JSON_EXTRACT(preferences, '$.theme') AS theme
FROM user_profiles;
```

### Common MySQL Commands
```bash
# Connect to MySQL
mysql -u username -p database_name

# Show databases
SHOW DATABASES;

# Show tables
SHOW TABLES;

# Describe table
DESCRIBE table_name;

# Show process list
SHOW PROCESSLIST;

# Show engine status
SHOW ENGINE INNODB STATUS;
```

## MySQL Best Practices

### Indexing Strategy
```sql
-- Composite index for WHERE clauses
CREATE INDEX idx_user_status_created
ON users (status, created_at);

-- Covering index
CREATE INDEX idx_user_name_email
ON users (last_name, first_name, email);
```

### Query Optimization
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM users WHERE status = 'active';

-- Force index usage (rarely needed)
SELECT * FROM users USE INDEX(idx_status)
WHERE status = 'active';
```

### Backup and Recovery
```bash
# Logical backup
mysqldump -u root -p sample_hr > backup.sql

# Restore from backup
mysql -u root -p sample_hr < backup.sql

# Binary backup (hot backup)
mysqlbackup --backup-dir=/path/to/backup backup
