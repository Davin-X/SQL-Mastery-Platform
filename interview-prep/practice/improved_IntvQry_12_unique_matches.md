# 🎯 Unique Record Matching Interview Question

## Question
Given two customer datasets from different sources, identify records that appear in only one source (unique matches) and detect potential data inconsistencies between matching records.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE crm_customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE,
    source_system VARCHAR(10) DEFAULT 'CRM'
);

CREATE TABLE erp_customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE,
    source_system VARCHAR(10) DEFAULT 'ERP'
);

INSERT INTO crm_customers VALUES
('C001', 'John Smith', 'john@email.com', '555-0101', '2023-01-15', 'CRM'),
('C002', 'Jane Doe', 'jane@email.com', '555-0102', '2023-02-20', 'CRM'),
('C003', 'Bob Johnson', 'bob@email.com', '555-0103', '2023-03-10', 'CRM'),
('C004', 'Alice Brown', 'alice@email.com', '555-0104', '2023-04-05', 'CRM');

INSERT INTO erp_customers VALUES
('E001', 'John Smith', 'john@email.com', '555-0101', '2023-01-15', 'ERP'),
('E002', 'Jane Doe', 'jane@email.com', '555-0105', '2023-02-20', 'ERP'),  -- Phone differs
('E005', 'Charlie Wilson', 'charlie@email.com', '555-0106', '2023-05-12', 'ERP'),
('E006', 'Diana Prince', 'diana@email.com', '555-0107', '2023-06-18', 'ERP');
```

## Answer: Finding Unique Records Across Systems

```sql
WITH all_customers AS (
    -- Combine all customer data with source identifier
    SELECT 
        customer_id,
        customer_name,
        email,
        phone,
        registration_date,
        'CRM' AS source_system
    FROM crm_customers
    
    UNION ALL
    
    SELECT 
        customer_id,
        customer_name,
        email,
        phone,
        registration_date,
        'ERP' AS source_system
    FROM erp_customers
),
customer_matching AS (
    -- Match customers by name and email (business key)
    SELECT 
        ac1.*,
        ac2.customer_id AS matched_customer_id,
        ac2.source_system AS matched_source,
        ac2.phone AS matched_phone,
        CASE 
            WHEN ac2.customer_id IS NOT NULL THEN 'Matched'
            ELSE 'Unique'
        END AS match_status,
        CASE 
            WHEN ac2.customer_id IS NOT NULL AND ac1.phone != ac2.phone THEN 'Phone Mismatch'
            WHEN ac2.customer_id IS NOT NULL AND ac1.registration_date != ac2.registration_date THEN 'Date Mismatch'
            WHEN ac2.customer_id IS NOT NULL THEN 'Perfect Match'
            ELSE 'No Match'
        END AS data_quality
    FROM all_customers ac1
    LEFT JOIN all_customers ac2 ON 
        ac1.customer_name = ac2.customer_name AND
        ac1.email = ac2.email AND
        ac1.source_system != ac2.source_system
)
SELECT 
    customer_id,
    customer_name,
    email,
    phone,
    registration_date,
    source_system,
    matched_customer_id,
    matched_source,
    match_status,
    data_quality,
    
    CASE 
        WHEN match_status = 'Unique' THEN 'Requires Manual Review'
        WHEN data_quality LIKE '%Mismatch%' THEN 'Requires Data Cleanup'
        ELSE 'Ready for Integration'
    END AS integration_status
    
FROM customer_matching
ORDER BY 
    CASE WHEN match_status = 'Unique' THEN 1 ELSE 2 END,
    customer_name;
```

**How it works**: Combines both datasets, matches on business keys (name + email), identifies unique records and data inconsistencies.

## Alternative: Simplified Unique Record Detection

```sql
-- Find customers unique to CRM
SELECT 'CRM_Unique' AS category, c.*
FROM crm_customers c
LEFT JOIN erp_customers e ON c.customer_name = e.customer_name AND c.email = e.email
WHERE e.customer_id IS NULL

UNION ALL

-- Find customers unique to ERP
SELECT 'ERP_Unique' AS category, e.*
FROM erp_customers e
LEFT JOIN crm_customers c ON e.customer_name = c.customer_name AND e.email = c.email
WHERE c.customer_id IS NULL

UNION ALL

-- Find matching customers with data differences
SELECT 'Data_Mismatch' AS category, 
       c.customer_id, c.customer_name, c.email, 
       c.phone AS crm_phone, e.phone AS erp_phone,
       c.registration_date AS crm_date, e.registration_date AS erp_date
