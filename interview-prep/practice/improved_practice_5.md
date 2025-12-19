# 🎯 SQL Practice 5: Comprehensive Database Operations

## Question
Complete the following comprehensive SQL exercises using the Warehouses and Boxes tables to practice SELECT queries, JOINs, aggregations, DML operations, and index management.

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE IF NOT EXISTS Exercise;
USE Exercise;

CREATE TABLE Warehouses (
   Code INTEGER NOT NULL,
   Location VARCHAR(255) NOT NULL,
   Capacity INTEGER NOT NULL,
   PRIMARY KEY (Code)
);

CREATE TABLE Boxes (
    Code CHAR(4) NOT NULL,
    Contents VARCHAR(255) NOT NULL,
    Value REAL NOT NULL,
    Warehouse INTEGER NOT NULL,
    PRIMARY KEY (Code),
    FOREIGN KEY (Warehouse) REFERENCES Warehouses(Code)
) ENGINE=INNODB;

INSERT INTO Warehouses(Code, Location, Capacity) VALUES
(1, 'Chicago', 3),
(2, 'Chicago', 4),
(3, 'New York', 7),
(4, 'Los Angeles', 2),
(5, 'San Francisco', 8);

INSERT INTO Boxes(Code, Contents, Value, Warehouse) VALUES
('0MN7', 'Rocks', 180, 3),
('4H8P', 'Rocks', 250, 1),
('4RT3', 'Scissors', 190, 4),
('7G3H', 'Rocks', 200, 1),
('8JN6', 'Papers', 75, 1),
('8Y6U', 'Papers', 50, 3),
('9J6F', 'Papers', 175, 2),
('LL08', 'Rocks', 140, 4),
('P0H6', 'Scissors', 125, 1),
('P2T6', 'Scissors', 150, 2),
('TU55', 'Papers', 90, 5);
```

## Query 3.1: Select all warehouses

```sql
SELECT * FROM Warehouses;
```

**Expected Output**: All warehouse records with Code, Location, and Capacity

## Query 3.2: Select all boxes with a value larger than $150

```sql
SELECT * FROM Boxes WHERE Value > 150;
```

**Expected Output**: Boxes with Value > 150 (0MN7, 4H8P, 4RT3, 7G3H, 9J6F)

## Query 3.3: Select all distinct contents in all the boxes

```sql
SELECT DISTINCT Contents FROM Boxes;
```

**Expected Output**: Unique contents (Rocks, Scissors, Papers)

## Query 3.4: Select the average value of all the boxes

```sql
SELECT AVG(Value) FROM Boxes;
```

**Expected Output**: Average value of all boxes

## Query 3.5: Select the warehouse code and the average value of the boxes in each warehouse

```sql
SELECT Warehouse, AVG(Value) FROM Boxes GROUP BY Warehouse;

-- Alternative syntax:
SELECT Warehouse, AVG(Value)
FROM Boxes
GROUP BY Warehouse;
```

**Expected Output**: Average value per warehouse

## Query 3.6: Same as previous exercise, but select only those warehouses where the average value of the boxes is greater than 150

```sql
SELECT Warehouse, AVG(Value)
FROM Boxes
GROUP BY Warehouse
HAVING AVG(Value) > 150;
```

**Expected Output**: Warehouses where average box value > 150

## Query 3.7: Select the code of each box, along with the name of the city the box is located in

```sql
SELECT Boxes.Code, Warehouses.Location
FROM Boxes JOIN Warehouses
ON Boxes.Warehouse = Warehouses.Code;

-- Alternative syntax:
SELECT Boxes.Code, Location
FROM Warehouses
INNER JOIN Boxes ON Warehouses.Code = Boxes.Warehouse;
```

**Expected Output**: Each box code with its warehouse city

## Query 3.8: Select the warehouse codes, along with the number of boxes in each warehouse

```sql
SELECT Warehouse, COUNT(*)
FROM Boxes
GROUP BY Warehouse;
```

**Note**: This query doesn't show empty warehouses (would need LEFT JOIN with Warehouses table)

## Query 3.9: Select the codes of all warehouses that are saturated (number of boxes > warehouse capacity)

```sql
SELECT Code
FROM Warehouses JOIN (SELECT Warehouse temp_a, COUNT(*) temp_b FROM Boxes GROUP BY Warehouse) temp
ON (Warehouses.Code = temp.temp_a)
WHERE Warehouses.Capacity < temp.temp_b;

