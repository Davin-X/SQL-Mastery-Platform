# Problem 05: FIRST_VALUE() and LAST_VALUE() - Window Boundaries

## Business Context
Business analysts often need to compare individual data points with the best/worst performers in their category or time period. FIRST_VALUE() and LAST_VALUE() enable access to boundary values within ordered partitions, useful for benchmarking, trend analysis, and performance comparisons.

## Requirements
Write SQL queries using FIRST_VALUE() and LAST_VALUE() to access boundary values within ordered partitions for comparative analysis and benchmarking.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE monthly_sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sale_month DATE NOT NULL,
    revenue DECIMAL(10, 2) NOT NULL,
    units_sold INT NOT NULL
);

CREATE TABLE employee_metrics (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dept_id INT,
    quarterly_performance DECIMAL(3, 1) NOT NULL,
    hire_quarter DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL
);

-- Insert sample data
INSERT INTO monthly_sales (sale_id, product_name, category, sale_month, revenue, units_sold) VALUES
(1, 'Laptop Pro', 'Electronics', '2024-01-01', 25000.00, 100),
(2, 'Laptop Pro', 'Electronics', '2024-02-01', 27500.00, 110),
(3, 'Laptop Pro', 'Electronics', '2024-03-01', 22000.00, 88),
(4, 'Laptop Pro', 'Electronics', '2024-04-01', 30000.00, 120),
(5, 'Tablet Air', 'Electronics', '2024-01-01', 15000.00, 200),
(6, 'Tablet Air', 'Electronics', '2024-02-01', 18000.00, 240),
(7, 'Tablet Air', 'Electronics', '2024-03-01', 12000.00, 160),
(8, 'Tablet Air', 'Electronics', '2024-04-01', 20000.00, 250),
(9, 'Office Chair', 'Furniture', '2024-01-01', 8000.00, 200),
(10, 'Office Chair', 'Furniture', '2024-02-01', 9600.00, 240),
(11, 'Office Chair', 'Furniture', '2024-03-01', 7200.00, 180),
(12, 'Office Chair', 'Furniture', '2024-04-01', 10400.00, 260);

INSERT INTO employee_metrics (emp_id, first_name, last_name, dept_id, quarterly_performance, hire_quarter, salary) VALUES
(1, 'John', 'Doe', 1, 4.5, '2022-01-01', 75000.00),
(2, 'Jane', 'Smith', 1, 4.8, '2021-04-01', 80000.00),
(3, 'Bob', 'Wilson', 1, 3.9, '2023-07-01', 72000.00),
(4, 'Alice', 'Brown', 2, 4.2, '2021-10-01', 65000.00),
(5, 'Charlie', 'Davis', 2, 4.2, '2022-01-01', 75000.00),
(6, 'Diana', 'Evans', 2, 4.7, '2020-07-01', 72000.00),
(7, 'Eve', 'Foster', 3, 4.0, '2023-01-01', 55000.00),
(8, 'Frank', 'Garcia', 3, 4.3, '2022-04-01', 60000.00);
```

## Query Requirements

### Query 1: Best monthly performance per product
```sql
SELECT 
    product_name,
    sale_month,
    revenue,
    units_sold,
    FIRST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY revenue DESC
    ) AS best_month_revenue,
    FIRST_VALUE(sale_month) OVER (
        PARTITION BY product_name 
        ORDER BY revenue DESC
    ) AS best_month_date,
    revenue - FIRST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY revenue DESC
    ) AS revenue_vs_best
