# 🎯 SQL Practice 9: Interplanetary Shipping Management

## Question
Complete the following SQL exercises using the interplanetary shipping database (inspired by Futurama) to practice package tracking, client analysis, and multi-table relationship queries.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE Employee (
  EmployeeID INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Position VARCHAR(255) NOT NULL,
  Salary REAL NOT NULL,
  Remarks VARCHAR(255)
) ENGINE = InnoDB;

CREATE TABLE Planet (
  PlanetID INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Coordinates REAL NOT NULL
) ENGINE = InnoDB;

CREATE TABLE Shipment (
  ShipmentID INTEGER PRIMARY KEY,
  Date DATE,
  Manager INTEGER NOT NULL,
  Planet INTEGER NOT NULL,
  FOREIGN KEY (Manager) REFERENCES Employee(EmployeeID),
  FOREIGN KEY (Planet) REFERENCES Planet(PlanetID)
) ENGINE = InnoDB;

CREATE TABLE Has_Clearance (
  Employee INTEGER NOT NULL,
  Planet INTEGER NOT NULL,
  Level INTEGER NOT NULL,
  PRIMARY KEY(Employee, Planet),
  FOREIGN KEY (Employee) REFERENCES Employee(EmployeeID),
  FOREIGN KEY (Planet) REFERENCES Planet(PlanetID)
) ENGINE = InnoDB;

