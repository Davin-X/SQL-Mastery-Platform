# Problem 01: Multi-Table Analytics with Complex JOINs

## Business Context
Advanced SQL queries often require joining 4-6+ tables to solve complex business intelligence problems. Organizations need sophisticated analytics that combine customer data, product information, sales transactions, inventory levels, and operational metrics to make data-driven decisions. These complex queries test the ability to understand database relationships and optimize query performance.

## Requirements
Write complex SQL queries using multiple JOINs (4-6+ tables) to solve advanced business analytics problems involving customer behavior analysis, product performance, operational efficiency, and cross-functional reporting.

## Sample Data Setup
```sql
-- Create comprehensive business database
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    region VARCHAR(50),
    customer_segment VARCHAR(20) DEFAULT 'Standard',
    credit_limit DECIMAL(12, 2),
    account_manager_id INT
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    manager_id INT,
    hire_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    base_price DECIMAL(8, 2) NOT NULL,
    cost_price DECIMAL(8, 2) NOT NULL,
    discontinued BOOLEAN DEFAULT FALSE
);

CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    payment_terms VARCHAR(50)
);

CREATE TABLE order_details (
    detail_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    line_total DECIMAL(10, 2)
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    warehouse_location VARCHAR(100),
    quantity_on_hand INT DEFAULT 0,
    reorder_point INT DEFAULT 10,
    safety_stock INT DEFAULT 5,
    last_inventory_date DATE
);

CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE,
    verified_purchase BOOLEAN DEFAULT FALSE
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    payment_terms VARCHAR(50),
    reliability_rating DECIMAL(3, 1)
);

CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supplier_cost DECIMAL(8, 2),
    lead_time_days INT,
    minimum_order_qty INT,
    is_preferred BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (product_id, supplier_id)
);

-- Insert comprehensive test data
INSERT INTO customers (customer_id, company_name, industry, region, customer_segment, credit_limit, account_manager_id) VALUES
(1, 'TechCorp Inc', 'Technology', 'North', 'Enterprise', 100000.00, 1),
(2, 'DataSys LLC', 'Technology', 'South', 'Standard', 50000.00, 2),
(3, 'Global Solutions', 'Consulting', 'East', 'Enterprise', 150000.00, 3),
(4, 'InnovateIT', 'Technology', 'West', 'Standard', 75000.00, 4),
(5, 'MegaCorp', 'Manufacturing', 'North', 'Enterprise', 200000.00, 1);

INSERT INTO employees (emp_id, first_name, last_name, title, department, salary, manager_id, hire_date) VALUES
(1, 'Alice', 'Johnson', 'VP Sales', 'Sales', 120000.00, NULL, '2018-01-15'),
(2, 'Bob', 'Smith', 'Senior Sales Rep', 'Sales', 80000.00, 1, '2019-03-20'),
(3, 'Carol', 'Davis', 'Account Manager', 'Sales', 75000.00, 1, '2020-06-10'),
(4, 'David', 'Wilson', 'Sales Associate', 'Sales', 65000.00, 2, '2021-09-15'),
(5, 'Eve', 'Brown', 'Sales Manager', 'Sales', 90000.00, 1, '2017-11-20');

INSERT INTO products (product_id, product_name, category, subcategory, base_price, cost_price) VALUES
(1, 'Laptop Pro 15"', 'Hardware', 'Laptops', 2000.00, 1500.00),
(2, 'Wireless Keyboard', 'Hardware', 'Peripherals', 120.00, 80.00),
(3, 'Cloud Storage Pro', 'Software', 'SaaS', 50.00, 10.00),
(4, 'Monitor 27" 4K', 'Hardware', 'Displays', 600.00, 400.00),
(5, 'Consulting Services', 'Services', 'Professional', 300.00, 150.00);

INSERT INTO sales_orders (order_id, customer_id, salesperson_id, order_date, ship_date, total_amount, status, payment_terms) VALUES
(1, 1, 2, '2024-01-15', '2024-01-18', 2120.00, 'Completed', 'Net 30'),
(2, 2, 3, '2024-01-20', '2024-01-22', 170.00, 'Completed', 'Net 15'),
(3, 3, 4, '2024-02-01', '2024-02-05', 650.00, 'Completed', 'Net 30'),
(4, 1, 2, '2024-02-10', '2024-02-12', 300.00, 'Completed', 'Net 30'),
(5, 4, 3, '2024-02-15', NULL, 120.00, 'Shipped', 'Net 15'),
(6, 5, 5, '2024-03-01', '2024-03-03', 2000.00, 'Completed', 'Net 45');

INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price, discount, line_total) VALUES
(1, 1, 1, 1, 2000.00, 0.00, 2000.00),
(2, 1, 2, 1, 120.00, 0.00, 120.00),
(3, 2, 3, 2, 50.00, 30.00, 70.00),
(4, 2, 2, 1, 120.00, 10.00, 108.00),
(5, 3, 4, 1, 600.00, 0.00, 600.00),
(6, 3, 2, 1, 120.00, 15.00, 102.00),
(7, 4, 5, 1, 300.00, 0.00, 300.00),
(8, 5, 2, 1, 120.00, 0.00, 120.00),
(9, 6, 1, 1, 2000.00, 0.00, 2000.00);

INSERT INTO inventory (product_id, warehouse_location, quantity_on_hand, reorder_point, safety_stock, last_inventory_date) VALUES
(1, 'Main Warehouse', 25, 10, 5, '2024-01-15'),
(2, 'Main Warehouse', 150, 50, 20, '2024-01-15'),
(3, 'Cloud Services', 999, 100, 50, '2024-01-15'),
(4, 'Main Warehouse', 12, 8, 3, '2024-01-15'),
(5, 'Service Center', 50, 10, 5, '2024-01-15');

INSERT INTO product_reviews (review_id, customer_id, product_id, order_id, rating, review_text, review_date, verified_purchase) VALUES
(1, 1, 1, 1, 5, 'Excellent performance and build quality', '2024-01-20', TRUE),
(2, 2, 3, 2, 4, 'Good value for cloud storage', '2024-01-25', TRUE),
(3, 3, 4, 3, 5, 'Perfect display quality', '2024-02-08', TRUE),
(4, 1, 5, 4, 4, 'Professional consulting service', '2024-02-15', TRUE),
(5, 4, 2, 5, 3, 'Decent keyboard, met expectations', '2024-02-20', TRUE);

INSERT INTO suppliers (supplier_id, supplier_name, contact_email, payment_terms, reliability_rating) VALUES
(1, 'TechSupply Inc', 'orders@techsupply.com', 'Net 30', 4.5),
(2, 'GlobalParts Ltd', 'procurement@globalparts.com', 'Net 45', 4.2),
(3, 'ServicePro', 'contracts@servicepro.com', 'Net 15', 4.8);

INSERT INTO product_suppliers (product_id, supplier_id, supplier_cost, lead_time_days, minimum_order_qty, is_preferred) VALUES
(1, 1, 1400.00, 7, 5, TRUE),
(1, 2, 1450.00, 10, 3, FALSE),
(2, 1, 75.00, 3, 10, TRUE),
(3, 3, 8.00, 1, 100, TRUE),
(4, 2, 380.00, 5, 2, TRUE),
(5, 3, 140.00, 2, 1, TRUE);
```

