-- 01_schema_and_ddl.sql
-- Topic: DDL — create/alter/drop tables, constraints, simple schema design
-- Goal: Learn how to create a schema and tables, add constraints, and change structure safely.

-- ===========================================
-- MYSQL VERSION
-- ===========================================

-- Sample: create a small HR schema and tables
CREATE DATABASE IF NOT EXISTS sample_hr;

USE sample_hr;

DROP TABLE IF EXISTS employee;

DROP TABLE IF EXISTS department;

-- Department table
CREATE TABLE department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget DECIMAL(15, 2)
);

-- Employee table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES department (dept_id),
    FOREIGN KEY (manager_id) REFERENCES employee (emp_id)
);

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax:

-- Create database (run separately in psql)
-- CREATE DATABASE sample_hr;

-- Connect to database
\c sample_hr;

-- Drop tables if exist
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

-- Department table
CREATE TABLE department (
dept_id SERIAL PRIMARY KEY,
dept_name VARCHAR(50) NOT NULL UNIQUE,
location VARCHAR(100),
budget DECIMAL(15, 2)
);

-- Employee table
CREATE TABLE employee (
emp_id SERIAL PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
gender VARCHAR(10),
hire_date DATE NOT NULL,
salary DECIMAL(10, 2) NOT NULL,
dept_id INTEGER,
manager_id INTEGER,
FOREIGN KEY (dept_id) REFERENCES department (dept_id),
FOREIGN KEY (manager_id) REFERENCES employee (emp_id)
);

-- PostgreSQL Notes:
-- - SERIAL creates an INTEGER column with associated SEQUENCE
-- - Use \c to connect to database instead of USE
-- - Same ALTER TABLE syntax for adding columns/constraints
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax:

-- Create database
CREATE DATABASE sample_hr;

-- Use database
USE sample_hr;

-- Drop tables if exist
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

-- Department table
CREATE TABLE department (
dept_id INT IDENTITY(1,1) PRIMARY KEY,
dept_name VARCHAR(50) NOT NULL UNIQUE,
location VARCHAR(100),
budget DECIMAL(15, 2)
);

-- Employee table
CREATE TABLE employee (
emp_id INT IDENTITY(1,1) PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
gender VARCHAR(10),
hire_date DATE NOT NULL,
salary DECIMAL(10, 2) NOT NULL,
dept_id INT,
manager_id INT,
FOREIGN KEY (dept_id) REFERENCES department (dept_id),
FOREIGN KEY (manager_id) REFERENCES employee (emp_id)
);

-- SQL Server Notes:
-- - IDENTITY(seed, increment) for auto-increment
-- - Same USE syntax as MySQL
-- - Column addition syntax slightly different (no COLUMN keyword needed)
-- - Same constraint syntax
*/

-- Exercises:
-- 1) Add a NOT NULL constraint on hire_date
--    MySQL: ALTER TABLE employee MODIFY hire_date DATE NOT NULL;
--    PostgreSQL: ALTER TABLE employee ALTER COLUMN hire_date SET NOT NULL;
--    SQL Server: ALTER TABLE employee ALTER COLUMN hire_date DATE NOT NULL;

-- 2) Create an index on dept_id for faster lookups
--    All databases: CREATE INDEX idx_emp_dept_id ON employee(dept_id);

-- 3) Drop the fk constraint and then remove the column
--    All databases: ALTER TABLE employee DROP CONSTRAINT fk_emp_dept;
--                   ALTER TABLE employee DROP COLUMN dept_id;

-- ===========================================
-- COMPREHENSIVE CONSTRAINT SYNTAX
-- ===========================================

-- PRIMARY KEY Constraints
-- Inline PRIMARY KEY
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL
);

-- Table-level PRIMARY KEY (composite)
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- Named PRIMARY KEY constraint
CREATE TABLE customers (
    customer_id INT,
    name VARCHAR(100),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- FOREIGN KEY Constraints
-- Inline FOREIGN KEY
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers (customer_id),
    order_date DATE
);

