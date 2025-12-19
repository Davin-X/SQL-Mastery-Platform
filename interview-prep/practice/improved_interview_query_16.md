# 🎯 Advanced Customer Churn Analysis Interview Question

## Question
Given customer transaction data, identify customers at risk of churning within the next 30 days. A customer is considered at risk if they haven't made a purchase in the last 60 days but were active in the previous 90-day period. Calculate churn risk scores and provide retention recommendations.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE customer_transactions (
    customer_id INT,
    transaction_id INT PRIMARY KEY,
    transaction_date DATE,
    amount DECIMAL(10,2),
    product_category VARCHAR(50)
);

CREATE TABLE customer_profiles (
    customer_id INT PRIMARY KEY,
    signup_date DATE,
    total_lifetime_value DECIMAL(10,2),
    customer_segment VARCHAR(20)
);

INSERT INTO customer_transactions VALUES
(1, 1001, '2024-01-15', 150.00, 'Electronics'),
(1, 1002, '2024-02-20', 200.00, 'Books'),
(1, 1003, '2024-03-10', 75.00, 'Clothing'),
(2, 1004, '2024-01-05', 300.00, 'Electronics'),
(2, 1005, '2024-02-15', 125.00, 'Books'),
(3, 1006, '2024-01-20', 450.00, 'Electronics'),
(3, 1007, '2024-03-01', 225.00, 'Books'),
(3, 1008, '2024-03-15', 150.00, 'Clothing'),
(4, 1009, '2024-01-10', 175.00, 'Books'),
(5, 1010, '2024-01-25', 600.00, 'Electronics'),
(5, 1011, '2024-02-08', 300.00, 'Books');

INSERT INTO customer_profiles VALUES
(1, '2023-06-15', 625.00, 'Gold'),
(2, '2023-08-20', 425.00, 'Silver'),
(3, '2023-05-10', 825.00, 'Gold'),
(4, '2023-09-05', 175.00, 'Bronze'),
(5, '2023-07-12', 900.00, 'Platinum');
```

## Answer: Comprehensive Churn Risk Analysis

```sql
WITH customer_activity AS (
    SELECT 
        customer_id,
        MAX(transaction_date) AS last_purchase_date,
        MIN(transaction_date) AS first_purchase_date,
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_spent,
        AVG(amount) AS avg_transaction_value,
        COUNT(DISTINCT product_category) AS categories_purchased
    FROM customer_transactions
    GROUP BY customer_id
),
churn_risk_calculation AS (
    SELECT 
        ca.customer_id,
        cp.signup_date,
        cp.total_lifetime_value,
        cp.customer_segment,
        ca.last_purchase_date,
        ca.total_transactions,
        ca.total_spent,
        ca.avg_transaction_value,
        ca.categories_purchased,
        
        -- Days since last purchase
        DATEDIFF(CURDATE(), ca.last_purchase_date) AS days_since_last_purchase,
        
        -- Customer tenure in days
        DATEDIFF(CURDATE(), cp.signup_date) AS customer_tenure_days,
        
        -- Activity in recent periods
        CASE WHEN ca.last_purchase_date >= DATE_SUB(CURDATE(), INTERVAL 60 DAY) THEN 1 ELSE 0 END AS active_last_60_days,
        CASE WHEN ca.last_purchase_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) 
                  AND ca.last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 60 DAY) THEN 1 ELSE 0 END AS active_61_90_days,
        
        -- Transaction frequency
        ca.total_transactions / GREATEST(DATEDIFF(CURDATE(), cp.signup_date) / 30.0, 1) AS monthly_transaction_rate
        
    FROM customer_activity ca
    JOIN customer_profiles cp ON ca.customer_id = cp.customer_id
)
SELECT 
    customer_id,
    customer_segment,
    last_purchase_date,
    days_since_last_purchase,
    total_transactions,
    ROUND(total_spent, 2) AS total_spent,
    ROUND(avg_transaction_value, 2) AS avg_transaction_value,
    categories_purchased,
    
    -- Churn risk score (0-100)
    CASE 
        WHEN days_since_last_purchase > 90 THEN 90
        WHEN days_since_last_purchase > 60 AND active_61_90_days = 1 THEN 75
        WHEN days_since_last_purchase > 30 AND active_last_60_days = 0 THEN 60
        WHEN monthly_transaction_rate < 0.5 THEN 45
        ELSE 20
    END AS churn_risk_score,
    
    -- Risk category
    CASE 
        WHEN days_since_last_purchase > 90 THEN 'Critical'
        WHEN days_since_last_purchase > 60 AND active_61_90_days = 1 THEN 'High'
        WHEN days_since_last_purchase > 30 AND active_last_60_days = 0 THEN 'Medium'
        WHEN monthly_transaction_rate < 0.5 THEN 'Low-Medium'
        ELSE 'Low'
    END AS risk_category,
    
    -- Retention recommendation
    CASE 
        WHEN days_since_last_purchase > 90 THEN 'Immediate outreach with special offer'
        WHEN days_since_last_purchase > 60 AND active_61_90_days = 1 THEN 'Personalized email campaign'
        WHEN days_since_last_purchase > 30 AND active_last_60_days = 0 THEN 'Win-back discount offer'
        WHEN monthly_transaction_rate < 0.5 THEN 'Re-engagement newsletter'
        ELSE 'Monitor and maintain engagement'
    END AS retention_recommendation
    
