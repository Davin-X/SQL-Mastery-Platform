# 14 — E-commerce Analytics (customer lifetime value, churn analysis, product trends)

Problem
- Analyze e-commerce sales data to calculate customer lifetime value (CLV), identify churn patterns, and analyze product performance trends using advanced SQL techniques.

**Business Context:**
- Calculate CLV as: Average order value × Purchase frequency × Customer lifespan
- Identify customers at risk of churn (no orders in last 60 days)
- Find products with declining sales (YoY comparison)
- Segment customers by purchasing behavior

Starter dataset / schema
```sql
-- Create e-commerce dataset
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE,
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

Questions
1. Calculate customer lifetime value (CLV) by customer segment
2. Identify customers at risk of churn
3. Analyze product sales trends (YoY growth/decline)
4. Find best-selling product combinations using market basket analysis
5. Calculate customer retention and repeat purchase rates

Hints
- Use window functions for cumulative aggregations over time
- CTEs for multi-stage calculations
- PERCENT_RANK for identifying outliers
- CUME_DIST for customer segmentation

### Solution
<details><summary>Show solution</summary>

**Sample Dataset Creation:**
```sql
-- Insert sample data (simplified for readability)
INSERT INTO customers VALUES
(1, 'Alice', 'Johnson', 'alice@ex.com', '2023-01-15', 'New York'),
(2, 'Bob', 'Smith', 'bob@ex.com', '2023-02-20', 'Chicago'),
(3, 'Carol', 'Davis', 'carol@ex.com', '2023-03-10', 'Los Angeles');

INSERT INTO products VALUES
(101, 'Wireless Headphones', 'Electronics', 199.99, 120.00),
(102, 'Bluetooth Speaker', 'Electronics', 79.99, 45.00),
(103, 'Coffee Maker', 'Kitchen', 149.99, 85.00);

INSERT INTO orders VALUES
(1001, 1, '2024-01-10', 199.99),
(1002, 1, '2024-02-15', 229.98),
(1003, 2, '2024-01-20', 79.99),
(1004, 1, '2024-03-01', 349.98),
(1005, 3, '2024-02-25', 149.99);

INSERT INTO order_items VALUES
(2001, 1001, 101, 1, 199.99),
(2002, 1002, 101, 1, 199.99),
(2003, 1002, 102, 1, 79.99);
```

**1. Customer Lifetime Value (CLV) Analysis:**
```sql
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value,
        DATEDIFF(CURDATE(), c.signup_date) / 30.0 AS customer_lifespan_months,
        COUNT(DISTINCT o.order_id) / (DATEDIFF(CURDATE(), c.signup_date) / 30.0) AS purchase_frequency_monthly,
        SUM(o.total_amount) / (DATEDIFF(CURDATE(), c.signup_date) / 30.0) AS monthly_customer_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.signup_date
),
clv_segmentation AS (
    SELECT
        *,
        -- CLV = Average Order Value × Purchase Frequency × Customer Lifespan
        avg_order_value * purchase_frequency_monthly * customer_lifespan_months AS lifetime_value,
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
    FROM customer_metrics
)
SELECT
    *,
    CASE
        WHEN revenue_quartile = 1 THEN 'High Value'
        WHEN revenue_quartile = 2 THEN 'Medium-High Value'
        WHEN revenue_quartile = 3 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM clv_segmentation
ORDER BY lifetime_value DESC;
```

**2. Customer Churn Risk Analysis:**
```sql
WITH customer_recency AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.signup_date,
        MAX(o.order_date) AS last_order_date,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
        DATEDIFF(CURDATE(), MAX(o.order_date)) / 30.0 AS months_since_last_order,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.signup_date
),
churn_risk AS (
    SELECT
        *,
        CASE
            WHEN days_since_last_order > 180 THEN 'High Risk'
            WHEN days_since_last_order > 90 THEN 'Medium Risk'
            WHEN days_since_last_order > 60 THEN 'Low Risk'
            ELSE 'Active'
        END AS churn_risk,
        -- RFM-like scoring (simple version)
        ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS monetary_rank,
        ROW_NUMBER() OVER (ORDER BY total_orders DESC) AS frequency_rank
    FROM customer_recency
)
SELECT *
FROM churn_risk
WHERE churn_risk IN ('High Risk', 'Medium Risk')
ORDER BY days_since_last_order DESC;
```

**3. Product Sales Trends Analysis:**
```sql
WITH monthly_sales AS (
    SELECT
        p.product_name,
        p.category,
        YEAR(order_date) AS sale_year,
        MONTH(order_date) AS sale_month,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.unit_price * oi.quantity) AS monthly_revenue,
        SUM(oi.unit_price * oi.quantity - p.cost * oi.quantity) AS monthly_profit
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY p.product_name, p.category, YEAR(order_date), MONTH(order_date)
),
yoy_trends AS (
    SELECT
        product_name,
        sale_year,
        sale_month,
        monthly_revenue,
        LAG(monthly_revenue, 12) OVER (
            PARTITION BY product_name
            ORDER BY sale_year, sale_month
        ) AS prev_year_revenue,
        ROUND(
            100.0 * (monthly_revenue - LAG(monthly_revenue, 12) OVER (
                PARTITION BY product_name
                ORDER BY sale_year, sale_month
            )) / NULLIF(LAG(monthly_revenue, 12) OVER (
                PARTITION BY product_name
                ORDER BY sale_year, sale_month
            ), 0),
            2
        ) AS yoy_growth_pct
    FROM monthly_sales
)
SELECT
    product_name,
    sale_year,
    sale_month,
    monthly_revenue,
    prev_year_revenue,
    yoy_growth_pct,
    CASE
        WHEN yoy_growth_pct < -20 THEN 'Declining'
        WHEN yoy_growth_pct > 20 THEN 'Growing'
        ELSE 'Stable'
    END AS trend_category
FROM yoy_trends
ORDER BY product_name, sale_year DESC, sale_month DESC;
```

**4. Market Basket Analysis (Product Affinity):**
```sql
WITH order_products AS (
    SELECT
        o.order_id,
        GROUP_CONCAT(DISTINCT p.product_name ORDER BY p.product_name) AS products_in_order,
        COUNT(DISTINCT oi.product_id) AS products_count
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_id
),
product_pairs AS (
    SELECT
        p1.product_name AS product_a,
        p2.product_name AS product_b,
        COUNT(*) AS times_bought_together
    FROM order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
    JOIN products p1 ON oi1.product_id = p1.product_id
    JOIN products p2 ON oi2.product_id = p2.product_id
    GROUP BY p1.product_name, p2.product_name
),
pair_frequencies AS (
    SELECT
        *,
        PERCENT_RANK() OVER (ORDER BY times_bought_together DESC) AS affinity_rank_pct
    FROM product_pairs
)
SELECT *
FROM pair_frequencies
WHERE affinity_rank_pct <= 0.1  -- Top 10% of product combinations
ORDER BY times_bought_together DESC;
```

</details>
