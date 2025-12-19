# Timed Mock Interview Problems (10 scenarios, 30–45 min each)

These are real-world-inspired problems to practice under interview conditions. Set a timer for 30–45 minutes per problem and solve without looking at the solution immediately.

---

## Mock 1 (Easy) — Employee salary by department

**Difficulty**: ⭐ (15–20 min)

**Problem**: Given an `employee` table with (emp_id, name, department, salary), return the average salary per department, rounded to 2 decimals, sorted by department name.

**Starter SQL**:

```sql
CREATE TABLE employee (  emp_id INT PRIMARY KEY,  name VARCHAR(50),  department VARCHAR(30),  salary INT);INSERT INTO employee VALUES(1,'Alice','Sales',50000),(2,'Bob','Sales',55000),(3,'Carol','HR',45000),(4,'David','HR',48000),(5,'Eve','IT',65000),(6,'Frank','IT',70000);
```

Solution

```sql
SELECT department, ROUND(AVG(salary), 2) AS avg_salaryFROM employeeGROUP BY departmentORDER BY department;
```

---

## Mock 2 (Easy) — Counting with CASE

**Difficulty**: ⭐ (15–20 min)

**Problem**: Count how many employees are in each salary bracket (low: <50k, medium: 50k–70k, high: >70k).

**Starter SQL**:

```sql
-- Use the employee table from Mock 1
```

Solution

```sql
SELECT  SUM(CASE WHEN salary < 50000 THEN 1 ELSE 0 END) AS low_bracket,  SUM(CASE WHEN salary BETWEEN 50000 AND 70000 THEN 1 ELSE 0 END) AS medium_bracket,  SUM(CASE WHEN salary > 70000 THEN 1 ELSE 0 END) AS high_bracketFROM employee;
```

---

## Mock 3 (Medium) — Second highest salary per department

**Difficulty**: ⭐⭐ (25–35 min)

**Problem**: For each department, find the second highest salary (or the highest if only one employee exists). Return department and salary.

**Starter SQL**:

```sql
-- Use employee table from Mock 1
```

Solution

```sql
SELECT DISTINCT department,  CASE    WHEN COUNT(*) OVER (PARTITION BY department) < 2    THEN MAX(salary) OVER (PARTITION BY department)    ELSE MAX(CASE WHEN salary < (SELECT MAX(salary) FROM employee e2 WHERE e2.department = employee.department) THEN salary END) OVER (PARTITION BY department)  END AS second_highestFROM employee;
```

Simpler alternative using ROW_NUMBER():

```sql
SELECT DISTINCT department, salaryFROM (  SELECT department, salary,         ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn,         COUNT(*) OVER (PARTITION BY department) AS total  FROM employee) tWHERE (rn = 2) OR (total = 1 AND rn = 1);
```

---

## Mock 4 (Medium) — Gaps and islands (consecutive login sessions)

**Difficulty**: ⭐⭐ (30–40 min)

**Problem**: Given a login_activity table with (user_id, login_time), identify consecutive session periods (where consecutive rows are < 1 hour apart). Return user_id, session_start, session_end, and session duration in minutes.

**Starter SQL**:

```sql
CREATE TABLE login_activity (  user_id INT,  login_time DATETIME);INSERT INTO login_activity VALUES(1, '2025-01-01 09:00:00'), (1, '2025-01-01 09:15:00'),(1, '2025-01-01 09:30:00'), (1, '2025-01-01 11:00:00'),(2, '2025-01-01 10:00:00'), (2, '2025-01-01 10:10:00'),(2, '2025-01-01 11:30:00');
```

Solution