FROM churn_risk_calculation
ORDER BY churn_risk_score DESC, days_since_last_purchase DESC;
```

**How it works**: 
- Analyzes customer transaction patterns and calculates churn risk
- Considers recency, frequency, and monetary value
- Provides actionable retention recommendations

## Alternative: Simplified Churn Detection

```sql
SELECT 
    c.customer_id,
    c.customer_segment,
    MAX(t.transaction_date) AS last_purchase,
    DATEDIFF(CURDATE(), MAX(t.transaction_date)) AS days_since_purchase,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_spent,
    
    CASE 
        WHEN DATEDIFF(CURDATE(), MAX(t.transaction_date)) > 60 
             AND MAX(t.transaction_date) >= DATE_SUB(CURDATE(), INTERVAL 120 DAY)
        THEN 'At Risk'
        ELSE 'Active'
    END AS churn_status
    
FROM customer_profiles c
LEFT JOIN customer_transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_segment
HAVING MAX(t.transaction_date) IS NOT NULL  -- Exclude customers with no transactions
ORDER BY days_since_purchase DESC;
```

**How it works**: Simple rule-based churn detection using recency and historical activity.

## Advanced: Cohort-Based Churn Analysis

```sql
WITH monthly_activity AS (
    SELECT 
        customer_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS activity_month,
        COUNT(*) AS monthly_transactions,
        SUM(amount) AS monthly_spend
    FROM customer_transactions
    GROUP BY customer_id, DATE_FORMAT(transaction_date, '%Y-%m')
),
cohort_analysis AS (
    SELECT 
        ma.customer_id,
        cp.customer_segment,
        MIN(ma.activity_month) AS cohort_month,
        COUNT(DISTINCT ma.activity_month) AS active_months,
        AVG(ma.monthly_transactions) AS avg_monthly_transactions,
        AVG(ma.monthly_spend) AS avg_monthly_spend,
        MAX(ma.activity_month) AS last_active_month
    FROM monthly_activity ma
    JOIN customer_profiles cp ON ma.customer_id = cp.customer_id
    GROUP BY ma.customer_id, cp.customer_segment
)
SELECT 
    customer_id,
    customer_segment,
    cohort_month,
    active_months,
    ROUND(avg_monthly_transactions, 1) AS avg_monthly_txns,
    ROUND(avg_monthly_spend, 2) AS avg_monthly_spend,
    
    -- Months since last activity
    PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), 
                DATE_FORMAT(STR_TO_DATE(CONCAT(last_active_month, '-01'), '%Y-%m-%d'), '%Y%m')) AS months_inactive,
    
    CASE 
        WHEN PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), 
                        DATE_FORMAT(STR_TO_DATE(CONCAT(last_active_month, '-01'), '%Y-%m-%d'), '%Y%m')) > 3
        THEN 'Churned'
        WHEN PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), 
                        DATE_FORMAT(STR_TO_DATE(CONCAT(last_active_month, '-01'), '%Y-%m-%d'), '%Y%m')) > 1
        THEN 'At Risk'
        ELSE 'Active'
    END AS churn_status
    
FROM cohort_analysis
ORDER BY months_inactive DESC, avg_monthly_spend DESC;
```

**How it works**: Cohort analysis tracks customer behavior over time, identifying churn patterns by inactivity periods.

