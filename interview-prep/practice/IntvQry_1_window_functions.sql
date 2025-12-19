-- Active: 1671859768936@@127.0.0.1@3306@practice
create database EMP;

use EMP;


CREATE TABLE employee (empname varchar(25), emp_id int, salary int , dept_id varchar(3) ) ;


insert into employee values

("Sam",1,30000.00,  "d1" ),
("Tan",2,25000.00, "d1" ),
("Leo",3,40000.00, "d1" ),
("Lily",4,33000.00, "d2" ),
("James",5,25000.00,"d2" ),
("Snape",6,50000.00, "d3")
;


create table department ( dept_id varchar(3), dept_name varchar(20)) ;


insert into department values 
("d1","Finance"),
("d2","Marketing"),
("d3","HR");

-- 1 depatment wise max salary
select * from (select empname,dept_id, salary, 
               rank() over (partition by dept_id order by salary desc) as salrank from employee) t
               where t.salrank=1;

-- simply ranking salary
select empname, salary, rank() over (order by salary desc) as salRank from employee;


-- 2nd highest salary based on department 
select empname, salary, dept_id from ( SELECT empname, salary, dept_id ,
                                      dense_rank() over (partition by dept_id ORDER BY salary desc) as rnk FROM employee) tmp
                                      where tmp.rnk = 2 ;


-- 2nd highest salary based on department  with department info (name )
select tmp.empname,tmp.salary,tmp.dept_id , d.dept_name from
( SELECT empname, salary,dept_id, 
  dense_rank() over (PARTITION BY dept_id ORDER BY salary desc) as rnk
 FROM employee ) tmp 

join department d on d.dept_id = tmp.dept_id where tmp.rnk = 2  
