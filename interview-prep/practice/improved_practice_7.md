# 🎯 SQL Practice 7: Supply Chain Management - Complex Relationships

## Question
Complete the following SQL exercises using the Pieces, Providers, and Provides tables to practice complex multi-table relationships, subqueries, and supply chain business logic.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE Pieces (
  Code INTEGER PRIMARY KEY NOT NULL,
  Name TEXT NOT NULL
);

CREATE TABLE Providers (
  Code VARCHAR(40) PRIMARY KEY NOT NULL,
  Name TEXT NOT NULL
);

CREATE TABLE Provides (
  Piece INTEGER,
  FOREIGN KEY (Piece) REFERENCES Pieces(Code),
  Provider VARCHAR(40),
  FOREIGN KEY (Provider) REFERENCES Providers(Code),
  Price INTEGER NOT NULL,
  PRIMARY KEY(Piece, Provider)
);

-- Alternative schema for SQLite
/*
CREATE TABLE Provides (
  Piece INTEGER,
  Provider VARCHAR(40),
  Price INTEGER NOT NULL,
  PRIMARY KEY(Piece, Provider)
);
*/

INSERT INTO Providers(Code, Name) VALUES
('HAL', 'Clarke Enterprises'),
('RBT', 'Susan Calvin Corp.'),
('TNBC', 'Skellington Supplies');

INSERT INTO Pieces(Code, Name) VALUES
(1, 'Sprocket'),
(2, 'Screw'),
(3, 'Nut'),
(4, 'Bolt');

INSERT INTO Provides(Piece, Provider, Price) VALUES
(1, 'HAL', 10),
(1, 'RBT', 15),
(2, 'HAL', 20),
(2, 'RBT', 15),
(2, 'TNBC', 14),
(3, 'RBT', 50),
(3, 'TNBC', 45),
(4, 'HAL', 5),
(4, 'RBT', 7);
```

## Query 5.1: Select the name of all the pieces

```sql
SELECT Name FROM Pieces;
```

**Expected Output**: All piece names (Sprocket, Screw, Nut, Bolt)

## Query 5.2: Select all the providers' data

```sql
SELECT * FROM Providers;
```

**Expected Output**: All provider records with codes and names

## Query 5.3: Obtain the average price of each piece (show only the piece code and the average price)

```sql
SELECT Piece, AVG(Price)
FROM Provides
GROUP BY Piece;
```

**Expected Output**: Average price for each piece code

## Query 5.4: Obtain the names of all providers who supply piece 1

```sql
SELECT Name
FROM Providers
WHERE Code IN (
  SELECT Provider FROM Provides WHERE Piece = 1
);

-- Alternative with JOIN
SELECT Providers.Name
FROM Providers JOIN Provides
ON Providers.Code = Provides.Provider
WHERE Provides.Piece = 1;

/* Without subquery */
SELECT Providers.Name
FROM Providers INNER JOIN Provides
ON Providers.Code = Provides.Provider
AND Provides.Piece = 1;

/* With subquery */
SELECT Name
FROM Providers
WHERE Code IN
(SELECT Provider FROM Provides WHERE Piece = 1);
```

**Expected Output**: Provider names supplying piece 1 (Clarke Enterprises, Susan Calvin Corp.)

## Query 5.5: Select the name of pieces provided by provider with code "HAL"

```sql
SELECT Name FROM Pieces
WHERE Code IN (
  SELECT Piece FROM Provides WHERE Provider = 'HAL'
);

-- Alternative with JOIN
SELECT Pieces.Name
FROM Pieces JOIN Provides
ON (Pieces.Code = Provides.Piece)
WHERE Provides.Provider = 'HAL';

/* With EXISTS subquery - Interesting clause */
SELECT Name
FROM Pieces
WHERE EXISTS
(
  SELECT * FROM Provides
  WHERE Provider = 'HAL'
  AND Piece = Pieces.Code
);
```

**Expected Output**: Pieces provided by HAL (Sprocket, Screw, Bolt)

## Query 5.6: For each piece, find the most expensive offering of that piece and include the piece name, provider name, and price

```sql
-- WRONG solution
SELECT a.Name, a.Code, b.Price, c.Name
FROM Pieces a JOIN Provides b
ON a.Code = b.Piece
JOIN Providers c
ON b.Provider = c.Code
GROUP BY a.Code;
-- This is wrong since when I group by a.code, SQL will automatically select the first c.Name in each group to return, which is not what we expected.