FROM monthly_sales
ORDER BY product_name, sale_month;
```

**Expected Result:**
| product_name | sale_month | revenue  | units_sold | best_month_revenue | best_month_date | revenue_vs_best |
|--------------|------------|----------|------------|-------------------|-----------------|-----------------|
| Laptop Pro   | 2024-01-01 | 25000.00 | 100        | 30000.00          | 2024-04-01      | -5000.00        |
| Laptop Pro   | 2024-02-01 | 27500.00 | 110        | 30000.00          | 2024-04-01      | -2500.00        |
| Laptop Pro   | 2024-03-01 | 22000.00 | 88         | 30000.00          | 2024-04-01      | -8000.00        |
| Laptop Pro   | 2024-04-01 | 30000.00 | 120        | 30000.00          | 2024-04-01      | 0.00            |
| Office Chair | 2024-01-01 | 8000.00  | 200        | 10400.00          | 2024-04-01      | -2400.00        |
| Office Chair | 2024-02-01 | 9600.00  | 240        | 10400.00          | 2024-04-01      | -800.00         |
| Office Chair | 2024-03-01 | 7200.00  | 180        | 10400.00          | 2024-04-01      | -3200.00        |
| Office Chair | 2024-04-01 | 10400.00 | 260        | 10400.00          | 2024-04-01      | 0.00            |
| Tablet Air   | 2024-01-01 | 15000.00 | 200        | 20000.00          | 2024-04-01      | -5000.00        |
| Tablet Air   | 2024-02-01 | 18000.00 | 240        | 20000.00          | 2024-04-01      | -2000.00        |
| Tablet Air   | 2024-03-01 | 12000.00 | 160        | 20000.00          | 2024-04-01      | -8000.00        |
| Tablet Air   | 2024-04-01 | 20000.00 | 250        | 20000.00          | 2024-04-01      | 0.00            |

### Query 2: Employee performance vs department best
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    quarterly_performance,
    salary,
    FIRST_VALUE(quarterly_performance) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
    ) AS dept_best_performance,
    FIRST_VALUE(salary) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
    ) AS dept_best_performer_salary,
    quarterly_performance - FIRST_VALUE(quarterly_performance) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
    ) AS performance_gap
FROM employee_metrics
ORDER BY dept_id, quarterly_performance DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | quarterly_performance | salary   | dept_best_performance | dept_best_performer_salary | performance_gap |
|--------|------------|-----------|----------------------|----------|-----------------------|----------------------------|-----------------|
| 2      | Jane       | Smith     | 4.8                  | 80000.00 | 4.8                   | 80000.00                  | 0.0             |
| 1      | John       | Doe       | 4.5                  | 75000.00 | 4.8                   | 80000.00                  | -0.3            |
| 3      | Bob        | Wilson    | 3.9                  | 72000.00 | 4.8                   | 80000.00                  | -0.9            |
| 6      | Diana      | Evans     | 4.7                  | 72000.00 | 4.7                   | 72000.00                  | 0.0             |
| 5      | Charlie    | Davis     | 4.2                  | 75000.00 | 4.7                   | 72000.00                  | -0.5            |
| 4      | Alice      | Brown     | 4.2                  | 65000.00 | 4.7                   | 72000.00                  | -0.5            |
| 8      | Frank      | Garcia    | 4.3                  | 60000.00 | 4.3                   | 60000.00                  | 0.0             |
| 7      | Eve        | Foster    | 4.0                  | 55000.00 | 4.3                   | 60000.00                  | -0.3            |

### Query 3: Monthly trends using LAST_VALUE
```sql
SELECT 
    product_name,
    sale_month,
    revenue,
    LAST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_month_revenue,
    revenue - LAST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS vs_latest_month