## Query Requirements

### Query 1: Comprehensive customer order analysis (6-table JOIN)
```sql
SELECT 
    c.company_name,
    c.industry,
    c.region,
    c.customer_segment,
    e.first_name || ' ' || e.last_name AS account_manager,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(od.quantity) AS total_units_purchased,
    COUNT(DISTINCT od.product_id) AS unique_products_bought,
    MAX(o.order_date) AS last_order_date,
    AVG(pr.rating) AS avg_product_rating
FROM customers c
INNER JOIN employees e ON c.account_manager_id = e.emp_id
LEFT JOIN sales_orders o ON c.customer_id = o.customer_id AND o.status = 'Completed'
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN products p ON od.product_id = p.product_id
LEFT JOIN product_reviews pr ON c.customer_id = pr.customer_id AND od.product_id = pr.product_id
GROUP BY c.customer_id, c.company_name, c.industry, c.region, c.customer_segment, e.first_name, e.last_name
ORDER BY total_revenue DESC NULLS LAST;
```

**Expected Result:**
| company_name  | industry    | region | customer_segment | account_manager | total_orders | total_revenue | avg_order_value | total_units_purchased | unique_products_bought | last_order_date | avg_product_rating |
|---------------|-------------|--------|------------------|-----------------|--------------|---------------|-----------------|----------------------|-----------------------|-----------------|-------------------|
| TechCorp Inc  | Technology | North  | Enterprise       | Alice Johnson  | 2            | 2420.00       | 1210.00         | 3                    | 3                     | 2024-02-10      | 4.5               |
| MegaCorp      | Manufacturing| North | Enterprise      | Alice Johnson  | 1            | 2000.00       | 2000.00         | 1                    | 1                     | 2024-03-01      |                   |
| Global Solutions| Consulting| East  | Enterprise      | Carol Davis    | 1            | 702.00        | 702.00          | 2                    | 2                     | 2024-02-01      | 5.0               |
| DataSys LLC   | Technology | South  | Standard        | Bob Smith      | 1            | 178.00        | 178.00          | 3                    | 2                     | 2024-01-20      | 4.0               |
| InnovateIT    | Technology | West  | Standard        | David Wilson   | 1            | 120.00        | 120.00          | 1                    | 1                     | 2024-02-15      | 3.0               |