FROM crm_customers c
JOIN erp_customers e ON c.customer_name = e.customer_name AND c.email = e.email
WHERE c.phone != e.phone OR c.registration_date != e.registration_date;
```

**How it works**: Uses UNION to categorize records as unique to each system or having data mismatches.

## Advanced: Fuzzy Matching for Better Deduplication

```sql
WITH customer_comparison AS (
    SELECT 
        c.customer_name AS crm_name,
        e.customer_name AS erp_name,
        c.email AS crm_email,
        e.email AS erp_email,
        c.phone AS crm_phone,
        e.phone AS erp_phone,
        
        -- Similarity scores (simplified)
        CASE WHEN c.customer_name = e.customer_name THEN 1 ELSE 0 END AS name_match,
        CASE WHEN c.email = e.email THEN 1 ELSE 0 END AS email_match,
        CASE WHEN c.phone = e.phone THEN 1 ELSE 0 END AS phone_match,
        
        -- Overall match confidence
        (CASE WHEN c.customer_name = e.customer_name THEN 1 ELSE 0 END +
         CASE WHEN c.email = e.email THEN 2 ELSE 0 END +  -- Email more important
         CASE WHEN c.phone = e.phone THEN 1 ELSE 0 END) / 4.0 AS match_confidence
        
    FROM crm_customers c
    CROSS JOIN erp_customers e
    WHERE (c.customer_name = e.customer_name OR c.email = e.email)  -- Potential matches
)
SELECT 
    crm_name,
    erp_name,
    crm_email,
    erp_email,
    crm_phone,
    erp_phone,
    name_match,
    email_match,
    phone_match,
    ROUND(match_confidence * 100, 1) AS match_confidence_pct,
    
    CASE 
        WHEN match_confidence >= 0.75 THEN 'High Confidence Match'
        WHEN match_confidence >= 0.5 THEN 'Medium Confidence Match'
        ELSE 'Low Confidence Match'
    END AS match_quality
    
FROM customer_comparison
WHERE match_confidence > 0  -- Only show potential matches
ORDER BY match_confidence DESC, crm_name;
```

**How it works**: Cross joins potential matches and calculates confidence scores based on matching fields.

## Data Quality Metrics

```sql
WITH data_quality_analysis AS (
    SELECT 
        'CRM' AS source,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN phone IS NULL OR phone = '' THEN 1 END) AS missing_phones,
        COUNT(CASE WHEN email IS NULL OR email NOT LIKE '%@%' THEN 1 END) AS invalid_emails,
        COUNT(DISTINCT customer_name) AS unique_names,
        COUNT(DISTINCT email) AS unique_emails
    FROM crm_customers
    
    UNION ALL
    
    SELECT 
        'ERP' AS source,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN phone IS NULL OR phone = '' THEN 1 END) AS missing_phones,
        COUNT(CASE WHEN email IS NULL OR email NOT LIKE '%@%' THEN 1 END) AS invalid_emails,
        COUNT(DISTINCT customer_name) AS unique_names,
        COUNT(DISTINCT email) AS unique_emails
    FROM erp_customers
)
SELECT 
    source,
    total_records,
    ROUND((missing_phones * 100.0) / total_records, 1) AS missing_phone_pct,
    ROUND((invalid_emails * 100.0) / total_records, 1) AS invalid_email_pct,
    CASE 
        WHEN unique_names < total_records THEN 'Potential Duplicates'
        ELSE 'Unique Names'
    END AS name_uniqueness,
    CASE 
        WHEN unique_emails < total_records THEN 'Duplicate Emails Found'
        ELSE 'Unique Emails'
    END AS email_uniqueness
FROM data_quality_analysis;
```

**How it works**: Analyzes data quality metrics for each source system.

## Performance Considerations

- **JOIN performance**: LEFT JOIN is efficient for this pattern
- **Index strategy**: Composite indexes on (customer_name, email)
- **UNION ALL**: Faster than UNION when duplicates are acceptable
- **CROSS JOIN**: Use only for small datasets in fuzzy matching

## Common Interview Patterns

1. **Data integration**: Merging customer data from multiple systems
2. **Duplicate detection**: Finding and resolving duplicate records
3. **Data reconciliation**: Comparing datasets for consistency
4. **Master data management**: Creating unified customer views


- **Business context**: Understanding why unique matching matters
- **Matching criteria**: Which fields to use for matching (exact vs fuzzy)
- **Data quality**: How to handle inconsistencies between sources
- **Scalability**: Performance with millions of customer records
- **Edge cases**: NULL values, partial matches, case sensitivity


- **CRM integration**: Merging customer data from multiple platforms
- **Data warehousing**: ETL deduplication processes
- **Customer 360**: Creating unified customer profiles
- **Regulatory compliance**: Ensuring consistent customer data
- **Marketing**: Building accurate customer lists for campaigns

## Database-Specific Optimizations

### MySQL:
- Use STRCMP() for case-insensitive comparisons
- Consider FULLTEXT indexes for fuzzy matching
- Use INSERT ... ON DUPLICATE KEY UPDATE for merging

### PostgreSQL:
- Leverage similarity functions (levenshtein distance)
- Use ARRAY operations for multi-field matching
- Consider TRIGRAM indexes for fuzzy text matching

### SQL Server:
- Use DIFFERENCE() function for phonetic matching
- Implement custom CLR functions for advanced fuzzy logic
- Use MERGE statement for upsert operations

