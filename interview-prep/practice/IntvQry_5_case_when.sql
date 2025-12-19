
/* nterview questions
/*
1Q) input data
  ID
  1
  2
  3
  4
  5
Output
--------------
 1,2
 2,3
 3,4
 4,5
 */

*/
;

CREATE TABLE table_1 (id int );
INSERT INTO table_1 values (1),(2),(3),(4),(5);


Select id as A ,lead(id) over (ORDER BY id) as B FROM table_1;

/* 
2Q) calculate positive numbers and negative numbers.
Input data
-------------------
ID
1
2
3
-1
-2
-3

Output
--------------
6,-6
*/

CREATE TABLE table_2 (nums int );
INSERT INTO table_2 values (1),(2),(3),(-3),(-2),(-1);
select sum(case when nums >=0 then nums else 0 end) as positive,
sum(case when nums  <0 then nums else 0 end) as negative
from table_2;

/*

3Q) in hive I have external table. I want to change external to manage table. With use alter command and tblproperties()
What will be happen  internally in Hadoop?

ans = ALTER TABLE table_name  SET TBLPROPERTIES('EXTERNAL'='TRUE');
* /