### Query 2: Product profitability and supply chain analysis (5-table JOIN)
```sql
SELECT 
    p.product_name,
    p.category,
    p.subcategory,
    SUM(od.quantity * od.unit_price * (1 - od.discount/100)) AS total_revenue,
    SUM(od.quantity * p.cost_price) AS total_cost,
    SUM(od.quantity * od.unit_price * (1 - od.discount/100)) - SUM(od.quantity * p.cost_price) AS gross_profit,
    ROUND(
        (
            SUM(od.quantity * od.unit_price * (1 - od.discount/100)) - SUM(od.quantity * p.cost_price)
        ) / NULLIF(SUM(od.quantity * od.unit_price * (1 - od.discount/100)), 0) * 100, 2
    ) AS profit_margin_pct,
    i.quantity_on_hand AS current_stock,
    i.reorder_point,
    CASE 
        WHEN i.quantity_on_hand <= i.reorder_point THEN 'Reorder Needed'
        WHEN i.quantity_on_hand <= i.reorder_point + i.safety_stock THEN 'Low Stock'
        ELSE 'Adequate Stock'
    END AS stock_status,
    MIN(ps.supplier_cost) AS best_supplier_cost,
    MIN(ps.lead_time_days) AS fastest_lead_time,
    AVG(pr.rating) AS avg_customer_rating
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN sales_orders so ON od.order_id = so.order_id AND so.status = 'Completed'
LEFT JOIN inventory i ON p.product_id = i.product_id
LEFT JOIN product_suppliers ps ON p.product_id = ps.product_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
WHERE p.discontinued = FALSE
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, i.quantity_on_hand, i.reorder_point, i.safety_stock
ORDER BY gross_profit DESC NULLS LAST;
```

