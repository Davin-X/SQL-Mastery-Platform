# 🎯 Advanced Aggregations Practice Collection

## Overview
This consolidated file contains advanced aggregation techniques including string aggregation functions, statistical calculations, and complex grouping scenarios.

---

## 🎯 Problem 1: String Aggregation by Category

**Business Context:** Product catalog management requires displaying grouped product lists for category browsing and reporting.

### Requirements
Show each category with a comma-separated list of all products in that category, ordered alphabetically.

### SQL Setup
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(8,2)
);

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 999.99),
(2, 'Mouse', 'Electronics', 29.99),
(3, 'Keyboard', 'Electronics', 79.99),
(4, 'Novel', 'Books', 19.99),
(5, 'Textbook', 'Books', 89.99),
(6, 'Tablet', 'Electronics', 499.99);
```

### Solutions

#### MySQL (GROUP_CONCAT):
```sql
SELECT 
    category,
    GROUP_CONCAT(product_name ORDER BY product_name SEPARATOR ', ') AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

#### PostgreSQL (STRING_AGG):
```sql
SELECT 
    category,
    STRING_AGG(product_name, ', ' ORDER BY product_name) AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

#### SQL Server (STRING_AGG):
```sql
SELECT 
    category,
    STRING_AGG(product_name, ', ') WITHIN GROUP (ORDER BY product_name) AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

#### SQL Server (XML PATH - Legacy):
```sql
SELECT 
    category,
    STUFF((
        SELECT ', ' + product_name
        FROM products p2
        WHERE p2.category = p1.category
        ORDER BY product_name
        FOR XML PATH('')
    ), 1, 2, '') AS products_list
FROM (SELECT DISTINCT category FROM products) p1
ORDER BY category;
```

---

## 🎯 Problem 2: Advanced Statistical Aggregations

**Business Context:** Sales performance analysis requires statistical measures beyond basic totals.

### Requirements
Calculate comprehensive sales statistics including percentiles, standard deviations, and distribution analysis.

### SQL Setup
```sql
CREATE TABLE sales_performance (
    salesperson_id INT,
    salesperson_name VARCHAR(50),
    month_year VARCHAR(7),
    sales_amount DECIMAL(10,2),
    deals_closed INT
);

INSERT INTO sales_performance VALUES
(1, 'Alice Johnson', '2024-01', 15000.00, 12),
(1, 'Alice Johnson', '2024-02', 18000.00, 15),
(1, 'Alice Johnson', '2024-03', 22000.00, 18),
(2, 'Bob Smith', '2024-01', 12000.00, 10),
(2, 'Bob Smith', '2024-02', 14000.00, 11),
(2, 'Bob Smith', '2024-03', 16000.00, 13),
(3, 'Carol Davis', '2024-01', 25000.00, 20),
(3, 'Carol Davis', '2024-02', 28000.00, 22),
(3, 'Carol Davis', '2024-03', 32000.00, 25);
```

### Solutions

#### Comprehensive Sales Statistics:
```sql
SELECT 
    salesperson_name,
    COUNT(*) AS months_active,
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_monthly_sales,
    MIN(sales_amount) AS min_monthly_sales,
    MAX(sales_amount) AS max_monthly_sales,
    STDDEV(sales_amount) AS sales_volatility,
    SUM(deals_closed) AS total_deals,
    AVG(deals_closed) AS avg_deals_per_month,
    -- Percentiles (database-specific)
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sales_amount) AS median_sales,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY sales_amount) AS p90_sales
FROM sales_performance
GROUP BY salesperson_id, salesperson_name
ORDER BY total_sales DESC;
```

#### Rolling Statistics by Month:
```sql
SELECT 
    month_year,
    SUM(sales_amount) AS monthly_total,
    AVG(SUM(sales_amount)) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3month_avg,
    SUM(SUM(sales_amount)) OVER (ORDER BY month_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales,
    RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS month_rank
FROM sales_performance
GROUP BY month_year
ORDER BY month_year;
```

---

## 🎯 Problem 3: Conditional Aggregations with CASE

**Business Context:** Customer segmentation and performance analysis requires conditional calculations.

### Requirements
Analyze customer behavior with conditional aggregations and segmentation.

### SQL Setup
```sql
CREATE TABLE customer_orders (
    customer_id INT,
    customer_name VARCHAR(50),
    order_date DATE,
    order_amount DECIMAL(8,2),
    category VARCHAR(20),
    region VARCHAR(20)
);

INSERT INTO customer_orders VALUES
(1, 'TechCorp', '2024-01-15', 5000.00, 'Electronics', 'North'),
(1, 'TechCorp', '2024-02-20', 3000.00, 'Software', 'North'),
(2, 'DataSys', '2024-01-10', 8000.00, 'Electronics', 'South'),
(2, 'DataSys', '2024-03-05', 2000.00, 'Services', 'South'),
(3, 'Global Solutions', '2024-02-15', 12000.00, 'Software', 'East');
```

