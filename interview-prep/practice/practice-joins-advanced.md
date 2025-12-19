# 🎯 Advanced JOINs Practice Collection

## Overview
This consolidated file contains advanced JOIN techniques and patterns from multiple practice scenarios, including JOIN row counts, LEAST/GREATEST functions, and complex JOIN relationships.

---

## 🎯 Problem 1: JOIN Row Count Analysis

**Business Context:** Understanding how different JOIN types affect result sets, crucial for query optimization and data analysis.

### Requirements
Given tables with specific data distributions, determine how many rows each JOIN type returns.

### SQL Setup
```sql
CREATE DATABASE tmp;
USE tmp;

CREATE TABLE table1 (t1 INT);
INSERT INTO table1 VALUES (1), (1), (1), (NULL), (NULL);

CREATE TABLE table2 (t2 INT);
INSERT INTO table2 VALUES (1), (1), (1), (1), (1);
```

### Solutions

#### INNER JOIN (15 records):
```sql
SELECT * FROM table1 INNER JOIN table2 ON table1.t1 = table2.t2;
```
**Explanation:** Only matching non-NULL rows. 3 × 5 = 15 combinations.

#### LEFT JOIN (17 records):
```sql
SELECT * FROM table1 LEFT JOIN table2 ON table1.t1 = table2.t2;
```
**Explanation:** All left rows + matches. 15 matches + 2 NULL rows = 17.

#### RIGHT JOIN (15 records):
```sql
SELECT * FROM table1 RIGHT JOIN table2 ON table1.t1 = table2.t2;
```
**Explanation:** All right rows + matches. All 5 right rows have matches.

#### FULL OUTER JOIN (17 records):
```sql
-- MySQL workaround
SELECT * FROM table1 
LEFT JOIN table2 ON table1.t1 = table2.t2
UNION ALL
SELECT * FROM table1 
RIGHT JOIN table2 ON table1.t1 = table2.t2 
WHERE table1.t1 IS NULL;
```

---

## 🎯 Problem 2: Price Analysis with LEAST/GREATEST

**Business Context:** Retail price comparison across multiple stores to find price ranges and optimal purchasing opportunities.

### Requirements
Find products priced differently across stores and show min/max prices with store information.

### SQL Setup
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);

CREATE TABLE store_prices (
    product_id INT,
    store_id INT,
    price DECIMAL(8,2),
    PRIMARY KEY (product_id, store_id)
);

INSERT INTO products VALUES
(1, 'Laptop'), (2, 'Mouse'), (3, 'Keyboard');

INSERT INTO store_prices VALUES
(1, 1, 999.99), (1, 2, 1029.99), (1, 3, 979.99),
(2, 1, 29.99), (2, 2, 25.99),
(3, 1, 79.99), (3, 2, 85.99), (3, 3, 75.99);
```

### Solutions

#### Comprehensive Price Analysis:
```sql
SELECT 
    p.product_name,
    COUNT(sp.store_id) AS stores_carrying,
    MIN(sp.price) AS min_price,
    MAX(sp.price) AS max_price,
    MAX(sp.price) - MIN(sp.price) AS price_range,
    ROUND(AVG(sp.price), 2) AS avg_price,
    
    -- Find stores with min/max prices (MySQL-specific)
    (SELECT GROUP_CONCAT(store_id) 
     FROM store_prices sp_min 
     WHERE sp_min.product_id = p.product_id 
     AND sp_min.price = MIN(sp.price)) AS stores_with_min_price,
     
    (SELECT GROUP_CONCAT(store_id) 
     FROM store_prices sp_max 
     WHERE sp_max.product_id = p.product_id 
     AND sp_max.price = MAX(sp.price)) AS stores_with_max_price
FROM products p
JOIN store_prices sp ON p.product_id = sp.product_id
GROUP BY p.product_id, p.product_name
ORDER BY price_range DESC;
```

#### Window Functions Approach:
```sql
SELECT DISTINCT
    p.product_name,
    FIRST_VALUE(sp.price) OVER (
        PARTITION BY p.product_id 
        ORDER BY sp.price ASC
    ) AS min_price,
    FIRST_VALUE(sp.price) OVER (
        PARTITION BY p.product_id 
        ORDER BY sp.price DESC
    ) AS max_price,
    FIRST_VALUE(sp.store_id) OVER (
        PARTITION BY p.product_id 
        ORDER BY sp.price ASC
    ) AS store_with_min_price,
    FIRST_VALUE(sp.store_id) OVER (
        PARTITION BY p.product_id 
        ORDER BY sp.price DESC
    ) AS store_with_max_price
FROM products p
JOIN store_prices sp ON p.product_id = sp.product_id
ORDER BY p.product_name;
```

#### Store-to-Store Price Comparison:
```sql
SELECT 
    p.product_name,
    sp1.price AS store_1_price,
    sp2.price AS store_2_price,
    GREATEST(sp1.price, sp2.price) AS higher_price,
    LEAST(sp1.price, sp2.price) AS lower_price,
    GREATEST(sp1.price, sp2.price) - LEAST(sp1.price, sp2.price) AS price_difference
FROM products p
JOIN store_prices sp1 ON p.product_id = sp1.product_id AND sp1.store_id = 1
JOIN store_prices sp2 ON p.product_id = sp2.product_id AND sp2.store_id = 2;
```

---

## 📚 Key Concepts Covered

### JOIN Types & Behavior
- **INNER JOIN**: Only matching rows
- **LEFT JOIN**: All left rows + matches
- **RIGHT JOIN**: All right rows + matches  
- **FULL OUTER JOIN**: All rows from both tables
- **NULL handling**: NULL values don't match in JOINs

### LEAST/GREATEST Functions
- **LEAST**: Returns smallest value from list
- **GREATEST**: Returns largest value from list
- **Cross-database compatibility**: Available in MySQL, PostgreSQL, Oracle
- **SQL Server alternatives**: Use CASE statements

### Advanced JOIN Patterns
- **Multi-table price comparisons**
- **Store performance analysis**
- **Range calculations across relationships**
- **Conditional aggregations with JOINs**

---

## 🎯 Interview-Ready Patterns

### Pattern 1: Price Optimization
Finding best prices across suppliers/stores for procurement optimization.

### Pattern 2: Data Completeness Analysis  
Using different JOIN types to understand data relationships and missing values.

### Pattern 3: Comparative Analysis
Side-by-side comparisons using LEAST/GREATEST for decision making.

### Pattern 4: Range Analysis
Calculating spreads and variances across multiple data sources.

