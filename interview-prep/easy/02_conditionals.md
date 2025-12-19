# 02 — Conditionals (gender counts per department)

Problem
- Given an employee table, produce department-wise counts of males, females, and total employees. Replace missing department values with a readable label (e.g., `Not Assigned`).

Starter dataset / schema
```sql
CREATE TABLE tbEmployeeMaster (
    EmployeeId INT PRIMARY KEY NOT NULL,
    EmployeeName VARCHAR(50),
    Gender VARCHAR(10),
    Department VARCHAR(50)
);

INSERT INTO tbEmployeeMaster VALUES
(1,'Arjun','Male','Administration'),
(2,'Rohan','Male','Sales'),
(3,'Ishita',NULL,'HRM'),
(4,'Aadi','Male','Sales'),
(5,'Preetam','Male','HRM'),
(6,'Anjan','Male','Administration'),
(7,'Rajesh',NULL,'HRM'),
(8,'Ankur','Male','HRM'),
(9,'Robin','Male',NULL),
(10,'Mayank','Male','Sales'),
(11,'Manisha','Female','HRM'),
(12,'Sonam','Female','HRM'),
(13,'Rajan','Male','HRM'),
(14,'Kapil',NULL,'Sales'),
(15,'Ritika','Female','HRM'),
(16,'Akshay','Male','Finance'),
(17,'Aryan','Male','HRM'),
(18,'Anju','Female','Finance'),
(19,'Sapna','Female','Finance'),
(20,'Ruhi','Female',NULL),
(21,'Robin','Male','Sales'),
(22,'Neelam','Female','HRM'),
(23,'Rajni','Female','Administration'),
(24,'Sonakshi','Female','Finance');
```

Hints
- Use conditional aggregation or `COUNT(CASE WHEN ...)` to compute separate gender counts in one pass.
- Handle NULL departments with `COALESCE`/`IFNULL`.

### Solution
<details><summary>Show solution</summary>

Step-by-step
- Use `COUNT(CASE WHEN UPPER(Gender) = 'MALE' THEN 1 END)` to count males and similarly for females.
- Group by `Department` and replace NULL with `Not Assigned` for readability.

Final SQL
```sql
SELECT IFNULL(TB.Department, 'Not Assigned') AS Department,
       TB.Male,
       TB.Female,
       (TB.Male + TB.Female) AS Total_Employees
FROM (
  SELECT Department,
         COUNT(CASE WHEN UPPER(Gender) = 'MALE' THEN 1 END) AS Male,
         COUNT(CASE WHEN UPPER(Gender) = 'FEMALE' THEN 1 END) AS Female
  FROM tbEmployeeMaster
  GROUP BY Department
) AS TB
ORDER BY CASE WHEN TB.Department IS NULL THEN 1 ELSE 0 END;
```

Notes
- This counts only rows explicitly labeled male/female; NULL genders are ignored in these two counts but still appear in totals if you prefer to count them, adjust accordingly.

</details>