-- CORRECT SOLUTION
SELECT Pieces.Name, Providers.Name, Price
FROM Pieces INNER JOIN Provides ON Pieces.Code = Piece
            INNER JOIN Providers ON Providers.Code = Provider
WHERE Price =
(
  SELECT MAX(Price) FROM Provides
  WHERE Piece = Pieces.Code
);
-- This is worthwhile to look into again
```

**Expected Output**: Each piece with its most expensive provider and price

## Query 5.7: Add an entry to indicate that "Skellington Supplies" (code "TNBC") will provide sprockets (code "1") for 7 cents each

```sql
INSERT INTO Provides(Piece, Provider, Price) VALUES (1, 'TNBC', 7);
```

**Result**: New supply relationship added

## Query 5.8: Increase all prices by one cent

```sql
UPDATE Provides
SET Price = Price + 1;
```

**Result**: All prices increased by 1

## Query 5.9: Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply bolts (code 4)

```sql
DELETE FROM Provides WHERE Provider = 'RBT' AND Piece = 4;
```

**Result**: Specific supply relationship removed

## Query 5.10: Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply any pieces

```sql
DELETE FROM Provides
WHERE Provider = 'RBT';
```

**Result**: All supply relationships for RBT removed (provider still exists)

## Key Concepts Demonstrated

### Complex Multi-Table Relationships
- **Many-to-many relationships**: Pieces ↔ Providers via Provides table
- **Foreign key constraints**: Maintaining referential integrity
- **Composite primary keys**: (Piece, Provider) uniqueness

### Advanced Query Patterns
- **Subqueries in WHERE**: IN clauses and correlated EXISTS
- **Multi-table JOINs**: 3+ table relationships
- **Aggregate with JOIN**: GROUP BY across related tables

### Critical GROUP BY Warning
```sql
-- WRONG: GROUP BY with JOIN can give unexpected results
SELECT a.Name, a.Code, b.Price, c.Name
FROM Pieces a JOIN Provides b ON a.Code = b.Piece
JOIN Providers c ON b.Provider = c.Code
GROUP BY a.Code;
-- SQL picks arbitrary values from non-grouped columns
```

### Proper Solutions
```sql
-- CORRECT: Use subquery for aggregation
SELECT Pieces.Name, Providers.Name, Price
FROM Pieces INNER JOIN Provides ON Pieces.Code = Piece
            INNER JOIN Providers ON Providers.Code = Provider
WHERE Price = (SELECT MAX(Price) FROM Provides WHERE Piece = Pieces.Code);
```

## Interview Tips

- **Many-to-many relationships**: Understand junction tables and their queries
- **GROUP BY with JOINs**: Be careful about non-aggregated columns
- **Subquery vs JOIN**: Know when each approach is appropriate
- **EXISTS vs IN**: Performance implications for different scenarios
- **Business logic**: Supply chain queries are common in interviews

## Real-World Applications

These patterns are essential for:
- **Supply chain management**: Products, suppliers, pricing
- **E-commerce platforms**: Products, vendors, inventory
- **Manufacturing**: Parts, suppliers, costs
- **Retail**: Items, distributors, pricing
- **Any many-to-many relationship** with pricing/cost data

## Common Mistakes

1. **Incorrect GROUP BY**: Including non-aggregated columns
2. **Missing table aliases**: Ambiguous column references
3. **Wrong JOIN conditions**: Cartesian products or missing data
4. **Subquery correlation**: Forgetting to correlate EXISTS subqueries
5. **NULL handling**: Not considering missing relationships

## Performance Considerations

- **Composite indexes**: On (Piece, Provider) for Provides table
- **Foreign key indexes**: Automatic with constraints
- **Subquery optimization**: EXISTS often faster than IN for large datasets
- **JOIN order**: Optimizer may rearrange, but understanding helps

## Best Practices

1. **Use meaningful aliases**: p for Pieces, pr for Providers, pv for Provides
2. **Test with sample data**: Verify complex queries return expected results
3. **Consider normalization**: Junction tables for many-to-many relationships
4. **Document business rules**: Pricing logic, supplier relationships
5. **Index foreign keys**: Critical for JOIN performance

## Business Logic Examples

- **Cost analysis**: Finding cheapest suppliers for each part
- **Supplier diversity**: Ensuring multiple suppliers per critical part
- **Price negotiations**: Comparing supplier pricing
- **Inventory optimization**: Balancing cost and availability
- **Quality control**: Tracking supplier performance metrics
