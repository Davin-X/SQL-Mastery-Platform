# Problem 03: LAG() and LEAD() - Accessing Previous/Next Row Values

## Business Context
Analytics teams often need to compare current values with previous or future periods to identify trends, calculate growth rates, and perform time-series analysis. LAG() and LEAD() functions enable access to previous and next row values within ordered partitions.

## Requirements
Write SQL queries using LAG() and LEAD() functions to perform sequential analysis, calculate period-over-period changes, and identify trends in ordered data.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sale_date DATE NOT NULL,
    revenue DECIMAL(10, 2) NOT NULL,
    units_sold INT NOT NULL
);

-- Insert sample data
INSERT INTO sales_data (sale_id, product_name, category, sale_date, revenue, units_sold) VALUES
(1, 'Laptop Pro', 'Electronics', '2024-01-15', 2500.00, 10),
(2, 'Laptop Pro', 'Electronics', '2024-02-15', 2750.00, 11),
(3, 'Laptop Pro', 'Electronics', '2024-03-15', 2200.00, 8),
(4, 'Laptop Pro', 'Electronics', '2024-04-15', 3000.00, 12),
(5, 'Tablet Air', 'Electronics', '2024-01-15', 800.00, 20),
(6, 'Tablet Air', 'Electronics', '2024-02-15', 900.00, 22),
(7, 'Tablet Air', 'Electronics', '2024-03-15', 750.00, 18),
(8, 'Tablet Air', 'Electronics', '2024-04-15', 1000.00, 25),
(9, 'Office Chair', 'Furniture', '2024-01-15', 600.00, 15),
(10, 'Office Chair', 'Furniture', '2024-02-15', 720.00, 18),
(11, 'Office Chair', 'Furniture', '2024-03-15', 540.00, 12),
(12, 'Office Chair', 'Furniture', '2024-04-15', 780.00, 20);
```

## Query Requirements

### Query 1: Month-over-month revenue comparison using LAG()
```sql
SELECT 
    product_name,
    sale_date,
    revenue AS current_revenue,
    LAG(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_date
    ) AS previous_revenue,
    revenue - LAG(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_date
    ) AS revenue_change,
    ROUND(
        ((revenue - LAG(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        )) / LAG(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        )) * 100, 2
    ) AS growth_percentage
FROM sales_data
ORDER BY product_name, sale_date;
```

**Expected Result:**
| product_name | sale_date  | current_revenue | previous_revenue | revenue_change | growth_percentage |
|--------------|------------|-----------------|------------------|----------------|-------------------|
| Laptop Pro   | 2024-01-15 | 2500.00         |                  |                |                   |
| Laptop Pro   | 2024-02-15 | 2750.00         | 2500.00          | 250.00         | 10.00             |
| Laptop Pro   | 2024-03-15 | 2200.00         | 2750.00          | -550.00        | -20.00            |
| Laptop Pro   | 2024-04-15 | 3000.00         | 2200.00          | 800.00         | 36.36             |
| Office Chair | 2024-01-15 | 600.00          |                  |                |                   |
| Office Chair | 2024-02-15 | 720.00          | 600.00           | 120.00         | 20.00             |
| Office Chair | 2024-03-15 | 540.00          | 720.00           | -180.00        | -25.00            |
| Office Chair | 2024-04-15 | 780.00          | 540.00           | 240.00         | 44.44             |
| Tablet Air   | 2024-01-15 | 800.00          |                  |                |                   |
| Tablet Air   | 2024-02-15 | 900.00          | 800.00           | 100.00         | 12.50             |
| Tablet Air   | 2024-03-15 | 750.00          | 900.00           | -150.00        | -16.67            |
| Tablet Air   | 2024-04-15 | 1000.00         | 750.00           | 250.00         | 33.33             |

### Query 2: Three-month moving averages using LAG()
```sql
SELECT 
    product_name,
    sale_date,
    revenue,
    ROUND(
        (revenue + COALESCE(LAG(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ), 0) + COALESCE(LAG(revenue, 2) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ), 0)) / 
        NULLIF(
            (CASE WHEN LAG(revenue) OVER (PARTITION BY product_name ORDER BY sale_date) IS NOT NULL THEN 1 ELSE 0 END +
             CASE WHEN LAG(revenue, 2) OVER (PARTITION BY product_name ORDER BY sale_date) IS NOT NULL THEN 1 ELSE 0 END + 1), 
            0
        ), 2
    ) AS three_month_avg
