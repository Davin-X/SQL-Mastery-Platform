# 🎯 SQL Practice 3: Aggregation and Grouping

## Question
Write SQL queries using GROUP BY, aggregate functions, and HAVING clauses to analyze and summarize data, demonstrating data analysis and reporting capabilities.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE sales_transactions (
    transaction_id INT PRIMARY KEY,
    salesperson_id INT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(8,2),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    region VARCHAR(20)
);

CREATE TABLE salespeople (
    salesperson_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(30),
    hire_date DATE,
    base_salary DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    cost_price DECIMAL(8,2),
    list_price DECIMAL(8,2)
);

INSERT INTO salespeople VALUES
(1, 'Alice Johnson', 'Electronics', '2020-01-15', 50000.00),
(2, 'Bob Smith', 'Appliances', '2020-03-20', 45000.00),
(3, 'Charlie Brown', 'Electronics', '2020-05-10', 48000.00),
(4, 'Diana Prince', 'Books', '2020-07-22', 42000.00),
(5, 'Eve Wilson', 'Electronics', '2020-09-15', 55000.00);

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 800.00, 1200.00),
(102, 'Tablet', 'Electronics', 300.00, 500.00),
(103, 'Refrigerator', 'Appliances', 600.00, 1000.00),
(104, 'Washing Machine', 'Appliances', 400.00, 700.00),
(105, 'Novel', 'Books', 5.00, 15.00),
(106, 'Textbook', 'Books', 20.00, 50.00);

INSERT INTO sales_transactions VALUES
(1001, 1, 101, '2024-01-15', 2, 1200.00, 5.00, 'North'),
(1002, 1, 102, '2024-01-16', 1, 500.00, 0.00, 'North'),
(1003, 2, 103, '2024-01-15', 1, 1000.00, 10.00, 'South'),
(1004, 3, 101, '2024-01-17', 1, 1200.00, 0.00, 'East'),
(1005, 4, 105, '2024-01-18', 5, 15.00, 0.00, 'West'),
(1006, 5, 102, '2024-01-19', 3, 500.00, 8.00, 'North'),
(1007, 1, 106, '2024-01-20', 2, 50.00, 0.00, 'North'),
(1008, 3, 104, '2024-01-21', 1, 700.00, 5.00, 'East'),
(1009, 2, 103, '2024-01-22', 2, 1000.00, 0.00, 'South'),
(1010, 5, 101, '2024-01-23', 1, 1200.00, 15.00, 'North');
```

## Query 1: Basic GROUP BY - Sales by Salesperson

```sql
SELECT 
    salesperson_id,
    COUNT(*) AS total_sales,
    SUM(quantity) AS total_units_sold,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS total_revenue
FROM sales_transactions
GROUP BY salesperson_id
ORDER BY total_revenue DESC;
```

**Expected Output**: Sales summary for each salesperson.

## Query 2: Multiple Aggregations - Product Performance

```sql
SELECT 
    product_id,
    COUNT(*) AS times_sold,
    SUM(quantity) AS total_quantity_sold,
    MIN(unit_price) AS min_sale_price,
    MAX(unit_price) AS max_sale_price,
    AVG(unit_price) AS avg_sale_price,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS total_revenue
FROM sales_transactions
GROUP BY product_id
ORDER BY total_revenue DESC;
```

**Expected Output**: Comprehensive product sales analysis.

## Query 3: GROUP BY with JOIN - Salesperson Details

```sql
SELECT 
    s.name,
    s.department,
    COUNT(st.transaction_id) AS sales_count,
    SUM(st.quantity * st.unit_price * (1 - st.discount_percent/100)) AS total_revenue,
    AVG(st.quantity * st.unit_price * (1 - st.discount_percent/100)) AS avg_sale_amount
FROM salespeople s
LEFT JOIN sales_transactions st ON s.salesperson_id = st.salesperson_id
GROUP BY s.salesperson_id, s.name, s.department
ORDER BY total_revenue DESC;
```

**Expected Output**: Sales performance by salesperson with their details.

## Query 4: HAVING Clause - Filter Groups

```sql
SELECT 
    salesperson_id,
    COUNT(*) AS sales_count,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS total_revenue
FROM sales_transactions
GROUP BY salesperson_id
HAVING COUNT(*) >= 2 AND SUM(quantity * unit_price * (1 - discount_percent/100)) > 1000
ORDER BY total_revenue DESC;
```

**Expected Output**: Only salespeople with 2+ sales and >$1000 revenue.

## Query 5: Date-Based Grouping - Monthly Sales

```sql
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    COUNT(*) AS transactions,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS monthly_revenue,
    AVG(quantity * unit_price * (1 - discount_percent/100)) AS avg_transaction_value
FROM sales_transactions
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month;
```

**Expected Output**: Monthly sales summary.

## Query 6: Multiple GROUP BY Levels - Region and Product

```sql
SELECT 
    region,
    product_id,
    COUNT(*) AS sales_count,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS revenue
