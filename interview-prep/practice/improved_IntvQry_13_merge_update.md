# 🎯 MERGE/UPDATE Operations Interview Question

## Question
Given product inventory data from two sources (current inventory and supplier updates), merge the data so that:
- New products are inserted
- Existing products have their quantities updated (add supplier quantity to current)
- Products with zero total quantity are marked as discontinued

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE current_inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    current_quantity INT,
    unit_price DECIMAL(8,2),
    last_updated DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE supplier_updates (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    incoming_quantity INT,
    new_price DECIMAL(8,2),
    update_date DATE
);

INSERT INTO current_inventory VALUES
(1, 'Laptop', 50, 999.99, '2024-01-01', 'Active'),
(2, 'Mouse', 100, 29.99, '2024-01-01', 'Active'),
(3, 'Keyboard', 75, 79.99, '2024-01-01', 'Active'),
(4, 'Monitor', 25, 299.99, '2024-01-01', 'Active');

INSERT INTO supplier_updates VALUES
(1, 'Laptop', 30, 979.99, '2024-01-15'),        -- Price decrease, quantity add
(2, 'Mouse', -20, 25.99, '2024-01-15'),         -- Quantity decrease (returns)
(5, 'Tablet', 100, 499.99, '2024-01-15'),       -- New product
(6, 'Headphones', 50, 89.99, '2024-01-15');     -- Another new product
```

## Answer: MySQL - INSERT ... ON DUPLICATE KEY UPDATE

```sql
INSERT INTO current_inventory 
    (product_id, product_name, current_quantity, unit_price, last_updated, status)
SELECT 
    su.product_id,
    su.product_name,
    COALESCE(ci.current_quantity, 0) + su.incoming_quantity,
    COALESCE(su.new_price, ci.unit_price),
    su.update_date,
    CASE 
        WHEN COALESCE(ci.current_quantity, 0) + su.incoming_quantity <= 0 THEN 'Discontinued'
        ELSE 'Active'
    END
FROM supplier_updates su
LEFT JOIN current_inventory ci ON su.product_id = ci.product_id
ON DUPLICATE KEY UPDATE
    current_quantity = current_quantity + VALUES(current_quantity),
    unit_price = VALUES(unit_price),
    last_updated = VALUES(last_updated),
    status = CASE 
        WHEN current_quantity + VALUES(current_quantity) <= 0 THEN 'Discontinued'
        ELSE 'Active'
    END;
```

**How it works**: 
- INSERT ... ON DUPLICATE KEY UPDATE handles both INSERT and UPDATE
- For new products: Inserts with calculated initial quantity
- For existing products: Updates quantity by adding incoming amount
- Status changes to 'Discontinued' when total quantity <= 0

## Alternative: SQL Server - MERGE Statement

```sql
MERGE current_inventory AS target
USING (
    SELECT 
        su.product_id,
        su.product_name,
        ISNULL(ci.current_quantity, 0) + su.incoming_quantity AS new_quantity,
        ISNULL(su.new_price, ci.unit_price) AS final_price,
        su.update_date,
        CASE 
            WHEN ISNULL(ci.current_quantity, 0) + su.incoming_quantity <= 0 THEN 'Discontinued'
            ELSE 'Active'
        END AS new_status
    FROM supplier_updates su
    LEFT JOIN current_inventory ci ON su.product_id = ci.product_id
) AS source ON target.product_id = source.product_id
WHEN MATCHED THEN
    UPDATE SET 
        current_quantity = source.new_quantity,
        unit_price = source.final_price,
        last_updated = source.update_date,
        status = source.new_status
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, current_quantity, unit_price, last_updated, status)
    VALUES (source.product_id, source.product_name, source.new_quantity, 
            source.final_price, source.update_date, source.new_status);
```

**How it works**: MERGE provides explicit control over INSERT vs UPDATE operations with a single statement.

## PostgreSQL: UPSERT with ON CONFLICT

```sql
INSERT INTO current_inventory 
    (product_id, product_name, current_quantity, unit_price, last_updated, status)
SELECT 
    su.product_id,
    su.product_name,
    COALESCE(ci.current_quantity, 0) + su.incoming_quantity,
    COALESCE(su.new_price, ci.unit_price),
    su.update_date,
    CASE 
        WHEN COALESCE(ci.current_quantity, 0) + su.incoming_quantity <= 0 THEN 'Discontinued'
        ELSE 'Active'
    END
FROM supplier_updates su
LEFT JOIN current_inventory ci ON su.product_id = ci.product_id
ON CONFLICT (product_id) DO UPDATE SET
    current_quantity = EXCLUDED.current_quantity,
    unit_price = EXCLUDED.unit_price,
    last_updated = EXCLUDED.last_updated,
    status = CASE 
        WHEN EXCLUDED.current_quantity <= 0 THEN 'Discontinued'
        ELSE 'Active'
    END;
```

**How it works**: PostgreSQL's ON CONFLICT clause provides UPSERT functionality with access to both existing and new values.

## Verification Query

```sql
SELECT 
    product_id,
    product_name,
    current_quantity,
    unit_price,
    last_updated,
    status
FROM current_inventory
ORDER BY product_id;
```

**Expected Results After Merge:**
- Product 1: Quantity 80 (50+30), Price 979.99, Active
- Product 2: Quantity 80 (100-20), Price 25.99, Active  
- Product 3: Unchanged (no update)
- Product 4: Unchanged (no update)
- Product 5: New product, Quantity 100, Price 499.99, Active
- Product 6: New product, Quantity 50, Price 89.99, Active

## Performance Considerations

- **Index requirements**: Primary key or unique constraints needed for ON DUPLICATE KEY/MERGE
- **Transaction safety**: Consider wrapping in transactions for data integrity
- **Locking**: MERGE can cause more locking than separate INSERT/UPDATE
- **Batch processing**: Process updates in batches for large datasets

## Common Interview Patterns

1. **Data synchronization**: Keeping multiple systems in sync
2. **ETL processes**: Loading data with conflict resolution
3. **Inventory management**: Handling stock updates and new items
4. **Change data capture**: Applying incremental updates


- **Database differences**: MySQL uses INSERT ... ON DUPLICATE, SQL Server uses MERGE, PostgreSQL uses ON CONFLICT
- **Business logic**: Understand when to INSERT vs UPDATE vs ignore
- **Data integrity**: Consider constraints and validation rules
- **Performance**: MERGE can be expensive on large tables
- **Error handling**: What happens with constraint violations


- **Inventory systems**: Updating stock levels from multiple sources
- **ETL pipelines**: Loading data with conflict resolution
- **CRM systems**: Merging customer data from multiple channels
- **Financial systems**: Applying transaction updates
- **E-commerce**: Synchronizing product catalogs

## Database-Specific Syntax

| Database | Syntax | Key Features |
|----------|--------|--------------|
| MySQL | INSERT ... ON DUPLICATE KEY UPDATE | Simple, widely used |
| SQL Server | MERGE | Explicit control, powerful |
| PostgreSQL | INSERT ... ON CONFLICT | Standards-compliant |
| Oracle | MERGE | Similar to SQL Server |

