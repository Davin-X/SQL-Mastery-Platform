-- 12_cloud_data_warehousing.sql
-- MASTER CLASS: Cloud-Native SQL — BigQuery, Snowflake, Redshift Optimization
-- Partitioning, clustering, semi-structured data, and cloud-specific performance

-- ===========================================
-- MYSQL VERSION (Traditional RDBMS)
-- ===========================================

USE sample_hr;

-- Traditional MySQL approach for comparison
DROP TABLE IF EXISTS activity_log_partitioned;

CREATE TABLE activity_log_partitioned (
    emp_id INT,
    activity_date DATE,
    activity_type VARCHAR(50),
    hours_logged DECIMAL(4, 2),
    metadata JSON,
    INDEX idx_activity_date (activity_date),
    INDEX idx_activity_type_date (activity_type, activity_date)
);

-- ===========================================
-- BIGQUERY-SPECIFIC OPTIMIZATION
-- ===========================================

-- Partitioned tables (BigQuery)
-- Create time-partitioned table for activity logs
CREATE TABLE activity_log_partitioned (
    emp_id INT64,
    activity_date DATE,
    activity_type STRING,
    hours_logged FLOAT64,
    metadata JSON
)
PARTITION BY
    DATE(activity_date) CLUSTER BY activity_type,
    emp_id;

-- Optimized partitioned query (partition pruning)
SELECT
    activity_type,
    DATE_TRUNC (activity_date, MONTH) AS month,
    COUNT(*) AS activities,
    SUM(hours_logged) AS total_hours,
    AVG(hours_logged) AS avg_hours
FROM activity_log_partitioned
WHERE
    activity_date BETWEEN DATE('2024-01-01') AND DATE('2024-03-31') -- Automatic partition pruning
GROUP BY
    activity_type,
    DATE_TRUNC (activity_date, MONTH)
ORDER BY month, activities DESC;

-- Clustering optimization example
SELECT
    dept_name,
    activity_type,
    COUNT(*) AS activity_count,
    APPROX_COUNT_DISTINCT (emp_id) AS unique_employees -- Approximate distinct count
FROM
    activity_log_partitioned a
    JOIN employee e ON a.emp_id = e.emp_id
    JOIN department d ON e.dept_id = d.dept_id
WHERE
    activity_date >= DATE_SUB(
        CURRENT_DATE(),
        INTERVAL 90 DAY
    )
GROUP BY
    dept_name,
    activity_type
ORDER BY activity_count DESC;

-- ===========================================
-- SEMI-STRUCTURED DATA (VARIANT/JSON)
-- ===========================================

-- JSON column with advanced querying (BigQuery/Snowflake)
CREATE TABLE employee_profiles (
    emp_id INT64,
    basic_info JSON,
    skills JSON, -- Array of skills with proficiency levels
    certifications JSON,
    performance_history JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert rich JSON data
INSERT INTO
    employee_profiles (
        emp_id,
        basic_info,
        skills,
        certifications,
        performance_history
    )
VALUES (
        3,
        JSON '{"name": "John Doe", "department": "Sales", "level": "Senior", "start_date": "2020-01-15"}',
        JSON '[
        {"skill": "SQL", "proficiency": 5, "years": 8},
        {"skill": "Salesforce", "proficiency": 5, "years": 6},
        {"skill": "Data Analysis", "proficiency": 4, "years": 5}
    ]',
        JSON '["PMP", "AWS Solutions Architect", "Salesforce Admin"]',
        JSON '{
        "2023": {"rating": 4.8, "projects": 12, "revenue": 2500000},
        "2024": {"rating": 4.9, "projects": 15, "revenue": 2750000}
    }'
    ),
    (
        6,
        JSON '{"name": "Jane Smith", "department": "IT", "level": "Lead", "start_date": "2019-03-22"}',
        JSON '[
        {"skill": "Python", "proficiency": 5, "years": 6},
        {"skill": "AWS", "proficiency": 5, "years": 5},
        {"skill": "Machine Learning", "proficiency": 4, "years": 3}
    ]',
        JSON '["AWS DevOps Professional", "CISSP", "CKA"]',
        JSON '{
        "2023": {"rating": 4.9, "projects": 8, "complexity": "High"},
        "2024": {"rating": 4.8, "projects": 10, "complexity": "Enterprise"}
    }'
    );

