# Problem 04: CTEs vs Subqueries - Performance Comparison and Optimization

## Business Context
SQL developers often face choices between CTEs, subqueries, and temporary tables for complex queries. Understanding the performance implications and appropriate use cases for each approach is crucial for writing efficient database code. This problem demonstrates when to use CTEs vs subqueries and how to optimize query performance.

## Requirements
Write SQL queries comparing CTEs and subqueries approaches, analyze their performance characteristics, and demonstrate optimization techniques for complex analytical queries.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending'
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(20) DEFAULT 'Standard'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    base_price DECIMAL(8, 2) NOT NULL
);

-- Insert sample data
INSERT INTO customers (customer_id, customer_name, region, customer_segment) VALUES
(1, 'TechCorp', 'North', 'Enterprise'),
(2, 'DataSys', 'South', 'Enterprise'),
(3, 'WebFlow', 'East', 'Standard'),
(4, 'CloudNet', 'West', 'Standard'),
(5, 'InnovateIT', 'North', 'Enterprise'),
(6, 'DevTools', 'South', 'Standard'),
(7, 'CodeMasters', 'East', 'Standard'),
(8, 'DataFlow', 'West', 'Enterprise');

INSERT INTO products (product_id, product_name, category, base_price) VALUES
(1, 'Laptop Pro', 'Hardware', 1200.00),
(2, 'Software Suite', 'Software', 500.00),
(3, 'Cloud Storage', 'Services', 100.00),
(4, 'Monitor 4K', 'Hardware', 400.00),
(5, 'Keyboard Wireless', 'Hardware', 80.00),
(6, 'Consulting Services', 'Services', 200.00),
(7, 'Training Package', 'Services', 150.00),
(8, 'Support Contract', 'Services', 300.00);

INSERT INTO sales_orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2024-01-15', 2400.00, 'Completed'),
(2, 2, '2024-01-20', 900.00, 'Completed'),
(3, 3, '2024-02-01', 1280.00, 'Completed'),
(4, 4, '2024-02-10', 400.00, 'Completed'),
(5, 5, '2024-02-15', 2000.00, 'Completed'),
(6, 6, '2024-03-01', 750.00, 'Completed'),
(7, 7, '2024-03-05', 300.00, 'Pending'),
(8, 8, '2024-03-10', 1800.00, 'Completed'),
(9, 1, '2024-03-15', 1600.00, 'Shipped'),
(10, 3, '2024-03-20', 600.00, 'Completed');

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 2, 1200.00, 0.00),
(2, 2, 2, 1, 500.00, 100.00),
(3, 2, 3, 2, 100.00, 0.00),
(4, 3, 1, 1, 1200.00, 0.00),
(5, 3, 4, 1, 400.00, 80.00),
(6, 4, 5, 5, 80.00, 0.00),
(7, 5, 6, 10, 200.00, 0.00),
(8, 6, 7, 5, 150.00, 0.00),
(9, 8, 8, 6, 300.00, 0.00),
(10, 9, 2, 2, 500.00, 200.00),
(11, 9, 4, 1, 400.00, 100.00),
(12, 10, 3, 6, 100.00, 0.00);
```

## Query Requirements

### Query 1: Customer order analysis - CTE vs Subquery comparison
```sql
-- CTE Approach
WITH customer_order_summary AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.region,
        c.customer_segment,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN sales_orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.region, c.customer_segment
),
customer_performance AS (
    SELECT 
        *,
        CASE 
            WHEN total_orders = 0 THEN 'New'
            WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Regular'
            ELSE 'VIP'
        END AS customer_status,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_order_summary
)
SELECT 
    customer_name,
    region,
    customer_segment,
    total_orders,
    total_revenue,
    customer_status,
    revenue_rank
FROM customer_performance
ORDER BY total_revenue DESC;

-- Subquery Approach (equivalent logic)
SELECT 
    c.customer_name,
    c.region,
    c.customer_segment,
    COALESCE(order_stats.total_orders, 0) AS total_orders,
    COALESCE(order_stats.total_revenue, 0) AS total_revenue,
    CASE 
        WHEN COALESCE(order_stats.total_orders, 0) = 0 THEN 'New'
        WHEN COALESCE(order_stats.total_orders, 0) = 1 THEN 'One-time'
        WHEN COALESCE(order_stats.total_orders, 0) BETWEEN 2 AND 3 THEN 'Regular'
        ELSE 'VIP'
    END AS customer_status,
    RANK() OVER (ORDER BY COALESCE(order_stats.total_revenue, 0) DESC) AS revenue_rank
