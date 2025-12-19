# 🎯 Business Intelligence Case Studies Collection

## Overview
This consolidated file contains advanced business intelligence scenarios and analytical problems from multiple practice cases, focusing on real-world business applications and complex analytical requirements.

---

## 🎯 Case 1: Customer Analytics - New vs Repeat Purchase Analysis

**Business Context:** E-commerce company needs to analyze customer purchasing patterns to optimize marketing spend and improve customer lifetime value.

### Requirements
Analyze new vs repeat customers, calculate retention rates, and identify high-value customer segments.

### SQL Setup
```sql
CREATE TABLE customer_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    order_date DATE,
    order_amount DECIMAL(10,2),
    product_category VARCHAR(50)
);

INSERT INTO customer_orders VALUES
(1, 1, 'Alice Johnson', '2024-01-15', 150.00, 'Electronics'),
(2, 1, 'Alice Johnson', '2024-02-20', 200.00, 'Books'),
(3, 1, 'Alice Johnson', '2024-03-10', 300.00, 'Electronics'),
(4, 2, 'Bob Smith', '2024-01-25', 75.00, 'Books'),
(5, 2, 'Bob Smith', '2024-03-15', 250.00, 'Electronics'),
(6, 3, 'Carol Davis', '2024-02-05', 400.00, 'Electronics'),
(7, 4, 'David Wilson', '2024-01-10', 125.00, 'Books'),
(8, 4, 'David Wilson', '2024-02-12', 180.00, 'Books'),
(9, 4, 'David Wilson', '2024-03-20', 350.00, 'Electronics');
```

### Solutions

#### Customer Classification & Lifetime Value:
```sql
WITH customer_summary AS (
    SELECT 
        customer_id,
        customer_name,
        COUNT(*) AS total_orders,
        SUM(order_amount) AS lifetime_value,
        MIN(order_date) AS first_purchase_date,
        MAX(order_date) AS last_purchase_date,
        COUNT(DISTINCT product_category) AS categories_purchased
    FROM customer_orders
    GROUP BY customer_id, customer_name
),
customer_segments AS (
    SELECT *,
        CASE 
            WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders = 2 THEN 'Repeat'
            ELSE 'Frequent'
        END AS customer_type,
        CASE 
            WHEN lifetime_value >= 500 THEN 'High Value'
            WHEN lifetime_value >= 200 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_segment
    FROM customer_summary
)
SELECT 
    customer_name,
    customer_type,
    value_segment,
    total_orders,
    lifetime_value,
    categories_purchased,
    DATEDIFF(CURDATE(), last_purchase_date) AS days_since_last_purchase
FROM customer_segments
ORDER BY lifetime_value DESC;
```

#### Monthly Retention & Cohort Analysis:
```sql
WITH monthly_orders AS (
    SELECT 
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_amount) AS monthly_spend,
        COUNT(*) AS orders_in_month
    FROM customer_orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
),
cohort_analysis AS (
    SELECT 
        customer_id,
        MIN(order_month) AS cohort_month,
        COUNT(DISTINCT order_month) AS months_active,
        SUM(monthly_spend) AS total_spend,
        AVG(monthly_spend) AS avg_monthly_spend
    FROM monthly_orders
    GROUP BY customer_id
)
SELECT 
    cohort_month,
    COUNT(*) AS cohort_size,
    AVG(months_active) AS avg_months_active,
    AVG(total_spend) AS avg_lifetime_value,
    AVG(avg_monthly_spend) AS avg_monthly_spend
FROM cohort_analysis
GROUP BY cohort_month
ORDER BY cohort_month;
```

---

## 🎯 Case 2: Building Access Analytics - Floor Visit Patterns

**Business Context:** Commercial building management company needs to analyze tenant movement patterns for security and facility planning.

### Requirements
Analyze floor visit patterns, peak usage times, and tenant behavior analytics.

