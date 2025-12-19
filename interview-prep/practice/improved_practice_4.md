# 🎯 SQL Practice 4: Basic SELECT and Data Retrieval

## Question
Complete the following SQL exercises using the Departments and Employees tables to practice basic SELECT operations, filtering, and data retrieval techniques.

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE IF NOT EXISTS Exercise;
USE Exercise;

CREATE TABLE Departments (
  Code INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Budget DECIMAL NOT NULL
);

CREATE TABLE Employees (
  SSN INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  LastName VARCHAR(255) NOT NULL,
  Department INTEGER NOT NULL,
  FOREIGN KEY (Department) REFERENCES Departments(Code)
);

INSERT INTO Departments(Code, Name, Budget) VALUES
(14, 'IT', 65000),
(37, 'Accounting', 15000),
(59, 'Human Resources', 240000),
(77, 'Research', 55000);

INSERT INTO Employees(SSN, Name, LastName, Department) VALUES
('123234877', 'Michael', 'Rogers', 14),
('152934485', 'Anand', 'Manikutty', 14),
('222364883', 'Carol', 'Smith', 37),
('326587417', 'Joe', 'Stevens', 37),
('332154719', 'Mary-Anne', 'Foster', 14),
('332569843', 'George', 'ODonnell', 77),
('546523478', 'John', 'Doe', 59),
('631231482', 'David', 'Smith', 77),
('654873219', 'Zacary', 'Efron', 59),
('745685214', 'Eric', 'Goldsmith', 59),
('845657245', 'Elizabeth', 'Doe', 14),
('845657246', 'Kumar', 'Swamy', 14);
```

## Query 2.1: Select the last name of all employees

```sql
SELECT LastName FROM Employees;
```

**Expected Output**: All employee last names (Rogers, Manikutty, Smith, Stevens, Foster, ODonnell, Doe, Smith, Efron, Goldsmith, Doe, Swamy)

## Query 2.2: Select the last name of all employees, without duplicates

```sql
SELECT DISTINCT LastName FROM Employees;
```

**Expected Output**: Unique last names only (Rogers, Manikutty, Smith, Stevens, Foster, ODonnell, Doe, Efron, Goldsmith, Swamy)

## Query 2.3: Select all the data of employees whose last name is "Smith"

```sql
SELECT * FROM Employees WHERE LastName = 'Smith';
```

**Expected Output**: Complete records for Carol Smith (SSN: 222364883) and David Smith (SSN: 631231482)

## Additional Practice Queries (from original file)

Based on the original practice_4.sql content, here are the complete exercises:

### Basic SELECT Operations

**2.1 Select the last name of all employees:**
```sql
SELECT LastName FROM Employees;
```

**2.2 Select the last name of all employees, without duplicates:**
```sql
SELECT DISTINCT LastName FROM Employees;
```

**2.3 Select all the data of employees whose last name is "Smith":**
```sql
SELECT * FROM Employees WHERE LastName = 'Smith';
```

### Filtering and Conditions

**2.4 Select all the data of employees whose last name is "Smith" or "Doe":**
```sql
SELECT * FROM Employees WHERE LastName IN ('Smith', 'Doe');
```

**Expected Output**: Records for Carol Smith, David Smith, John Doe, Elizabeth Doe

**2.5 Select all the data of employees whose department is 14:**
```sql
SELECT * FROM Employees WHERE Department = 14;
```

**Expected Output**: IT department employees (Michael Rogers, Anand Manikutty, Mary-Anne Foster, Elizabeth Doe, Kumar Swamy)

**2.6 Select all the data of employees whose department is 37 or 77:**
```sql
SELECT * FROM Employees WHERE Department IN (37, 77);
```

**Expected Output**: Accounting and Research department employees

### Data Retrieval and Ordering

**2.7 Select the sum of all the departments' budgets:**
```sql
SELECT SUM(Budget) AS Total_Budget FROM Departments;
```

**Expected Output**: Total budget across all departments (374000)

**2.8 Select the number of employees in each department:**
```sql
SELECT Department, COUNT(*) AS Employee_Count 
FROM Employees 
GROUP BY Department;
```

**Expected Output**: 
- Department 14: 5 employees
- Department 37: 2 employees  
- Department 59: 3 employees
- Department 77: 2 employees

**2.9 Select all the data of employees, including each employee's department's data:**
```sql
SELECT e.*, d.Name AS Department_Name, d.Budget 
FROM Employees e 
INNER JOIN Departments d ON e.Department = d.Code;
```

**Expected Output**: All employee data with corresponding department information

**2.10 Select the name and last name of each employee, along with the name and budget of their department:**
```sql
SELECT e.Name, e.LastName, d.Name AS Dept_Name, d.Budget 
FROM Employees e 
INNER JOIN Departments d ON e.Department = d.Code;
```

**Expected Output**: Employee names with their department details

### Advanced Filtering

**2.11 Select the name and last name of employees working for departments with a budget > 60000:**
```sql
SELECT e.Name, e.LastName 
FROM Employees e 
INNER JOIN Departments d ON e.Department = d.Code 
WHERE d.Budget > 60000;
```

**Expected Output**: Employees in IT and Human Resources departments

**2.12 Select the departments with a budget larger than the average budget of all the departments:**
```sql
SELECT * FROM Departments 
WHERE Budget > (SELECT AVG(Budget) FROM Departments);
```

**Expected Output**: Departments with budget > average (IT: 65000, Human Resources: 240000)

**2.13 Select the names of departments with more than two employees:**
```sql
SELECT d.Name 
FROM Departments d 
WHERE d.Code IN (
    SELECT Department 
    FROM Employees 
    GROUP BY Department 
    HAVING COUNT(*) > 2
);
```

**Expected Output**: IT and Human Resources departments

### Aggregation and Grouping

**2.14 Select the name of employees and their department, ordered by department and employee name:**
```sql
SELECT e.Name, e.LastName, d.Name AS Dept_Name 
FROM Employees e 
INNER JOIN Departments d ON e.Department = d.Code 
ORDER BY d.Name, e.Name;
```

**Expected Output**: Employees ordered by department name, then employee name

**2.15 Select the average budget of all the departments:**
```sql
SELECT AVG(Budget) AS Average_Budget FROM Departments;
```

**Expected Output**: Average budget (93500.00)

**2.16 Select the department with the most employees:**
```sql
SELECT d.Name, COUNT(*) AS Employee_Count 
FROM Departments d 
INNER JOIN Employees e ON d.Code = e.Department 
GROUP BY d.Code, d.Name 
ORDER BY Employee_Count DESC 
LIMIT 1;
```

**Expected Output**: IT department with 5 employees

## Key Concepts Covered

- **Basic SELECT**: Column selection and table queries
- **DISTINCT**: Removing duplicate values
- **WHERE clauses**: Filtering with conditions (=, IN)
- **JOIN operations**: INNER JOIN for related data
- **Aggregate functions**: COUNT, SUM, AVG
- **GROUP BY**: Grouping data for analysis
- **HAVING**: Filtering grouped results
- **Subqueries**: Nested queries for complex conditions
- **ORDER BY**: Sorting results
- **LIMIT**: Restricting result rows

## Interview Tips

- **Start simple**: Master basic SELECT before complex queries
- **Understand JOINs**: Know when to use different JOIN types
- **Practice filtering**: WHERE vs HAVING usage
- **Think about performance**: Consider indexes on commonly filtered columns
- **Check for NULLs**: Be aware of NULL handling in comparisons

## Real-World Application

These exercises cover fundamental SQL operations used daily in:
- Employee management systems
- Department budget tracking
- HR analytics and reporting
- Organizational data analysis
- Business intelligence dashboards