FROM sales_transactions
GROUP BY region, product_id
ORDER BY region, revenue DESC;
```

**Expected Output**: Sales by region and product.

## Query 7: ROLLUP for Subtotal Analysis

```sql
SELECT 
    region,
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    COUNT(*) AS transactions,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS revenue
FROM sales_transactions
GROUP BY region, DATE_FORMAT(sale_date, '%Y-%m') WITH ROLLUP
ORDER BY region, month;
```

**Expected Output**: Region and monthly subtotals with grand total.

## Query 8: Complex Aggregation with CASE

```sql
SELECT 
    salesperson_id,
    COUNT(*) AS total_sales,
    SUM(CASE WHEN discount_percent > 0 THEN 1 ELSE 0 END) AS discounted_sales,
    ROUND(AVG(discount_percent), 2) AS avg_discount_given,
    SUM(CASE WHEN discount_percent >= 10 THEN quantity * unit_price * (discount_percent/100) ELSE 0 END) AS total_discount_amount,
    SUM(quantity * unit_price) AS gross_revenue,
    SUM(quantity * unit_price * (1 - discount_percent/100)) AS net_revenue
FROM sales_transactions
GROUP BY salesperson_id
ORDER BY net_revenue DESC;
```

**Expected Output**: Discount analysis and revenue breakdown.

## Query 9: Category-Based Analysis with JOINs

```sql
SELECT 
    p.category,
    COUNT(DISTINCT st.transaction_id) AS unique_transactions,
    COUNT(DISTINCT st.salesperson_id) AS salespeople_involved,
    SUM(st.quantity) AS total_units_sold,
    SUM(st.quantity * st.unit_price * (1 - st.discount_percent/100)) AS category_revenue,
    AVG(st.quantity * st.unit_price * (1 - st.discount_percent/100)) AS avg_transaction_value,
    SUM((st.unit_price - p.cost_price) * st.quantity * (1 - st.discount_percent/100)) AS total_profit
FROM sales_transactions st
INNER JOIN products p ON st.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;
```

**Expected Output**: Product category performance analysis.

## Query 10: Time-Based Trends with Grouping

```sql
SELECT 
    salesperson_id,
    COUNT(*) AS total_sales,
    SUM(CASE WHEN sale_date >= '2024-01-01' AND sale_date <= '2024-01-15' THEN quantity ELSE 0 END) AS first_half_month,
    SUM(CASE WHEN sale_date >= '2024-01-16' AND sale_date <= '2024-01-31' THEN quantity ELSE 0 END) AS second_half_month,
    ROUND(
        (SUM(CASE WHEN sale_date >= '2024-01-16' AND sale_date <= '2024-01-31' THEN quantity ELSE 0 END) - 
         SUM(CASE WHEN sale_date >= '2024-01-01' AND sale_date <= '2024-01-15' THEN quantity ELSE 0 END)) * 100.0 / 
        NULLIF(SUM(CASE WHEN sale_date >= '2024-01-01' AND sale_date <= '2024-01-15' THEN quantity ELSE 0 END), 0), 2
    ) AS growth_percentage
FROM sales_transactions
WHERE sale_date >= '2024-01-01' AND sale_date <= '2024-01-31'
GROUP BY salesperson_id
ORDER BY growth_percentage DESC;
```

**Expected Output**: Salesperson performance comparison between first and second half of month.

## Query 11: Statistical Analysis with GROUP BY

```sql
SELECT 
    product_id,
    COUNT(*) AS sales_count,
    ROUND(AVG(quantity * unit_price * (1 - discount_percent/100)), 2) AS avg_sale_amount,
    ROUND(STDDEV(quantity * unit_price * (1 - discount_percent/100)), 2) AS std_dev_sale_amount,
    MIN(quantity * unit_price * (1 - discount_percent/100)) AS min_sale_amount,
    MAX(quantity * unit_price * (1 - discount_percent/100)) AS max_sale_amount,
    ROUND(
        AVG(quantity * unit_price * (1 - discount_percent/100)) - 
        (SELECT AVG(quantity * unit_price * (1 - discount_percent/100)) FROM sales_transactions), 2
    ) AS deviation_from_overall_avg
FROM sales_transactions
GROUP BY product_id
HAVING COUNT(*) >= 1
ORDER BY avg_sale_amount DESC;
```

**Expected Output**: Statistical analysis of product sales performance.

## Query 12: Department Performance Comparison

```sql
SELECT 
    s.department,
    COUNT(DISTINCT s.salesperson_id) AS salespeople_count,
    COUNT(st.transaction_id) AS total_transactions,
    SUM(st.quantity) AS total_units_sold,
    ROUND(SUM(st.quantity * st.unit_price * (1 - st.discount_percent/100)), 2) AS department_revenue,
    ROUND(AVG(st.quantity * st.unit_price * (1 - st.discount_percent/100)), 2) AS avg_transaction_value,
    ROUND(SUM(st.discount_percent * st.quantity * st.unit_price / 100), 2) AS total_discounts_given