```sql
WITH numbered AS (  SELECT user_id, login_time,         EXTRACT(EPOCH FROM (login_time - LAG(login_time) OVER (PARTITION BY user_id ORDER BY login_time))) / 60 AS mins_since_last  FROM login_activity),islands AS (  SELECT user_id, login_time,         SUM(CASE WHEN mins_since_last IS NULL OR mins_since_last >= 60 THEN 1 ELSE 0 END)         OVER (PARTITION BY user_id ORDER BY login_time ROWS UNBOUNDED PRECEDING) AS session_id  FROM numbered)SELECT user_id, session_id,       MIN(login_time) AS session_start,       MAX(login_time) AS session_end,       EXTRACT(EPOCH FROM (MAX(login_time) - MIN(login_time))) / 60 AS duration_minsFROM islandsGROUP BY user_id, session_idORDER BY user_id, session_start;
```

---

## Mock 5 (Medium) — LEFT JOIN to find missing data

**Difficulty**: ⭐⭐ (20–30 min)

**Problem**: Given `customer` and `order` tables, find customers who have never made an order (include customer name and email).

**Starter SQL**:

```sql
CREATE TABLE customer (  cust_id INT PRIMARY KEY,  name VARCHAR(50),  email VARCHAR(50));CREATE TABLE "order" (  order_id INT PRIMARY KEY,  cust_id INT,  amount DECIMAL(10,2));INSERT INTO customer VALUES (1,'Alice','alice@ex.com'),(2,'Bob','bob@ex.com'),(3,'Carol','carol@ex.com');INSERT INTO "order" VALUES (101,1,100.00),(102,1,200.00),(103,3,50.00);
```

Solution

```sql
SELECT c.cust_id, c.name, c.emailFROM customer cLEFT JOIN "order" o ON c.cust_id = o.cust_idWHERE o.order_id IS NULL;
```

---

## Mock 6 (Hard) — Window functions with LEAD/LAG

**Difficulty**: ⭐⭐⭐ (35–45 min)

**Problem**: Given a stock_price table with (ticker, date, closing_price), compute the day-over-day price change and the next day's closing price. Only return rows where the price change was > 5% or < -5%.

**Starter SQL**:

```sql
CREATE TABLE stock_price (  ticker VARCHAR(5),  date DATE,  closing_price DECIMAL(10,2));INSERT INTO stock_price VALUES('AAPL', '2025-01-01', 150.00),('AAPL', '2025-01-02', 155.00),('AAPL', '2025-01-03', 145.00),('AAPL', '2025-01-04', 150.00),('MSFT', '2025-01-01', 300.00),('MSFT', '2025-01-02', 285.00);
```

Solution

```sql
WITH daily_changes AS (  SELECT ticker, date, closing_price,         ROUND(((closing_price - LAG(closing_price) OVER (PARTITION BY ticker ORDER BY date)) / LAG(closing_price) OVER (PARTITION BY ticker ORDER BY date)) * 100, 2) AS pct_change,         LEAD(closing_price) OVER (PARTITION BY ticker ORDER BY date) AS next_closing_price  FROM stock_price)SELECT ticker, date, closing_price, pct_change, next_closing_priceFROM daily_changesWHERE pct_change IS NOT NULL AND (pct_change > 5 OR pct_change < -5)ORDER BY ticker, date;
```

---

## Mock 7 (Hard) — Recursive CTE (org chart depth)

**Difficulty**: ⭐⭐⭐ (40–45 min)

**Problem**: Given an employee table with manager relationships (emp_id, name, manager_id), compute the reporting depth (levels below CEO). Return emp_id, name, and depth.

**Starter SQL**:

```sql
CREATE TABLE emp_org (  emp_id INT PRIMARY KEY,  name VARCHAR(50),  manager_id INT);INSERT INTO emp_org VALUES(1, 'CEO', NULL),(2, 'VP Sales', 1),(3, 'VP IT', 1),(4, 'Sales Manager', 2),(5, 'Developer', 3),(6, 'Sales Rep', 4);
```

Solution

```sql
WITH RECURSIVE org_chart AS (  SELECT emp_id, name, manager_id, 0 AS depth  FROM emp_org  WHERE manager_id IS NULL  UNION ALL  SELECT e.emp_id, e.name, e.manager_id, oc.depth + 1  FROM emp_org e  JOIN org_chart oc ON e.manager_id = oc.emp_id)SELECT emp_id, name, depthFROM org_chartORDER BY depth, emp_id;
```

