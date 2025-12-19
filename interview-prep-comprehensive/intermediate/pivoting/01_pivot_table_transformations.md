# Problem 01: PIVOT Table Transformations - Data Restructuring and Reporting

## Business Context
Data analysts and business intelligence professionals frequently need to transform row-based data into columnar formats for reporting, dashboard creation, and analytical modeling. PIVOT operations enable efficient data restructuring, making it easier to analyze trends, compare categories, and create summary reports across multiple dimensions.

## Requirements
Write SQL queries using PIVOT operations to transform data from row-based to columnar formats, enabling better analysis and reporting capabilities for business intelligence and data visualization.

## Sample Data Setup
```sql
-- Create tables for sales and inventory data
CREATE TABLE monthly_sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    sale_month DATE NOT NULL,
    quantity_sold INT NOT NULL,
    revenue DECIMAL(10, 2) NOT NULL
);

CREATE TABLE quarterly_inventory (
    inventory_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    warehouse VARCHAR(50) NOT NULL,
    quarter_date DATE NOT NULL,
    beginning_stock INT NOT NULL,
    ending_stock INT NOT NULL,
    stockouts INT DEFAULT 0
);

CREATE TABLE employee_performance (
    performance_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    quarter_date DATE NOT NULL,
    kpi_score DECIMAL(5, 2) NOT NULL,
    kpi_type VARCHAR(50) NOT NULL
);

CREATE TABLE regional_metrics (
    metric_id INT PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    metric_date DATE NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10, 2) NOT NULL
);

-- Insert sample data
INSERT INTO monthly_sales (sale_id, product_name, region, sale_month, quantity_sold, revenue) VALUES
(1, 'Laptop Pro', 'North', '2024-01-01', 50, 125000.00),
(2, 'Laptop Pro', 'North', '2024-02-01', 45, 112500.00),
(3, 'Laptop Pro', 'North', '2024-03-01', 60, 150000.00),
(4, 'Laptop Pro', 'South', '2024-01-01', 30, 75000.00),
(5, 'Laptop Pro', 'South', '2024-02-01', 35, 87500.00),
(6, 'Laptop Pro', 'South', '2024-03-01', 40, 100000.00),
(7, 'Wireless Mouse', 'North', '2024-01-01', 200, 10000.00),
(8, 'Wireless Mouse', 'North', '2024-02-01', 180, 9000.00),
(9, 'Wireless Mouse', 'North', '2024-03-01', 220, 11000.00),
(10, 'Wireless Mouse', 'South', '2024-01-01', 150, 7500.00),
(11, 'Wireless Mouse', 'South', '2024-02-01', 160, 8000.00),
(12, 'Wireless Mouse', 'South', '2024-03-01', 170, 8500.00);

INSERT INTO quarterly_inventory (inventory_id, product_name, warehouse, quarter_date, beginning_stock, ending_stock, stockouts) VALUES
(1, 'Laptop Pro', 'Main', '2024-01-01', 100, 80, 0),
(2, 'Laptop Pro', 'Main', '2024-04-01', 80, 65, 1),
(3, 'Laptop Pro', 'Regional', '2024-01-01', 50, 45, 0),
(4, 'Laptop Pro', 'Regional', '2024-04-01', 45, 40, 0),
(5, 'Wireless Mouse', 'Main', '2024-01-01', 500, 420, 0),
(6, 'Wireless Mouse', 'Main', '2024-04-01', 420, 380, 2),
(7, 'Wireless Mouse', 'Regional', '2024-01-01', 300, 280, 1),
(8, 'Wireless Mouse', 'Regional', '2024-04-01', 280, 250, 0);

INSERT INTO employee_performance (performance_id, employee_name, department, quarter_date, kpi_score, kpi_type) VALUES
(1, 'Alice Johnson', 'Sales', '2024-01-01', 4.5, 'Customer Satisfaction'),
(2, 'Alice Johnson', 'Sales', '2024-01-01', 4.2, 'Revenue Target'),
(3, 'Alice Johnson', 'Sales', '2024-01-01', 4.8, 'Lead Conversion'),
(4, 'Bob Smith', 'Sales', '2024-01-01', 4.3, 'Customer Satisfaction'),
(5, 'Bob Smith', 'Sales', '2024-01-01', 4.6, 'Revenue Target'),
(6, 'Bob Smith', 'Sales', '2024-01-01', 4.1, 'Lead Conversion'),
(7, 'Alice Johnson', 'Sales', '2024-04-01', 4.7, 'Customer Satisfaction'),
(8, 'Alice Johnson', 'Sales', '2024-04-01', 4.4, 'Revenue Target'),
(9, 'Alice Johnson', 'Sales', '2024-04-01', 4.9, 'Lead Conversion'),
(10, 'Bob Smith', 'Sales', '2024-04-01', 4.5, 'Customer Satisfaction'),
(11, 'Bob Smith', 'Sales', '2024-04-01', 4.8, 'Revenue Target'),
(12, 'Bob Smith', 'Sales', '2024-04-01', 4.3, 'Lead Conversion');

INSERT INTO regional_metrics (metric_id, region, metric_date, metric_name, metric_value) VALUES
(1, 'North', '2024-01-01', 'Market Share', 25.5),
(2, 'North', '2024-01-01', 'Customer Satisfaction', 4.2),
(3, 'North', '2024-01-01', 'Revenue Growth', 12.5),
(4, 'South', '2024-01-01', 'Market Share', 30.2),
(5, 'South', '2024-01-01', 'Customer Satisfaction', 4.5),
(6, 'South', '2024-01-01', 'Revenue Growth', 15.8),
(7, 'North', '2024-04-01', 'Market Share', 26.8),
(8, 'North', '2024-04-01', 'Customer Satisfaction', 4.4),
(9, 'North', '2024-04-01', 'Revenue Growth', 14.2),
(10, 'South', '2024-04-01', 'Market Share', 31.5),
(11, 'South', '2024-04-01', 'Customer Satisfaction', 4.7),
(12, 'South', '2024-04-01', 'Revenue Growth', 16.9);
```