**Expected Result:**
| product_name      | category | subcategory | total_revenue | total_cost | gross_profit | profit_margin_pct | current_stock | reorder_point | stock_status    | best_supplier_cost | fastest_lead_time | avg_customer_rating |
|-------------------|----------|-------------|---------------|------------|--------------|-------------------|---------------|---------------|-----------------|--------------------|-------------------|-------------------|
| Laptop Pro 15"    | Hardware| Laptops    | 4000.00       | 3000.00   | 1000.00     | 25.00             | 25            | 10            | Adequate Stock | 1400.00           | 7                 | 5.0               |
| Monitor 27" 4K    | Hardware| Displays   | 702.00        | 400.00    | 302.00      | 43.02             | 12            | 8             | Adequate Stock | 380.00            | 5                 | 5.0               |
| Consulting Services| Services| Professional| 300.00       | 150.00    | 150.00      | 50.00             | 50            | 10            | Adequate Stock | 140.00            | 2                 | 4.0               |
| Wireless Keyboard | Hardware| Peripherals| 330.00        | 240.00    | 90.00       | 27.27             | 150           | 50            | Adequate Stock | 75.00             | 3                 | 3.0               |
| Cloud Storage Pro | Software| SaaS       | 70.00         | 20.00     | 50.00       | 71.43             | 999           | 100           | Adequate Stock | 8.00              | 1                 | 4.0               |

### Query 3: Sales performance with regional and product insights (6-table JOIN)
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS salesperson,
    e.department,
    e.title,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_sales,
    AVG(o.total_amount) AS avg_order_size,
    SUM(od.quantity) AS total_units_sold,
    COUNT(DISTINCT od.product_id) AS products_sold,
    COUNT(DISTINCT p.category) AS categories_sold,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(o.order_id), 0), 2) AS sales_per_order,
    MAX(o.order_date) AS last_sale_date,
    AVG(pr.rating) AS avg_customer_rating_received
FROM employees e
INNER JOIN sales_orders o ON e.emp_id = o.salesperson_id AND o.status = 'Completed'
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id
INNER JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN product_reviews pr ON od.product_id = pr.product_id AND o.customer_id = pr.customer_id
WHERE e.department = 'Sales'
GROUP BY e.emp_id, e.first_name, e.last_name, e.department, e.title
ORDER BY total_sales DESC;
```

**Expected Result:**
| salesperson  | department | title            | unique_customers | total_orders | total_sales | avg_order_size | total_units_sold | products_sold | categories_sold | sales_per_order | last_sale_date | avg_customer_rating_received |
|--------------|------------|------------------|------------------|--------------|-------------|----------------|------------------|---------------|-----------------|-----------------|---------------|-----------------------------|
| Bob Smith    | Sales     | Senior Sales Rep | 2                | 2            | 878.00      | 439.00         | 5                | 3             | 2               | 439.00         | 2024-01-20    | 4.0                         |
| David Wilson | Sales     | Sales Associate  | 2                | 2            | 770.00      | 385.00         | 3                | 3             | 3               | 385.00         | 2024-02-15    | 3.5                         |
| Eve Brown    | Sales     | Sales Manager    | 1                | 1            | 2000.00     | 2000.00        | 1                | 1             | 1               | 2000.00        | 2024-03-01    |                             |
| Carol Davis  | Sales     | Account Manager  | 1                | 1            | 702.00      | 702.00         | 2                | 2             | 1               | 702.00         | 2024-02-01    | 5.0                         |

### Query 4: Inventory optimization and supplier analysis (5-table JOIN)
```sql
SELECT 
    p.product_name,
    p.category,
    i.warehouse_location,
    i.quantity_on_hand,
    i.reorder_point,
    i.safety_stock,
    CASE 
        WHEN i.quantity_on_hand <= i.reorder_point THEN 'Critical - Reorder Immediately'
        WHEN i.quantity_on_hand <= i.reorder_point + i.safety_stock THEN 'Warning - Reorder Soon'
        WHEN i.quantity_on_hand <= i.reorder_point + (i.safety_stock * 2) THEN 'Monitor - Adequate'
        ELSE 'Good - No Action Needed'
    END AS inventory_status,
    ps.supplier_cost,
    s.supplier_name,
    s.reliability_rating,
    ps.lead_time_days,
    ps.minimum_order_qty,
    CASE WHEN ps.is_preferred THEN 'Preferred' ELSE 'Alternative' END AS supplier_status,
    ROUND(
        (i.quantity_on_hand * p.cost_price) + 
        (ps.supplier_cost * ps.minimum_order_qty), 2
    ) AS estimated_reorder_cost
