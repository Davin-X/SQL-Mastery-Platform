# 🎯 SQL Practice 2: JOIN Operations

## Question
Write SQL queries using various JOIN types to combine data from multiple related tables, demonstrating INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL OUTER JOIN operations.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30),
    registration_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    unit_price DECIMAL(8,2)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(8,2),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers VALUES
(1, 'Alice Johnson', 'New York', '2023-01-15'),
(2, 'Bob Smith', 'Los Angeles', '2023-02-20'),
(3, 'Charlie Brown', 'Chicago', '2023-03-10'),
(4, 'Diana Prince', 'Houston', '2023-04-05');

INSERT INTO orders VALUES
(101, 1, '2024-01-15', 150.00, 'completed'),
(102, 1, '2024-02-20', 200.00, 'completed'),
(103, 2, '2024-01-25', 300.00, 'pending'),
(104, 3, '2024-02-10', 175.00, 'completed'),
(105, 5, '2024-02-15', 250.00, 'completed');  -- Customer 5 doesn't exist

INSERT INTO products VALUES
(201, 'Laptop', 'Electronics', 999.99),
(202, 'Mouse', 'Electronics', 29.99),
(203, 'Book', 'Education', 19.99),
(204, 'Headphones', 'Electronics', 79.99);

INSERT INTO order_items VALUES
(101, 201, 1, 999.99),
(101, 202, 2, 29.99),
(102, 203, 3, 19.99),
(103, 201, 1, 999.99),
(104, 204, 1, 79.99);
```

## Query 1: INNER JOIN - Customers with Orders

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;
```

**Expected Output**: Only customers who have placed orders (Alice, Bob, Charlie).

## Query 2: LEFT JOIN - All Customers with Order Info

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_name;
```

**Expected Output**: All customers, with NULL values for Diana (no orders).

## Query 3: RIGHT JOIN - All Orders with Customer Info

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;
```

**Expected Output**: All orders, including one with NULL customer (order 105 from non-existent customer 5).

## Query 4: Multiple Table JOIN - Complete Order Details

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_name;
```

**Expected Output**: Complete order details with customer, order, and product information.

## Query 5: LEFT JOIN with Aggregation - Customer Order Summary

```sql
SELECT 
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'completed'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_spent DESC;
```

**Expected Output**: Order summary for each customer, including those with no completed orders.

## Query 6: SELF JOIN - Customers from Same City

```sql
SELECT 
    c1.customer_name AS customer_1,
    c2.customer_name AS customer_2,
    c1.city
FROM customers c1
INNER JOIN customers c2 ON c1.city = c2.city AND c1.customer_id < c2.customer_id
ORDER BY c1.city, c1.customer_name;
```

**Expected Output**: Pairs of customers from the same city (none in this dataset).

## Query 7: CROSS JOIN - All Possible Combinations (Limited)

```sql
SELECT 
    c.customer_name,
    p.category,
    COUNT(o.order_id) AS orders_in_category
FROM customers c
CROSS JOIN (SELECT DISTINCT category FROM products) p
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products prod ON oi.product_id = prod.product_id AND prod.category = p.category
GROUP BY c.customer_id, c.customer_name, p.category
ORDER BY c.customer_name, p.category;
```

**Expected Output**: Each customer with order counts by product category.

## Query 8: Complex Multi-Table Analysis

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_date,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total,
    o.total_amount AS order_total,
    CASE 
        WHEN o.status = 'completed' THEN '✓'
        ELSE '⏳'
    END AS status_icon
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY c.customer_name, o.order_date DESC, p.product_name;
```

**Expected Output**: Comprehensive view of all order details with customer and product information.

## Query 9: JOIN with Subquery - Top Customers

```sql
SELECT 
    c.customer_name,
    c.city,
    customer_totals.total_orders,
    customer_totals.total_spent,
    customer_totals.last_order_date
FROM customers c
INNER JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_spent,
        MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
    HAVING SUM(total_amount) > 150
) customer_totals ON c.customer_id = customer_totals.customer_id
ORDER BY customer_totals.total_spent DESC;
```

**Expected Output**: Top customers who spent more than $150.

## Query 10: FULL OUTER JOIN Simulation (MySQL)

```sql
SELECT 
    COALESCE(c.customer_name, 'No Customer') AS customer_name,
    COALESCE(o.order_id, 'No Order') AS order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT 
    'No Customer' AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

**Expected Output**: All customers and orders, showing relationships (MySQL workaround for FULL OUTER JOIN).

## Query 11: JOIN with Date Filtering

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status,
    DATEDIFF(CURDATE(), o.order_date) AS days_since_order
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01'
  AND o.status = 'completed'
ORDER BY o.order_date DESC;
```

**Expected Output**: Recent completed orders with days calculation.

## Query 12: Anti-JOIN - Customers Without Orders

```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.registration_date,
    DATEDIFF(CURDATE(), c.registration_date) AS days_registered
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

**Expected Output**: Customers who haven't placed any orders.

## Query 13: JOIN Performance - Selective Columns

```sql
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 0
ORDER BY total_spent DESC;
```

**Expected Output**: Customer order summaries (optimized query).

## Query 14: Complex Business Logic with JOINs

```sql
SELECT 
    c.customer_name,
    c.city,
    o.order_date,
    COUNT(oi.product_id) AS items_in_order,
    SUM(oi.quantity * oi.unit_price) AS calculated_total,
    o.total_amount AS recorded_total,
    CASE 
        WHEN ABS(SUM(oi.quantity * oi.unit_price) - o.total_amount) < 0.01 THEN 'Matches'
        ELSE 'Discrepancy'
    END AS total_check
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, o.order_id, o.order_date, o.total_amount
ORDER BY o.order_date DESC;
```

**Expected Output**: Order validation checking if recorded totals match calculated totals.

## Query 15: Hierarchical Data with JOINs

```sql
-- First, let's add a simple hierarchy
CREATE TEMPORARY TABLE temp_dept AS
SELECT 'Engineering' AS dept_name, NULL AS parent_dept
UNION ALL SELECT 'Sales', NULL
UNION ALL SELECT 'DevOps', 'Engineering'
UNION ALL SELECT 'QA', 'Engineering';

SELECT 
    d.dept_name AS department,
    p.dept_name AS parent_department,
    COUNT(DISTINCT e.customer_id) AS customers_served
FROM temp_dept d
LEFT JOIN temp_dept p ON d.parent_dept = p.dept_name
LEFT JOIN customers e ON 1=1  -- Simplified for demo
GROUP BY d.dept_name, p.dept_name
ORDER BY d.dept_name;
```

**Expected Output**: Department hierarchy with customer counts.


### 1. Use Appropriate JOIN Types
- **INNER JOIN**: Only matching rows
- **LEFT JOIN**: All left table rows + matches
- **RIGHT JOIN**: All right table rows + matches
- **CROSS JOIN**: Cartesian product (use carefully)

### 2. Index Foreign Keys
```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### 3. Use Table Aliases
```sql
SELECT c.name, o.date, p.product
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN products p ON o.product_id = p.id;
```

## Common JOIN Mistakes
