# Comprehensive Business Case: E-commerce Business Intelligence Dashboard

## Business Context
As a senior data analyst at TechCommerce Inc., you've been tasked with creating a comprehensive business intelligence dashboard for the executive team. The dashboard must combine data from multiple systems to provide actionable insights across customer behavior, product performance, sales trends, and operational efficiency.

This comprehensive case requires integrating concepts from all SQL topics covered in this platform: JOINs, aggregations, window functions, CTEs, subqueries, set operations, and complex analytical patterns.

## Business Requirements
Create a comprehensive BI dashboard that answers these key business questions:
1. Customer lifetime value and segmentation analysis
2. Product performance and profitability trends
3. Sales team performance and territory analysis
4. Inventory optimization and supply chain efficiency
5. Executive summary with key performance indicators

## Database Schema
```sql
-- Customer and sales data
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(20) DEFAULT 'Standard',
    signup_date DATE NOT NULL,
    credit_limit DECIMAL(10, 2)
);

CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Completed',
    payment_terms VARCHAR(50)
);

CREATE TABLE order_details (
    detail_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0
);

-- Product and inventory data
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    base_price DECIMAL(8, 2) NOT NULL,
    cost_price DECIMAL(8, 2) NOT NULL,
    discontinued BOOLEAN DEFAULT FALSE
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    warehouse_location VARCHAR(50),
    quantity_on_hand INT DEFAULT 0,
    reorder_point INT DEFAULT 10,
    last_inventory_date DATE
);

-- Employee and organizational data
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    manager_id INT,
    hire_date DATE
);

-- Supplier and procurement data
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    reliability_rating DECIMAL(3, 1)
);

CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supplier_cost DECIMAL(8, 2),
    lead_time_days INT,
    PRIMARY KEY (product_id, supplier_id)
);

-- Insert comprehensive test data
INSERT INTO customers VALUES
(1, 'TechCorp Inc', 'North', 'Enterprise', '2020-01-15', 100000.00),
(2, 'DataSys LLC', 'South', 'Standard', '2021-03-20', 50000.00),
(3, 'WebFlow Corp', 'East', 'Enterprise', '2019-11-05', 150000.00),
(4, 'CloudNet Inc', 'West', 'Standard', '2022-07-12', 75000.00),
(5, 'MegaCorp Ltd', 'North', 'Enterprise', '2018-09-30', 200000.00);

INSERT INTO employees VALUES
(1, 'Alice', 'Johnson', 'Sales', 120000.00, NULL, '2018-01-15'),
(2, 'Bob', 'Smith', 'Sales', 80000.00, 1, '2019-03-20'),
(3, 'Carol', 'Davis', 'Sales', 75000.00, 1, '2020-06-10'),
(4, 'David', 'Wilson', 'Sales', 65000.00, 2, '2021-09-15'),
(5, 'Eve', 'Brown', 'Operations', 90000.00, NULL, '2017-11-20');

INSERT INTO products VALUES
(1, 'Laptop Pro 15"', 'Hardware', 2000.00, 1500.00, FALSE),
(2, 'Wireless Keyboard', 'Hardware', 120.00, 80.00, FALSE),
(3, 'Cloud Storage Pro', 'Software', 50.00, 10.00, FALSE),
(4, 'Monitor 27" 4K', 'Hardware', 600.00, 400.00, FALSE),
(5, 'Consulting Services', 'Services', 300.00, 150.00, FALSE);

INSERT INTO suppliers VALUES
(1, 'TechSupply Inc', 4.5),
(2, 'GlobalParts Ltd', 4.2),
(3, 'ServicePro Inc', 4.8);

INSERT INTO product_suppliers VALUES
(1, 1, 1400.00, 7),
(1, 2, 1450.00, 10),
(2, 1, 75.00, 3),
(3, 3, 8.00, 1),
(4, 2, 380.00, 5),
(5, 3, 140.00, 2);

INSERT INTO inventory VALUES
(1, 'Main Warehouse', 25, 10, '2024-01-15'),
(2, 'Main Warehouse', 150, 50, '2024-01-15'),
(3, 'Cloud Services', 999, 100, '2024-01-15'),
(4, 'Main Warehouse', 12, 8, '2024-01-15'),
(5, 'Service Center', 50, 10, '2024-01-15');

INSERT INTO sales_orders VALUES
(1, 1, 2, '2024-01-15', 2120.00, 'Completed', 'Net 30'),
(2, 2, 3, '2024-01-20', 170.00, 'Completed', 'Net 15'),
(3, 3, 4, '2024-02-01', 702.00, 'Completed', 'Net 30'),
(4, 1, 2, '2024-02-10', 300.00, 'Completed', 'Net 30'),
(5, 4, 3, '2024-02-15', 120.00, 'Shipped', 'Net 15'),
(6, 5, 5, '2024-03-01', 2000.00, 'Completed', 'Net 45');

INSERT INTO order_details VALUES
(1, 1, 1, 1, 2000.00, 0.00),
(2, 1, 2, 1, 120.00, 0.00),
(3, 2, 3, 2, 50.00, 30.00),
(4, 2, 2, 1, 120.00, 10.00),
(5, 3, 4, 1, 600.00, 0.00),
(6, 3, 2, 1, 120.00, 15.00),
(7, 4, 5, 1, 300.00, 0.00),
(8, 5, 2, 1, 120.00, 0.00),
(9, 6, 1, 1, 2000.00, 0.00);
```

