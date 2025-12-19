# Problem 02: Advanced Set Operations with Aggregations

## Business Context
Combine UNION/INTERSECT/EXCEPT with aggregations and window functions for sophisticated business intelligence reporting across multiple data sources.

## Requirements
Create advanced queries combining set operations with complex analytical patterns for multi-source data consolidation and statistical analysis.

## Sample Data Setup
```sql
-- Core tables for quarterly analysis
CREATE TABLE sales_q1 (sale_id INT PRIMARY KEY, product_id INT, region VARCHAR(50), salesperson_id INT, quantity INT, unit_price DECIMAL(8,2), sale_date DATE);
CREATE TABLE sales_q2 (sale_id INT PRIMARY KEY, product_id INT, region VARCHAR(50), salesperson_id INT, quantity INT, unit_price DECIMAL(8,2), sale_date DATE);
CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR(100), category VARCHAR(50), base_price DECIMAL(8,2), discontinued BOOLEAN DEFAULT FALSE);
CREATE TABLE salespeople (salesperson_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), region VARCHAR(50), hire_date DATE, salary DECIMAL(10,2));
CREATE TABLE inventory_q1 (product_id INT PRIMARY KEY, beginning_stock INT, ending_stock INT, stockouts INT DEFAULT 0);
CREATE TABLE inventory_q2 (product_id INT PRIMARY KEY, beginning_stock INT, ending_stock INT, stockouts INT DEFAULT 0);
CREATE TABLE customer_feedback_q1 (feedback_id INT PRIMARY KEY, customer_id INT, product_id INT, rating INT, feedback_date DATE, comments TEXT);
CREATE TABLE customer_feedback_q2 (feedback_id INT PRIMARY KEY, customer_id INT, product_id INT, rating INT, feedback_date DATE, comments TEXT);

-- Sample data (condensed for brevity)
INSERT INTO products VALUES (1, 'Laptop Pro', 'Electronics', 1200.00, FALSE), (2, 'Wireless Mouse', 'Electronics', 25.00, FALSE), (3, 'Office Chair', 'Furniture', 300.00, FALSE), (4, 'Monitor 4K', 'Electronics', 400.00, FALSE), (5, 'Keyboard Wireless', 'Electronics', 80.00, FALSE);
INSERT INTO salespeople VALUES (1, 'Alice', 'Johnson', 'North', '2020-01-15', 55000.00), (2, 'Bob', 'Smith', 'South', '2019-03-20', 60000.00), (3, 'Carol', 'Davis', 'East', '2018-11-05', 58000.00);
INSERT INTO sales_q1 VALUES (1, 1, 'North', 1, 5, 1200.00, '2024-01-15'), (2, 2, 'North', 1, 20, 25.00, '2024-01-16'), (3, 3, 'South', 2, 8, 300.00, '2024-01-20');
INSERT INTO sales_q2 VALUES (8, 1, 'North', 1, 7, 1150.00, '2024-04-15'), (9, 2, 'North', 1, 25, 24.00, '2024-04-16'), (10, 3, 'South', 2, 10, 320.00, '2024-04-20');
INSERT INTO inventory_q1 VALUES (1, 50, 42, 0), (2, 100, 85, 0), (3, 30, 22, 0);
INSERT INTO inventory_q2 VALUES (1, 42, 33, 0), (2, 85, 67, 0), (3, 22, 12, 1);
INSERT INTO customer_feedback_q1 VALUES (1, 101, 1, 5, '2024-01-20', 'Excellent'), (2, 102, 2, 4, '2024-01-25', 'Good value');
INSERT INTO customer_feedback_q2 VALUES (6, 101, 1, 5, '2024-04-20', 'Still excellent'), (7, 106, 2, 4, '2024-04-25', 'Reliable');
```

## Query 1: Sales Performance with Ranking
```sql
WITH quarterly_sales AS (
    SELECT 'Q1' AS quarter, s.product_id, p.product_name, s.region,
           SUM(s.quantity * s.unit_price) AS total_sales, SUM(s.quantity) AS total_quantity, COUNT(*) AS total_orders
    FROM sales_q1 s INNER JOIN products p ON s.product_id = p.product_id
    GROUP BY s.product_id, p.product_name, s.region
    UNION ALL
    SELECT 'Q2' AS quarter, s.product_id, p.product_name, s.region,
           SUM(s.quantity * s.unit_price) AS total_sales, SUM(s.quantity) AS total_quantity, COUNT(*) AS total_orders
    FROM sales_q2 s INNER JOIN products p ON s.product_id = p.product_id
    GROUP BY s.product_id, p.product_name, s.region
),
ranked_products AS (
    SELECT *, RANK() OVER (PARTITION BY region, quarter ORDER BY total_sales DESC) AS regional_rank,
           RANK() OVER (ORDER BY total_sales DESC) AS global_rank,
           LAG(total_sales) OVER (PARTITION BY product_id, region ORDER BY quarter) AS prev_quarter_sales
    FROM quarterly_sales
)
SELECT quarter, product_name, region, total_sales, regional_rank, global_rank,
       ROUND((total_sales - COALESCE(prev_quarter_sales, 0)) / NULLIF(COALESCE(prev_quarter_sales, 0), 0) * 100, 2) AS growth_pct
FROM ranked_products ORDER BY region, quarter, total_sales DESC;
```

