# 🎯 Window Functions Practice Collection

## Overview
This consolidated file contains advanced window function problems and techniques from multiple practice scenarios.

---

## 🎯 Problem 1: Employee Salary Rankings

**Business Context:** HR salary analysis across departments.

### SQL Setup
```sql
CREATE TABLE employee (empname VARCHAR(25), emp_id INT, salary INT, dept_id VARCHAR(3));
INSERT INTO employee VALUES
('Sam', 1, 30000, 'd1'), ('Tan', 2, 25000, 'd1'), ('Leo', 3, 40000, 'd1'),
('Lily', 4, 33000, 'd2'), ('James', 5, 25000, 'd2'), ('Snape', 6, 50000, 'd3');

CREATE TABLE department (dept_id VARCHAR(3), dept_name VARCHAR(20));
INSERT INTO department VALUES ('d1', 'Finance'), ('d2', 'Marketing'), ('d3', 'HR');
```

### Solutions
#### Highest paid by department:
```sql
SELECT * FROM (
    SELECT empname, dept_id, salary, 
           RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS salrank 
    FROM employee
) t WHERE t.salrank = 1;
```

#### Company-wide ranking:
```sql
SELECT empname, salary, RANK() OVER (ORDER BY salary DESC) AS salRank FROM employee;
```

---

## 🎯 Problem 2: Sales Moving Averages

**Business Context:** Sales trend analysis with moving averages.

### SQL Setup
```sql
CREATE TABLE sales (sale_date DATE PRIMARY KEY, amount DECIMAL(10,2));
INSERT INTO sales VALUES
('2024-01-01', 1000.00), ('2024-01-02', 1200.00), ('2024-01-03', 800.00),
('2024-01-04', 1500.00), ('2024-01-05', 900.00), ('2024-01-06', 1100.00),
('2024-01-07', 1300.00);
```

### 3-Day Moving Average:
```sql
SELECT sale_date, amount,
    ROUND(AVG(amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3day,
    CASE WHEN amount > AVG(amount) OVER (ORDER BY sale_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
         THEN 'Above Average' ELSE 'Below Average' END AS performance
FROM sales ORDER BY sale_date;
```

---

## 🎯 Problem 3: Comprehensive Sales Analytics

**Business Context:** Complete sales performance dashboard.

### Solutions include ranking functions, running totals, growth analysis, and complex frames.

**Note:** Full comprehensive examples available in original practice files for detailed study.