FROM sales_data
ORDER BY product_name, sale_date;
```

### Query 3: Identifying sales trends using LEAD()
```sql
SELECT 
    product_name,
    sale_date,
    revenue AS current_revenue,
    LEAD(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_date
    ) AS next_revenue,
    LEAD(revenue, 2) OVER (
        PARTITION BY product_name 
        ORDER BY sale_date
    ) AS two_months_ahead,
    CASE 
        WHEN revenue < LEAD(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ) THEN 'Increasing'
        WHEN revenue > LEAD(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ) THEN 'Decreasing'
        ELSE 'Stable'
    END AS trend
FROM sales_data
ORDER BY product_name, sale_date;
```

**Expected Result:**
| product_name | sale_date  | current_revenue | next_revenue | two_months_ahead | trend      |
|--------------|------------|-----------------|--------------|------------------|------------|
| Laptop Pro   | 2024-01-15 | 2500.00         | 2750.00      | 2200.00          | Increasing |
| Laptop Pro   | 2024-02-15 | 2750.00         | 2200.00      | 3000.00          | Decreasing |
| Laptop Pro   | 2024-03-15 | 2200.00         | 3000.00      |                  | Increasing |
| Laptop Pro   | 2024-04-15 | 3000.00         |              |                  |            |
| Office Chair | 2024-01-15 | 600.00          | 720.00       | 540.00           | Increasing |
| Office Chair | 2024-02-15 | 720.00          | 540.00       | 780.00           | Decreasing |
| Office Chair | 2024-03-15 | 540.00          | 780.00       |                  | Increasing |
| Office Chair | 2024-04-15 | 780.00          |              |                  |            |
| Tablet Air   | 2024-01-15 | 800.00          | 900.00       | 750.00           | Increasing |
| Tablet Air   | 2024-02-15 | 900.00          | 750.00       | 1000.00          | Decreasing |
| Tablet Air   | 2024-03-15 | 750.00          | 1000.00      |                  | Increasing |
| Tablet Air   | 2024-04-15 | 1000.00         |              |                  |            |

### Query 4: Best and worst performing months using LAG() and LEAD()
```sql
WITH monthly_performance AS (
    SELECT 
        product_name,
        sale_date,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ) AS prev_month,
        LEAD(revenue) OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ) AS next_month,
        ROW_NUMBER() OVER (
            PARTITION BY product_name 
            ORDER BY sale_date
        ) AS month_number
    FROM sales_data
)
SELECT 
    product_name,
    sale_date,
    revenue,
    prev_month,
    next_month,
    CASE 
        WHEN prev_month IS NULL THEN 'First Month'
        WHEN revenue > prev_month AND revenue > COALESCE(next_month, revenue) THEN 'Peak Month'
        WHEN revenue < prev_month AND revenue < COALESCE(next_month, revenue) THEN 'Low Month'
        WHEN revenue > prev_month THEN 'Improving'
        WHEN revenue < prev_month THEN 'Declining'
        ELSE 'Stable'
    END AS performance_type
FROM monthly_performance
ORDER BY product_name, sale_date;
```

## Key Learning Points
- **LAG(column, offset)**: Access previous row values (default offset = 1)
- **LEAD(column, offset)**: Access next row values (default offset = 1)
- **Offset parameter**: How many rows back/forward to look
- **PARTITION BY + ORDER BY**: Essential for meaningful comparisons
- **NULL handling**: LAG/LEAD return NULL for non-existent rows
- **Time-series analysis**: Perfect for trend analysis and comparisons

## Common LAG()/LEAD() Applications
- **Period-over-period analysis**: Month-over-month, year-over-year
- **Trend identification**: Increasing, decreasing, stable patterns
- **Moving averages**: Rolling calculations over time periods
- **Performance tracking**: Peak/valley identification
- **Comparative analysis**: Before/after comparisons

## Performance Notes
- LAG/LEAD are efficient window functions
- Proper indexing on partition and order columns crucial
- Consider data volume for large datasets
- Can be combined with other window functions

## Extension Challenge
Create a query that identifies products with consistent growth patterns (revenue increasing for 3+ consecutive months) vs. volatile products with significant fluctuations.
