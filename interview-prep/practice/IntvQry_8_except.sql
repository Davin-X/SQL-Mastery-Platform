-- Active: 1671859768936@@127.0.0.1@3306@practice

-- select all the records from table1 those arre not in table2 -

CREATE table t1 (id int);

CREATE table t2 (id int);

insert into t1(id) values  (10),  (20),  (30),  (40),  (50);

insert into t2(id) values  (10),  (30),  (50);

select * from t1 where id NOT IN ( select * from t2 );

-- -oracle 
select * from t1
except
select * from t2;