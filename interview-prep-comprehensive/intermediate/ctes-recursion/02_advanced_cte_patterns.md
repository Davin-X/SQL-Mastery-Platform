# Problem 02: Advanced CTE Patterns and Optimization

## Business Context
Advanced CTE usage involves multiple CTEs, complex data transformations, and performance optimization techniques. Organizations need to handle complex reporting requirements, data quality checks, and analytical queries that benefit from CTE modularity and reusability.

## Requirements
Write advanced SQL queries using multiple CTEs, recursive patterns, and optimization techniques to solve complex business problems involving data transformation, quality assurance, and analytical reporting.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending'
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    registration_date DATE NOT NULL,
    customer_segment VARCHAR(20) DEFAULT 'Standard'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    base_price DECIMAL(8, 2) NOT NULL,
    cost_price DECIMAL(8, 2) NOT NULL
);

-- Insert sample data
INSERT INTO customers (customer_id, customer_name, email, registration_date, customer_segment) VALUES
(1, 'Acme Corp', 'contact@acme.com', '2020-01-15', 'Enterprise'),
(2, 'TechStart Inc', 'info@techstart.com', '2021-03-20', 'Standard'),
(3, 'Global Solutions', 'sales@global.com', '2019-11-05', 'Enterprise'),
(4, 'SmallBiz LLC', 'hello@smallbiz.com', '2022-07-12', 'Standard'),
(5, 'MegaCorp', 'procurement@megacorp.com', '2018-09-30', 'Enterprise');

INSERT INTO products (product_id, product_name, category, base_price, cost_price) VALUES
(1, 'Laptop Pro', 'Electronics', 1200.00, 900.00),
(2, 'Wireless Mouse', 'Electronics', 25.00, 15.00),
(3, 'Office Chair', 'Furniture', 300.00, 150.00),
(4, 'Monitor 27"', 'Electronics', 400.00, 250.00),
(5, 'Keyboard', 'Electronics', 80.00, 40.00);

INSERT INTO sales_orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2024-01-15', 2450.00, 'Completed'),
(2, 2, '2024-01-20', 425.00, 'Completed'),
(3, 3, '2024-02-01', 1700.00, 'Completed'),
(4, 1, '2024-02-10', 800.00, 'Pending'),
(5, 4, '2024-02-15', 325.00, 'Completed'),
(6, 5, '2024-03-01', 3200.00, 'Completed'),
(7, 2, '2024-03-05', 1200.00, 'Shipped'),
(8, 3, '2024-03-10', 625.00, 'Completed');

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 2, 1200.00, 0.00),
(2, 1, 4, 1, 400.00, 50.00),
(3, 2, 2, 10, 25.00, 0.00),
(4, 2, 5, 5, 80.00, 0.00),
(5, 3, 1, 1, 1200.00, 0.00),
(6, 3, 3, 2, 300.00, 0.00),
(7, 3, 4, 1, 400.00, 0.00),
(8, 4, 3, 2, 300.00, 50.00),
(9, 5, 2, 5, 25.00, 0.00),
(10, 5, 5, 2, 80.00, 25.00),
(11, 6, 1, 2, 1200.00, 0.00),
(12, 6, 4, 2, 400.00, 0.00),
(13, 6, 3, 2, 300.00, 0.00),
(14, 7, 1, 1, 1200.00, 0.00),
(15, 8, 5, 5, 80.00, 0.00),
(16, 8, 2, 5, 25.00, 0.00);
```

## Query Requirements

### Query 1: Customer purchase analysis with multiple CTE layers
```sql
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        AVG(o.total_amount) AS avg_order_value,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN sales_orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.customer_segment
),
order_frequency AS (
    SELECT 
        *,
        CASE 
            WHEN total_orders = 0 THEN 'New Customer'
            WHEN total_orders = 1 THEN 'One-time Buyer'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Regular Customer'
            ELSE 'VIP Customer'
        END AS customer_category,
        DATEDIFF(CURRENT_DATE, last_order_date) AS days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        customer_segment,
        COUNT(*) AS customer_count,
        AVG(total_spent) AS avg_segment_spending,
        SUM(total_spent) AS total_segment_revenue,
        AVG(total_orders) AS avg_orders_per_customer
    FROM customer_orders
    WHERE total_orders > 0
    GROUP BY customer_segment
)
SELECT 
    co.customer_name,
    co.customer_segment,
    co.total_orders,
    co.total_spent,
    co.customer_category,
    co.days_since_last_order,
    sa.avg_segment_spending,
    ROUND((co.total_spent / NULLIF(sa.avg_segment_spending, 0)) * 100, 2) AS spending_vs_segment_avg