FROM customers c
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS avg_order_value,
        MAX(order_date) AS last_order_date
    FROM sales_orders
    WHERE status = 'Completed'
    GROUP BY customer_id
) order_stats ON c.customer_id = order_stats.customer_id
ORDER BY COALESCE(order_stats.total_revenue, 0) DESC;
```

**Expected Result (both approaches):**
| customer_name | region | customer_segment | total_orders | total_revenue | customer_status | revenue_rank |
|---------------|--------|------------------|--------------|---------------|-----------------|--------------|
| TechCorp      | North  | Enterprise       | 2            | 4000.00       | Regular         | 1            |
| InnovateIT    | North  | Enterprise       | 1            | 2000.00       | One-time        | 2            |
| DataFlow      | West   | Enterprise       | 1            | 1800.00       | One-time        | 3            |
| WebFlow       | East   | Standard         | 2            | 1880.00       | Regular         | 4            |
| DataSys       | South  | Enterprise       | 1            | 900.00        | One-time        | 5            |
| DevTools      | South  | Standard         | 1            | 750.00        | One-time        | 6            |
| CloudNet      | West   | Standard         | 1            | 400.00        | One-time        | 7            |
| CodeMasters   | East   | Standard         | 0            | 0.00          | New             | 8            |

### Query 2: Product category analysis with different approaches
```sql
-- CTE Approach with multiple levels
WITH category_orders AS (
    SELECT 
        p.category,
        p.product_name,
        COUNT(oi.item_id) AS items_sold,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS revenue,
        SUM(oi.quantity) AS total_quantity
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN sales_orders so ON oi.order_id = so.order_id AND so.status = 'Completed'
    GROUP BY p.category, p.product_name
),
category_summary AS (
    SELECT 
        category,
        COUNT(DISTINCT product_name) AS products_in_category,
        SUM(items_sold) AS total_orders,
        SUM(revenue) AS total_revenue,
        SUM(total_quantity) AS total_units
    FROM category_orders
    GROUP BY category
),
category_performance AS (
    SELECT 
        *,
        ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS avg_order_value,
        ROUND(total_revenue / NULLIF(total_units, 0), 2) AS avg_price_per_unit,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM category_summary
)
SELECT * FROM category_performance ORDER BY total_revenue DESC;

-- Nested Subquery Approach
SELECT 
    category,
    products_in_category,
    total_orders,
    total_revenue,
    total_units,
    ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS avg_order_value,
    ROUND(total_revenue / NULLIF(total_units, 0), 2) AS avg_price_per_unit,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
    SELECT 
        category,
        COUNT(DISTINCT product_name) AS products_in_category,
        SUM(items_sold) AS total_orders,
        SUM(revenue) AS total_revenue,
        SUM(total_quantity) AS total_units
    FROM (
        SELECT 
            p.category,
            p.product_name,
            COUNT(oi.item_id) AS items_sold,
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS revenue,
            SUM(oi.quantity) AS total_quantity
        FROM products p
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
        LEFT JOIN sales_orders so ON oi.order_id = so.order_id AND so.status = 'Completed'
        GROUP BY p.category, p.product_name
    ) product_orders
    GROUP BY category
) category_summary
ORDER BY total_revenue DESC;
```

**Expected Result (both approaches):**
| category  | products_in_category | total_orders | total_revenue | total_units | avg_order_value | avg_price_per_unit | revenue_rank |
|-----------|----------------------|--------------|---------------|-------------|-----------------|---------------------|--------------|
| Services | 4                    | 21           | 5500.00       | 29          | 261.90          | 189.66              | 1            |
| Hardware | 3                    | 9            | 3680.00       | 10          | 408.89          | 368.00              | 2            |
| Software | 1                    | 3            | 800.00        | 2           | 266.67          | 400.00              | 3            |

### Query 3: Complex filtering with CTEs vs correlated subqueries
```sql
-- CTE Approach: Customers with above-average orders in their region
WITH regional_avg AS (
    SELECT 
        region,
        AVG(total_amount) AS avg_order_value,
        COUNT(*) AS total_orders_in_region
    FROM customers c
    INNER JOIN sales_orders so ON c.customer_id = so.customer_id
    WHERE so.status = 'Completed'
    GROUP BY region
),
customer_order_stats AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.region,
        COUNT(so.order_id) AS customer_orders,
        AVG(so.total_amount) AS customer_avg_order,
        SUM(so.total_amount) AS customer_total_revenue
    FROM customers c
    LEFT JOIN sales_orders so ON c.customer_id = so.customer_id AND so.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.region
)
SELECT 
    cos.customer_name,
    cos.region,
    cos.customer_orders,
    cos.customer_avg_order,
    cos.customer_total_revenue,
    ra.avg_order_value AS regional_avg,
    cos.customer_avg_order - ra.avg_order_value AS diff_from_regional_avg
FROM customer_order_stats cos
INNER JOIN regional_avg ra ON cos.region = ra.region
WHERE cos.customer_orders > 0 
  AND cos.customer_avg_order > ra.avg_order_value
