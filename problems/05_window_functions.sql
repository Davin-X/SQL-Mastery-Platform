/* we are going to explore windowing functions in Hive. These are the windowing functions:
LEAD
LAD
FIRST_VALUE
LAST_VALUE
MIN/MAX/COUNT/AVG OVER Clause
*/

--enabling loading from file
SET GLOBAL local_infile = 1;

create table emp_dept_tbl (
    ID int,
    FIRST_NAME varchar(20),
    LAST_NAME varchar(20),
    DESIGNATION varchar(20),
    DEPARTMENT varchar(20),
    SALARY int
);

LOAD DATA LOCAL INFILE "C:\\Users\\dev30\\Downloads\\data\\dept_data.csv" INTO
TABLE emp_dept_tbl FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM emp_dept_tbl;

--PARTITION BY
--Count Employees in each department
SELECT department, COUNT(id) OVER (
        PARTITION BY
            department
    )
FROM emp_dept_tbl;

SELECT DISTINCT
    *
FROM (
        SELECT department, COUNT(id) OVER (
                PARTITION BY
                    department
            )
        FROM emp_dept_tbl
    ) A;

--ORDER BY
--Case I: Without PARTITION
--Count Employee with salary descending order
SELECT id, department, salary, COUNT(id) OVER (
        ORDER BY salary DESC
    )
FROM emp_dept_tbl;

--Case II: With PARTITION
--Count Employees of each department order by salary
SELECT id, department, salary, COUNT(id) OVER (
        PARTITION BY
            department
        ORDER BY salary DESC
    )
FROM emp_dept_tbl;