# 🎯 SQL Practice 1: Basic SELECT and Filtering

## Question
Write SQL queries to analyze employee data, demonstrating basic SELECT operations, WHERE clauses, and simple aggregations.

## SQL Setup

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    hire_date DATE,
    manager_id INT
);

INSERT INTO employees VALUES
(1, 'John', 'Smith', 'Engineering', 75000.00, '2020-01-15', NULL),
(2, 'Jane', 'Doe', 'Engineering', 80000.00, '2020-03-20', 1),
(3, 'Bob', 'Johnson', 'Sales', 60000.00, '2020-05-10', NULL),
(4, 'Alice', 'Brown', 'Sales', 65000.00, '2020-07-22', 3),
(5, 'Charlie', 'Wilson', 'HR', 55000.00, '2020-09-15', NULL),
(6, 'Diana', 'Davis', 'Engineering', 72000.00, '2021-01-10', 1),
(7, 'Eve', 'Miller', 'Sales', 58000.00, '2021-03-05', 3),
(8, 'Frank', 'Garcia', 'HR', 52000.00, '2021-06-20', 5);
```

## Solutions

### Query 1: Basic SELECT - All Employees
```sql
SELECT * FROM employees;
```
**Result**: All 8 employee records

### Query 2: SELECT Specific Columns
```sql
SELECT first_name, last_name, department, salary FROM employees;
```
**Result**: Employee names, departments, and salaries

### Query 3: Filter by Department
```sql
SELECT first_name, last_name, department, salary FROM employees 
WHERE department = 'Engineering';
```
**Result**: John Smith, Jane Doe, Diana Davis

### Query 4: Filter by Salary Range
```sql
SELECT first_name, last_name, salary FROM employees 
WHERE salary BETWEEN 60000 AND 75000;
```
**Result**: John Smith ($75k), Bob Johnson ($60k), Alice Brown ($65k), Diana Davis ($72k)

### Query 5: Filter with Multiple Conditions
```sql
SELECT first_name, last_name, department, salary, hire_date FROM employees 
WHERE department = 'Engineering' AND salary > 70000;
```
**Result**: Jane Doe and Diana Davis

### Query 6: Sort Results
```sql
SELECT first_name, last_name, department, salary FROM employees 
ORDER BY department, salary DESC;
```
**Result**: Employees sorted by department, then salary descending

### Query 7: Find Managers (No Manager ID)
```sql
SELECT first_name, last_name, department FROM employees 
WHERE manager_id IS NULL;
```
**Result**: John Smith, Bob Johnson, Charlie Wilson

### Query 8: Pattern Matching with LIKE
```sql
SELECT first_name, last_name, department FROM employees 
WHERE first_name LIKE 'J%';
```
**Result**: John Smith and Jane Doe

### Query 9: Calculate Average Salary
```sql
SELECT AVG(salary) AS average_salary FROM employees;
```
**Result**: Average salary across all employees

### Query 10: Count Employees by Department
```sql
SELECT department, COUNT(*) AS employee_count FROM employees 
GROUP BY department;
```
**Result**: Employee count per department

### Query 11: Find Highest Paid Employee
```sql
SELECT first_name, last_name, salary FROM employees 
WHERE salary = (SELECT MAX(salary) FROM employees);
```
**Result**: Jane Doe with $80,000

### Query 12: Recent Hires
```sql
SELECT first_name, last_name, hire_date FROM employees 
WHERE hire_date >= '2021-01-01' ORDER BY hire_date DESC;
```
**Result**: Employees hired in 2021 or later

### Query 13: Department Salary Summary
```sql
SELECT department, COUNT(*) AS num_employees, MIN(salary) AS min_salary, 
       MAX(salary) AS max_salary, AVG(salary) AS avg_salary 
FROM employees GROUP BY department;
```
**Result**: Salary statistics for each department

### Query 14: Employees Earning Above Department Average
```sql
SELECT e.first_name, e.last_name, e.department, e.salary, dept_avg.avg_salary
FROM employees e
JOIN (SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department) dept_avg 
  ON e.department = dept_avg.department
WHERE e.salary > dept_avg.avg_salary
ORDER BY e.department, e.salary DESC;
```
**Result**: Employees earning above their department average

### Query 15: Employee Hierarchy (Simple)
```sql
SELECT e.first_name + ' ' + e.last_name AS employee,
       m.first_name + ' ' + m.last_name AS manager
FROM employees e LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY m.last_name, e.last_name;
```
**Result**: Each employee with their manager