### Solutions

#### Customer Segmentation with Conditional Aggregations:
```sql
SELECT 
    customer_name,
    region,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS total_spent,
    
    -- Category-specific spending
    SUM(CASE WHEN category = 'Electronics' THEN order_amount ELSE 0 END) AS electronics_spent,
    SUM(CASE WHEN category = 'Software' THEN order_amount ELSE 0 END) AS software_spent,
    SUM(CASE WHEN category = 'Services' THEN order_amount ELSE 0 END) AS services_spent,
    
    -- Seasonal analysis
    SUM(CASE WHEN MONTH(order_date) <= 3 THEN order_amount ELSE 0 END) AS q1_spent,
    SUM(CASE WHEN MONTH(order_date) BETWEEN 4 AND 6 THEN order_amount ELSE 0 END) AS q2_spent,
    
    -- Customer tier based on spending
    CASE 
        WHEN SUM(order_amount) > 10000 THEN 'Platinum'
        WHEN SUM(order_amount) > 5000 THEN 'Gold'
        ELSE 'Silver'
    END AS customer_tier
    
FROM customer_orders
GROUP BY customer_id, customer_name, region
ORDER BY total_spent DESC;
```

#### Pivot-Style Reporting with Aggregations:
```sql
SELECT 
    region,
    COUNT(DISTINCT CASE WHEN category = 'Electronics' THEN customer_id END) AS electronics_customers,
    COUNT(DISTINCT CASE WHEN category = 'Software' THEN customer_id END) AS software_customers,
    COUNT(DISTINCT CASE WHEN category = 'Services' THEN customer_id END) AS services_customers,
    SUM(CASE WHEN category = 'Electronics' THEN order_amount ELSE 0 END) AS electronics_revenue,
    SUM(CASE WHEN category = 'Software' THEN order_amount ELSE 0 END) AS software_revenue,
    SUM(CASE WHEN category = 'Services' THEN order_amount ELSE 0 END) AS services_revenue
FROM customer_orders
GROUP BY region
ORDER BY region;
```

---

## 📚 Key Concepts Covered

### String Aggregation Functions
- **MySQL**: GROUP_CONCAT(column ORDER BY column SEPARATOR ', ')
- **PostgreSQL**: STRING_AGG(column, ', ' ORDER BY column)
- **SQL Server**: STRING_AGG(column, ', ') WITHIN GROUP (ORDER BY column)
- **Oracle**: LISTAGG(column, ', ') WITHIN GROUP (ORDER BY column)

### Statistical Functions
- **Basic**: COUNT, SUM, AVG, MIN, MAX
- **Advanced**: STDDEV, VARIANCE, PERCENTILE functions
- **Distribution**: MEDIAN, MODE, PERCENTILES

### Conditional Aggregations
- **CASE in Aggregates**: SUM(CASE WHEN condition THEN value ELSE 0 END)
- **Pivot Logic**: Conditional counting and summing
- **Segmentation**: Customer/profit tier calculations

### Performance Considerations
- **Index Usage**: Aggregations benefit from indexed GROUP BY columns
- **Memory Usage**: String aggregations can consume memory
- **Function Availability**: Statistical functions vary by database
- **Large Datasets**: Consider pre-aggregation for performance

---

## 🎯 Interview-Ready Patterns

### Pattern 1: Report Generation
Creating summary reports with multiple aggregation levels.

### Pattern 2: Customer Segmentation
Conditional aggregations for tier analysis and targeting.

### Pattern 3: Time Series Analysis
Rolling statistics and trend calculations.

### Pattern 4: Cross-Tabulation
Pivot-style reporting with conditional aggregations.

---

## 🔧 Database-Specific Notes

### MySQL:
- GROUP_CONCAT length limit: Default 1024, adjustable with group_concat_max_len
- Statistical functions: STDDEV() or STDDEV_POP()/STDDEV_SAMP()
- Percentiles: Limited support, use window functions

### PostgreSQL:
- Rich statistical functions: percentile_cont(), percentile_disc()
- STRING_AGG with full ordering support
- Advanced aggregate functions available

### SQL Server:
- STRING_AGG in SQL Server 2017+
- PERCENTILE_CONT/PERCENTILE_DISC functions
- Window function support for advanced statistics

### Oracle:
- LISTAGG for string aggregation
- Rich statistical function library
- Advanced analytics functions available

