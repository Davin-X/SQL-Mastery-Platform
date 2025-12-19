-- select all the records from table1 those are not in table2 - (anti-join pattern)

CREATE table t1 (id int);

CREATE table t2 (id int);

insert into t1 (id) values (10), (20), (30), (40), (50);

insert into t2 (id) values (10), (30), (50);

select * from t1 where id NOT IN( select id from t2 );

-- In databases that support EXCEPT (e.g., Postgres/Oracle):
-- select * from t1
-- except
-- select * from t2;