CREATE TABLE Client (
  AccountNumber INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE Package (
  Shipment INTEGER NOT NULL,
  PackageNumber INTEGER NOT NULL,
  Contents VARCHAR(255) NOT NULL,
  Weight FLOAT NOT NULL,
  Sender INTEGER NOT NULL,
  Recipient INTEGER NOT NULL,
  PRIMARY KEY (Shipment, PackageNumber),
  FOREIGN KEY (Shipment) REFERENCES Shipment (ShipmentID),
  FOREIGN KEY (Sender) REFERENCES Client (AccountNumber),
  FOREIGN KEY (Recipient) REFERENCES Client (AccountNumber)
) ENGINE = InnoDB;

INSERT INTO Client VALUES
(1, 'Zapp Brannigan'),
(2, 'Al Gore''s Head'),
(3, 'Barbados Slim'),
(4, 'Ogden Wernstrom'),
(5, 'Leo Wong'),
(6, 'Lrrr'),
(7, 'John Zoidberg'),
(8, 'John Zoidfarb'),
(9, 'Morbo'),
(10, 'Judge John Whitey'),
(11, 'Calculon');

INSERT INTO Employee VALUES
(1, 'Phillip J. Fry', 'Delivery boy', 7500.0, 'Not to be confused with the Philip J. Fry from Hovering Squid World 97a'),
(2, 'Turanga Leela', 'Captain', 10000.0, NULL),
(3, 'Bender Bending Rodriguez', 'Robot', 7500.0, NULL),
(4, 'Hubert J. Farnsworth', 'CEO', 20000.0, NULL),
(5, 'John A. Zoidberg', 'Physician', 25.0, NULL),
(6, 'Amy Wong', 'Intern', 5000.0, NULL),
(7, 'Hermes Conrad', 'Bureaucrat', 10000.0, NULL),
(8, 'Scruffy Scruffington', 'Janitor', 5000.0, NULL);

INSERT INTO Planet VALUES
(1, 'Omicron Persei 8', 89475345.3545),
(2, 'Decapod X', 65498463216.3466),
(3, 'Mars', 32435021.65468),
(4, 'Omega III', 98432121.5464),
(5, 'Tarantulon VI', 849842198.354654),
(6, 'Cannibalon', 654321987.21654),
(7, 'DogDoo VII', 65498721354.688),
(8, 'Nintenduu 64', 6543219894.1654),
(9, 'Amazonia', 65432135979.6547);

INSERT INTO Has_Clearance VALUES
(1, 1, 2),
(1, 2, 3),
(2, 3, 2),
(2, 4, 4),
(3, 5, 2),
(3, 6, 4),
(4, 7, 1);

INSERT INTO Shipment VALUES
(1, '3004/05/11', 1, 1),
(2, '3004/05/11', 1, 2),
(3, NULL, 2, 3),
(4, NULL, 2, 4),
(5, NULL, 7, 5);

INSERT INTO Package VALUES
(1, 1, 'Undeclared', 1.5, 1, 2),
(2, 1, 'Undeclared', 10.0, 2, 3),
(2, 2, 'A bucket of krill', 2.0, 8, 7),
(3, 1, 'Undeclared', 15.0, 3, 4),
(3, 2, 'Undeclared', 3.0, 5, 1),
(3, 3, 'Undeclared', 7.0, 2, 3),
(4, 1, 'Undeclared', 5.0, 4, 5),
(4, 2, 'Undeclared', 27.0, 1, 2),
(5, 1, 'Undeclared', 100.0, 5, 1);
```

## Query 7.1: Who received a 1.5kg package?

```sql
SELECT Recipient FROM Package WHERE Weight = 1.5;

-- With client names
SELECT Client.Name
FROM Client JOIN Package
ON Client.AccountNumber = Package.Recipient
WHERE Package.Weight = 1.5;

-- Alternative syntax
SELECT Client.Name
FROM Client JOIN Package
  ON Client.AccountNumber = Package.Recipient
WHERE Package.Weight = 1.5;
```

**Expected Output**: "Al Gore's Head" (Client AccountNumber = 2)

## Query 7.2: What is the total weight of all the packages that he sent?

```sql
SELECT SUM(Weight) FROM Package
WHERE Sender = (
  SELECT Recipient FROM Package WHERE Weight = 1.5
);

-- Alternative with JOIN
SELECT SUM(P.Weight)
FROM Client AS C
  JOIN Package AS P
  ON C.AccountNumber = P.Sender
WHERE C.Name = "Al Gore's Head";
```

**Expected Output**: Total weight of packages sent by "Al Gore's Head"

## Additional Practice Queries (Based on Schema)

### Package Tracking and Analysis

**7.3: List all packages with sender and recipient names**
```sql
SELECT 
    P.Shipment,
    P.PackageNumber,
    P.Contents,
    P.Weight,
    Sender.Name AS Sender_Name,
    Recipient.Name AS Recipient_Name
FROM Package P
JOIN Client Sender ON P.Sender = Sender.AccountNumber
JOIN Client Recipient ON P.Recipient = Recipient.AccountNumber
ORDER BY P.Shipment, P.PackageNumber;
```

**Expected Output**: Complete package details with client names

**7.4: Find the heaviest package in each shipment**
```sql
SELECT 
    P1.Shipment,
    P1.PackageNumber,
    P1.Contents,
    P1.Weight,
    C.Name AS Recipient
FROM Package P1
JOIN Client C ON P1.Recipient = C.AccountNumber
WHERE P1.Weight = (
    SELECT MAX(P2.Weight)
    FROM Package P2
    WHERE P2.Shipment = P1.Shipment
)
ORDER BY P1.Shipment;
```

**Expected Output**: Heaviest package per shipment

**7.5: Calculate total weight and package count per shipment**
```sql
SELECT 
    Shipment,
    COUNT(*) AS Package_Count,
    SUM(Weight) AS Total_Weight,
    AVG(Weight) AS Avg_Package_Weight
FROM Package
GROUP BY Shipment
ORDER BY Shipment;
```

**Expected Output**: Shipment summary statistics

### Employee and Clearance Analysis

**7.6: List employees and their planet clearances**
```sql
SELECT 
    E.Name AS Employee_Name,
    E.Position,
    P.Name AS Planet_Name,
    HC.Level AS Clearance_Level
FROM Employee E
JOIN Has_Clearance HC ON E.EmployeeID = HC.Employee
JOIN Planet P ON HC.Planet = P.PlanetID
ORDER BY E.Name, P.Name;
```

**Expected Output**: Employee clearance levels for each planet

**7.7: Find employees with the highest clearance level**
```sql
SELECT 
    E.Name,
    MAX(HC.Level) AS Max_Clearance_Level,
    COUNT(HC.Planet) AS Planets_Accessible
FROM Employee E
JOIN Has_Clearance HC ON E.EmployeeID = HC.Employee
GROUP BY E.EmployeeID, E.Name
HAVING MAX(HC.Level) = (SELECT MAX(Level) FROM Has_Clearance)
ORDER BY Max_Clearance_Level DESC;
```

**Expected Output**: Employees with highest clearance levels

### Shipment and Management Analysis

**7.8: List all shipments with manager and destination planet**
```sql
SELECT 
    S.ShipmentID,
    S.Date,
    E.Name AS Manager_Name,
    P.Name AS Destination_Planet,
    P.Coordinates
FROM Shipment S
JOIN Employee E ON S.Manager = E.EmployeeID
JOIN Planet P ON S.Planet = P.PlanetID
ORDER BY S.Date DESC, S.ShipmentID;
```

**Expected Output**: Complete shipment information

**7.9: Find shipments managed by each employee**
```sql
SELECT 
    E.Name AS Manager_Name,
    COUNT(S.ShipmentID) AS Shipments_Managed,
    COUNT(DISTINCT S.Planet) AS Planets_Served
FROM Employee E
LEFT JOIN Shipment S ON E.EmployeeID = S.Manager
GROUP BY E.EmployeeID, E.Name
ORDER BY Shipments_Managed DESC;
```

**Expected Output**: Management workload per employee

### Complex Business Intelligence

**7.10: Comprehensive shipping analytics**
```sql
SELECT 
    E.Name AS Manager,
    P.Name AS Planet,
    COUNT(S.ShipmentID) AS Shipments,
    COUNT(Pkg.PackageNumber) AS Packages,
    SUM(Pkg.Weight) AS Total_Weight,
    COUNT(DISTINCT Pkg.Sender) AS Unique_Senders,
    COUNT(DISTINCT Pkg.Recipient) AS Unique_Recipients
FROM Employee E
LEFT JOIN Shipment S ON E.EmployeeID = S.Manager
LEFT JOIN Planet P ON S.Planet = P.PlanetID
LEFT JOIN Package Pkg ON S.ShipmentID = Pkg.Shipment
GROUP BY E.EmployeeID, E.Name, P.PlanetID, P.Name
ORDER BY E.Name, P.Name;
```

**Expected Output**: Comprehensive shipping analytics by manager and planet

- **Employee clearances**: Many-to-many with security levels
- **Shipment management**: Linking managers, planets, and packages
- **Package tracking**: Sender/recipient relationships through shipments

### Real-World Business Logic
- **Security clearances**: Access control for different planets
- **Package routing**: Interplanetary shipping logistics
- **Management oversight**: Employee responsibilities and workloads

### Advanced Query Patterns
- **Correlated subqueries**: Finding max values per group
- **Multiple JOINs**: 4-5 table relationships
- **LEFT JOINs**: Handling missing relationships
- **Aggregate functions**: Business metrics and KPIs


- **Complex schemas**: Understanding business domain relationships
- **Security models**: Access control and clearance levels
- **Supply chain**: Package tracking and logistics
- **Performance**: Optimizing multi-table queries
- **Data integrity**: Foreign key relationships and constraints


These patterns are essential for:
- **Shipping companies**: Package tracking and routing
- **Security systems**: Access control and clearance management
- **Logistics**: Supply chain management and optimization
- **Government**: Planetary exploration and mission management
- **Any system with complex permissions and routing**


- **Index strategy**: Foreign keys need indexing for JOIN performance
- **Query optimization**: Complex JOINs may need query tuning
- **Data distribution**: Consider partitioning for large datasets
- **Caching**: Frequently accessed clearance data could be cached

## Business Logic Examples

- **Route optimization**: Finding best shipping paths between planets
- **Capacity planning**: Managing employee workloads and clearances
- **Quality assurance**: Tracking package integrity across shipments
- **Customer service**: Package status and delivery tracking
- **Compliance**: Ensuring proper clearances for restricted planets

## Futurama Theme Notes

This dataset is inspired by the animated series *Futurama*, featuring:
- **Planet Express crew**: Delivery employees with unique personalities
- **Interplanetary shipping**: Packages delivered across the galaxy
- **Alien clients**: Diverse recipients from different planets
- **Security clearances**: Access levels for different planetary destinations

The queries demonstrate how real-world shipping and logistics systems work, just with a more entertaining theme!
