# 🎯 Window Analytical Functions Comprehensive Guide

## Question
Demonstrate proficiency with SQL window functions by solving various analytical problems including ranking, running totals, moving averages, and comparative analysis using different window frame specifications.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    salesperson VARCHAR(50),
    region VARCHAR(20),
    sale_date DATE,
    amount DECIMAL(10,2),
    product_category VARCHAR(30)
);

INSERT INTO sales_data VALUES
(1, 'Alice', 'North', '2024-01-15', 5000.00, 'Electronics'),
(2, 'Bob', 'North', '2024-01-16', 4500.00, 'Books'),
(3, 'Charlie', 'South', '2024-01-15', 6200.00, 'Electronics'),
(4, 'Diana', 'South', '2024-01-17', 3800.00, 'Books'),
(5, 'Alice', 'North', '2024-02-10', 7200.00, 'Electronics'),
(6, 'Bob', 'North', '2024-02-12', 5100.00, 'Books'),
(7, 'Charlie', 'South', '2024-02-11', 4800.00, 'Electronics'),
(8, 'Diana', 'South', '2024-02-13', 6900.00, 'Books'),
(9, 'Alice', 'North', '2024-03-05', 5800.00, 'Electronics'),
(10, 'Bob', 'North', '2024-03-07', 4200.00, 'Books');
```

## Window Function 1: Ranking Functions (ROW_NUMBER, RANK, DENSE_RANK)

```sql
SELECT 
    salesperson,
    region,
    sale_date,
    amount,
    
    -- Different ranking approaches
    ROW_NUMBER() OVER (ORDER BY amount DESC) AS overall_row_num,
    RANK() OVER (ORDER BY amount DESC) AS overall_rank,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS overall_dense_rank,
    
    -- Regional rankings
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC) AS regional_row_num,
    RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS regional_rank,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS regional_dense_rank,
    
    -- Salesperson rankings over time
    ROW_NUMBER() OVER (PARTITION BY salesperson ORDER BY sale_date) AS salesperson_sale_num
    
FROM sales_data
ORDER BY region, amount DESC;
```

**How it works**: 
- ROW_NUMBER: Sequential numbering (1, 2, 3...)
- RANK: Same values get same rank, skips next (1, 1, 3...)
- DENSE_RANK: Same values get same rank, no skipping (1, 1, 2...)

## Window Function 2: Aggregate Functions (SUM, AVG, COUNT with Windows)

```sql
SELECT 
    salesperson,
    region,
    sale_date,
    amount,
    
    -- Running totals by salesperson
    SUM(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date
    ) AS salesperson_running_total,
    
    -- Running averages by region
    AVG(amount) OVER (
        PARTITION BY region 
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS regional_running_avg,
    
    -- Cumulative count
    COUNT(*) OVER (
        PARTITION BY region 
        ORDER BY sale_date
    ) AS regional_sale_count,
    
    -- Total sales per region
    SUM(amount) OVER (PARTITION BY region) AS region_total_sales,
    
    -- Sales percentage of region total
    ROUND((amount / SUM(amount) OVER (PARTITION BY region)) * 100, 2) AS pct_of_region_sales
    
FROM sales_data
ORDER BY region, salesperson, sale_date;
```

**How it works**: Window aggregates calculate running totals, averages, and percentages within partitions.

## Window Function 3: Value Functions (LAG, LEAD, FIRST_VALUE, LAST_VALUE)

```sql
SELECT 
    salesperson,
    region,
    sale_date,
    amount,
    
    -- Previous sale amount
    LAG(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date
    ) AS prev_sale_amount,
    
    -- Next sale amount
    LEAD(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date
    ) AS next_sale_amount,
    
    -- Sales growth from previous
    CASE 
        WHEN LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_date) IS NOT NULL
        THEN ROUND(((amount - LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_date)) 
                   / LAG(amount) OVER (PARTITION BY salesperson ORDER BY sale_date)) * 100, 2)
        ELSE NULL
    END AS sale_growth_pct,
    
    -- First sale of salesperson
    FIRST_VALUE(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date
    ) AS first_sale_amount,
    
    -- Best sale of salesperson
    MAX(amount) OVER (
        PARTITION BY salesperson
    ) AS best_sale_amount,
    
    -- Regional best performer
    FIRST_VALUE(salesperson) OVER (
        PARTITION BY region 
        ORDER BY amount DESC
    ) AS regional_top_salesperson
    
