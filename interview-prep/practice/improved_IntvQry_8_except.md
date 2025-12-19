# 🎯 Set Operations - EXCEPT/MINUS Interview Question

## Question
Given two tables of customer data from different systems, find customers who exist in the first system but not in the second system (using set operations).

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE system_a_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE system_b_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO system_a_customers VALUES
(1, 'Alice Johnson', 'alice@email.com'),
(2, 'Bob Smith', 'bob@email.com'),
(3, 'Charlie Brown', 'charlie@email.com'),
(4, 'Diana Prince', 'diana@email.com'),
(5, 'Eve Wilson', 'eve@email.com');

INSERT INTO system_b_customers VALUES
(1, 'Alice Johnson', 'alice@email.com'),
(2, 'Bob Smith', 'bob@email.com'),
(6, 'Frank Miller', 'frank@email.com'),
(7, 'Grace Lee', 'grace@email.com');
```

## Answer: Using EXCEPT (SQL Server/PostgreSQL)

```sql
SELECT customer_id, customer_name, email
FROM system_a_customers
EXCEPT
SELECT customer_id, customer_name, email
FROM system_b_customers;
```

**Result**: Returns customers 3, 4, 5 (Charlie, Diana, Eve)

**How it works**: EXCEPT returns rows from the first query that don't exist in the second query. All columns must match exactly.

## Alternative: Using MINUS (Oracle)

```sql
SELECT customer_id, customer_name, email
FROM system_a_customers
MINUS
SELECT customer_id, customer_name, email
FROM system_b_customers;
```

**How it works**: MINUS is Oracle's equivalent of EXCEPT.

## Alternative: Using NOT EXISTS

```sql
SELECT sa.customer_id, sa.customer_name, sa.email
FROM system_a_customers sa
WHERE NOT EXISTS (
    SELECT 1
    FROM system_b_customers sb
    WHERE sa.customer_id = sb.customer_id
    AND sa.customer_name = sb.customer_name
    AND sa.email = sb.email
);
```

**How it works**: Correlated subquery checks if each row from system_a has a matching row in system_b.

## Alternative: Using LEFT JOIN

```sql
SELECT sa.customer_id, sa.customer_name, sa.email
FROM system_a_customers sa
LEFT JOIN system_b_customers sb ON 
    sa.customer_id = sb.customer_id AND
    sa.customer_name = sb.customer_name AND
    sa.email = sb.email
WHERE sb.customer_id IS NULL;
```

**How it works**: LEFT JOIN includes all rows from system_a, then filters for rows where no match was found in system_b.

## Set Operations by Database

| Operation | MySQL | PostgreSQL | SQL Server | Oracle |
|-----------|-------|------------|------------|--------|
| EXCEPT | ❌ (use LEFT JOIN) | ✅ | ✅ | ❌ |
| MINUS | ❌ | ❌ | ❌ | ✅ |
| INTERSECT | ❌ (use INNER JOIN) | ✅ | ✅ | ✅ |
| UNION | ✅ | ✅ | ✅ | ✅ |

## Performance Comparison

### EXCEPT/MINUS:
- **Pros**: Clean syntax, optimized for set operations
- **Cons**: Not available in all databases
- **Best for**: Exact duplicate elimination

### NOT EXISTS:
- **Pros**: Works in all databases, can use indexes
- **Cons**: Correlated subquery can be slower
- **Best for**: Complex matching conditions

### LEFT JOIN:
- **Pros**: Works in all databases, often fastest
- **Cons**: More verbose syntax
- **Best for**: Simple key-based comparisons

## Common Interview Patterns

1. **Data Migration**: Finding records that didn't transfer
2. **System Integration**: Identifying missing data between systems
3. **Data Quality**: Finding duplicates or missing records
4. **Audit Trails**: Comparing expected vs actual data

## Important Notes

- **Column Count**: Both queries must have same number of columns
- **Data Types**: Corresponding columns must have compatible types
- **NULL Handling**: NULL = NULL is false, so NULLs affect matching
- **Duplicates**: Set operations automatically remove duplicates

## Interview Tips

- **Database Awareness**: EXCEPT works in PostgreSQL/SQL Server, MINUS in Oracle
- **Alternatives**: Know NOT EXISTS and LEFT JOIN approaches
- **Performance**: LEFT JOIN is often fastest, but EXCEPT can be optimized
- **Use Cases**: System comparison, data validation, migration verification
- **Edge Cases**: NULL values, partial matches, data type differences

## Real-World Applications

- **ETL Processes**: Verifying data transfer completeness
- **System Migration**: Finding records that didn't migrate
- **Data Reconciliation**: Comparing financial records between systems
- **User Management**: Finding users in one system but not another
- **Inventory Control**: Identifying stock discrepancies