-- Alternative with subquery:
SELECT Code
FROM Warehouses
WHERE Capacity <
(
  SELECT COUNT(*)
  FROM Boxes
  WHERE Warehouse = Warehouses.Code
);
```

**Expected Output**: Warehouse codes that are over capacity

## Query 3.10: Select the codes of all the boxes located in Chicago

```sql
SELECT Boxes.Code
FROM Boxes JOIN Warehouses
ON Boxes.Warehouse = Warehouses.Code
WHERE Warehouses.Location = 'Chicago';

/* Without subqueries */
SELECT Boxes.Code
FROM Warehouses LEFT JOIN Boxes
ON Warehouses.Code = Boxes.Warehouse
WHERE Location = 'Chicago';

/* With a subquery */
SELECT Code
FROM Boxes
WHERE Warehouse IN
(
  SELECT Code
  FROM Warehouses
  WHERE Location = 'Chicago'
);
```

**Expected Output**: Box codes in Chicago warehouses

## Query 3.11: Create a new warehouse in New York with a capacity for 3 boxes

```sql
INSERT INTO Warehouses VALUES (6, 'New York', 3);
```

**Result**: New warehouse added with Code=6, Location='New York', Capacity=3

## Query 3.12: Create a new box, with code "H5RT", containing "Papers" with a value of $200, and located in warehouse 2

```sql
INSERT INTO Boxes VALUES('H5RT', 'Papers', 200, 2);
```

**Result**: New box added to warehouse 2

## Query 3.13: Reduce the value of all boxes by 15%

```sql
UPDATE Boxes
SET Value = Value * 0.85;
```

**Result**: All box values reduced by 15%

## Query 3.14: Remove all boxes with a value lower than $100

```sql
DELETE FROM Boxes
WHERE Value < 100;
```

**Result**: Boxes with value < $100 removed

## Query 3.15: Remove all boxes from saturated warehouses

```sql
DELETE FROM Boxes
WHERE Warehouse IN
(
  SELECT Code
  FROM Warehouses
  WHERE Capacity <
  (
    SELECT COUNT(*)
    FROM Boxes
    WHERE Warehouse = Warehouses.Code
  )
);
```

**Result**: Boxes removed from warehouses that are over capacity

## Query 3.16: Add Index for column "Warehouse" in table "boxes"

```sql
-- !!!NOTE!!!: index should NOT be used on small tables in practice
CREATE INDEX INDEX_WAREHOUSE ON Boxes (Warehouse);
```

**Result**: Index created on Warehouse column

## Query 3.17: Print all the existing indexes

```sql
-- !!!NOTE!!!: index should NOT be used on small tables in practice

-- MySQL
SHOW INDEX FROM Boxes FROM Exercise;
-- OR
SHOW INDEX FROM Exercise.Boxes;

-- SQLite
.indexes Boxes
-- OR
SELECT * FROM SQLITE_MASTER WHERE type = "index";

-- Oracle
SELECT INDEX_NAME, TABLE_NAME, TABLE_OWNER
FROM SYS.ALL_INDEXES
ORDER BY TABLE_OWNER, TABLE_NAME, INDEX_NAME;
```

**Result**: Lists all indexes on the Boxes table

## Query 3.18: Remove (drop) the index you added

```sql
-- !!!NOTE!!!: index should NOT be used on small tables in practice
DROP INDEX INDEX_WAREHOUSE;
```

**Result**: Index removed from Warehouse column

## Key Concepts Covered

- **Basic SELECT**: Table queries and column selection
- **Filtering**: WHERE clauses with comparisons
- **DISTINCT**: Removing duplicates
- **Aggregations**: AVG, COUNT with GROUP BY and HAVING
- **JOINs**: INNER JOIN and LEFT JOIN operations
- **Subqueries**: Nested queries and correlated subqueries
- **DML Operations**: INSERT, UPDATE, DELETE statements
- **Index Management**: CREATE INDEX and DROP INDEX
- **Cross-Platform**: SQL variations for different databases

## Interview Tips

- **JOIN Performance**: Understand when different JOIN types are appropriate
- **Index Strategy**: Know when and how to create indexes
- **Subquery Usage**: Correlated vs non-correlated subqueries
- **Aggregate Functions**: GROUP BY and HAVING clause usage
- **Data Modification**: ACID properties and transaction safety

## Real-World Application

These exercises cover essential SQL operations used in:
- Inventory management systems
- Warehouse operations
- E-commerce platforms
- Supply chain management
- Database administration tasks
- Business intelligence reporting