FROM sales_data
ORDER BY salesperson, sale_date;
```

**How it works**: LAG/LEAD access previous/next rows, FIRST_VALUE/LAST_VALUE access specific positions in the window.

## Window Function 4: NTILE and Percentile Functions

```sql
SELECT 
    salesperson,
    region,
    sale_date,
    amount,
    
    -- Quartiles (4 groups)
    NTILE(4) OVER (ORDER BY amount) AS amount_quartile,
    
    -- Deciles (10 groups)
    NTILE(10) OVER (ORDER BY amount) AS amount_decile,
    
    -- Regional performance tiers
    NTILE(3) OVER (PARTITION BY region ORDER BY amount DESC) AS regional_performance_tier,
    
    -- Percent rank
    ROUND(PERCENT_RANK() OVER (ORDER BY amount) * 100, 2) AS percent_rank,
    
    -- Cumulative distribution
    ROUND(CUME_DIST() OVER (ORDER BY amount) * 100, 2) AS cumulative_dist_pct
    
FROM sales_data
ORDER BY amount DESC;
```

**How it works**: NTILE divides data into equal groups, PERCENT_RANK shows relative position, CUME_DIST shows cumulative distribution.

## Window Function 5: Complex Frame Specifications

```sql
SELECT 
    salesperson,
    region,
    sale_date,
    amount,
    
    -- 3-sale moving average
    ROUND(AVG(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) AS moving_avg_3_sales,
    
    -- Running total (unbounded to current)
    SUM(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_unbounded,
    
    -- Last 30 days total
    SUM(amount) OVER (
        PARTITION BY salesperson 
        ORDER BY sale_date 
        RANGE BETWEEN INTERVAL 30 DAY PRECEDING AND CURRENT ROW
    ) AS last_30_days_total,
    
    -- Regional rank with custom frame
    RANK() OVER (
        PARTITION BY region 
        ORDER BY amount DESC
    ) AS regional_rank
    
FROM sales_data
ORDER BY salesperson, sale_date;
```

**How it works**: Demonstrates different frame specifications - ROWS for physical rows, RANGE for logical ranges.

## Advanced Window Function Patterns

### Pattern 1: Year-over-Year Growth
```sql
SELECT 
    salesperson,
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(amount) AS monthly_total,
    LAG(SUM(amount)) OVER (
        PARTITION BY salesperson 
        ORDER BY YEAR(sale_date), MONTH(sale_date)
    ) AS prev_month_total,
    ROUND(
        ((SUM(amount) - LAG(SUM(amount)) OVER (
            PARTITION BY salesperson 
            ORDER BY YEAR(sale_date), MONTH(sale_date)
        )) / LAG(SUM(amount)) OVER (
            PARTITION BY salesperson 
            ORDER BY YEAR(sale_date), MONTH(sale_date)
        )) * 100, 2
    ) AS mom_growth_pct
FROM sales_data
GROUP BY salesperson, YEAR(sale_date), MONTH(sale_date)
ORDER BY salesperson, sale_year, sale_month;
```

### Pattern 2: Top N per Group with Ties
```sql
WITH ranked_sales AS (
    SELECT 
        *,
        DENSE_RANK() OVER (
            PARTITION BY region 
            ORDER BY amount DESC
        ) AS regional_rank
    FROM sales_data
)
SELECT * 
FROM ranked_sales 
WHERE regional_rank <= 2  -- Top 2 per region, handles ties
ORDER BY region, regional_rank, amount DESC;
```

## Performance Considerations

- **Index Strategy**: Order By columns should be indexed
- **Partition Size**: Large partitions can be expensive
- **Frame Specification**: ROWS is generally faster than RANGE
- **Materialized Views**: For frequently accessed window calculations

## Common Interview Patterns

1. **Ranking problems**: Top N, percentile analysis
2. **Time series**: Running totals, moving averages
3. **Comparative analysis**: Year-over-year, peer comparison
4. **Trend identification**: Growth rates, anomaly detection


- **Explain window components**: PARTITION BY, ORDER BY, frame
- **Choose right function**: ROW_NUMBER vs RANK vs DENSE_RANK
- **Performance awareness**: Window functions can be expensive
- **Frame specification**: Understand ROWS vs RANGE
- **Real-world application**: Connect to business use cases

## Database-Specific Notes

### MySQL:
- Window functions since 8.0
- Limited frame specifications compared to PostgreSQL

### PostgreSQL:
- Full window function support
- Advanced frame specifications
- Additional functions like PERCENTILE_CONT

### SQL Server:
- Good window function support
- NTILE and ranking functions work well
- OVER clause required for window functions


- **Sales analytics**: Performance rankings, territory analysis
- **Financial reporting**: Running totals, period comparisons
- **User behavior**: Session analysis, funnel progression
- **Quality metrics**: Performance percentiles, trend analysis
- **Inventory management**: Stock level monitoring, reorder analysis