-- Advanced JSON analytics
SELECT
    JSON_VALUE(basic_info, '$.name') AS employee_name,
    JSON_VALUE(basic_info, '$.department') AS department,
    ARRAY_LENGTH (JSON_QUERY (skills, '$')) AS skill_count,
    -- Sum of all skill proficiencies
    (
        SELECT SUM(
                CAST(
                    JSON_VALUE(skill_item, '$.proficiency') AS INT64
                )
            )
        FROM UNNEST (
                JSON_QUERY_ARRAY (skills, '$')
            ) AS skill_item
    ) AS total_proficiency_score,
    -- Check for specific certifications
    CASE
        WHEN 'AWS' IN UNNEST (
            JSON_VALUE_ARRAY (certifications)
        ) THEN 'AWS Certified'
        ELSE 'Not AWS Certified'
    END AS aws_status,
    -- Extract 2024 performance metrics
    JSON_VALUE(
        performance_history,
        '$.2024.rating'
    ) AS current_rating
FROM employee_profiles
ORDER BY total_proficiency_score DESC;

-- ===========================================
-- SNOWFLAKE-SPECIFIC FEATURES
-- ===========================================

-- Time Travel queries (Snowflake)
SELECT
    emp_id,
    first_name,
    department,
    AVG(salary) AS avg_salary
FROM employee
GROUP BY
    emp_id,
    first_name,
    department;

-- Query historical data (7 days ago)
SELECT
    emp_id,
    first_name,
    department,
    AVG(salary) AS avg_salary_7days_ago
FROM employee AT (
        TIMESTAMP = > DATEADD (DAY, -7, CURRENT_TIMESTAMP)
    )
GROUP BY
    emp_id,
    first_name,
    department;

-- Clone table for testing (Snowflake)
CREATE TABLE employee_backup CLONE employee;

-- Multi-cluster warehouse (Snowflake concept)
-- For very large tables, use multi-cluster warehouses
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- ===========================================
-- REDSHIFT-SPECIFIC OPTIMIZATION
-- ===========================================

-- Distribution styles and sort keys (Redshift)
-- Create optimized tables for analytics
CREATE TABLE sales_facts (
    sale_id BIGINT IDENTITY (1, 1),
    customer_id BIGINT,
    product_id BIGINT,
    sale_date DATE,
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    total_amount DECIMAL(12, 2),
    region_id INTEGER
) DISTKEY (customer_id) -- Distribute by customer for join optimization
SORTKEY (sale_date, customer_id) -- Sort for time-based queries
ENCODE (
    sale_id AUTO,
    customer_id DELTA,
    product_id DELTA,
    sale_date ZSTD,
    quantity MOSTLY16,
    unit_price ZSTD,
    total_amount ZSTD,
    region_id BYTEDICT
);

-- Analyze compression and distribution
ANALYZE COMPRESSION sales_facts;

ANALYZE sales_facts;

-- Query with automatic distribution optimization
SELECT
    r.region_name,
    DATE_TRUNC ('month', sale_date) AS month,
    SUM(total_amount) AS monthly_revenue,
    COUNT(*) AS orders,
    AVG(quantity) AS avg_quantity
FROM sales_facts sf
    JOIN regions r ON sf.region_id = r.region_id
WHERE
    sale_date >= DATEADD (MONTH, -12, CURRENT_DATE)
GROUP BY
    r.region_name,
    DATE_TRUNC ('month', sale_date)