-- Table-level FOREIGN KEY
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category_id INT,
    name VARCHAR(100),
    FOREIGN KEY (category_id) REFERENCES categories (category_id)
);

-- Named FOREIGN KEY constraint with actions
CREATE TABLE inventory (
    product_id INT,
    warehouse_id INT,
    quantity INT,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id) ON UPDATE SET NULL
);

-- UNIQUE Constraints
-- Inline UNIQUE
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

-- Table-level UNIQUE (composite)
CREATE TABLE user_permissions (
    user_id INT,
    permission_id INT,
    granted_date DATE,
    UNIQUE (user_id, permission_id)
);

-- Named UNIQUE constraint
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_number VARCHAR(20),
    routing_number VARCHAR(20),
    CONSTRAINT uk_account_number UNIQUE (account_number)
);

-- CHECK Constraints
-- Inline CHECK
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2) CHECK (price > 0),
    discount DECIMAL(3, 2) CHECK (discount BETWEEN 0 AND 1)
);

-- Table-level CHECK
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    salary DECIMAL(10, 2),
    department VARCHAR(50),
    CHECK (
        age >= 18
        AND age <= 65
    ),
    CHECK (salary > 0)
);

-- Named CHECK constraint
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    delivery_date DATE,
    status VARCHAR(20),
    CONSTRAINT ck_delivery_after_order CHECK (delivery_date >= order_date),
    CONSTRAINT ck_status_values CHECK (
        status IN (
            'pending',
            'processing',
            'shipped',
            'delivered'
        )
    )
);

-- DEFAULT Constraints
-- Inline DEFAULT
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- MySQL only
);

-- Named DEFAULT constraint (SQL Server)
CREATE TABLE configurations (
    config_id INT PRIMARY KEY,
    config_key VARCHAR(100),
    config_value VARCHAR(500) CONSTRAINT df_config_value DEFAULT 'default_value'
);