## Dashboard Components

### 1. Customer Lifetime Value Analysis
```sql
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.region,
        c.customer_segment,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value,
        MAX(o.order_date) AS last_order_date,
        MIN(o.order_date) AS first_order_date,
        EXTRACT(EPOCH FROM (MAX(o.order_date) - MIN(o.order_date)))/86400 AS customer_lifespan_days
    FROM customers c
    LEFT JOIN sales_orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name, c.region, c.customer_segment
),
customer_value_metrics AS (
    SELECT 
        *,
        CASE 
            WHEN total_orders = 0 THEN 'New Customer'
            WHEN total_orders = 1 THEN 'One-time Buyer'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Regular Customer'
            ELSE 'VIP Customer'
        END AS customer_category,
        total_revenue / NULLIF(total_orders, 0) AS avg_order_value_calc,
        CASE 
            WHEN customer_lifespan_days > 365 THEN total_revenue / (customer_lifespan_days / 365.0)
            ELSE total_revenue
        END AS annual_customer_value
    FROM customer_orders
)
SELECT 
    customer_name,
    region,
    customer_segment,
    customer_category,
    total_orders,
    total_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(annual_customer_value, 2) AS annual_customer_value,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_value_metrics
ORDER BY total_revenue DESC;
```

### 2. Product Performance and Profitability
```sql
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(od.quantity) AS total_quantity_sold,
        SUM(od.quantity * od.unit_price * (1 - od.discount/100)) AS total_revenue,
        SUM(od.quantity * p.cost_price) AS total_cost,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM products p
    LEFT JOIN order_details od ON p.product_id = od.product_id
    LEFT JOIN sales_orders o ON od.order_id = o.order_id AND o.status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category
),
product_profitability AS (
    SELECT 
        *,
        total_revenue - total_cost AS gross_profit,
        ROUND((total_revenue - total_cost) / NULLIF(total_revenue, 0) * 100, 2) AS profit_margin,
        ROUND(total_revenue / NULLIF(total_quantity_sold, 0), 2) AS avg_selling_price,
        ROUND(total_quantity_sold / NULLIF(total_orders, 0), 2) AS avg_quantity_per_order
    FROM product_sales
),
product_inventory AS (
    SELECT 
        p.product_id,
        i.quantity_on_hand,
        i.reorder_point,
        CASE 
            WHEN i.quantity_on_hand <= i.reorder_point THEN 'Reorder Needed'
            WHEN i.quantity_on_hand <= i.reorder_point * 1.5 THEN 'Low Stock'
            ELSE 'Adequate Stock'
        END AS stock_status
    FROM products p
    LEFT JOIN inventory i ON p.product_id = i.product_id
)
SELECT 
    pp.product_name,
    pp.category,
    pp.total_quantity_sold,
    pp.total_revenue,
    pp.gross_profit,
    pp.profit_margin,
    pp.avg_selling_price,
    pi.stock_status,
    RANK() OVER (ORDER BY pp.gross_profit DESC) AS profitability_rank
FROM product_profitability pp
LEFT JOIN product_inventory pi ON pp.product_id = pi.product_id
ORDER BY pp.gross_profit DESC;
```

