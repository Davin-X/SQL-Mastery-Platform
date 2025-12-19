# 🎯 Window Functions Interview Question

## Question
Given an employee table with salary information and a department table, write queries to:
1. Find the highest paid employee in each department
2. Find employees ranked by salary across the entire company
3. Find the 2nd highest paid employee in each department
4. Find the 2nd highest paid employee in each department with department name

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE EMP;
USE EMP;

CREATE TABLE employee (
    empname VARCHAR(25), 
    emp_id INT, 
    salary INT, 
    dept_id VARCHAR(3)
);

INSERT INTO employee VALUES
('Sam', 1, 30000, 'd1'),
('Tan', 2, 25000, 'd1'),
('Leo', 3, 40000, 'd1'),
('Lily', 4, 33000, 'd2'),
('James', 5, 25000, 'd2'),
('Snape', 6, 50000, 'd3');

CREATE TABLE department (
    dept_id VARCHAR(3), 
    dept_name VARCHAR(20)
);

INSERT INTO department VALUES 
('d1', 'Finance'),
('d2', 'Marketing'),
('d3', 'HR');
```

## Answer 1: Department-wise Maximum Salary

```sql
SELECT * FROM (
    SELECT empname, dept_id, salary, 
           RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS salrank 
    FROM employee
) t
WHERE t.salrank = 1;
```

**How it works**: Uses RANK() window function partitioned by department and ordered by salary descending. Filters for rank = 1 to get the highest paid employee per department.

## Answer 2: Company-wide Salary Ranking

```sql
SELECT empname, salary, 
       RANK() OVER (ORDER BY salary DESC) AS salRank 
FROM employee;
```

**How it works**: Uses RANK() window function ordered by salary descending across the entire table (no PARTITION BY clause).

## Answer 3: 2nd Highest Salary by Department

```sql
SELECT empname, salary, dept_id 
FROM (
    SELECT empname, salary, dept_id,
           DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk 
    FROM employee
) tmp
WHERE tmp.rnk = 2;
```

**How it works**: Uses DENSE_RANK() to handle ties properly, partitioned by department, and filters for rank = 2.

## Answer 4: 2nd Highest Salary with Department Names

```sql
SELECT tmp.empname, tmp.salary, tmp.dept_id, d.dept_name 
FROM (
    SELECT empname, salary, dept_id, 
           DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rnk
    FROM employee
) tmp 
JOIN department d ON d.dept_id = tmp.dept_id 
WHERE tmp.rnk = 2;
```

**How it works**: Combines the ranking query with a JOIN to the department table to include department names, then filters for 2nd highest in each department.
