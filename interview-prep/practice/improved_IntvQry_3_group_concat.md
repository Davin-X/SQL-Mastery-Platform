# 🎯 String Aggregation Interview Question

## Question
Given a `products` table with product names and their categories, write a query to show each category with a comma-separated list of all products in that category, ordered alphabetically.

**Sample Input:**
```
category    | product_name
------------|-------------
Electronics | Laptop
Electronics | Mouse  
Electronics | Keyboard
Books       | Novel
Books       | Textbook
```

**Expected Output:**
```
category    | products_list
------------|-------------------
Books       | Novel, Textbook
Electronics | Keyboard, Laptop, Mouse
```

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(8,2)
);

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 999.99),
(2, 'Mouse', 'Electronics', 29.99),
(3, 'Keyboard', 'Electronics', 79.99),
(4, 'Novel', 'Books', 19.99),
(5, 'Textbook', 'Books', 89.99),
(6, 'Tablet', 'Electronics', 499.99);
```

## Answer 1: MySQL (GROUP_CONCAT)

```sql
SELECT 
    category,
    GROUP_CONCAT(product_name ORDER BY product_name SEPARATOR ', ') AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

**How it works**: GROUP_CONCAT() aggregates strings with a custom separator. The ORDER BY clause sorts products alphabetically within each group.

## Answer 2: PostgreSQL (STRING_AGG)

```sql
SELECT 
    category,
    STRING_AGG(product_name, ', ' ORDER BY product_name) AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

**How it works**: STRING_AGG() is PostgreSQL's equivalent to MySQL's GROUP_CONCAT(). Same functionality with different syntax.

## Answer 3: SQL Server (STRING_AGG)

```sql
SELECT 
    category,
    STRING_AGG(product_name, ', ') WITHIN GROUP (ORDER BY product_name) AS products_list
FROM products
GROUP BY category
ORDER BY category;
```

**How it works**: SQL Server also uses STRING_AGG() but requires WITHIN GROUP clause for ordering.

## Alternative: XML Path (SQL Server - older versions)

```sql
SELECT 
    category,
    STUFF((
        SELECT ', ' + product_name
        FROM products p2
        WHERE p2.category = p1.category
        ORDER BY product_name
        FOR XML PATH('')
    ), 1, 2, '') AS products_list
FROM (SELECT DISTINCT category FROM products) p1
ORDER BY category;
```

**How it works**: Uses XML PATH to concatenate strings, then STUFF() to remove the leading comma. More complex but works in older SQL Server versions.

## Database-Specific Notes

- **MySQL**: GROUP_CONCAT() with optional SEPARATOR and ORDER BY
- **PostgreSQL**: STRING_AGG() with ORDER BY in function call
- **SQL Server**: STRING_AGG() with WITHIN GROUP (ORDER BY)
- **Oracle**: LISTAGG() function instead
- **SQLite**: GROUP_CONCAT() like MySQL

## Common Issues

1. **Length Limits**: MySQL GROUP_CONCAT has a default 1024 character limit
2. **NULL Values**: NULL values are ignored in aggregation
3. **Empty Groups**: Categories with no products won't appear
4. **Sorting**: Without ORDER BY, results may be in arbitrary order


- **Ask about database**: Different databases have different functions
- **Mention alternatives**: XML PATH for older SQL Server
- **Consider performance**: String aggregation can be expensive on large datasets
- **Edge cases**: Empty categories, special characters in product names


- **Product catalogs**: Group products by category for display
- **Tag systems**: Show all tags for an article
- **Report generation**: Combine multiple values in a single cell
- **Email lists**: Concatenate emails by department
