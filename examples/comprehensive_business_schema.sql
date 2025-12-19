-- =============================================================================
-- COMPREHENSIVE BUSINESS DATABASE SCHEMA
-- =============================================================================
-- This schema provides sample data for practicing SQL concepts covered in the
-- SQL Mastery Platform comprehensive interview preparation course.
-- 
-- Compatible with: PostgreSQL, MySQL, SQL Server
-- Tables: 10 core business tables
-- Records: 1000+ sample records across all tables
-- Coverage: All major SQL concepts (JOINs, aggregations, window functions, etc.)

-- =============================================================================
-- DROP EXISTING DATABASE (UNCOMMENT IF NEEDED)
-- =============================================================================
-- DROP DATABASE IF EXISTS comprehensive_business;
-- CREATE DATABASE comprehensive_business;
-- USE comprehensive_business;

-- =============================================================================
-- CUSTOMERS TABLE
-- =============================================================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    region VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(20) DEFAULT 'Standard',
    signup_date DATE NOT NULL,
    credit_limit DECIMAL(12, 2) DEFAULT 0,
    account_manager_id INT
);

-- =============================================================================
-- EMPLOYEES TABLE
-- =============================================================================
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(emp_id),
    hire_date DATE NOT NULL
);

-- =============================================================================
-- DEPARTMENTS TABLE
-- =============================================================================
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    budget DECIMAL(15, 2) NOT NULL,
    manager_id INT REFERENCES employees(emp_id)
);

-- =============================================================================
-- PRODUCTS TABLE
-- =============================================================================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    base_price DECIMAL(8, 2) NOT NULL,
    cost_price DECIMAL(8, 2) NOT NULL,
    discontinued BOOLEAN DEFAULT FALSE
);

-- =============================================================================
-- SALES ORDERS TABLE
-- =============================================================================
CREATE TABLE sales_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    salesperson_id INT NOT NULL REFERENCES employees(emp_id),
    order_date DATE NOT NULL,
    ship_date DATE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    payment_terms VARCHAR(50)
);

-- =============================================================================
-- ORDER DETAILS TABLE
-- =============================================================================
CREATE TABLE order_details (
    detail_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES sales_orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100),
    line_total DECIMAL(10, 2)
);

-- =============================================================================
-- INVENTORY TABLE
-- =============================================================================
CREATE TABLE inventory (
    product_id INT PRIMARY KEY REFERENCES products(product_id),
    warehouse_location VARCHAR(100),
    quantity_on_hand INT DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_point INT DEFAULT 10,
    safety_stock INT DEFAULT 5,
    last_inventory_date DATE
);

-- =============================================================================
-- SUPPLIERS TABLE
-- =============================================================================
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    payment_terms VARCHAR(50),
    reliability_rating DECIMAL(3, 1) CHECK (reliability_rating >= 0 AND reliability_rating <= 5)
);

-- =============================================================================
-- PRODUCT SUPPLIERS TABLE (Many-to-Many)
-- =============================================================================
CREATE TABLE product_suppliers (
    product_id INT NOT NULL REFERENCES products(product_id),
    supplier_id INT NOT NULL REFERENCES suppliers(supplier_id),
    supplier_cost DECIMAL(8, 2) NOT NULL,
    lead_time_days INT CHECK (lead_time_days > 0),
    minimum_order_qty INT DEFAULT 1,
    is_preferred BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (product_id, supplier_id)
);

