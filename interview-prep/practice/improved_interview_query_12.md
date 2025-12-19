# 🎯 Complex Query Optimization Interview Question

## Question
Given a large e-commerce orders table, write an optimized query to find the top 10 customers by total order value in the last 6 months, including their order count, average order value, and most recent order date. Optimize for performance on a table with millions of records.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    status VARCHAR(20)
);

-- Create index for performance
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_date ON orders(order_date);

INSERT INTO orders VALUES
(1, 101, '2024-01-15', 150.00, 'completed'),
(2, 101, '2024-02-20', 200.00, 'completed'),
(3, 102, '2024-01-10', 300.00, 'completed'),
(4, 102, '2024-03-05', 250.00, 'completed'),
(5, 103, '2024-02-15', 175.00, 'completed'),
(6, 101, '2024-03-10', 225.00, 'completed'),
(7, 104, '2024-01-20', 400.00, 'completed'),
(8, 105, '2024-03-15', 125.00, 'completed'),
(9, 103, '2024-03-20', 275.00, 'completed'),
(10, 106, '2024-02-28', 350.00, 'completed');
```

## Answer: Optimized Customer Analytics Query

```sql
WITH recent_orders AS (
    SELECT 
        customer_id,
        order_date,
        order_amount
    FROM orders
    WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    AND status = 'completed'
),
customer_summary AS (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(order_amount) AS total_amount,
        AVG(order_amount) AS avg_order_value,
        MAX(order_date) AS most_recent_order
    FROM recent_orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    order_count,
    ROUND(total_amount, 2) AS total_order_value,
    ROUND(avg_order_value, 2) AS avg_order_value,
    most_recent_order,
    DENSE_RANK() OVER (ORDER BY total_amount DESC) AS customer_rank
FROM customer_summary
ORDER BY total_amount DESC
LIMIT 10;
```

**How it works**: 
- CTE filters recent orders for better performance
- Aggregates customer metrics in second CTE
- Uses DENSE_RANK for ranking (handles ties properly)
- LIMIT 10 for top customers

## Alternative: Using Window Functions Only

```sql
SELECT 
    customer_id,
    COUNT(*) OVER (PARTITION BY customer_id) AS order_count,
    SUM(order_amount) OVER (PARTITION BY customer_id) AS total_amount,
    ROUND(AVG(order_amount) OVER (PARTITION BY customer_id), 2) AS avg_order_value,
    MAX(order_date) OVER (PARTITION BY customer_id) AS most_recent_order,
    DENSE_RANK() OVER (ORDER BY SUM(order_amount) OVER (PARTITION BY customer_id) DESC) AS customer_rank
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
AND status = 'completed'
QUALIFY DENSE_RANK() OVER (ORDER BY SUM(order_amount) OVER (PARTITION BY customer_id) DESC) <= 10
ORDER BY total_amount DESC;
```

**How it works**: 
- Single query with window functions
- QUALIFY clause filters top 10 (Snowflake/Teradata syntax)
- Avoids CTEs but may be less readable

## Performance Optimization Strategies

### 1. Index Strategy
```sql
-- Composite index for WHERE clause
CREATE INDEX idx_orders_status_date_customer ON orders(status, order_date, customer_id);

-- Covering index for SELECT columns
CREATE INDEX idx_orders_customer_metrics ON orders(customer_id, order_date, order_amount, status);
```

### 2. Query Execution Plan Analysis
```sql
EXPLAIN SELECT 
    customer_id,
    COUNT(*) as order_count,
    SUM(order_amount) as total_amount
FROM orders 
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
AND status = 'completed'
GROUP BY customer_id
ORDER BY total_amount DESC 
LIMIT 10;
```

**Look for**: Index usage, temporary table creation, sort operations

### 3. Partitioning Strategy (for large tables)
```sql
-- Partition by month for date-based queries
ALTER TABLE orders 
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);
```

## Scalability Considerations

### For 1M+ Records:
- **Pre-aggregated tables**: Daily/weekly summary tables
- **Materialized views**: For frequently accessed metrics
- **Caching layer**: Redis/Memcached for top customers
- **Data warehousing**: Separate OLAP database for analytics

### Query Optimization Checklist:
- [ ] Indexes on filter columns (date, status)
- [ ] Composite indexes for common query patterns
- [ ] Statistics up to date (`ANALYZE TABLE`)
- [ ] Query execution plan reviewed
- [ ] LIMIT/OFFSET vs window functions evaluated
- [ ] Subqueries vs JOINs performance compared

## Common Interview Patterns

1. **Top-N queries**: Finding best customers/products
2. **Time-window analysis**: Recent period performance
3. **Customer segmentation**: High-value customer identification
4. **Performance optimization**: Scaling analytical queries