## Query 2: Inventory Turnover Analysis
```sql
WITH quarterly_inventory AS (
    SELECT 'Q1' AS quarter, i.product_id, p.product_name, i.beginning_stock, i.ending_stock, i.stockouts,
           (i.beginning_stock + i.ending_stock) / 2.0 AS avg_inventory
    FROM inventory_q1 i INNER JOIN products p ON i.product_id = p.product_id
    UNION ALL
    SELECT 'Q2' AS quarter, i.product_id, p.product_name, i.beginning_stock, i.ending_stock, i.stockouts,
           (i.beginning_stock + i.ending_stock) / 2.0 AS avg_inventory
    FROM inventory_q2 i INNER JOIN products p ON i.product_id = p.product_id
),
inventory_metrics AS (
    SELECT *, LAG(ending_stock) OVER (PARTITION BY product_id ORDER BY quarter) AS prev_ending_stock,
           CASE WHEN LAG(ending_stock) OVER (PARTITION BY product_id ORDER BY quarter) IS NOT NULL
                THEN (beginning_stock - ending_stock) / NULLIF(avg_inventory, 0) ELSE NULL END AS turnover
    FROM quarterly_inventory
)
SELECT quarter, product_name, ROUND(avg_inventory, 1) AS avg_inventory, ROUND(turnover, 2) AS turnover_rate,
       CASE WHEN stockouts > 0 THEN 'Stockout Risk' WHEN turnover > 2 THEN 'High Turnover'
            WHEN turnover < 0.5 THEN 'Slow Moving' ELSE 'Normal' END AS status
FROM inventory_metrics ORDER BY product_name, quarter;
```

## Query 3: Customer Feedback Trends
```sql
WITH quarterly_feedback AS (
    SELECT 'Q1' AS quarter, f.product_id, p.product_name, f.rating, COUNT(*) AS feedback_count
    FROM customer_feedback_q1 f INNER JOIN products p ON f.product_id = p.product_id
    GROUP BY f.product_id, p.product_name, f.rating
    UNION ALL
    SELECT 'Q2' AS quarter, f.product_id, p.product_name, f.rating, COUNT(*) AS feedback_count
    FROM customer_feedback_q2 f INNER JOIN products p ON f.product_id = p.product_id
    GROUP BY f.product_id, p.product_name, f.rating
),
feedback_summary AS (
    SELECT product_name, quarter, ROUND(AVG(rating), 2) AS avg_rating, SUM(feedback_count) AS total_feedback,
           MAX(rating) AS highest_rating, MIN(rating) AS lowest_rating
    FROM quarterly_feedback GROUP BY product_name, quarter
)
SELECT *, LAG(avg_rating) OVER (PARTITION BY product_name ORDER BY quarter) AS prev_rating,
       CASE WHEN avg_rating - LAG(avg_rating) OVER (PARTITION BY product_name ORDER BY quarter) > 0 THEN 'Improving'
            WHEN avg_rating - LAG(avg_rating) OVER (PARTITION BY product_name ORDER BY quarter) < 0 THEN 'Declining'
            ELSE 'Stable' END AS trend
FROM feedback_summary ORDER BY product_name, quarter;
```

## Query 4: Sales Performance Dashboard
```sql
WITH sales_performance AS (
    SELECT 'Q1' AS quarter, s.region, sp.first_name || ' ' || sp.last_name AS salesperson,
           SUM(s.quantity * s.unit_price) AS total_sales, COUNT(DISTINCT s.product_id) AS products_sold, COUNT(*) AS orders
    FROM sales_q1 s INNER JOIN salespeople sp ON s.salesperson_id = sp.salesperson_id
    GROUP BY s.region, sp.first_name, sp.last_name
    UNION ALL
    SELECT 'Q2' AS quarter, s.region, sp.first_name || ' ' || sp.last_name AS salesperson,
           SUM(s.quantity * s.unit_price) AS total_sales, COUNT(DISTINCT s.product_id) AS products_sold, COUNT(*) AS orders
    FROM sales_q2 s INNER JOIN salespeople sp ON s.salesperson_id = sp.salesperson_id
    GROUP BY s.region, sp.first_name, sp.last_name
),
performance_ranks AS (
    SELECT *, RANK() OVER (PARTITION BY region, quarter ORDER BY total_sales DESC) AS regional_rank,
           RANK() OVER (ORDER BY total_sales DESC) AS global_rank
    FROM sales_performance
),
regional_totals AS (
    SELECT region, quarter, SUM(total_sales) AS regional_sales
    FROM sales_performance GROUP BY region, quarter
)
SELECT pr.quarter, pr.region, pr.salesperson, pr.total_sales, pr.regional_rank,
       ROUND(pr.total_sales / NULLIF(rt.regional_sales, 0) * 100, 2) AS pct_of_regional,
       CASE WHEN pr.regional_rank = 1 THEN 'Top Performer' WHEN pr.regional_rank <= 3 THEN 'High Performer' ELSE 'Standard' END AS tier
FROM performance_ranks pr INNER JOIN regional_totals rt ON pr.region = rt.region AND pr.quarter = rt.quarter
ORDER BY pr.region, pr.quarter, pr.total_sales DESC;
```

## Key Learning Points
- **Set Operations + Aggregations**: UNION with GROUP BY and window functions
- **Complex CTE Chains**: Multi-step analytical transformations
- **Business Intelligence**: Comprehensive KPI dashboards
- **Performance Analysis**: Ranking, trends, and comparative metrics

## Common Applications
- **Quarterly Comparisons**: Sales, inventory, and performance analysis
- **Multi-Source Consolidation**: Regional and departmental data aggregation
- **Trend Analysis**: Growth calculations and performance monitoring
- **Executive Dashboards**: Comprehensive business intelligence reporting

## Performance Considerations
- UNION ALL preferred over UNION for better performance
- Index join columns for set operation queries
- Consider materialized views for frequently accessed analytics
- Monitor query execution plans for complex set operations

## Extension Challenge
Build a comprehensive executive dashboard combining sales performance, inventory management, and customer feedback using advanced set operations to identify business opportunities and operational risks.