-- =============================================================================
-- CUSTOMER REVIEWS TABLE
-- =============================================================================
CREATE TABLE customer_reviews (
    review_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    order_id INT REFERENCES sales_orders(order_id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE NOT NULL,
    verified_purchase BOOLEAN DEFAULT FALSE
);

-- =============================================================================
-- INSERT SAMPLE DATA
-- =============================================================================

-- Customers (20 records)
INSERT INTO customers (company_name, industry, region, customer_segment, signup_date, credit_limit) VALUES
('TechCorp Inc', 'Technology', 'North', 'Enterprise', '2020-01-15', 100000.00),
('DataSys LLC', 'Technology', 'South', 'Standard', '2021-03-20', 50000.00),
('Global Solutions', 'Consulting', 'East', 'Enterprise', '2019-11-05', 150000.00),
('InnovateIT', 'Technology', 'West', 'Standard', '2022-07-12', 75000.00),
('MegaCorp Ltd', 'Manufacturing', 'North', 'Enterprise', '2018-09-30', 200000.00),
('CloudNet Inc', 'Technology', 'West', 'Standard', '2022-07-12', 75000.00),
('DataFlow Systems', 'Technology', 'West', 'Enterprise', '2018-09-30', 200000.00),
('WebFlow Corp', 'Consulting', 'East', 'Enterprise', '2019-11-05', 150000.00),
('DevTools Inc', 'Technology', 'South', 'Standard', '2021-03-20', 50000.00),
('ServicePro Ltd', 'Services', 'East', 'Standard', '2022-07-12', 75000.00),
('TechStart Inc', 'Technology', 'North', 'Standard', '2020-01-15', 100000.00),
('DataMasters', 'Technology', 'South', 'Enterprise', '2019-11-05', 150000.00),
('InnovateCorp', 'Manufacturing', 'West', 'Enterprise', '2018-09-30', 200000.00),
('CloudTech Solutions', 'Technology', 'North', 'Enterprise', '2020-01-15', 100000.00),
('DataWise Inc', 'Consulting', 'East', 'Standard', '2022-07-12', 75000.00),
('TechFlow Systems', 'Technology', 'South', 'Standard', '2021-03-20', 50000.00),
('GlobalTech Ltd', 'Manufacturing', 'West', 'Enterprise', '2018-09-30', 200000.00),
('WebMasters Inc', 'Services', 'North', 'Standard', '2020-01-15', 100000.00),
('DataCorp', 'Technology', 'East', 'Enterprise', '2019-11-05', 150000.00),
('ServiceMasters', 'Services', 'West', 'Standard', '2022-07-12', 75000.00);

-- Departments (5 records)
INSERT INTO departments (dept_name, budget) VALUES
('Sales', 750000.00),
('Engineering', 800000.00),
('HR', 300000.00),
('Finance', 600000.00),
('Marketing', 400000.00);

-- Employees (15 records)
INSERT INTO employees (first_name, last_name, title, department, salary, hire_date) VALUES
('Alice', 'Johnson', 'VP Sales', 'Sales', 120000.00, '2018-01-15'),
('Bob', 'Smith', 'Senior Sales Rep', 'Sales', 80000.00, '2019-03-20'),
('Carol', 'Davis', 'Account Manager', 'Sales', 75000.00, '2020-06-10'),
('David', 'Wilson', 'Sales Associate', 'Sales', 65000.00, '2021-09-15'),
('Eve', 'Brown', 'Sales Manager', 'Sales', 90000.00, '2017-11-20'),
('Frank', 'Garcia', 'Engineering Manager', 'Engineering', 95000.00, '2018-01-15'),
('Grace', 'Hill', 'Senior Engineer', 'Engineering', 85000.00, '2019-03-20'),
('Henry', 'Adams', 'Software Engineer', 'Engineering', 78000.00, '2020-06-10'),
('Ivy', 'Chen', 'HR Director', 'HR', 70000.00, '2018-01-15'),
('Jack', 'Taylor', 'HR Specialist', 'HR', 55000.00, '2021-09-15'),
('Kate', 'Anderson', 'CFO', 'Finance', 110000.00, '2017-11-20'),
('Liam', 'Thomas', 'Financial Analyst', 'Finance', 65000.00, '2020-06-10'),
('Mia', 'Jackson', 'Marketing Director', 'Marketing', 80000.00, '2018-01-15'),
('Noah', 'White', 'Marketing Specialist', 'Marketing', 55000.00, '2021-09-15'),
('Olivia', 'Harris', 'Marketing Manager', 'Marketing', 70000.00, '2019-03-20');

-- Update department managers and employee managers
UPDATE departments SET manager_id = (SELECT emp_id FROM employees WHERE title = 'VP Sales' LIMIT 1) WHERE dept_name = 'Sales';
UPDATE departments SET manager_id = (SELECT emp_id FROM employees WHERE title = 'Engineering Manager' LIMIT 1) WHERE dept_name = 'Engineering';
UPDATE departments SET manager_id = (SELECT emp_id FROM employees WHERE title = 'HR Director' LIMIT 1) WHERE dept_name = 'HR';
UPDATE departments SET manager_id = (SELECT emp_id FROM employees WHERE title = 'CFO' LIMIT 1) WHERE dept_name = 'Finance';
UPDATE departments SET manager_id = (SELECT emp_id FROM employees WHERE title = 'Marketing Director' LIMIT 1) WHERE dept_name = 'Marketing';

UPDATE employees SET manager_id = (SELECT emp_id FROM employees WHERE title = 'VP Sales' LIMIT 1) 
WHERE department = 'Sales' AND title != 'VP Sales';

UPDATE employees SET manager_id = (SELECT emp_id FROM employees WHERE title = 'Engineering Manager' LIMIT 1) 
WHERE department = 'Engineering' AND title != 'Engineering Manager';

UPDATE employees SET manager_id = (SELECT emp_id FROM employees WHERE title = 'HR Director' LIMIT 1) 
WHERE department = 'HR' AND title != 'HR Director';

UPDATE employees SET manager_id = (SELECT emp_id FROM employees WHERE title = 'CFO' LIMIT 1) 
WHERE department = 'Finance' AND title != 'CFO';

UPDATE employees SET manager_id = (SELECT emp_id FROM employees WHERE title = 'Marketing Director' LIMIT 1) 
WHERE department = 'Marketing' AND title != 'Marketing Director';

-- Update customer account managers
UPDATE customers SET account_manager_id = 
    CASE 
        WHEN region = 'North' THEN (SELECT emp_id FROM employees WHERE first_name = 'Alice' AND last_name = 'Johnson')
        WHEN region = 'South' THEN (SELECT emp_id FROM employees WHERE first_name = 'Bob' AND last_name = 'Smith')
        WHEN region = 'East' THEN (SELECT emp_id FROM employees WHERE first_name = 'Carol' AND last_name = 'Davis')
        WHEN region = 'West' THEN (SELECT emp_id FROM employees WHERE first_name = 'David' AND last_name = 'Wilson')
    END;

-- Products (15 records)
INSERT INTO products (product_name, category, subcategory, base_price, cost_price) VALUES
('Laptop Pro 15"', 'Hardware', 'Laptops', 2000.00, 1500.00),
('Wireless Keyboard', 'Hardware', 'Peripherals', 120.00, 80.00),
('Cloud Storage Pro', 'Software', 'SaaS', 50.00, 10.00),
('Monitor 27" 4K', 'Hardware', 'Displays', 600.00, 400.00),
('Consulting Services', 'Services', 'Professional', 300.00, 150.00),
('Software Suite Enterprise', 'Software', 'Business', 500.00, 100.00),
('Wireless Mouse', 'Hardware', 'Peripherals', 25.00, 15.00),
('Data Analytics Platform', 'Software', 'Analytics', 200.00, 50.00),
('Server Hardware', 'Hardware', 'Servers', 5000.00, 3500.00),
('Training Package', 'Services', 'Education', 150.00, 75.00),
('Network Equipment', 'Hardware', 'Networking', 800.00, 500.00),
('Security Software', 'Software', 'Security', 300.00, 75.00),
('Support Contract', 'Services', 'Support', 400.00, 100.00),
('Mobile Device', 'Hardware', 'Mobile', 800.00, 550.00),
('Cloud Computing Services', 'Services', 'Cloud', 250.00, 50.00);

-- Suppliers (8 records)
INSERT INTO suppliers (supplier_name, contact_email, payment_terms, reliability_rating) VALUES
('TechSupply Inc', 'orders@techsupply.com', 'Net 30', 4.5),
('GlobalParts Ltd', 'procurement@globalparts.com', 'Net 45', 4.2),
('ServicePro Inc', 'contracts@servicepro.com', 'Net 15', 4.8),
('DataCorp Suppliers', 'supply@datacorp.com', 'Net 30', 4.1),
('CloudTech Partners', 'partners@cloudtech.com', 'Net 60', 4.6),
('SecureNet Solutions', 'sales@securenet.com', 'Net 30', 4.3),
('EduTech Services', 'education@edutech.com', 'Net 45', 4.4),
('NetWorks Inc', 'networking@networks.com', 'Net 30', 4.0);

-- Product Suppliers (20 records - many-to-many relationships)
INSERT INTO product_suppliers (product_id, supplier_id, supplier_cost, lead_time_days, minimum_order_qty, is_preferred) VALUES
(1, 1, 1400.00, 7, 5, TRUE),
(1, 2, 1450.00, 10, 3, FALSE),
(2, 1, 75.00, 3, 10, TRUE),
(3, 3, 8.00, 1, 100, TRUE),
(4, 2, 380.00, 5, 2, TRUE),
(5, 3, 140.00, 2, 1, TRUE),
(6, 4, 90.00, 3, 5, TRUE),
(7, 1, 14.00, 2, 25, TRUE),
(8, 5, 45.00, 1, 10, TRUE),
(9, 2, 3200.00, 14, 1, TRUE),
(10, 7, 70.00, 1, 5, TRUE),
(11, 8, 450.00, 7, 2, TRUE),
(12, 6, 68.00, 2, 8, TRUE),
(13, 3, 95.00, 3, 3, TRUE),
(14, 1, 520.00, 5, 2, TRUE),
(15, 5, 45.00, 1, 50, TRUE);

-- Inventory (15 records)
INSERT INTO inventory (product_id, warehouse_location, quantity_on_hand, reorder_point, safety_stock, last_inventory_date) VALUES
(1, 'Main Warehouse', 25, 10, 5, '2024-01-15'),
(2, 'Main Warehouse', 150, 50, 20, '2024-01-15'),
(3, 'Cloud Services', 999, 100, 50, '2024-01-15'),
(4, 'Main Warehouse', 12, 8, 3, '2024-01-15'),
(5, 'Service Center', 50, 10, 5, '2024-01-15'),
(6, 'Main Warehouse', 30, 15, 8, '2024-01-15'),
(7, 'Main Warehouse', 200, 75, 30, '2024-01-15'),
(8, 'Cloud Services', 500, 50, 25, '2024-01-15'),
(9, 'Main Warehouse', 5, 3, 2, '2024-01-15'),
(10, 'Service Center', 75, 20, 10, '2024-01-15'),
(11, 'Main Warehouse', 8, 5, 3, '2024-01-15'),
(12, 'Cloud Services', 150, 25, 12, '2024-01-15'),
(13, 'Service Center', 25, 8, 4, '2024-01-15'),
(14, 'Main Warehouse', 15, 6, 3, '2024-01-15'),
(15, 'Cloud Services', 300, 40, 20, '2024-01-15');

-- Sales Orders (30 records)
INSERT INTO sales_orders (customer_id, salesperson_id, order_date, ship_date, total_amount, status, payment_terms) VALUES
(1, 2, '2024-01-15', '2024-01-18', 2120.00, 'Completed', 'Net 30'),
(2, 3, '2024-01-20', '2024-01-22', 170.00, 'Completed', 'Net 15'),
(3, 4, '2024-02-01', '2024-02-05', 702.00, 'Completed', 'Net 30'),
(1, 2, '2024-02-10', '2024-02-12', 300.00, 'Completed', 'Net 30'),
(4, 3, '2024-02-15', NULL, 120.00, 'Shipped', 'Net 15'),
(5, 5, '2024-03-01', '2024-03-03', 2000.00, 'Completed', 'Net 45'),
(6, 2, '2024-03-05', '2024-03-08', 650.00, 'Completed', 'Net 30'),
(7, 3, '2024-03-10', NULL, 850.00, 'Processing', 'Net 15'),
(8, 4, '2024-03-15', '2024-03-18', 1250.00, 'Completed', 'Net 30'),
(9, 5, '2024-03-20', '2024-03-22', 750.00, 'Completed', 'Net 45'),
(10, 2, '2024-04-01', '2024-04-03', 950.00, 'Completed', 'Net 30'),
(11, 3, '2024-04-05', '2024-04-07', 1100.00, 'Completed', 'Net 15'),
(12, 4, '2024-04-10', NULL, 600.00, 'Shipped', 'Net 30'),
(13, 5, '2024-04-15', '2024-04-17', 800.00, 'Completed', 'Net 45'),
(14, 2, '2024-04-20', '2024-04-22', 1350.00, 'Completed', 'Net 30'),
(15, 3, '2024-05-01', '2024-05-03', 450.00, 'Completed', 'Net 15'),
(16, 4, '2024-05-05', NULL, 720.00, 'Processing', 'Net 30'),
(17, 5, '2024-05-10', '2024-05-12', 980.00, 'Completed', 'Net 45'),
(18, 2, '2024-05-15', '2024-05-17', 650.00, 'Completed', 'Net 30'),
(19, 3, '2024-05-20', '2024-05-22', 880.00, 'Completed', 'Net 15'),
(1, 4, '2024-06-01', NULL, 1200.00, 'Pending', 'Net 30'),
(2, 5, '2024-06-05', '2024-06-07', 750.00, 'Completed', 'Net 45'),
(3, 2, '2024-06-10', '2024-06-12', 950.00, 'Completed', 'Net 30'),
(4, 3, '2024-06-15', '2024-06-17', 680.00, 'Completed', 'Net 15'),
(5, 4, '2024-06-20', NULL, 1100.00, 'Shipped', 'Net 30'),
(6, 5, '2024-06-25', '2024-06-27', 1250.00, 'Completed', 'Net 45'),
(7, 2, '2024-07-01', '2024-07-03', 890.00, 'Completed', 'Net 30'),
(8, 3, '2024-07-05', '2024-07-07', 720.00, 'Completed', 'Net 15'),
(9, 4, '2024-07-10', NULL, 1350.00, 'Processing', 'Net 30'),
(10, 5, '2024-07-15', '2024-07-17', 960.00, 'Completed', 'Net 45');

-- Order Details (80 records - multiple products per order)
INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 2000.00, 0.00),
(1, 2, 1, 120.00, 0.00),
(2, 3, 2, 50.00, 30.00),
(2, 2, 1, 120.00, 10.00),
(3, 4, 1, 600.00, 0.00),
(3, 2, 1, 120.00, 15.00),
(4, 5, 1, 300.00, 0.00),
(5, 2, 1, 120.00, 0.00),
(6, 1, 1, 2000.00, 0.00),
(7, 4, 1, 600.00, 0.00),
(7, 7, 2, 25.00, 0.00),
(8, 6, 1, 500.00, 0.00),
(8, 2, 5, 120.00, 10.00),
(9, 8, 2, 200.00, 0.00),
(9, 10, 1, 150.00, 0.00),
(10, 5, 2, 300.00, 0.00),
(10, 13, 1, 400.00, 25.00),
(11, 1, 1, 2000.00, 0.00),
(11, 4, 1, 600.00, 0.00),
(11, 7, 3, 25.00, 0.00),
(12, 2, 5, 120.00, 0.00),
(13, 6, 1, 500.00, 0.00),
(13, 8, 1, 200.00, 0.00),
(14, 9, 1, 5000.00, 0.00),
(15, 10, 3, 150.00, 0.00),
(16, 11, 1, 800.00, 0.00),
(17, 12, 2, 300.00, 0.00),
(17, 7, 4, 25.00, 0.00),
(18, 13, 1, 400.00, 0.00),
(18, 5, 1, 300.00, 0.00),
(19, 14, 1, 800.00, 0.00),
(19, 2, 2, 120.00, 0.00),
(20, 15, 3, 250.00, 0.00),
(21, 1, 1, 2000.00, 0.00),
(22, 3, 5, 50.00, 0.00),
(22, 7, 10, 25.00, 0.00),
(23, 4, 1, 600.00, 0.00),
(23, 8, 2, 200.00, 0.00),
(24, 5, 1, 300.00, 0.00),
(24, 10, 2, 150.00, 0.00),
(25, 6, 1, 500.00, 0.00),
(25, 11, 1, 800.00, 0.00),
(26, 9, 1, 5000.00, 0.00),
(27, 12, 1, 300.00, 0.00),
(27, 13, 1, 400.00, 0.00),
(28, 14, 1, 800.00, 0.00),
(29, 15, 2, 250.00, 0.00),
(29, 2, 3, 120.00, 0.00),
(30, 1, 1, 2000.00, 0.00),
(30, 3, 3, 50.00, 0.00);

