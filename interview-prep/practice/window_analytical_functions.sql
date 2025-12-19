/* we are going to explore windowing functions in Hive. These are the windowing functions:
LEAD
LAD
FIRST_VALUE
LAST_VALUE
MIN/MAX/COUNT/AVG OVER Clause
*/

--enabling loading from file 
 SET GLOBAL local_infile=1;

create table emp_dept_tbl (ID int ,
FIRST_NAME varchar(20),
LAST_NAME varchar(20),
DESIGNATION varchar(20),
DEPARTMENT varchar(20),
SALARY int) ;

LOAD DATA LOCAL INFILE "C:\\Users\\dev30\\Downloads\\data\\dept_data.csv"
 INTO TABLE emp_dept_tbl FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM emp_dept_tbl;

/* Windowing allows features to create a window on the set of data in order to operate aggregation like COUNT, AVG, MIN, MAX and other analytical functions such as LEAD, LAG, FIRST_VALUE, and LAST_VALUE.

The syntax of the query with windows:

SELECT <columns_name>, <aggregate>(column_name) OVER (<windowing specification>) FROM <table_name>;

where,

column_name – column name of the table

Aggregate – Any aggregate function(s) like COUNT, AVG, MIN, MAX

Windowing specification – It includes following:

PARTITION BY – Takes a column(s) of the table as a reference.
ORDER BY – Specified the Order of column(s) either Ascending or Descending.
Frame – Specified the boundary of the frame by stat and end value. The boundary either be a type of RANGE or ROW followed by PRECEDING, FOLLOWING and any value.
These three (PARTITION, ORDER BY, and Window frame) are either be alone or together.

*/

--PARTITION BY
--Count Employees in each department
SELECT department, COUNT(id) OVER (PARTITION BY department) FROM emp_dept_tbl;

SELECT DISTINCT * FROM (SELECT department, COUNT(id) OVER (PARTITION BY department) FROM emp_dept_tbl) A;


--ORDER BY
--Case I: Without PARTITION
--Count Employee with salary descending order
SELECT id, department, salary, COUNT(id) OVER (ORDER BY salary DESC) FROM emp_dept_tbl;


--Case II: With PARTITION
--Count Employees of each department order by salary
SELECT id, department, salary, COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC)
 FROM emp_dept_tbl;

 /*
 WINDOWING Specification
In the windowing frame, you can define the subset of rows in which the windowing function will work. You can specify this subset using upper and lower boundary value using windowing specification.

The syntax to defined windowing specification with ROW/RANGE looks like:

ROW|RANGE BETWEEN <upper expression> AND <lower expression>

Here,

UPPER EXPRESSION can have these 3 value:

UNBOUNDED PRECEDING – It denotes window will start from the first row of the group/partition.
CURRENT ROW – Window will start from the current row.
<INTEGER VALUE> PRECEDING – Provide any specific row to start window
LOWER EXPRESSION

UNBOUNDED FOLLOWING – It means the window will end at the last row of the group/partition.
CURRENT ROW – Window will end at the current row
<INTEGER VALUE> FOLLOWING – Window will end at specific row
Now, let’s use these different upper and lower expression as a combination on different cases and check how it is working.
*/

--UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING

--Case I: Count Employees with windowing specification
 	
SELECT id, first_name, designation, department, 
COUNT(id) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 FROM emp_dept_tbl;

--Case II: Count Employees with PARTITION BY department and windowing specification
	
SELECT id, first_name, designation, department,
 COUNT(id) OVER (PARTITION BY department
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
 FROM emp_dept_tbl;

 --Case III: Count Employees with PARTITION BY department and ORDER BY salary DESC and windowing specification
 SELECT id, first_name, designation, department, salary, 
 COUNT(id) OVER (PARTITION BY department ORDER BY salary 
    DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
 FROM emp_dept_tbl;


--UNBOUNDED PRECEDING and CURRENT ROW
--Case I: Count Employees with windowing specification only
SELECT id, first_name, designation, department, salary, 
COUNT(id) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
FROM emp_dept_tbl;


--Case II: Count Employees with PARTITION BY department and windowing specification
 	
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER (PARTITION BY department ROWS BETWEEN 
            UNBOUNDED PRECEDING AND CURRENT ROW)
 FROM emp_dept_tbl;


-- Case III: Count Employees with PARTITION BY department and ORDER BY salary DESC and windowing specification
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER 
    (PARTITION BY department ORDER BY salary DESC 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
FROM emp_dept_tbl;


--CURRENT ROW AND UNBOUNDED FOLLOWING
--Case I: Count Employees with windowing specification only
SELECT id, first_name, designation, department, salary, 
COUNT(id) OVER (ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING ) 
FROM emp_dept_tbl;


--Case II: Count Employees with PARTITION BY department and windowing specification
SELECT id, first_name, designation, department,salary, COUNT(id) OVER (PARTITION BY department ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) FROM emp_dept_tbl;

--Case III: Count Employees with PARTITION BY department and ORDER BY salary DESC and windowing specification	
SELECT id, first_name, designation, department,salary, COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) FROM emp_dept_tbl;


--CURRENT ROW AND 3 FOLLOWING
SELECT id, first_name, designation, department,salary,
 COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC 
    ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) 
    FROM emp_dept_tbl;

--3 PRECEDING AND 3 FOLLOWING
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC
 ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING) 
 FROM emp_dept_tbl;


--3 PRECEDING AND CURRENT ROW
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC 
ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) 
FROM emp_dept_tbl;


-- 3 PRECEDING AND UNBOUNDED FOLLOWING
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC 
ROWS BETWEEN 3 PRECEDING AND UNBOUNDED FOLLOWING)
 FROM emp_dept_tbl;


-- UNBOUNDED PRECEDING AND 3 FOLLOWING
SELECT id, first_name, designation, department,salary, 
COUNT(id) OVER (PARTITION BY department ORDER BY salary DESC
 ROWS BETWEEN UNBOUNDED PRECEDING AND 3 FOLLOWING) 
 FROM emp_dept_tbl;


/* LEAD
It is an analytics function used to return the data from the next set of rows. 
By default, the lead is of 1 row and it will return NULL in case it exceeds the current window.
*/

SELECT id, first_name, designation, department,salary, 
LEAD(id) OVER (PARTITION BY department ORDER BY salary) 
FROM emp_dept_tbl;


/*  LAG
It is the opposite of LEAD function, it returns the data from the previous set of data.
 By default lag is of 1 row and return NULL in case the lag for the current row is exceeded before the beginning of the window:
 */
 	
SELECT id, first_name, designation, department,salary, 
LAG(id) OVER (PARTITION BY department ORDER BY salary) 
FROM emp_dept_tbl;

/*
FIRST_VALUE
This function returns the value from the first row in the window based on the clause and assigned to all the rows of the same group:
*/
 	
SELECT id, first_name, designation, department,salary,
 FIRST_VALUE(id) OVER (PARTITION BY department ORDER BY salary) 
 FROM emp_dept_tbl;

 /*  LAST_VALUE
In reverse of FIRST_VALUE, it return the value from the last row in a window based on the clause and assigned to all the rows of the same group:
*/

SELECT id, first_name, designation, department,salary,
 LAST_VALUE(id) OVER (PARTITION BY department ORDER BY salary) 
 FROM emp_dept_tbl;