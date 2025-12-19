# 🎯 Customer New vs Repeat Purchase Analysis

## Question
Analyze customer purchase patterns to identify new customers vs repeat customers, and calculate metrics like customer acquisition, retention rates, and purchase frequency.

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE IF NOT EXISTS complex_queries;
USE complex_queries;

CREATE TABLE customer_orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE,
    order_amount INTEGER
);

INSERT INTO customer_orders VALUES
(1, 101, '2024-01-15', 150),
(2, 102, '2024-01-16', 200),
(3, 101, '2024-01-20', 75),
(4, 103, '2024-01-22', 300),
(5, 102, '2024-01-25', 125),
(6, 104, '2024-01-28', 450),
(7, 101, '2024-02-01', 225),
(8, 105, '2024-02-05', 175),
(9, 103, '2024-02-10', 325),
(10, 102, '2024-02-15', 275);
```

## Answer: New vs Repeat Customer Analysis

```sql
WITH customer_first_purchase AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_purchase_date,
        COUNT(*) AS total_orders,
        SUM(order_amount) AS total_spent
    FROM customer_orders
    GROUP BY customer_id
),
customer_classification AS (
    SELECT 
        customer_id,
        first_purchase_date,
        total_orders,
        total_spent,
        CASE 
            WHEN total_orders = 1 THEN 'One-time Customer'
            WHEN total_orders = 2 THEN 'Repeat Customer (2 orders)'
            WHEN total_orders BETWEEN 3 AND 5 THEN 'Frequent Customer'
            ELSE 'VIP Customer'
        END AS customer_segment,
        CASE 
            WHEN total_orders > 1 THEN 'Repeat'
            ELSE 'New'
        END AS customer_type
    FROM customer_first_purchase
)
SELECT 
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_orders), 1) AS avg_orders_per_customer,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(SUM(total_spent), 2) AS total_revenue_from_segment,
    ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(order_amount) FROM customer_orders), 1) AS revenue_percentage
FROM customer_classification
GROUP BY customer_type
ORDER BY total_revenue_from_segment DESC;
```

**How it works**: 
- Identifies first purchase date for each customer
- Classifies customers as new vs repeat based on order count
- Calculates segment-wise metrics and revenue contribution

## Alternative: Monthly Customer Acquisition and Retention

```sql
WITH monthly_customer_activity AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month_year,
        customer_id,
        COUNT(*) AS orders_in_month,
        SUM(order_amount) AS spent_in_month
    FROM customer_orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'), customer_id
),
customer_cohort AS (
    SELECT 
        customer_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort_month,
        COUNT(DISTINCT DATE_FORMAT(order_date, '%Y-%m')) AS active_months,
        SUM(orders_in_month) AS total_orders,
        SUM(spent_in_month) AS total_spent
    FROM monthly_customer_activity
    GROUP BY customer_id
),
monthly_metrics AS (
    SELECT 
        cohort_month,
        COUNT(*) AS cohort_size,
        AVG(active_months) AS avg_active_months,
        AVG(total_orders) AS avg_orders_per_customer,
        AVG(total_spent) AS avg_spent_per_customer,
        SUM(total_spent) AS total_cohort_revenue
    FROM customer_cohort
    GROUP BY cohort_month
)
SELECT 
    cohort_month,
    cohort_size,
    ROUND(avg_active_months, 1) AS avg_lifespan_months,
    ROUND(avg_orders_per_customer, 1) AS avg_orders,
    ROUND(avg_spent_per_customer, 2) AS avg_customer_value,
    ROUND(total_cohort_revenue, 2) AS total_revenue,
    ROUND(total_cohort_revenue / cohort_size, 2) AS revenue_per_customer
FROM monthly_metrics
ORDER BY cohort_month DESC;
```

**How it works**: 
- Tracks customer cohorts by acquisition month
- Calculates retention metrics and customer lifetime value
- Provides insights into customer acquisition effectiveness

## Advanced: Customer Purchase Frequency Analysis

```sql
WITH customer_order_patterns AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_lifespan_days,
        AVG(order_amount) AS avg_order_value,
        SUM(order_amount) AS total_spent,
        COUNT(DISTINCT DATE_FORMAT(order_date, '%Y-%m')) AS active_months
    FROM customer_orders
    GROUP BY customer_id
),
frequency_analysis AS (
    SELECT 
        *,
        CASE 
            WHEN total_orders = 1 THEN 'One-time'
            WHEN customer_lifespan_days = 0 THEN 'Same-day multiple'
            WHEN customer_lifespan_days BETWEEN 1 AND 30 THEN 'Monthly shopper'
            WHEN customer_lifespan_days BETWEEN 31 AND 90 THEN 'Quarterly shopper'
            WHEN customer_lifespan_days BETWEEN 91 AND 365 THEN 'Annual shopper'
            ELSE 'Irregular shopper'
        END AS purchase_frequency,
        
        -- Calculate order frequency rate
        CASE 
            WHEN active_months > 0 THEN ROUND(total_orders * 1.0 / active_months, 2)
            ELSE total_orders
        END AS orders_per_active_month,
        
        -- Customer value segmentation
        CASE 
            WHEN total_spent >= 1000 THEN 'High Value'
            WHEN total_spent >= 500 THEN 'Medium Value'
            WHEN total_spent >= 100 THEN 'Low Value'
            ELSE 'Micro Value'
        END AS customer_value_segment
        
    FROM customer_order_patterns
)
SELECT 
    purchase_frequency,
    customer_value_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_orders), 1) AS avg_total_orders,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(SUM(total_spent), 2) AS segment_total_revenue
FROM frequency_analysis
GROUP BY purchase_frequency, customer_value_segment
ORDER BY segment_total_revenue DESC;
```

**How it works**: 
- Analyzes purchase patterns and frequency
- Segments customers by value and behavior
- Provides detailed customer analytics for business decisions

## Key Metrics for Customer Analysis

### Acquisition Metrics
- **New Customers**: First-time buyers in time period
- **Customer Acquisition Cost**: Marketing spend per new customer
- **Conversion Rate**: Visitors who become customers

### Retention Metrics  
- **Repeat Purchase Rate**: Customers with multiple orders
- **Customer Retention Rate**: Percentage of customers who return
- **Churn Rate**: Percentage of customers lost

### Value Metrics
- **Customer Lifetime Value**: Total expected revenue from customer
- **Average Order Value**: Revenue per transaction
- **Purchase Frequency**: Orders per time period