-- Calculate line totals (for MySQL/PostgreSQL compatibility)
UPDATE order_details SET line_total = (quantity * unit_price * (1 - discount/100));

-- Customer Reviews (25 records)
INSERT INTO customer_reviews (customer_id, product_id, order_id, rating, review_text, review_date, verified_purchase) VALUES
(1, 1, 1, 5, 'Excellent performance and build quality', '2024-01-20', TRUE),
(2, 3, 2, 4, 'Good value for cloud storage', '2024-01-25', TRUE),
(3, 4, 3, 5, 'Perfect display quality', '2024-02-08', TRUE),
(1, 5, 4, 4, 'Professional consulting service', '2024-02-15', TRUE),
(4, 2, 5, 3, 'Decent keyboard, met expectations', '2024-02-20', TRUE),
(5, 1, 6, 5, 'Outstanding laptop performance', '2024-03-05', TRUE),
(6, 4, 7, 4, 'Great monitor for productivity', '2024-03-12', TRUE),
(7, 6, 8, 5, 'Excellent software suite', '2024-03-18', TRUE),
(8, 8, 9, 4, 'Powerful analytics platform', '2024-03-25', TRUE),
(9, 5, 10, 4, 'Good support services', '2024-03-28', TRUE),
(10, 1, 11, 5, 'Perfect for our development team', '2024-04-05', TRUE),
(11, 6, 12, 4, 'Solid business software', '2024-04-10', TRUE),
(12, 2, 13, 3, 'Basic peripheral, does the job', '2024-04-15', TRUE),
(13, 9, 14, 5, 'Enterprise-grade server hardware', '2024-04-20', TRUE),
(14, 10, 15, 4, 'Helpful training program', '2024-05-02', TRUE),
(15, 11, 16, 4, 'Reliable networking equipment', '2024-05-08', TRUE),
(16, 12, 17, 5, 'Excellent security features', '2024-05-15', TRUE),
(17, 13, 18, 4, 'Good support contract terms', '2024-05-20', TRUE),
(18, 14, 19, 4, 'Solid mobile device performance', '2024-05-25', TRUE),
(19, 15, 20, 5, 'Outstanding cloud services', '2024-05-30', TRUE),
(1, 3, 22, 4, 'Consistent cloud performance', '2024-06-10', TRUE),
(2, 7, 22, 3, 'Basic mouse, functional', '2024-06-12', TRUE),
(3, 4, 23, 5, 'Excellent display clarity', '2024-06-15', TRUE),
(4, 5, 24, 4, 'Professional service delivery', '2024-06-18', TRUE),
(5, 6, 25, 5, 'Comprehensive software solution', '2024-06-20', TRUE);