### 3. Sales Team Performance Dashboard
```sql
WITH salesperson_performance AS (
    SELECT 
        e.emp_id,
        e.first_name || ' ' || e.last_name AS salesperson_name,
        e.department,
        COUNT(o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        SUM(o.total_amount) AS total_sales,
        AVG(o.total_amount) AS avg_order_size,
        SUM(od.quantity) AS total_units_sold,
        COUNT(DISTINCT od.product_id) AS products_sold
    FROM employees e
    LEFT JOIN sales_orders o ON e.emp_id = o.salesperson_id AND o.status = 'Completed'
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE e.department = 'Sales'
    GROUP BY e.emp_id, e.first_name, e.last_name, e.department
),
sales_ranking AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
        RANK() OVER (ORDER BY total_units_sold DESC) AS volume_rank,
        RANK() OVER (ORDER BY avg_order_size DESC) AS order_value_rank
    FROM salesperson_performance
)
SELECT 
    salesperson_name,
    total_orders,
    unique_customers,
    total_sales,
    avg_order_size,
    total_units_sold,
    products_sold,
    sales_rank,
    CASE 
        WHEN sales_rank <= 2 THEN 'Top Performer'
        WHEN sales_rank <= 4 THEN 'High Performer'
        ELSE 'Standard Performer'
    END AS performance_tier
FROM sales_ranking
ORDER BY total_sales DESC;
```

### 4. Inventory and Supply Chain Analysis
```sql
WITH inventory_status AS (
    SELECT 
        p.product_id,
        p.product_name,
        i.quantity_on_hand,
        i.reorder_point,
        i.quantity_on_hand - i.reorder_point AS available_buffer,
        CASE 
            WHEN i.quantity_on_hand <= i.reorder_point THEN 'Critical'
            WHEN i.quantity_on_hand <= i.reorder_point * 1.2 THEN 'Warning'
            WHEN i.quantity_on_hand <= i.reorder_point * 1.5 THEN 'Monitor'
            ELSE 'Good'
        END AS inventory_status
    FROM products p
    LEFT JOIN inventory i ON p.product_id = i.product_id
),
supplier_options AS (
    SELECT 
        ps.product_id,
        COUNT(*) AS supplier_count,
        MIN(ps.supplier_cost) AS best_cost,
        MIN(ps.lead_time_days) AS fastest_delivery,
        AVG(s.reliability_rating) AS avg_supplier_rating
    FROM product_suppliers ps
    INNER JOIN suppliers s ON ps.supplier_id = s.supplier_id
    GROUP BY ps.product_id
)
SELECT 
    i.product_name,
    i.quantity_on_hand,
    i.reorder_point,
    i.available_buffer,
    i.inventory_status,
    s.supplier_count,
    s.best_cost,
    s.fastest_delivery,
    ROUND(s.avg_supplier_rating, 1) AS avg_supplier_rating,
    CASE 
        WHEN i.inventory_status = 'Critical' THEN 'Immediate Action Required'
        WHEN i.inventory_status = 'Warning' THEN 'Plan Reorder'
        WHEN i.inventory_status = 'Monitor' THEN 'Monitor Closely'
        ELSE 'No Action Needed'
    END AS recommended_action
FROM inventory_status i
LEFT JOIN supplier_options s ON i.product_id = s.product_id
ORDER BY 
    CASE i.inventory_status 
        WHEN 'Critical' THEN 1
        WHEN 'Warning' THEN 2
        WHEN 'Monitor' THEN 3
        ELSE 4
    END,
    i.product_name;
```