---

## Mock 8 (Hard) — String aggregation and pivot

**Difficulty**: ⭐⭐⭐ (35–45 min)

**Problem**: Given a student_grade table (student_id, subject, grade), pivot to show student_id, name, and comma-separated list of subjects where grade >= 'B'.

**Starter SQL**:

```sql
CREATE TABLE student (  student_id INT PRIMARY KEY,  name VARCHAR(50));CREATE TABLE student_grade (  student_id INT,  subject VARCHAR(20),  grade CHAR(1));INSERT INTO student VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Carol');INSERT INTO student_grade VALUES(1, 'Math', 'A'), (1, 'Science', 'B'), (1, 'English', 'C'),(2, 'Math', 'B'), (2, 'Science', 'A'), (2, 'English', 'B'),(3, 'Math', 'D'), (3, 'Science', 'B');
```

Solution

```sql
SELECT s.student_id, s.name,       GROUP_CONCAT(sg.subject ORDER BY sg.subject SEPARATOR ', ') AS good_subjectsFROM student sJOIN student_grade sg ON s.student_id = sg.student_idWHERE sg.grade IN ('A', 'B')GROUP BY s.student_id, s.nameORDER BY s.student_id;
```

---

## Mock 9 (Expert) — Cumulative sum with running window

**Difficulty**: ⭐⭐⭐⭐ (40–45 min)

**Problem**: Given a transaction table (trans_id, date, amount), compute a running balance for each day (cumulative sum). Include trans_id, date, amount, and running_balance. Sort by date.

**Starter SQL**:

```sql
CREATE TABLE transactions (  trans_id INT PRIMARY KEY,  date DATE,  amount DECIMAL(10,2));INSERT INTO transactions VALUES(1, '2025-01-01', 100.00),(2, '2025-01-01', 50.00),(3, '2025-01-02', -30.00),(4, '2025-01-02', 200.00),(5, '2025-01-03', 75.00);
```

Solution

```sql
SELECT trans_id, date, amount,       SUM(amount) OVER (ORDER BY date, trans_id ROWS UNBOUNDED PRECEDING) AS running_balanceFROM transactionsORDER BY date, trans_id;
```

---

## Mock 10 (Expert) — Anti-join with aggregation

**Difficulty**: ⭐⭐⭐⭐ (40–45 min)

**Problem**: Given product and sale tables, find products that were never sold AND have been in inventory for > 30 days (based on created_date). Return product_id, name, and days_in_inventory.

**Starter SQL**:

```sql
CREATE TABLE product (  product_id INT PRIMARY KEY,  name VARCHAR(50),  created_date DATE);CREATE TABLE sale (  sale_id INT PRIMARY KEY,  product_id INT,  sale_date DATE);INSERT INTO product VALUES(1, 'Laptop', '2024-11-01'),(2, 'Mouse', '2024-12-15'),(3, 'Keyboard', '2024-10-01'),(4, 'Monitor', '2024-12-01');INSERT INTO sale VALUES (101, 1, '2025-01-01'), (102, 2, '2025-01-02');
```

Solution

```sql
SELECT p.product_id, p.name,       DATEDIFF(CURDATE(), p.created_date) AS days_in_inventoryFROM product pLEFT JOIN sale s ON p.product_id = s.product_idWHERE s.sale_id IS NULL  AND DATEDIFF(CURDATE(), p.created_date) > 30ORDER BY p.product_id;
```

---

## How to use these mocks

1.  Set a 30–45 minute timer
2.  Read the problem and ask clarifying questions (2–3 min)
3.  Write the query (25–35 min)
4.  Test and explain (5–10 min)
5.  Compare your solution to the provided answer
6.  Note differences and patterns

**Progression**: Start with mocks 1–3 (easy), then 4–7 (medium–hard), then 8–10 (expert). Repeat as needed.