FROM monthly_sales
ORDER BY product_name, sale_month;
```

**Expected Result:**
| product_name | sale_month | revenue  | latest_month_revenue | vs_latest_month |
|--------------|------------|----------|---------------------|-----------------|
| Laptop Pro   | 2024-01-01 | 25000.00 | 30000.00            | -5000.00        |
| Laptop Pro   | 2024-02-01 | 27500.00 | 30000.00            | -2500.00        |
| Laptop Pro   | 2024-03-01 | 22000.00 | 30000.00            | -8000.00        |
| Laptop Pro   | 2024-04-01 | 30000.00 | 30000.00            | 0.00            |
| Office Chair | 2024-01-01 | 8000.00  | 10400.00            | -2400.00        |
| Office Chair | 2024-02-01 | 9600.00  | 10400.00            | -800.00         |
| Office Chair | 2024-03-01 | 7200.00  | 10400.00            | -3200.00        |
| Office Chair | 2024-04-01 | 10400.00 | 10400.00            | 0.00            |
| Tablet Air   | 2024-01-01 | 15000.00 | 20000.00            | -5000.00        |
| Tablet Air   | 2024-02-01 | 18000.00 | 20000.00            | -2000.00        |
| Tablet Air   | 2024-03-01 | 12000.00 | 20000.00            | -8000.00        |
| Tablet Air   | 2024-04-01 | 20000.00 | 20000.00            | 0.00            |

### Query 4: Performance benchmarking with FIRST_VALUE and LAST_VALUE
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    quarterly_performance,
    salary,
    FIRST_VALUE(quarterly_performance) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
    ) AS dept_best_performance,
    LAST_VALUE(quarterly_performance) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_worst_performance,
    FIRST_VALUE(salary) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
    ) AS top_performer_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY dept_id 
        ORDER BY quarterly_performance DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_performer_salary
FROM employee_metrics
ORDER BY dept_id, quarterly_performance DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | quarterly_performance | salary   | dept_best_performance | dept_worst_performance | top_performer_salary | lowest_performer_salary |
|--------|------------|-----------|----------------------|----------|-----------------------|-----------------------|----------------------|-------------------------|
| 2      | Jane       | Smith     | 4.8                  | 80000.00 | 4.8                   | 3.9                   | 80000.00             | 72000.00                |
| 1      | John       | Doe       | 4.5                  | 75000.00 | 4.8                   | 3.9                   | 80000.00             | 72000.00                |
| 3      | Bob        | Wilson    | 3.9                  | 72000.00 | 4.8                   | 3.9                   | 80000.00             | 72000.00                |
| 6      | Diana      | Evans     | 4.7                  | 72000.00 | 4.7                   | 4.2                   | 72000.00             | 65000.00                |
| 5      | Charlie    | Davis     | 4.2                  | 75000.00 | 4.7                   | 4.2                   | 72000.00             | 65000.00                |
| 4      | Alice      | Brown     | 4.2                  | 65000.00 | 4.7                   | 4.2                   | 72000.00             | 65000.00                |
| 8      | Frank      | Garcia    | 4.3                  | 60000.00 | 4.3                   | 4.0                   | 60000.00             | 55000.00                |
| 7      | Eve        | Foster    | 4.0                  | 55000.00 | 4.3                   | 4.0                   | 60000.00             | 55000.00                |

### Query 5: Revenue analysis with window frame boundaries
```sql
SELECT 
    product_name,
    sale_month,
    revenue,
    FIRST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS first_month_revenue,
    LAST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS current_month_revenue,
    revenue - FIRST_VALUE(revenue) OVER (
        PARTITION BY product_name 
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS growth_from_first_month
FROM monthly_sales
ORDER BY product_name, sale_month;
```

**Expected Result:**
| product_name | sale_month | revenue  | first_month_revenue | current_month_revenue | growth_from_first_month |
|--------------|------------|----------|---------------------|-----------------------|-------------------------|
| Laptop Pro   | 2024-01-01 | 25000.00 | 25000.00            | 25000.00              | 0.00                    |
| Laptop Pro   | 2024-02-01 | 27500.00 | 25000.00            | 27500.00              | 2500.00                 |
| Laptop Pro   | 2024-03-01 | 22000.00 | 25000.00            | 22000.00              | -3000.00                |
| Laptop Pro   | 2024-04-01 | 30000.00 | 25000.00            | 30000.00              | 5000.00                 |
| Office Chair | 2024-01-01 | 8000.00  | 8000.00             | 8000.00               | 0.00                    |
| Office Chair | 2024-02-01 | 9600.00  | 8000.00             | 9600.00               | 1600.00                 |
| Office Chair | 2024-03-01 | 7200.00  | 8000.00             | 7200.00               | -800.00                 |
| Office Chair | 2024-04-01 | 10400.00 | 8000.00             | 10400.00              | 2400.00                 |
| Tablet Air   | 2024-01-01 | 15000.00 | 15000.00            | 15000.00              | 0.00                    |
| Tablet Air   | 2024-02-01 | 18000.00 | 15000.00            | 18000.00              | 3000.00                 |
| Tablet Air   | 2024-03-01 | 12000.00 | 15000.00            | 12000.00              | -3000.00                |
| Tablet Air   | 2024-04-01 | 20000.00 | 15000.00            | 20000.00              | 5000.00                 |

## Key Learning Points
- **FIRST_VALUE(column)**: Returns the first value in the window frame
- **LAST_VALUE(column)**: Returns the last value in the window frame
- **Window frames**: Define the range of rows for calculations
- **ROWS BETWEEN**: Specifies frame boundaries explicitly
- **Benchmarking**: Compare against best/worst performers
- **Trend analysis**: Compare with starting/ending values

## Common FIRST_VALUE/LAST_VALUE Applications
- **Benchmarking**: Compare against top/bottom performers
- **Trend analysis**: Growth from baseline periods
- **Quality control**: Compare against standards
- **Performance analysis**: Gap analysis vs. best practices
- **Time-series patterns**: Start/end period comparisons

## Performance Notes
- FIRST_VALUE/LAST_VALUE are efficient window functions
- Default frame is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- Use ROWS BETWEEN for precise frame control
- Can be expensive with large partitions

## Extension Challenge
Create a comprehensive sales performance dashboard that identifies products with declining performance (last month worse than first month) and suggests corrective actions based on the performance gaps.
