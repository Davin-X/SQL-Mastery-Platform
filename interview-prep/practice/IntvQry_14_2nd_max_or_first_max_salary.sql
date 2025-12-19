-- the employee data is stored in a table called employees with columns emp_id, name, department, and salary, 
--the following query can be used to get the second highest salary for each department:
-- if there is <2 employee get 1st one 

CREATE TABLE employee_dept (
  id INT,
  name VARCHAR(50),
  department VARCHAR(50),
  salary INT
);

INSERT INTO employee_dept VALUES
(1, 'John', 'Sales', 5000),
(2, 'Jane', 'Marketing', 6000),
(3, 'Bob', 'Sales', 4000),
(4, 'Alice', 'Marketing', 5500),
(5, 'David', 'Sales', 4500),
(6, 'Carol', 'Marketing', 7000),
(7, 'Tom', 'HR', 3000),
(8, 'Mary', 'HR', 3500),
(9, 'Bill', 'HR', 3200),
(10, 'Sarah', 'IT', 8000),
(11, 'Mike', 'IT', 9000),
(12, 'Susan', 'IT', 7500),
(13, 'Paul', 'IT', 8200),
(14, 'Karen', 'IT', 7500);

INSERT INTO employee_dept VALUES
(1, 'Davin', 'ENG', 15000);

SELECT department, 
    CASE 
        WHEN COUNT(*) < 2 THEN MAX(salary)
        ELSE (
            SELECT MAX(salary) 
            FROM employee_dept e2 
            WHERE e1.department = e2.department 
            AND e2.salary < (SELECT MAX(salary) FROM employee_dept e3 WHERE e2.department = e3.department)
        )
    END AS second_highest_salary
FROM employee_dept e1
GROUP BY department ;

----------------------------------------------;


SELECT DISTINCT  department, 
       CASE 
         WHEN COUNT(*) >= 2 THEN MAX(salary) OVER (PARTITION BY department ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) 
         ELSE MAX(salary) OVER (PARTITION BY department) 
       END AS second_highest_salary
FROM employee_dept
GROUP BY department, salary;