-- NOT NULL Constraints
-- Inline NOT NULL
CREATE TABLE required_fields (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Adding Constraints After Table Creation
-- MySQL syntax
ALTER TABLE employees
ADD CONSTRAINT pk_employees PRIMARY KEY (emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments (dept_id);

ALTER TABLE employees ADD CONSTRAINT uk_emp_email UNIQUE (email);

ALTER TABLE employees
ADD CONSTRAINT ck_emp_salary CHECK (salary > 0);

ALTER TABLE employees MODIFY COLUMN name VARCHAR(100) NOT NULL;

ALTER TABLE employees ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- PostgreSQL syntax
ALTER TABLE employees
ADD CONSTRAINT pk_employees PRIMARY KEY (emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments (dept_id);

ALTER TABLE employees ADD CONSTRAINT uk_emp_email UNIQUE (email);

ALTER TABLE employees
ADD CONSTRAINT ck_emp_salary CHECK (salary > 0);

ALTER TABLE employees ALTER COLUMN name SET NOT NULL;

ALTER TABLE employees ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- SQL Server syntax
ALTER TABLE employees
ADD CONSTRAINT pk_employees PRIMARY KEY (emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments (dept_id);

ALTER TABLE employees ADD CONSTRAINT uk_emp_email UNIQUE (email);

ALTER TABLE employees
ADD CONSTRAINT ck_emp_salary CHECK (salary > 0);

ALTER TABLE employees ALTER COLUMN name VARCHAR(100) NOT NULL;

ALTER TABLE employees
ADD status VARCHAR(20) CONSTRAINT df_emp_status DEFAULT 'active';

-- Dropping Constraints
-- MySQL/PostgreSQL syntax
ALTER TABLE employees DROP CONSTRAINT pk_employees;

ALTER TABLE employees DROP CONSTRAINT fk_emp_dept;

ALTER TABLE employees DROP CONSTRAINT uk_emp_email;

ALTER TABLE employees DROP CONSTRAINT ck_emp_salary;

ALTER TABLE employees MODIFY COLUMN name VARCHAR(100);
-- Remove NOT NULL
ALTER TABLE employees DROP COLUMN status;

-- SQL Server syntax
ALTER TABLE employees DROP CONSTRAINT pk_employees;

ALTER TABLE employees DROP CONSTRAINT fk_emp_dept;

ALTER TABLE employees DROP CONSTRAINT uk_emp_email;

ALTER TABLE employees DROP CONSTRAINT ck_emp_salary;

ALTER TABLE employees ALTER COLUMN name VARCHAR(100) NULL;
-- Remove NOT NULL
ALTER TABLE employees DROP CONSTRAINT df_emp_status;

ALTER TABLE employees DROP COLUMN status;

-- ===========================================
-- CONSTRAINT NAMING CONVENTIONS
-- ===========================================

-- Consistent naming helps with maintenance and debugging

-- Primary Keys: pk_table_name or pk_table_column
-- Foreign Keys: fk_table_referenced_table or fk_child_parent
-- Unique Keys: uk_table_column or uk_table_columns
-- Check Constraints: ck_table_condition or ck_table_column_condition
-- Default Constraints: df_table_column or df_table_column_value

-- Examples:
CONSTRAINT pk_users PRIMARY KEY (user_id) CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers (customer_id) CONSTRAINT uk_users_email UNIQUE (email) CONSTRAINT ck_products_price_positive CHECK (price > 0) CONSTRAINT df_users_status DEFAULT 'active'

-- ===========================================
-- CONSTRAINT DIFFERENCES BY DATABASE
-- ===========================================

/*
Constraint Type Differences:

1. PRIMARY KEY:
- All databases: Support inline and table-level
- Naming: All support named constraints
- Clustering: SQL Server clusters on primary key by default

2. FOREIGN KEY:
- All databases: Support CASCADE, SET NULL, RESTRICT, NO ACTION
- MySQL: Also supports SET DEFAULT
- PostgreSQL: Supports DEFERRABLE constraints
- SQL Server: Supports additional actions

3. UNIQUE:
- All databases: Support inline and table-level
- Multiple NULLs: PostgreSQL/SQL Server allow multiple NULLs
- MySQL: Treats NULL as distinct value

4. CHECK:
- MySQL: Limited CHECK constraint support (ignored before 8.0.16)
- PostgreSQL: Full CHECK constraint support, can reference other columns
- SQL Server: Full CHECK constraint support

5. NOT NULL:
- Inline: All databases support column-level NOT NULL
- Alter: Different ALTER COLUMN syntax

6. DEFAULT:
- MySQL: Supports expressions, functions, ON UPDATE
- PostgreSQL: Supports expressions, functions
- SQL Server: Limited to constants, GETDATE(), etc.

Constraint Enforcement Differences:

- MySQL: Foreign key constraints checked immediately
- PostgreSQL: Can defer constraint checking until end of transaction
- SQL Server: Supports CHECK and NOCHECK for enabling/disabling constraints

Best Practices:
1. Use descriptive constraint names following naming conventions
2. Test constraints with edge cases (NULL values, boundary conditions)
3. Consider performance impact of constraints on INSERT/UPDATE operations
4. Use appropriate constraint types for data integrity needs
5. Document constraint business rules in comments
*/

-- Hints: Use ALTER TABLE to change structure; back up data before destructive changes.
-- Key Differences:
-- - Auto-increment: AUTO_INCREMENT (MySQL) vs SERIAL (PostgreSQL) vs IDENTITY (SQL Server)
-- - Database connection: USE (MySQL/SQL Server) vs \c (PostgreSQL)
-- - Adding columns: ADD COLUMN (MySQL/PostgreSQL) vs ADD (SQL Server)
-- - Constraint naming: Consistent across databases but implementation varies
-- - CHECK constraints: Full support in PostgreSQL/SQL Server, limited in MySQL
-- - DEFAULT constraints: Most flexible in MySQL, most restrictive in SQL Server