## Query Requirements

### Query 1: Monthly sales pivot by product and region
```sql
-- PostgreSQL PIVOT equivalent using CASE and aggregation
SELECT 
    product_name,
    region,
    SUM(CASE WHEN EXTRACT(MONTH FROM sale_month) = 1 THEN revenue ELSE 0 END) AS jan_revenue,
    SUM(CASE WHEN EXTRACT(MONTH FROM sale_month) = 2 THEN revenue ELSE 0 END) AS feb_revenue,
    SUM(CASE WHEN EXTRACT(MONTH FROM sale_month) = 3 THEN revenue ELSE 0 END) AS mar_revenue,
    SUM(revenue) AS total_revenue
FROM monthly_sales
WHERE EXTRACT(YEAR FROM sale_month) = 2024
GROUP BY product_name, region
ORDER BY product_name, region;
```

**Expected Result:**
| product_name  | region | jan_revenue | feb_revenue | mar_revenue | total_revenue |
|---------------|--------|-------------|-------------|-------------|---------------|
| Laptop Pro    | North  | 125000.00   | 112500.00   | 150000.00   | 387500.00     |
| Laptop Pro    | South  | 75000.00    | 87500.00    | 100000.00   | 262500.00     |
| Wireless Mouse| North  | 10000.00    | 9000.00     | 11000.00    | 30000.00      |
| Wireless Mouse| South  | 7500.00     | 8000.00     | 8500.00     | 24000.00      |

### Query 2: Quarterly inventory status pivot
```sql
SELECT 
    product_name,
    warehouse,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 1 THEN beginning_stock ELSE 0 END) AS q1_beginning,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 1 THEN ending_stock ELSE 0 END) AS q1_ending,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 1 THEN stockouts ELSE 0 END) AS q1_stockouts,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 2 THEN beginning_stock ELSE 0 END) AS q2_beginning,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 2 THEN ending_stock ELSE 0 END) AS q2_ending,
    SUM(CASE WHEN EXTRACT(QUARTER FROM quarter_date) = 2 THEN stockouts ELSE 0 END) AS q2_stockouts
FROM quarterly_inventory
WHERE EXTRACT(YEAR FROM quarter_date) = 2024
GROUP BY product_name, warehouse
ORDER BY product_name, warehouse;
```

**Expected Result:**
| product_name   | warehouse | q1_beginning | q1_ending | q1_stockouts | q2_beginning | q2_ending | q2_stockouts |
|----------------|-----------|--------------|-----------|--------------|--------------|-----------|--------------|
| Laptop Pro     | Main      | 100          | 80        | 0            | 80           | 65        | 1            |
| Laptop Pro     | Regional  | 50           | 45        | 0            | 45           | 40        | 0            |
| Wireless Mouse | Main      | 500          | 420       | 0            | 420          | 380       | 2            |
| Wireless Mouse | Regional  | 300          | 280       | 1            | 280          | 250       | 0            |

### Query 3: Employee KPI performance matrix pivot
```sql
SELECT 
    employee_name,
    department,
    quarter_date,
    MAX(CASE WHEN kpi_type = 'Customer Satisfaction' THEN kpi_score END) AS customer_satisfaction,
    MAX(CASE WHEN kpi_type = 'Revenue Target' THEN kpi_score END) AS revenue_target,
    MAX(CASE WHEN kpi_type = 'Lead Conversion' THEN kpi_score END) AS lead_conversion,
    ROUND(AVG(kpi_score), 2) AS avg_kpi_score
FROM employee_performance
GROUP BY employee_name, department, quarter_date
ORDER BY employee_name, quarter_date;
```

**Expected Result:**
| employee_name  | department | quarter_date | customer_satisfaction | revenue_target | lead_conversion | avg_kpi_score |
|----------------|------------|--------------|-----------------------|----------------|-----------------|---------------|
| Alice Johnson  | Sales      | 2024-01-01   | 4.5                   | 4.2            | 4.8             | 4.50          |
| Alice Johnson  | Sales      | 2024-04-01   | 4.7                   | 4.4            | 4.9             | 4.67          |
| Bob Smith      | Sales      | 2024-01-01   | 4.3                   | 4.6            | 4.1             | 4.33          |
| Bob Smith      | Sales      | 2024-04-01   | 4.5                   | 4.8            | 4.3             | 4.53          |

