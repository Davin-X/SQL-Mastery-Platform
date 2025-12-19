CREATE database EMP;

use EMP;


 Create table Employees
(
     ID int ,primary key (ID),
     FirstName varchar(50),
     LastName varchar(50),
     Gender varchar(50),
     Salary int
);

insert into Employees values (1, 'Ben', 'Hoskins', 'Male', 70000),
(2,'Mark', 'Hastings', 'Male', 60000),
(3, 'Steve', 'Pound', 'Male', 45000),
 (4, 'Ben', 'Hoskins', 'Male', 70000),
(5, 'Philip', 'Hastings', 'Male', 45000),
(6, 'Mary', 'Lambeth', 'Female', 30000),
(7, 'Valarie', 'Vikings', 'Female', 35000),
(8, 'John', 'Stanmore', 'Male', 80000);

----------#To find the highest salary it is straight forward. We can simply use the Max() function as shown below.
Select max(Salary) from Employees;

------------#To get the second highest salary use a sub query along with Max() function as shown below.
Select max(Salary) from Employees where Salary < (Select Max(Salary) from Employees);

----------#To find nth highest salary using Sub-Query

Select Salary
from (
      Select distinct Salary
      FROM Employees
      ORDER BY Salary DESC limit 3
      ) results 
ORDER BY Salary limit 1;


SELECT DISTINCT FirstName,LastName FROM Employees 
ORDER BY LastName limit 10;

----------#To find nth highest salary using CTE
 WITH RESULT AS
(
    SELECT Salary,
           DENSE_RANK() OVER (ORDER BY Salary DESC) AS DENSERANK
    FROM Employees
)
SELECT Salary
FROM RESULT
WHERE DENSERANK = 3 LIMIT 1;

----------#if there are no duplicates.
 WITH RESULT AS
(
    SELECT Salary,
           ROW_NUMBER() OVER (ORDER BY SALARY DESC) AS ROWNUMBER
    FROM Employees
)
SELECT Salary
FROM RESULT
WHERE ROWNUMBER = 3;