ORDER BY cos.customer_avg_order - ra.avg_order_value DESC;

-- Correlated Subquery Approach (equivalent logic)
SELECT 
    c.customer_name,
    c.region,
    customer_stats.customer_orders,
    customer_stats.customer_avg_order,
    customer_stats.customer_total_revenue,
    regional_stats.avg_order_value AS regional_avg,
    customer_stats.customer_avg_order - regional_stats.avg_order_value AS diff_from_regional_avg
FROM customers c
CROSS JOIN (
    SELECT AVG(total_amount) AS avg_order_value, region
    FROM customers c2
    INNER JOIN sales_orders so ON c2.customer_id = so.customer_id
    WHERE so.status = 'Completed'
    GROUP BY region
) regional_stats
INNER JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS customer_orders,
        AVG(total_amount) AS customer_avg_order,
        SUM(total_amount) AS customer_total_revenue
    FROM sales_orders
    WHERE status = 'Completed'
    GROUP BY customer_id
) customer_stats ON c.customer_id = customer_stats.customer_id
WHERE c.region = regional_stats.region
  AND customer_stats.customer_avg_order > regional_stats.avg_order_value
ORDER BY customer_stats.customer_avg_order - regional_stats.avg_order_value DESC;
```

**Expected Result (both approaches):**
| customer_name | region | customer_orders | customer_avg_order | customer_total_revenue | regional_avg | diff_from_regional_avg |
|---------------|--------|-----------------|-------------------|-----------------------|--------------|------------------------|
| TechCorp      | North  | 2               | 2000.00           | 4000.00               | 3000.00      | -1000.00               |
| WebFlow       | East   | 2               | 940.00            | 1880.00               | 940.00       | 0.00                   |

### Query 4: Performance comparison - CTE vs Temp table approach
```sql
-- CTE Approach for complex multi-step analysis
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sale_month,
        COUNT(*) AS orders_count,
        SUM(total_amount) AS monthly_revenue,
        AVG(total_amount) AS avg_order_value
    FROM sales_orders
    WHERE status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
sales_with_growth AS (
    SELECT 
        sale_month,
        orders_count,
        monthly_revenue,
        avg_order_value,
        LAG(monthly_revenue) OVER (ORDER BY sale_month) AS prev_month_revenue,
        monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month) AS revenue_growth
    FROM monthly_sales
),
growth_analysis AS (
    SELECT 
        *,
        CASE 
            WHEN revenue_growth > 0 THEN 'Growing'
            WHEN revenue_growth < 0 THEN 'Declining'
            ELSE 'Stable'
        END AS growth_trend,
        ROUND(
            (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month)) / 
            NULLIF(LAG(monthly_revenue) OVER (ORDER BY sale_month), 0) * 100, 2
        ) AS growth_percentage
    FROM sales_with_growth
)
SELECT 
    sale_month,
    orders_count,
    monthly_revenue,
    revenue_growth,
    growth_trend,
    growth_percentage
FROM growth_analysis
ORDER BY sale_month;

-- Alternative: Temp table approach (for comparison)
-- CREATE TEMP TABLE monthly_sales AS (
--     SELECT ... (same logic as CTE)
-- );
-- Then perform subsequent operations on the temp table
```

**Expected Result:**
| sale_month          | orders_count | monthly_revenue | revenue_growth | growth_trend | growth_percentage |
|---------------------|--------------|-----------------|----------------|--------------|-------------------|
| 2024-01-01 00:00:00 | 2            | 3300.00         |                | Stable       |                   |
| 2024-02-01 00:00:00 | 3            | 3680.00         | 380.00         | Growing      | 11.52             |
| 2024-03-01 00:00:00 | 4            | 4150.00         | 470.00         | Growing      | 12.77             |

## Key Learning Points
- **CTEs vs Subqueries**: Readability and performance trade-offs
- **Multiple CTEs**: Building complex transformations step-by-step
- **Correlated subqueries**: Performance implications
- **Query optimization**: Choosing the right approach
- **Temp tables**: Alternative for complex persistent calculations

## Performance Considerations
- **CTEs**: Generally good for readability, optimized by query planner
- **Subqueries**: Can be slower with correlations, better for simple cases
- **Temp tables**: Useful for complex multi-step processes with reuse
- **Materialization**: Some databases materialize CTEs for performance
- **Index usage**: CTEs can utilize indexes better than complex subqueries

## When to Use Each Approach
- **CTEs**: Complex multi-step logic, recursive queries, readability
- **Subqueries**: Simple filtering, existence checks, scalar values
- **Temp tables**: Large intermediate results, multiple query reuse
- **Correlated subqueries**: Row-by-row processing when needed

## Extension Challenge
Create a comprehensive query performance analysis comparing CTE, subquery, and temporary table approaches for a complex sales forecasting scenario, including execution time measurements and query plan analysis.