ORDER BY month DESC, monthly_revenue DESC;

-- ===========================================
-- CLOUD PERFORMANCE OPTIMIZATION
-- ===========================================

-- Materialized views for complex aggregations (all platforms)
CREATE MATERIALIZED VIEW employee_dashboard AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    AVG(
        TIMESTAMPDIFF(
            YEAR,
            e.hire_date,
            CURRENT_DATE
        )
    ) AS avg_tenure_years,
    COUNT(
        CASE
            WHEN e.salary > (
                SELECT AVG(salary)
                FROM employee
            ) THEN 1
        END
    ) AS above_avg_salary_count
FROM department d
    JOIN employee e ON d.dept_id = e.dept_id
GROUP BY
    d.dept_name;

-- Refresh materialized view (automated in some platforms)
REFRESH MATERIALIZED VIEW employee_dashboard;

-- Query materialized view (much faster than computing on-the-fly)
SELECT * FROM employee_dashboard ORDER BY avg_salary DESC;

-- ===========================================
-- COST OPTIMIZATION TECHNIQUES
-- ===========================================

-- BigQuery cost-optimized query patterns
-- Use partitioning and clustering to minimize scanned bytes
SELECT
    DATE_TRUNC (activity_date, MONTH) AS month,
    activity_type,
    COUNT(*) AS activity_count,
    AVG(hours_logged) AS avg_hours,
    SUM(hours_logged) AS total_hours,
    SAFE_DIVIDE (SUM(hours_logged), COUNT(*)) AS computed_avg
FROM activity_log_partitioned
WHERE
    activity_date >= DATE_SUB(
        CURRENT_DATE(),
        INTERVAL 6 MONTH
    )
    AND activity_type IN (
        'Development',
        'Meeting',
        'Planning'
    ) -- Filter early
GROUP BY
    DATE_TRUNC (activity_date, MONTH),
    activity_type
HAVING
    activity_count > 5 -- Filter after aggregation
ORDER BY month DESC, total_hours DESC;

-- Approximate aggregation for large datasets (performance vs accuracy tradeoff)
SELECT
    APPROX_COUNT_DISTINCT (emp_id) AS approx_unique_employees,
    APPROX_TOP_COUNT (activity_type, 10) AS top_activities, -- Top 10 most frequent
    APPROX_TOP_SUM (
        activity_type,
        hours_logged,
        5
    ) AS top_5_by_hours -- Top 5 by total hours
FROM activity_log_partitioned
WHERE
    activity_date >= DATE_SUB(
        CURRENT_DATE(),
        INTERVAL 1 YEAR
    );

-- ===========================================
-- CLOUD ADVANCED ANALYTICS
-- ===========================================

-- ML functions (BigQuery ML example)
-- Create and use a linear regression model for salary prediction
CREATE OR REPLACE MODEL salary_prediction
OPTIONS(
    model_type = 'LINEAR_REG',
    input_label_cols = ['salary']
) AS
SELECT
    TIMESTAMPDIFF(YEAR, hire_date, CURRENT_DATE) AS tenure_years,
    CASE
        WHEN dept_name = 'IT' THEN 1
        WHEN dept_name = 'Sales' THEN 2
        WHEN dept_name = 'Finance' THEN 3
        ELSE 4
    END AS dept_code,
    salary
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;

-- Predict salaries using the model
SELECT
    e.first_name,
    e.last_name,
    e.salary AS actual_salary,
    ML.PREDICT (
        MODEL salary_prediction,
        STRUCT (
            TIMESTAMPDIFF(
                YEAR,
                e.hire_date,
                CURRENT_DATE
            ) AS tenure_years,
            CASE
                WHEN d.dept_name = 'IT' THEN 1
                WHEN d.dept_name = 'Sales' THEN 2
                WHEN d.dept_name = 'Finance' THEN 3
                ELSE 4
            END AS dept_code
        )
    ) AS predicted_salary
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- ===========================================
-- CLOUD SECURITY & GOVERNANCE
-- ===========================================