### Query 4: Regional metrics dashboard pivot
```sql
SELECT 
    region,
    metric_date,
    MAX(CASE WHEN metric_name = 'Market Share' THEN metric_value END) AS market_share_pct,
    MAX(CASE WHEN metric_name = 'Customer Satisfaction' THEN metric_value END) AS customer_satisfaction,
    MAX(CASE WHEN metric_name = 'Revenue Growth' THEN metric_value END) AS revenue_growth_pct,
    COUNT(*) AS metrics_count
FROM regional_metrics
WHERE EXTRACT(YEAR FROM metric_date) = 2024
GROUP BY region, metric_date
ORDER BY region, metric_date;
```

**Expected Result:**
| region | metric_date | market_share_pct | customer_satisfaction | revenue_growth_pct | metrics_count |
|--------|-------------|------------------|-----------------------|---------------------|---------------|
| North  | 2024-01-01  | 25.5             | 4.2                   | 12.5                | 3             |
| North  | 2024-04-01  | 26.8             | 4.4                   | 14.2                | 3             |
| South  | 2024-01-01  | 30.2             | 4.5                   | 15.8                | 3             |
| South  | 2024-04-01  | 31.5             | 4.7                   | 16.9                | 3             |

### Query 5: Cross-tabulation sales and inventory analysis
```sql
WITH sales_summary AS (
    SELECT 
        product_name,
        region,
        SUM(quantity_sold) AS total_quantity,
        SUM(revenue) AS total_revenue
    FROM monthly_sales
    WHERE EXTRACT(YEAR FROM sale_month) = 2024
    GROUP BY product_name, region
),
inventory_summary AS (
    SELECT 
        product_name,
        warehouse,
        SUM(beginning_stock) AS total_beginning,
        SUM(ending_stock) AS total_ending,
        SUM(stockouts) AS total_stockouts
    FROM quarterly_inventory
    WHERE EXTRACT(YEAR FROM quarter_date) = 2024
    GROUP BY product_name, warehouse
)
SELECT 
    s.product_name,
    s.region,
    s.total_quantity AS sales_qty,
    s.total_revenue AS sales_revenue,
    i.warehouse,
    i.total_beginning AS inventory_beginning,
    i.total_ending AS inventory_ending,
    i.total_stockouts AS stockouts,
    ROUND(s.total_revenue / NULLIF(i.total_beginning, 0), 2) AS revenue_per_unit_inventory
FROM sales_summary s
FULL OUTER JOIN inventory_summary i ON s.product_name = i.product_name
ORDER BY s.product_name, s.region, i.warehouse;
```

**Expected Result:**
| product_name   | region | sales_qty | sales_revenue | warehouse | inventory_beginning | inventory_ending | stockouts | revenue_per_unit_inventory |
|----------------|--------|-----------|---------------|-----------|---------------------|------------------|-----------|----------------------------|
| Laptop Pro     | North  | 155       | 387500.00     | Main      | 100                 | 80               | 0         | 3875.00                    |
| Laptop Pro     | North  | 155       | 387500.00     | Regional  | 50                  | 45               | 0         | 7750.00                    |
| Laptop Pro     | South  | 105       | 262500.00     | Main      | 100                 | 80               | 0         | 2625.00                    |
| Laptop Pro     | South  | 105       | 262500.00     | Regional  | 50                  | 45               | 0         | 5250.00                    |
| Wireless Mouse | North  | 600       | 30000.00      | Main      | 500                 | 420              | 0         | 60.00                      |
| Wireless Mouse | North  | 600       | 30000.00      | Regional  | 300                 | 280              | 1         | 100.00                     |
| Wireless Mouse | South  | 480       | 24000.00      | Main      | 500                 | 420              | 0         | 48.00                      |
| Wireless Mouse | South  | 480       | 24000.00      | Regional  | 300                 | 280              | 1         | 80.00                      |

## Key Learning Points
- **PIVOT operations**: Transforming rows to columns for analysis
- **CASE statements**: Conditional aggregation for pivoting
- **Cross-tabulation**: Multi-dimensional data restructuring
- **Business intelligence**: Creating report-ready data formats
- **Performance considerations**: When to use PIVOT vs other approaches

## Common PIVOT Applications
- **Sales reporting**: Monthly/quarterly sales by product/region
- **Inventory analysis**: Stock levels across warehouses/time periods
- **Performance dashboards**: KPI matrices by employee/department
- **Financial reporting**: Budget vs actual comparisons
- **Trend analysis**: Time-series data restructuring

## Performance Notes
- CASE-based pivoting is efficient for most scenarios
- Consider pre-aggregated data for large datasets
- Use appropriate indexing on pivot columns
- Balance between readability and performance

## Extension Challenge
Create a comprehensive business intelligence dashboard that combines sales data, inventory levels, and performance metrics using advanced PIVOT operations to identify opportunities for inventory optimization, sales growth, and operational improvements.
