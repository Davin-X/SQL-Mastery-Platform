# 🎯 Unique Data Matching Interview Question

## Question
Given customer data from two different sources, identify records that appear only once across both tables (unique matches) and find potential duplicates or inconsistencies.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE source_a (
    customer_id INT,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE
);

CREATE TABLE source_b (
    customer_id INT,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE
);

INSERT INTO source_a VALUES
(1, 'John Smith', 'john@email.com', '555-0101', '2023-01-15'),
(2, 'Jane Doe', 'jane@email.com', '555-0102', '2023-02-20'),
(3, 'Bob Johnson', 'bob@email.com', '555-0103', '2023-03-10'),
(4, 'Alice Brown', 'alice@email.com', '555-0104', '2023-04-05');

INSERT INTO source_b VALUES
(1, 'John Smith', 'john@email.com', '555-0101', '2023-01-15'),
(2, 'Jane Doe', 'jane@email.com', '555-0105', '2023-02-20'),  -- Different phone
(5, 'Charlie Wilson', 'charlie@email.com', '555-0106', '2023-05-12'),
(6, 'Diana Prince', 'diana@email.com', '555-0107', '2023-06-18');
```

## Answer: Finding Unique Records Across Sources

```sql
-- Method 1: Using UNION and aggregation
SELECT 
    customer_name,
    email,
    COUNT(*) AS occurrences
FROM (
    SELECT customer_name, email FROM source_a
    UNION ALL
    SELECT customer_name, email FROM source_b
) combined
GROUP BY customer_name, email
HAVING COUNT(*) = 1;
```

**How it works**: Combines both tables with UNION ALL, then groups by identifying fields to count occurrences. HAVING COUNT(*) = 1 finds records that appear exactly once across both sources.

## Alternative: Using FULL OUTER JOIN

```sql
SELECT 
    COALESCE(sa.customer_name, sb.customer_name) AS customer_name,
    COALESCE(sa.email, sb.email) AS email,
    COALESCE(sa.phone, sb.phone) AS phone,
    CASE 
        WHEN sa.customer_id IS NOT NULL AND sb.customer_id IS NOT NULL THEN 'Both Sources'
        WHEN sa.customer_id IS NOT NULL THEN 'Source A Only'
        ELSE 'Source B Only'
    END AS source_presence
FROM source_a sa
FULL OUTER JOIN source_b sb ON sa.customer_name = sb.customer_name 
                              AND sa.email = sb.email
ORDER BY customer_name;
```

**How it works**: FULL OUTER JOIN shows all records from both tables, with NULLs where no match exists. COALESCE fills in missing values.

## Advanced: Identifying Data Quality Issues

```sql
SELECT 
    COALESCE(sa.customer_name, sb.customer_name) AS customer_name,
    COALESCE(sa.email, sb.email) AS email,
    sa.phone AS phone_a,
    sb.phone AS phone_b,
    CASE 
        WHEN sa.customer_id IS NOT NULL AND sb.customer_id IS NOT NULL THEN
            CASE WHEN sa.phone = sb.phone THEN 'Perfect Match' ELSE 'Phone Mismatch' END
        WHEN sa.customer_id IS NOT NULL THEN 'Source A Only'
        ELSE 'Source B Only'
    END AS match_status
FROM source_a sa
FULL OUTER JOIN source_b sb ON sa.customer_name = sb.customer_name 
                              AND sa.email = sb.email
ORDER BY 
    CASE WHEN sa.customer_id IS NOT NULL AND sb.customer_id IS NOT NULL THEN 1
         WHEN sa.customer_id IS NOT NULL THEN 2
         ELSE 3 END,
    customer_name;
```

**How it works**: Identifies not just presence but also data quality issues like phone number mismatches between sources.

## Finding True Duplicates

```sql
SELECT 
    customer_name,
    email,
    COUNT(*) AS total_occurrences,
    COUNT(DISTINCT phone) AS unique_phones,
    COUNT(DISTINCT registration_date) AS unique_dates
FROM (
    SELECT customer_name, email, phone, registration_date FROM source_a
    UNION ALL
    SELECT customer_name, email, phone, registration_date FROM source_b
) combined
GROUP BY customer_name, email
HAVING COUNT(*) > 1
ORDER BY total_occurrences DESC;
```

**How it works**: Finds records that appear multiple times and checks for data consistency across occurrences.

## Data Reconciliation Report

```sql
WITH reconciliation AS (
    SELECT 
        COALESCE(sa.customer_name, sb.customer_name) AS customer_name,
        COALESCE(sa.email, sb.email) AS email,
        CASE 
            WHEN sa.customer_id IS NOT NULL AND sb.customer_id IS NOT NULL THEN 'Both'
            WHEN sa.customer_id IS NOT NULL THEN 'Source A'
            ELSE 'Source B'
        END AS data_source,
        CASE 
            WHEN sa.customer_id IS NOT NULL AND sb.customer_id IS NOT NULL THEN
                CASE WHEN sa.phone = sb.phone THEN 'Consistent' ELSE 'Inconsistent' END
            ELSE 'Single Source'
        END AS data_quality
    FROM source_a sa
    FULL OUTER JOIN source_b sb ON sa.customer_name = sb.customer_name 
                                  AND sa.email = sb.email
)
SELECT 
    data_source,
    data_quality,
    COUNT(*) AS record_count
FROM reconciliation
GROUP BY data_source, data_quality
ORDER BY data_source, data_quality;
```

**How it works**: Creates a comprehensive reconciliation report showing data distribution and quality across sources.

## Performance Considerations

- **JOIN performance**: FULL OUTER JOIN can be expensive on large datasets
- **Index strategy**: Composite indexes on (customer_name, email) crucial
- **UNION ALL vs UNION**: UNION ALL is faster when duplicates are acceptable
- **Memory usage**: Large datasets may require temporary tables

## Common Interview Patterns

1. **Data integration**: Merging customer data from multiple systems
2. **Duplicate detection**: Finding and resolving duplicate records
3. **Data quality assessment**: Identifying inconsistencies between sources
4. **Master data management**: Creating unified customer views

## Interview Tips

- **Business context**: Understanding why data reconciliation matters
- **Matching criteria**: Which fields to use for matching (exact vs fuzzy)
- **Data quality**: How to handle inconsistencies between sources
- **Scalability**: Performance considerations for large datasets
- **Edge cases**: NULL values, partial matches, case sensitivity

## Real-World Applications

- **CRM integration**: Merging customer data from multiple systems
- **Data warehousing**: ETL processes and data quality checks
- **Customer deduplication**: Identifying and merging duplicate profiles
- **System migration**: Validating data transfer between platforms
- **Regulatory compliance**: Ensuring consistent customer data across systems

## Database-Specific Considerations

- **FULL OUTER JOIN**: Not available in MySQL (use UNION of LEFT JOINs)
- **String comparison**: Consider case sensitivity and collation
- **NULL handling**: COALESCE vs ISNULL vs NVL across databases
- **Performance**: Some databases optimize UNION ALL better than others