-- Row Level Security (RLS) example concept
-- (Implementation varies by platform)
-- CREATE POLICY employee_data_policy ON employee
-- FOR ALL USING (dept_id IN (
--     SELECT dept_id FROM user_permissions
--     WHERE user_id = CURRENT_USER_ID()
-- ));

-- Data masking for sensitive information
CREATE TABLE employee_sensitive (
    emp_id INT64,
    first_name STRING,
    last_name STRING,
    ssn STRING, -- Would be encrypted in practice
    salary INT64
);

-- In BigQuery, use authorized views for data security
CREATE OR REPLACE VIEW employee_public AS
SELECT
    emp_id,
    first_name,
    last_name,
    'XXX-XX-' || RIGHT(ssn, 4) AS masked_ssn, -- Last 4 digits only
    FLOOR(salary / 10000) * 10000 AS salary_range -- Round to nearest 10k
FROM employee_sensitive;

-- ===========================================
-- EXERCISES: Cloud Data Warehousing Mastery
-- ===========================================

-- EXERCISE 1: Optimize query performance
-- Convert this inefficient query to use cloud best practices
/*
Original (inefficient):
SELECT *
FROM large_activity_table
WHERE DATE(created_at) >= '2024-01-01'
ORDER BY created_at DESC;

Optimized (cloud-native):
SELECT
DATE(created_at) AS activity_date,
activity_type,
COUNT(*) AS daily_count
FROM large_activity_table
WHERE created_at >= TIMESTAMP('2024-01-01')
-- Uses partition pruning automatically when partitioned by DATE(created_at)
GROUP BY DATE(created_at), activity_type
ORDER BY activity_date DESC, daily_count DESC;
*/

-- EXERCISE 2: JSON document analytics
-- Extract statistics from nested JSON performance data
WITH
    performance_stats AS (
        SELECT
            emp_id,
            JSON_VALUE(basic_info, '$.name') AS employee_name,
            -- Unnest the skills array and aggregate proficiency
            (
                SELECT AVG(
                        CAST(
                            JSON_VALUE(skill, '$.proficiency') AS FLOAT64
                        )
                    )
                FROM UNNEST (
                        JSON_QUERY_ARRAY (skills, '$')
                    ) AS skill
            ) AS avg_skill_proficiency,
            -- Count certifications
            ARRAY_LENGTH (
                JSON_VALUE_ARRAY (certifications)
            ) AS certification_count
        FROM employee_profiles
    )
SELECT *
FROM performance_stats
ORDER BY
    avg_skill_proficiency DESC,
    certification_count DESC;

-- EXERCISE 3: Cost-optimized time series analysis
-- Analyze monthly trends with approximate aggregations
SELECT
    DATE_TRUNC (activity_date, MONTH) AS month,
    activity_type,
    -- Use approximate functions for large datasets
    APPROX_COUNT_DISTINCT (emp_id) AS approx_active_users,
    APPROX_TOP_COUNT (activity_type, 3) AS top_3_activities, -- Most common activities
    APPROX_TOP_SUM (
        activity_type,
        hours_logged,
        5
    ) AS top_5_by_hours -- Activities with most hours
FROM activity_log_partitioned
WHERE
    activity_date >= DATE_SUB(
        CURRENT_DATE(),
        INTERVAL 12 MONTH
    )
    -- Partition pruning on clustered columns
    AND activity_type IS NOT NULL
GROUP BY
    DATE_TRUNC (activity_date, MONTH),
    activity_type
ORDER BY month DESC, approx_active_users DESC;

-- ===========================================
-- POSTGRESQL VERSION (Traditional RDBMS Approach)
-- ===========================================