### 5. Executive Summary KPIs
```sql
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sale_month,
        COUNT(*) AS orders_count,
        SUM(total_amount) AS monthly_revenue,
        AVG(total_amount) AS avg_order_value,
        COUNT(DISTINCT customer_id) AS unique_customers
    FROM sales_orders
    WHERE status = 'Completed' AND EXTRACT(YEAR FROM order_date) = 2024
    GROUP BY DATE_TRUNC('month', order_date)
),
sales_trends AS (
    SELECT 
        *,
        LAG(monthly_revenue) OVER (ORDER BY sale_month) AS prev_month_revenue,
        monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month) AS revenue_growth,
        ROUND(
            (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month)) / 
            NULLIF(LAG(monthly_revenue) OVER (ORDER BY sale_month), 0) * 100, 2
        ) AS growth_percentage
    FROM monthly_sales
),
customer_summary AS (
    SELECT 
        COUNT(*) AS total_customers,
        COUNT(CASE WHEN customer_segment = 'Enterprise' THEN 1 END) AS enterprise_customers,
        COUNT(CASE WHEN customer_segment = 'Standard' THEN 1 END) AS standard_customers,
        AVG(credit_limit) AS avg_credit_limit
    FROM customers
),
product_summary AS (
    SELECT 
        COUNT(*) AS total_products,
        COUNT(CASE WHEN discontinued = FALSE THEN 1 END) AS active_products,
        AVG(base_price) AS avg_product_price,
        SUM(quantity_on_hand) AS total_inventory_value
    FROM products p
    LEFT JOIN inventory i ON p.product_id = i.product_id
)
SELECT 
    'EXECUTIVE SUMMARY' AS report_section,
    cs.total_customers AS total_customers,
    ROUND(cs.avg_credit_limit, 2) AS avg_customer_credit_limit,
    ps.total_products AS total_products,
    ps.active_products AS active_products,
    st.monthly_revenue AS latest_month_revenue,
    st.revenue_growth AS last_month_growth,
    st.growth_percentage AS growth_percentage,
    st.orders_count AS latest_month_orders,
    st.unique_customers AS latest_month_customers
FROM customer_summary cs
CROSS JOIN product_summary ps
CROSS JOIN (
    SELECT * FROM sales_trends 
    WHERE sale_month = (SELECT MAX(sale_month) FROM sales_trends)
) st;
```

## Key Learning Points
- **Complex multi-table JOINs**: 5-6 table combinations with business logic
- **Advanced CTEs**: Multi-step data transformations and aggregations
- **Window functions**: Ranking, trend analysis, and comparative metrics
- **Subqueries and derived tables**: Complex filtering and calculations
- **Set operations**: Combining multiple analytical queries
- **Business intelligence**: Creating executive dashboards with KPIs

## Business Insights Derived
1. **Customer Segmentation**: Identify high-value customers and buying patterns
2. **Product Performance**: Profitability analysis and inventory optimization
3. **Sales Effectiveness**: Team performance and territory analysis
4. **Operational Efficiency**: Supply chain and inventory management
5. **Executive KPIs**: High-level business metrics and trends

## Performance Considerations
- Complex queries may require query optimization
- Consider indexing on frequently joined columns
- Use EXPLAIN to analyze execution plans
- Consider materialized views for frequently accessed dashboards

## Extension Challenge
Add time-series forecasting, customer churn prediction, and automated alerting based on KPI thresholds to create a fully automated business intelligence system.
