
/* Write an SQL query to find the missing customer IDs. The missing IDs are ones that are not in the Customers table but are in the range between 1 and the maximum customer_id present in the table.

Notice that the maximum customer_id will not exceed 100.

Return the result table ordered by ids in ascending order.

The query result format is in the following example.

Customers table:
+-------------+---------------+
| customer_id | customer_name |
+-------------+---------------+
| 1           | Alice         |
| 4           | Bob           |
| 5           | Charlie       |
+-------------+---------------+

Result table:
+-----+
| ids |
+-----+
| 2   |
| 3   |
+-----+
The maximum customer_id present in the table is 5, so in the range [1,5], ID
*/

show tables ;

CREATE TABLE ms_ids ( customet_id int, customer_name varchar(25) );

INSERT into ms_ids values (1,"Alice"),(4,"Bob"),(6,"Charlie");

with recursive cte (ids) as
(
    select 1 as ids
    union all
    select ids + 1 
    from cte 
    where ids < (select max(customet_id) from ms_ids)
)
select ids
from cte
where ids not in (select customet_id from ms_ids)
order by ids;