/*
-- PostgreSQL equivalent for cloud data warehousing concepts:

\c sample_hr;

-- PostgreSQL partitioning (similar to BigQuery partitioning)
CREATE TABLE activity_log_partitioned (
emp_id INTEGER,
activity_date DATE,
activity_type VARCHAR(50),
hours_logged DECIMAL(4, 2),
metadata JSONB
) PARTITION BY RANGE (activity_date);

-- Create partitions for different date ranges
CREATE TABLE activity_log_2024_q1 PARTITION OF activity_log_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE activity_log_2024_q2 PARTITION OF activity_log_partitioned
FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Create indexes on partitioned tables
CREATE INDEX idx_activity_date ON activity_log_partitioned (activity_date);
CREATE INDEX idx_activity_type ON activity_log_partitioned (activity_type);
CREATE INDEX idx_metadata_gin ON activity_log_partitioned USING GIN (metadata);

-- Optimized partitioned query (partition pruning)
SELECT
activity_type,
DATE_TRUNC('month', activity_date) AS month,
COUNT(*) AS activities,
SUM(hours_logged) AS total_hours,
ROUND(AVG(hours_logged), 2) AS avg_hours
FROM activity_log_partitioned
WHERE activity_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY activity_type, DATE_TRUNC('month', activity_date)
ORDER BY month, activities DESC;

-- JSON operations in PostgreSQL
SELECT
emp_id,
metadata->>'activity_type' AS activity_type,
(metadata->>'hours_logged')::DECIMAL AS hours_logged,
metadata->'tags' AS tags_array,
jsonb_array_length(metadata->'tags') AS tag_count
FROM activity_log_partitioned
WHERE metadata ? 'tags';  -- Check if tags key exists

-- PostgreSQL advanced analytics
SELECT
DATE_TRUNC('month', activity_date) AS month,
activity_type,
COUNT(*) AS activities,
SUM(hours_logged) AS total_hours,
ROUND(AVG(hours_logged), 2) AS avg_hours,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hours_logged) AS median_hours
FROM activity_log_partitioned
WHERE activity_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', activity_date), activity_type
ORDER BY month DESC, total_hours DESC;

-- PostgreSQL Notes:
-- - PARTITION BY RANGE for time-based partitioning
-- - JSONB for better performance than JSON
-- - GIN indexes for JSONB operations
-- - DATE_TRUNC() instead of DATE_TRUNC
-- - PERCENTILE_CONT() for statistical functions
-- - INTERVAL syntax for date arithmetic
*/

-- ===========================================
-- SQL SERVER VERSION (Traditional RDBMS Approach)
-- ===========================================