FROM customer_orders co
LEFT JOIN segment_analysis sa ON co.customer_segment = sa.customer_segment
ORDER BY co.total_spent DESC NULLS LAST;
```

**Expected Result:**
| customer_name  | customer_segment | total_orders | total_spent | customer_category | days_since_last_order | avg_segment_spending | spending_vs_segment_avg |
|----------------|------------------|--------------|-------------|-------------------|-----------------------|----------------------|-------------------------|
| MegaCorp       | Enterprise       | 1            | 3200.00     | One-time Buyer   | [current_days]       | 2450.00             | 130.61                  |
| Acme Corp      | Enterprise       | 1            | 2450.00     | One-time Buyer   | [current_days]       | 2450.00             | 100.00                  |
| Global Solutions| Enterprise      | 2            | 2325.00     | Regular Customer | [current_days]       | 2450.00             | 94.90                   |
| TechStart Inc  | Standard         | 2            | 1625.00     | Regular Customer | [current_days]       | 425.00              | 382.35                  |
| SmallBiz LLC   | Standard         | 1            | 325.00      | One-time Buyer   | [current_days]       | 425.00              | 76.47                   |

### Query 2: Product profitability analysis using CTEs
```sql
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.base_price,
        p.cost_price,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_revenue,
        SUM(oi.quantity * p.cost_price) AS total_cost
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN sales_orders so ON oi.order_id = so.order_id AND so.status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category, p.base_price, p.cost_price
),
profitability_metrics AS (
    SELECT 
        *,
        total_revenue - total_cost AS total_profit,
        ROUND((total_revenue - total_cost) / NULLIF(total_revenue, 0) * 100, 2) AS profit_margin,
        ROUND(total_revenue / NULLIF(total_quantity_sold, 0), 2) AS avg_selling_price,
        CASE 
            WHEN total_quantity_sold = 0 THEN 'No Sales'
            WHEN total_profit > 1000 THEN 'High Profit'
            WHEN total_profit > 0 THEN 'Moderate Profit'
            ELSE 'Low/No Profit'
        END AS profitability_category
    FROM product_sales
),
category_summary AS (
    SELECT 
        category,
        COUNT(*) AS products_in_category,
        SUM(total_revenue) AS category_revenue,
        SUM(total_profit) AS category_profit,
        AVG(profit_margin) AS avg_category_margin
    FROM profitability_metrics
    GROUP BY category
)
SELECT 
    pm.product_name,
    pm.category,
    pm.total_quantity_sold,
    pm.total_revenue,
    pm.total_profit,
    pm.profit_margin,
    pm.profitability_category,
    cs.avg_category_margin,
    ROUND(pm.profit_margin - cs.avg_category_margin, 2) AS margin_vs_category_avg
