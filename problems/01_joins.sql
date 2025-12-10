/* given 2 tables table1 and table 2 
table 1 having t1 column and table2 having t2 column with following values 
t1   t2
1    1 
1    1
1    1
Null 1
Null 1

 question - how many records can be expected when performed -> 
1)inner join
2)left join
3)right join
4)full outer join

*/
/*
answer -
1)inner join = 15 records
2)left join = 17 records
3)right join = 15 records
4)full outer join = 

INNER JOIN: The INNER JOIN keyword selects all rows from both the tables as long as the condition satisfies. 

LEFT JOIN: This join returns all the rows of the table on the left side of the join and 
matching rows for the table on the right side of join. The rows for which there is no matching row on right side, 
the result-set will contain null. LEFT JOIN is also known as LEFT OUTER JOIN.

RIGHT JOIN: RIGHT JOIN is similar to LEFT JOIN. This join returns all the rows of the table on the right side of the join 
and matching rows for the table on the left side of join. The rows for which there is no matching row on left side,
 the result-set will contain null. RIGHT JOIN is also known as RIGHT OUTER JOIN

FULL JOIN: FULL JOIN creates the result-set by combining result of both LEFT JOIN and RIGHT JOIN.
 The result-set will contain all the rows from both the tables. The rows for which there is no matching, 
 the result-set will contain NULL values

*/

--practical 

CREATE database tmp;

use tmp;

create table table1 ( t1 int );

INSERT INTO table1 values (1),(1),(1),(null),(null);

create table table2 ( t2 int ) ;

INSERT INTO table2 values (1),(1),(1),(1),(1);

-- inner join 
SELECT * FROM table1 join table2 on table1.t1 = table2.t2;

-- LEFT JOIN 
SELECT * FROM table1 left join table2 on table1.t1 = table2.t2;

-- right join 

SELECT * FROM table1 right join table2 on table1.t1 = table2.t2;


-- full join 
SELECT * FROM table1 full join table2 ;

SELECT * FROM table1
LEFT JOIN table2 ON table1.t1 = table2.t2
UNION ALL
SELECT * FROM table1
RIGHT JOIN table2 ON table1.t1 = table2.t2