/*
-- SQL Server equivalent for cloud data warehousing concepts:

USE sample_hr;

-- SQL Server partitioning (similar to BigQuery partitioning)
-- Create partition function and scheme
CREATE PARTITION FUNCTION pf_activity_date (DATE)
AS RANGE RIGHT FOR VALUES ('2024-01-01', '2024-04-01', '2024-07-01');

CREATE PARTITION SCHEME ps_activity_date
AS PARTITION pf_activity_date TO (fg_2023, fg_2024_q1, fg_2024_q2, fg_future);

-- Create partitioned table
CREATE TABLE activity_log_partitioned (
emp_id INT,
activity_date DATE,
activity_type VARCHAR(50),
hours_logged DECIMAL(4, 2),
metadata NVARCHAR(MAX)
) ON ps_activity_date(activity_date);

-- Create indexes including filtered indexes for performance
CREATE CLUSTERED INDEX idx_activity_date ON activity_log_partitioned (activity_date);
CREATE NONCLUSTERED INDEX idx_activity_type ON activity_log_partitioned (activity_type);
CREATE NONCLUSTERED INDEX idx_metadata_json ON activity_log_partitioned (metadata)
WHERE ISJSON(metadata) = 1;

-- Optimized partitioned query
SELECT
activity_type,
DATEPART(YEAR, activity_date) * 100 + DATEPART(MONTH, activity_date) AS month,
COUNT(*) AS activities,
SUM(hours_logged) AS total_hours,
ROUND(AVG(hours_logged), 2) AS avg_hours
FROM activity_log_partitioned
WHERE activity_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY activity_type, DATEPART(YEAR, activity_date) * 100 + DATEPART(MONTH, activity_date)
ORDER BY month, activities DESC;

-- JSON operations in SQL Server
SELECT
emp_id,
JSON_VALUE(metadata, '$.activity_type') AS activity_type,
CAST(JSON_VALUE(metadata, '$.hours_logged') AS DECIMAL(4,2)) AS hours_logged,
JSON_QUERY(metadata, '$.tags') AS tags_array,
(
SELECT COUNT(*)
FROM OPENJSON(metadata, '$.tags')
) AS tag_count
FROM activity_log_partitioned
WHERE JSON_PATH_EXISTS(metadata, '$.tags') = 1;  -- Check if tags path exists

-- SQL Server advanced analytics with window functions
SELECT
DATEPART(YEAR, activity_date) * 100 + DATEPART(MONTH, activity_date) AS month,
activity_type,
COUNT(*) AS activities,
SUM(hours_logged) AS total_hours,
ROUND(AVG(hours_logged), 2) AS avg_hours,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hours_logged)
OVER (PARTITION BY DATEPART(YEAR, activity_date) * 100 + DATEPART(MONTH, activity_date), activity_type) AS median_hours
FROM activity_log_partitioned
WHERE activity_date >= DATEADD(MONTH, -6, GETDATE())
GROUP BY DATEPART(YEAR, activity_date) * 100 + DATEPART(MONTH, activity_date), activity_type, hours_logged
ORDER BY month DESC, total_hours DESC;

-- SQL Server Notes:
-- - Partition functions and schemes for advanced partitioning
-- - FILEGROUP placement for performance optimization
-- - Filtered indexes for JSON columns
-- - DATEPART() and DATEADD() for date operations
-- - OPENJSON() for parsing JSON arrays
-- - ISJSON() constraint for JSON validation
-- - PERCENTILE_CONT() OVER() for statistical calculations
*/

-- ===========================================
-- CROSS-PLATFORM CLOUD WAREHOUSING COMPARISON
-- ===========================================

/*
Cloud Data Warehousing Platforms Comparison:

| Feature | BigQuery | Snowflake | Redshift | PostgreSQL | SQL Server |
|---------|----------|-----------|----------|------------|------------|
| Partitioning | PARTITION BY DATE | Automatic clustering | DISTKEY/SORTKEY | PARTITION BY RANGE | Partition schemes |
| JSON Storage | JSON | VARIANT | SUPER | JSONB | NVARCHAR(MAX) |
| Date Functions | DATE_TRUNC | DATE_TRUNC | DATE_TRUNC | DATE_TRUNC | DATEPART/DATEADD |
| Approximate Agg | APPROX_* functions | APPROX_* functions | APPROXIMATE COUNT | Manual calculation | Manual calculation |
| ML Integration | BigQuery ML | Snowflake ML | Redshift ML | Extensions | Azure ML |
| Time Travel | Limited | Yes (up to 90 days) | No | No | No |
| Storage Cost | Very low | Medium | Medium | Variable | Variable |
| Query Performance | Excellent | Excellent | Good | Good | Good |
| Ecosystem | GCP | Multi-cloud | AWS | Open source | Microsoft |

Key Takeaways:
- BigQuery excels at massive scale with automatic optimization
- Snowflake offers excellent time travel and multi-cloud support
- Redshift provides deep AWS integration and columnar optimization
- PostgreSQL offers flexibility with partitioning and extensions
- SQL Server provides enterprise-grade features with JSON support

Choose based on:
- Cloud provider preference
- Data volume and performance requirements
- Budget constraints
- Existing infrastructure and skills
- Specific feature requirements (ML, time travel, etc.)
*/