FROM products p
INNER JOIN inventory i ON p.product_id = i.product_id
INNER JOIN product_suppliers ps ON p.product_id = ps.product_id
INNER JOIN suppliers s ON ps.supplier_id = s.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN sales_orders so ON od.order_id = so.order_id AND so.status = 'Completed'
WHERE p.discontinued = FALSE
GROUP BY p.product_id, p.product_name, p.category, i.warehouse_location, i.quantity_on_hand, 
         i.reorder_point, i.safety_stock, ps.supplier_cost, s.supplier_name, s.reliability_rating,
         ps.lead_time_days, ps.minimum_order_qty, ps.is_preferred
ORDER BY 
    CASE 
        WHEN i.quantity_on_hand <= i.reorder_point THEN 1
        WHEN i.quantity_on_hand <= i.reorder_point + i.safety_stock THEN 2
        WHEN i.quantity_on_hand <= i.reorder_point + (i.safety_stock * 2) THEN 3
        ELSE 4
    END,
    p.product_name,
    ps.is_preferred DESC;
```

**Expected Result:**
| product_name      | category | warehouse_location | quantity_on_hand | reorder_point | safety_stock | inventory_status          | supplier_cost | supplier_name  | reliability_rating | lead_time_days | minimum_order_qty | supplier_status | estimated_reorder_cost |
|-------------------|----------|-------------------|------------------|---------------|--------------|---------------------------|---------------|----------------|-------------------|----------------|-------------------|-----------------|-----------------------|
| Monitor 27" 4K    | Hardware| Main Warehouse   | 12               | 8             | 3            | Monitor - Adequate       | 380.00        | GlobalParts Ltd| 4.2               | 5              | 2                 | Preferred      | 4960.00               |
| Laptop Pro 15"    | Hardware| Main Warehouse   | 25               | 10            | 5            | Good - No Action Needed  | 1400.00       | TechSupply Inc | 4.5               | 7              | 5                 | Preferred      | 38500.00              |
| Laptop Pro 15"    | Hardware| Main Warehouse   | 25               | 10            | 5            | Good - No Action Needed  | 1450.00       | GlobalParts Ltd| 4.2               | 10             | 3                 | Alternative    | 38650.00              |
| Wireless Keyboard | Hardware| Main Warehouse   | 150              | 50            | 20           | Good - No Action Needed  | 75.00         | TechSupply Inc | 4.5               | 3              | 10                | Preferred      | 11750.00              |
| Cloud Storage Pro | Software| Cloud Services   | 999              | 100           | 50           | Good - No Action Needed  | 8.00          | ServicePro     | 4.8               | 1              | 100               | Preferred      | 8900.00               |
| Consulting Services| Services| Service Center   | 50              | 10            | 5            | Good - No Action Needed  | 140.00        | ServicePro     | 4.8               | 2              | 1                 | Preferred      | 7150.00               |

## Key Learning Points
- **Multi-table JOINs**: 5-6 table combinations with proper relationships
- **Complex filtering**: Business logic across multiple entities
- **Aggregations with JOINs**: Statistical analysis across related tables
- **NULL handling**: LEFT JOINs with conditional aggregations
- **Performance optimization**: Strategic JOIN order and filtering

## Common Complex JOIN Applications
- **Customer analytics**: Purchase behavior across products and time
- **Supply chain analysis**: Inventory, suppliers, and product performance
- **Sales performance**: Revenue analysis with customer and product dimensions
- **Operational dashboards**: Multi-entity KPI calculations

## Performance Notes
- Use EXPLAIN to analyze JOIN order and performance
- Consider indexing on foreign key columns
- Filter early in the query to reduce intermediate result sets
- Use appropriate JOIN types (INNER vs LEFT vs RIGHT)

## Extension Challenge
Create a comprehensive executive dashboard that analyzes business performance across customer segments, product categories, regional sales, and operational efficiency using complex multi-table JOINs with advanced aggregations and statistical analysis.