### SQL Setup
```sql
CREATE TABLE building_access (
    access_id INT PRIMARY KEY,
    tenant_id INT,
    tenant_name VARCHAR(100),
    floor_accessed INT,
    access_time DATETIME,
    access_type VARCHAR(20)  -- 'Entry' or 'Exit'
);

INSERT INTO building_access VALUES
(1, 1, 'TechCorp', 5, '2024-01-15 09:00:00', 'Entry'),
(2, 1, 'TechCorp', 5, '2024-01-15 17:00:00', 'Exit'),
(3, 1, 'TechCorp', 10, '2024-01-16 10:30:00', 'Entry'),
(4, 1, 'TechCorp', 10, '2024-01-16 15:45:00', 'Exit'),
(5, 2, 'DataSys', 3, '2024-01-15 08:30:00', 'Entry'),
(6, 2, 'DataSys', 3, '2024-01-15 16:30:00', 'Exit'),
(7, 3, 'GlobalTech', 8, '2024-01-16 09:15:00', 'Entry'),
(8, 3, 'GlobalTech', 8, '2024-01-16 18:00:00', 'Exit');
```

### Solutions

#### Floor Utilization Analysis:
```sql
SELECT 
    floor_accessed,
    COUNT(DISTINCT tenant_id) AS unique_tenants,
    COUNT(*) / 2 AS total_visits,  -- Each visit has entry and exit
    AVG(TIMESTAMPDIFF(HOUR, 
        MIN(CASE WHEN access_type = 'Entry' THEN access_time END),
        MAX(CASE WHEN access_type = 'Exit' THEN access_time END)
    )) AS avg_visit_duration_hours
FROM building_access
GROUP BY floor_accessed
ORDER BY total_visits DESC;
```

#### Peak Usage Time Analysis:
```sql
SELECT 
    HOUR(access_time) AS hour_of_day,
    COUNT(*) AS access_count,
    COUNT(DISTINCT tenant_id) AS unique_tenants,
    CASE 
        WHEN HOUR(access_time) BETWEEN 9 AND 17 THEN 'Business Hours'
        ELSE 'Off Hours'
    END AS time_category
FROM building_access
GROUP BY HOUR(access_time)
ORDER BY access_count DESC;
```

#### Tenant Behavior Analytics:
```sql
WITH tenant_stats AS (
    SELECT 
        tenant_id,
        tenant_name,
        COUNT(DISTINCT DATE(access_time)) AS active_days,
        COUNT(DISTINCT floor_accessed) AS floors_used,
        AVG(TIMESTAMPDIFF(HOUR, 
            MIN(CASE WHEN access_type = 'Entry' THEN access_time END),
            MAX(CASE WHEN access_type = 'Exit' THEN access_time END)
        )) AS avg_daily_hours
    FROM building_access
    GROUP BY tenant_id, tenant_name, DATE(access_time)
)
SELECT 
    tenant_name,
    COUNT(*) AS active_days_count,
    AVG(floors_used) AS avg_floors_per_day,
    AVG(avg_daily_hours) AS avg_hours_per_day,
    MAX(floors_used) AS max_floors_single_day
FROM tenant_stats
GROUP BY tenant_id, tenant_name
ORDER BY active_days_count DESC;
```

---

## 🎯 Case 3: Tournament Analytics - Sports Performance Tracking

**Business Context:** Cricket tournament organizers need to track team and player performance for rankings and strategic planning.

### Requirements
Calculate team rankings, player statistics, and performance metrics for tournament analysis.

### SQL Setup
```sql
CREATE TABLE tournament_matches (
    match_id INT PRIMARY KEY,
    team1 VARCHAR(50),
    team2 VARCHAR(50),
    winner VARCHAR(50),
    margin VARCHAR(20),
    match_date DATE,
    venue VARCHAR(100)
);

CREATE TABLE player_stats (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(100),
    team VARCHAR(50),
    matches_played INT,
    runs_scored INT,
    wickets_taken INT,
    batting_avg DECIMAL(5,2),
    bowling_avg DECIMAL(5,2)
);

INSERT INTO tournament_matches VALUES
(1, 'India', 'Australia', 'India', '5 wickets', '2024-01-15', 'Melbourne'),
(2, 'England', 'New Zealand', 'England', '45 runs', '2024-01-20', 'London'),
(3, 'India', 'England', 'India', '8 wickets', '2024-01-25', 'Mumbai'),
(4, 'Australia', 'New Zealand', 'Australia', '120 runs', '2024-01-30', 'Sydney');

INSERT INTO player_stats VALUES
(1, 'Virat Kohli', 'India', 10, 450, 0, 45.00, 0.00),
(2, 'Steve Smith', 'Australia', 8, 380, 2, 47.50, 35.00),
(3, 'Joe Root', 'England', 9, 420, 1, 46.67, 42.00),
(4, 'Kane Williamson', 'New Zealand', 7, 320, 3, 45.71, 28.33);
```