FROM salespeople s
LEFT JOIN sales_transactions st ON s.salesperson_id = st.salesperson_id
GROUP BY s.department
ORDER BY department_revenue DESC;
```

**Expected Output**: Department-level performance analysis.

## Query 13: Top Performers with Ranking

```sql
WITH salesperson_ranks AS (
    SELECT 
        salesperson_id,
        SUM(quantity * unit_price * (1 - discount_percent/100)) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(quantity * unit_price * (1 - discount_percent/100)) DESC) AS revenue_rank
    FROM sales_transactions
    GROUP BY salesperson_id
)
SELECT 
    sr.salesperson_id,
    s.name,
    sr.total_revenue,
    sr.revenue_rank,
    CASE 
        WHEN sr.revenue_rank <= 2 THEN 'Top Performer'
        WHEN sr.revenue_rank <= 4 THEN 'Good Performer'
        ELSE 'Developing'
    END AS performance_tier
FROM salesperson_ranks sr
JOIN salespeople s ON sr.salesperson_id = s.salesperson_id
ORDER BY sr.revenue_rank;
```

**Expected Output**: Ranked salesperson performance with tiers.

## Query 14: Time Series Analysis with Grouping

```sql
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m-%d') AS sale_day,
    COUNT(*) AS daily_transactions,
    SUM(quantity) AS daily_units,
    ROUND(SUM(quantity * unit_price * (1 - discount_percent/100)), 2) AS daily_revenue,
    ROUND(AVG(quantity * unit_price * (1 - discount_percent/100)), 2) AS avg_transaction_value,
    COUNT(DISTINCT salesperson_id) AS active_salespeople,
    COUNT(DISTINCT product_id) AS products_sold
FROM sales_transactions
GROUP BY DATE_FORMAT(sale_date, '%Y-%m-%d')
ORDER BY sale_day;
```

**Expected Output**: Daily sales analysis and trends.

## Query 15: Complex Business Metrics

```sql
SELECT 
    salesperson_id,
    COUNT(*) AS total_sales,
    SUM(quantity) AS total_units,
    ROUND(SUM(quantity * unit_price * (1 - discount_percent/100)), 2) AS net_revenue,
    ROUND(SUM(quantity * unit_price * discount_percent / 100), 2) AS total_discounts,
    ROUND(AVG(discount_percent), 2) AS avg_discount_rate,
    ROUND(SUM(quantity * (unit_price - (SELECT cost_price FROM products p WHERE p.product_id = st.product_id))) * 
          (1 - AVG(discount_percent)/100), 2) AS estimated_profit,
    COUNT(DISTINCT product_id) AS unique_products_sold,
    COUNT(DISTINCT region) AS regions_sold_in
FROM sales_transactions st
GROUP BY salesperson_id
HAVING COUNT(*) > 1
ORDER BY net_revenue DESC;
```

**Expected Output**: Comprehensive salesperson performance metrics including profit estimates.

## Aggregation Best Practices

### 1. Use Appropriate Aggregate Functions
- **COUNT(*)**: Count rows
- **COUNT(column)**: Count non-NULL values
- **SUM()**: Total numeric values
- **AVG()**: Average (ignores NULLs)
- **MIN/MAX()**: Extreme values
- **STDDEV/VARIANCE**: Statistical measures

### 2. GROUP BY Column Order
- Include all non-aggregated columns in GROUP BY
- Order can affect performance (consider covering indexes)

### 3. HAVING vs WHERE
- **WHERE**: Filters rows before aggregation
- **HAVING**: Filters groups after aggregation

### 4. NULL Handling
- Most aggregates ignore NULLs
- Use COALESCE for controlled NULL handling
- COUNT(*) includes NULL rows

## Common Aggregation Mistakes

1. **Missing GROUP BY columns** → Syntax errors
2. **Incorrect aggregate usage** → Unexpected results
3. **HAVING instead of WHERE** → Performance issues
4. **NULL value confusion** → Incorrect calculations
5. **Mixed aggregated/non-aggregated columns** → Logic errors

## Interview Tips

- **Explain aggregation logic**: What each function does
- **GROUP BY mechanics**: How grouping works
- **HAVING vs WHERE**: When to use each
- **Performance considerations**: Index usage and query optimization
- **Business context**: Why aggregations matter for analysis

## Real-World Applications

- **Sales reporting**: Revenue by region/product/time period
- **Customer analytics**: Purchase patterns and lifetime value
- **Inventory management**: Stock levels and turnover rates
- **Financial analysis**: Budget vs actual performance
- **Quality metrics**: Defect rates and performance indicators