FROM profitability_metrics pm
LEFT JOIN category_summary cs ON pm.category = cs.category
ORDER BY pm.total_profit DESC NULLS LAST;
```

**Expected Result:**
| product_name | category   | total_quantity_sold | total_revenue | total_profit | profit_margin | profitability_category | avg_category_margin | margin_vs_category_avg |
|--------------|------------|---------------------|---------------|--------------|---------------|------------------------|---------------------|------------------------|
| Laptop Pro   | Electronics| 6                   | 7200.00       | 3600.00      | 50.00         | High Profit           | 50.00               | 0.00                   |
| Office Chair | Furniture  | 6                   | 1800.00       | 900.00       | 50.00         | Moderate Profit       | 50.00               | 0.00                   |
| Monitor 27"  | Electronics| 4                   | 1400.00       | 600.00       | 42.86         | Moderate Profit       | 50.00               | -7.14                  |
| Keyboard     | Electronics| 12                  | 700.00        | 200.00       | 28.57         | Low/No Profit         | 50.00               | -21.43                 |
| Wireless Mouse| Electronics| 20                  | 500.00        | 100.00       | 20.00         | Low/No Profit         | 50.00               | -30.00                 |

### Query 3: Order fulfillment analysis with CTE chains
```sql
WITH order_details AS (
    SELECT 
        o.order_id,
        o.customer_id,
        c.customer_name,
        o.order_date,
        o.total_amount,
        o.status,
        COUNT(oi.item_id) AS item_count,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS calculated_total
    FROM sales_orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, c.customer_name, o.order_date, o.total_amount, o.status
),
order_validation AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(total_amount - calculated_total) < 0.01 THEN 'Valid'
            ELSE 'Discrepancy'
        END AS amount_validation,
        CASE 
            WHEN status = 'Completed' AND order_date <= CURRENT_DATE THEN 'Fulfilled'
            WHEN status = 'Pending' THEN 'Pending'
            WHEN status = 'Shipped' THEN 'In Transit'
            ELSE 'Unknown'
        END AS fulfillment_status,
        EXTRACT(EPOCH FROM (CURRENT_DATE - order_date))/86400 AS days_since_order
    FROM order_details
),
customer_order_history AS (
    SELECT 
        customer_id,
        customer_name,
        COUNT(*) AS total_orders,
        AVG(total_amount) AS avg_order_value,
        MAX(order_date) AS last_order_date,
        SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders
    FROM sales_orders
    INNER JOIN customers USING (customer_id)
    GROUP BY customer_id, customer_name
)
SELECT 
    ov.order_id,
    ov.customer_name,
    ov.order_date,
    ov.total_amount,
    ov.item_count,
    ov.fulfillment_status,
    ov.amount_validation,
    ROUND(ov.days_since_order, 0) AS days_since_order,
    coh.total_orders,
    coh.avg_order_value,
    ROUND((ov.total_amount / NULLIF(coh.avg_order_value, 0)) * 100, 2) AS order_size_vs_customer_avg
FROM order_validation ov
LEFT JOIN customer_order_history coh ON ov.customer_id = coh.customer_id
ORDER BY ov.order_date DESC, ov.total_amount DESC;
```

**Expected Result:**
| order_id | customer_name   | order_date | total_amount | item_count | fulfillment_status | amount_validation | days_since_order | total_orders | avg_order_value | order_size_vs_customer_avg |
|----------|-----------------|------------|--------------|------------|-------------------|------------------|------------------|--------------|-----------------|----------------------------|
| 8        | Global Solutions| 2024-03-10 | 625.00       | 2          | Fulfilled         | Valid            | [days]          | 2            | 1162.50         | 53.76                      |
| 7        | TechStart Inc  | 2024-03-05 | 1200.00      | 1          | In Transit        | Valid            | [days]          | 2            | 812.50          | 147.69                     |
| 6        | MegaCorp       | 2024-03-01 | 3200.00      | 3          | Fulfilled         | Valid            | [days]          | 1            | 3200.00         | 100.00                     |
| 5        | SmallBiz LLC   | 2024-02-15 | 325.00       | 2          | Fulfilled         | Valid            | [days]          | 1            | 325.00          | 100.00                     |
| 4        | Acme Corp      | 2024-02-10 | 800.00       | 1          | Pending           | Valid            | [days]          | 2            | 1625.00         | 49.23                      |
| 3        | Global Solutions| 2024-02-01 | 1700.00      | 3          | Fulfilled         | Valid            | [days]          | 2            | 1162.50         | 146.15                     |
| 2        | TechStart Inc  | 2024-01-20 | 425.00       | 2          | Fulfilled         | Valid            | [days]          | 2            | 812.50          | 52.31                      |
| 1        | Acme Corp      | 2024-01-15 | 2450.00      | 2          | Fulfilled         | Valid            | [days]          | 2            | 1625.00         | 150.77                     |

### Query 4: Recursive CTE for organizational hierarchy with performance metrics
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level managers (no manager)
    SELECT 
        emp_id,
        first_name || ' ' || last_name AS full_name,
        salary,
        dept_id,
        0 AS hierarchy_level,
        ARRAY[emp_id] AS path_to_root,
        salary AS max_salary_in_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT 
        e.emp_id,
        e.first_name || ' ' || e.last_name,
        e.salary,
        e.dept_id,
        eh.hierarchy_level + 1,
        eh.path_to_root || e.emp_id,
        GREATEST(eh.max_salary_in_path, e.salary)
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
),
hierarchy_stats AS (
    SELECT 
        dept_id,
        hierarchy_level,
        COUNT(*) AS employees_at_level,
        AVG(salary) AS avg_salary_at_level,
        MAX(salary) AS max_salary_at_level,
        MIN(salary) AS min_salary_at_level
    FROM employee_hierarchy
    GROUP BY dept_id, hierarchy_level
)
SELECT 
    eh.full_name,
    eh.salary,
    eh.hierarchy_level,
    d.dept_name,
    hs.employees_at_level,
    ROUND(hs.avg_salary_at_level, 2) AS dept_level_avg_salary,
    eh.salary - hs.avg_salary_at_level AS salary_vs_level_avg,
    CASE 
        WHEN eh.salary > hs.avg_salary_at_level THEN 'Above Average'
        WHEN eh.salary < hs.avg_salary_at_level THEN 'Below Average'
        ELSE 'At Average'
    END AS salary_performance
FROM employee_hierarchy eh
INNER JOIN departments d ON eh.dept_id = d.dept_id
LEFT JOIN hierarchy_stats hs ON eh.dept_id = hs.dept_id AND eh.hierarchy_level = hs.hierarchy_level
ORDER BY eh.dept_id, eh.hierarchy_level, eh.salary DESC;
```

