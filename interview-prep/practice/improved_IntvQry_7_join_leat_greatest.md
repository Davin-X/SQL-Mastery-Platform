# 🎯 LEAST/GREATEST Functions with JOINs Interview Question

## Question
Given two tables with price information, find products that are priced differently across stores and show the minimum and maximum prices for each product across all stores.

## SQL Setup (Tables and Sample Data)

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
(1, 'Laptop'),
(2, 'Mouse'),
(3, 'Keyboard');

INSERT INTO store_prices VALUES
(1, 1, 999.99),
(1, 2, 1029.99),
(1, 3, 979.99),
(2, 1, 29.99),
(2, 2, 25.99),
(3, 1, 79.99),
(3, 2, 85.99),
(3, 3, 75.99);
```

## Answer: Using LEAST/GREATEST with Aggregations

```sql
SELECT 
    p.product_name,
    COUNT(sp.store_id) AS stores_carrying,
    MIN(sp.price) AS min_price,
    MAX(sp.price) AS max_price,
    MAX(sp.price) - MIN(sp.price) AS price_range,
    ROUND(AVG(sp.price), 2) AS avg_price,
    
    -- Find stores with min/max prices
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

**How it works**: 
- JOIN connects products to their prices
- MIN/MAX find price range
- Subqueries identify which stores have the extreme prices
- GROUP_CONCAT shows multiple stores (MySQL-specific)

## Alternative: Using Window Functions

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

**How it works**: Window functions identify first/last values in ordered partitions.

## LEAST/GREATEST Usage Examples

```sql
-- Find the lowest price for each product across stores
SELECT 
    p.product_name,
    LEAST(
        MAX(CASE WHEN sp.store_id = 1 THEN sp.price END),
        MAX(CASE WHEN sp.store_id = 2 THEN sp.price END),
        MAX(CASE WHEN sp.store_id = 3 THEN sp.price END)
    ) AS lowest_price_across_stores
FROM products p
JOIN store_prices sp ON p.product_id = sp.product_id
GROUP BY p.product_id, p.product_name;

-- Price comparison between specific stores
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

## Database-Specific Notes

- **LEAST/GREATEST**: Available in MySQL, PostgreSQL, Oracle
- **SQL Server**: Use CASE statements or custom functions
- **Alternative in SQL Server**:
  ```sql
  SELECT CASE WHEN val1 < val2 THEN val1 ELSE val2 END AS min_val
  ```

## Common Interview Patterns

1. **Price Comparisons**: Finding best/worst prices across sources
2. **Range Analysis**: Calculating spreads between values
3. **Conditional Logic**: Implementing min/max logic
4. **Data Validation**: Checking value ranges

## Performance Considerations

- **Aggregations**: MIN/MAX are efficient with proper indexing
- **Window Functions**: May require sorting, good for complex analysis
- **JOIN Complexity**: Multiple store comparisons can be expensive
- **Subqueries**: Correlated subqueries can be slow on large datasets

## Interview Tips

- **Explain LEAST/GREATEST**: Returns minimum/maximum of given values
- **Database differences**: Not all databases support these functions
- **Alternatives**: CASE statements for broader compatibility
- **Use cases**: Price comparisons, boundary checking, range calculations
- **Performance**: Consider when aggregations vs window functions are better

## Real-World Applications

- **Retail**: Price comparison across stores
- **Finance**: Finding best/worst rates across providers
- **Inventory**: Stock level ranges across warehouses
- **Analytics**: Performance ranges across time periods