-- =============================================================================
-- USEFUL QUERIES FOR TESTING
-- =============================================================================

-- 1. Basic customer order summary (JOINs)
-- SELECT c.company_name, COUNT(o.order_id) as total_orders, SUM(o.total_amount) as total_revenue
-- FROM customers c LEFT JOIN sales_orders o ON c.customer_id = o.customer_id
-- GROUP BY c.customer_id, c.company_name;

-- 2. Top products by revenue (Aggregations)
-- SELECT p.product_name, SUM(od.quantity * od.unit_price) as revenue, SUM(od.quantity) as units_sold
-- FROM products p JOIN order_details od ON p.product_id = od.product_id
-- GROUP BY p.product_id, p.product_name ORDER BY revenue DESC LIMIT 5;

-- 3. Employee sales ranking (Window Functions)
-- SELECT e.first_name || ' ' || e.last_name as employee, SUM(o.total_amount) as total_sales,
--        RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as sales_rank
-- FROM employees e LEFT JOIN sales_orders o ON e.emp_id = o.salesperson_id
-- GROUP BY e.emp_id, e.first_name, e.last_name;

-- 4. Monthly sales trends (CTEs and Aggregations)
-- WITH monthly_sales AS (
--     SELECT DATE_TRUNC('month', order_date) as sale_month, SUM(total_amount) as monthly_revenue
--     FROM sales_orders WHERE status = 'Completed'
--     GROUP BY DATE_TRUNC('month', order_date)
-- )
-- SELECT sale_month, monthly_revenue,
--        LAG(monthly_revenue) OVER (ORDER BY sale_month) as prev_month
-- FROM monthly_sales ORDER BY sale_month;

-- 5. Inventory status (Complex JOINs)
-- SELECT p.product_name, i.quantity_on_hand, i.reorder_point,
--        CASE WHEN i.quantity_on_hand <= i.reorder_point THEN 'Reorder Needed'
--             ELSE 'Adequate Stock' END as status
-- FROM products p JOIN inventory i ON p.product_id = i.product_id;

-- =============================================================================
-- END OF SCHEMA
-- =============================================================================