**Expected Result:**
| full_name     | salary   | hierarchy_level | dept_name | employees_at_level | dept_level_avg_salary | salary_vs_level_avg | salary_performance |
|---------------|----------|-----------------|-----------|-------------------|----------------------|--------------------|-------------------|
| John Doe      | 75000.00 | 0               | IT        | 1                 | 75000.00             | 0.00               | At Average        |
| Alice Brown   | 65000.00 | 0               | Sales     | 1                 | 65000.00             | 0.00               | At Average        |
| Eve Foster    | 55000.00 | 0               | HR        | 1                 | 55000.00             | 0.00               | At Average        |
| Grace Hill    | 85000.00 | 0               | Finance   | 1                 | 85000.00             | 0.00               | At Average        |
| Jane Smith    | 80000.00 | 1               | IT        | 2                 | 75666.67             | 4333.33             | Above Average     |
| Bob Wilson    | 72000.00 | 1               | IT        | 2                 | 75666.67             | -3666.67            | Below Average     |
| Charlie Davis | 75000.00 | 1               | Sales     | 2                 | 73500.00             | 1500.00             | Above Average     |
| Diana Evans   | 72000.00 | 1               | Sales     | 2                 | 73500.00             | -1500.00            | Below Average     |
| Frank Garcia  | 60000.00 | 1               | HR        | 1                 | 60000.00             | 0.00               | At Average        |
| Henry Adams   | 78000.00 | 1               | Finance   | 1                 | 78000.00             | 0.00               | At Average        |

## Key Learning Points
- **Multiple CTEs**: Complex query organization with interdependent CTEs
- **Recursive CTEs**: Handling hierarchical data with UNION ALL
- **CTE chaining**: Building complex transformations step by step
- **Performance optimization**: Breaking down complex queries
- **Data validation**: Using CTEs for quality assurance
- **Analytical queries**: Advanced reporting with CTEs

## Common Advanced CTE Patterns
- **Data quality checks**: Validation and cleansing
- **Complex aggregations**: Multi-step calculations
- **Recursive hierarchies**: Organizational charts, BOM
- **Incremental processing**: Step-by-step transformations
- **Performance optimization**: Query decomposition

## Performance Notes
- CTEs are optimized as part of the main query
- Recursive CTEs can be expensive with deep hierarchies
- Consider materialized CTEs for complex recursive queries
- Monitor execution plans for CTE performance

## Extension Challenge
Create a comprehensive business intelligence dashboard using multiple CTEs to analyze sales trends, customer segmentation, product profitability, and operational efficiency metrics across multiple dimensions.
