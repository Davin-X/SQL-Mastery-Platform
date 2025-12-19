# 🎯 NULL Handling with CASE and COALESCE Interview Question

## Question
Given a `customer_orders` table with potentially NULL values in the discount and shipping_cost columns, calculate the final order total, applying a default discount of 5% when discount is NULL, and treating NULL shipping costs as free shipping (0).

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE customer_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_amount DECIMAL(10,2),
    discount_percent DECIMAL(5,2),  -- NULL means no discount
    shipping_cost DECIMAL(8,2)      -- NULL means free shipping
);

INSERT INTO customer_orders VALUES
(1, 'Alice', 100.00, 10.00, 5.00),
(2, 'Bob', 200.00, NULL, 10.00),
(3, 'Charlie', 150.00, 15.00, NULL),
(4, 'Diana', 300.00, NULL, NULL),
(5, 'Eve', 75.00, 5.00, 8.00);
```

## Answer: Handling NULLs with CASE and COALESCE

```sql
SELECT 
    order_id,
    customer_name,
    order_amount,
    discount_percent,
    shipping_cost,
    
    -- Method 1: Using CASE with IS NULL
    CASE 
        WHEN discount_percent IS NULL THEN 5.00
        ELSE discount_percent
    END AS effective_discount,
    
    -- Method 2: Using COALESCE (preferred)
    COALESCE(discount_percent, 5.00) AS effective_discount_coalesce,
    
    -- Method 3: Using IFNULL (MySQL specific)
    IFNULL(discount_percent, 5.00) AS effective_discount_ifnull,
    
    -- Shipping cost handling
    COALESCE(shipping_cost, 0.00) AS final_shipping,
    
    -- Final calculation
    ROUND(
        order_amount * (1 - COALESCE(discount_percent, 5.00)/100) + 
        COALESCE(shipping_cost, 0.00), 
        2
    ) AS final_total
FROM customer_orders
ORDER BY order_id;
```

**How it works**: 
- COALESCE returns the first non-NULL value
- CASE WHEN IS NULL provides explicit NULL checking
- IFNULL is MySQL-specific equivalent of COALESCE
- NULL shipping costs are treated as 0 (free shipping)

## Alternative: ISNULL (SQL Server)

```sql
SELECT 
    order_id,
    customer_name,
    order_amount,
    ISNULL(discount_percent, 5.00) AS effective_discount_sqlserver,
    ISNULL(shipping_cost, 0.00) AS final_shipping_sqlserver
FROM customer_orders;
```

**How it works**: ISNULL is SQL Server's equivalent to COALESCE.

## NULL Handling Functions by Database

| Function | MySQL | PostgreSQL | SQL Server | Oracle |
|----------|-------|------------|------------|--------|
| COALESCE | ✅ | ✅ | ✅ | ✅ |
| IFNULL | ✅ | ❌ | ❌ | ❌ |
| ISNULL | ❌ | ❌ | ✅ | ❌ |
| NVL | ❌ | ❌ | ❌ | ✅ |


1. **Missing Data**: Handle absent values gracefully
2. **Optional Fields**: Provide sensible defaults
3. **Calculations**: Prevent NULL from breaking math operations
4. **Joins**: Handle unmatched rows appropriately


- **Ask about database**: Different databases have different functions
- **Explain business logic**: Why specific defaults were chosen
- **Performance**: NULL handling is usually efficient
- **Edge cases**: What if all values are NULL?
- **Alternatives**: CASE vs COALESCE readability trade-offs


- **E-commerce**: Default shipping costs, discount handling
- **Financial data**: Missing interest rates, default values
- **User profiles**: Optional fields with defaults
- **Reporting**: Handling incomplete data sets