### Solutions

#### Team Performance Rankings:
```sql
SELECT 
    team,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN winner = team THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN winner != team THEN 1 ELSE 0 END) AS losses,
    ROUND(SUM(CASE WHEN winner = team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS win_percentage,
    ROW_NUMBER() OVER (ORDER BY SUM(CASE WHEN winner = team THEN 1 ELSE 0 END) DESC) AS rank
FROM (
    SELECT team1 AS team, winner FROM tournament_matches
    UNION ALL
    SELECT team2 AS team, winner FROM tournament_matches
) all_teams
GROUP BY team
ORDER BY wins DESC, win_percentage DESC;
```

#### Player Performance Rankings:
```sql
SELECT 
    player_name,
    team,
    matches_played,
    runs_scored,
    wickets_taken,
    batting_avg,
    bowling_avg,
    -- Composite performance score
    ROUND((runs_scored * 1.0) + (wickets_taken * 20) + (batting_avg * 2), 2) AS performance_score,
    RANK() OVER (ORDER BY (runs_scored + wickets_taken * 20 + batting_avg * 2) DESC) AS overall_rank
FROM player_stats
ORDER BY performance_score DESC;
```

#### Venue Performance Analysis:
```sql
SELECT 
    venue,
    COUNT(*) AS matches_hosted,
    COUNT(DISTINCT winner) AS different_winners,
    AVG(CASE 
        WHEN margin LIKE '%wickets' THEN CAST(SUBSTRING_INDEX(margin, ' ', 1) AS UNSIGNED)
        WHEN margin LIKE '%runs' THEN CAST(SUBSTRING_INDEX(margin, ' ', 1) AS UNSIGNED) / 10
        ELSE 0 
    END) AS avg_margin_score
FROM tournament_matches
GROUP BY venue
ORDER BY matches_hosted DESC;
```

---

## 📚 Key Business Intelligence Patterns Covered

### Customer Analytics
- **Lifetime Value Calculation**: Total spend, purchase frequency
- **Retention Analysis**: Repeat vs one-time customers
- **Cohort Analysis**: Customer behavior over time
- **Segmentation**: Value-based customer categorization

### Operational Analytics
- **Utilization Tracking**: Resource usage patterns
- **Time-based Analysis**: Peak usage identification
- **Behavioral Patterns**: User interaction analysis
- **Performance Metrics**: Efficiency and effectiveness measures

### Performance Analytics
- **Ranking Systems**: Competitive performance comparison
- **Statistical Measures**: Averages, percentages, rankings
- **Trend Analysis**: Performance over time
- **Predictive Indicators**: Future performance forecasting

### Data Warehousing Concepts
- **Star Schema Design**: Fact and dimension tables
- **Slowly Changing Dimensions**: Handling data changes
- **ETL Processes**: Data transformation and loading
- **Reporting Aggregations**: Summary data generation

---

## 🎯 Business Intelligence Best Practices

### Data Quality Management
- **Data Validation**: Ensuring accuracy and completeness
- **Duplicate Handling**: Identifying and resolving duplicates
- **Missing Data**: Appropriate handling of NULL values
- **Data Type Consistency**: Proper type usage and conversion

### Performance Optimization
- **Indexing Strategy**: Proper index design for analytical queries
- **Query Optimization**: Efficient aggregation and join patterns
- **Materialized Views**: Pre-computed results for complex analytics
- **Partitioning**: Large table management strategies

### Analytical Techniques
- **Trend Analysis**: Time-series pattern identification
- **Comparative Analysis**: Benchmarking against standards
- **Correlation Analysis**: Relationship identification
- **Predictive Modeling**: Future performance estimation

These business intelligence case studies demonstrate advanced SQL analytical capabilities for solving complex real-world business problems across different industries and domains.
