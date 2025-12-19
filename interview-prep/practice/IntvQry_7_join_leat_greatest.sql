-- Active: 1671859768936@@127.0.0.1@3306@practice

/*
Problem Statement: Below is the flight schedule mentioning the source and destination. We have to show the unique combination of source and destination as an output. For eg: Delhi to Mumbai and Mumbai to Delhi being one unique combination

#Input
+---------------+
src     dest
+---------------+
Delhi    Mum
Mum     Delhi
Delhi    Kolkata
Kolkata   Delhi
Mum     Nagpure 


#Required-Output
+-------------------+
src     dest
+-------------------+
Delhi    Mum
Mum     Nagpure
Delhi    Kolkata

*/
create table flts as
select *
from (values ROW( 'Delhi', 'Mum'),
             ROW( 'Mum', 'Delhi'),
             ROW( 'Delhi', 'Kolkata'),
             ROW( 'Kolkata  ', 'Delhi'),
             ROW( 'Mum', 'Nagpure ')
  ) as v (src, dest );

select * from flts;

select t.src, t.dest
from (  select *, row_number()
    over(
         partition by least(src, dest), 
         greatest(src, dest) 
         ) rn from flts 
     ) t where t.rn = 1
;

select distinct least(src,dest), greatest(src,dest) from flts;

create table  flight_schedule as (
select 'Mum' src, 'Delhi' dest
union select 'Delhi', 'Mum'
union select 'Mum', 'Nagpure'
union select 'Delhi', 'Kolkata'
union select 'Kolkata', 'Delhi')
;
########## Solution1 #####################
select distinct least(src,dest), greatest(src,dest) from flight_schedule;

########## Solution2 #####################
select vw1.*
from flight_schedule vw1 left join flight_schedule vw2 on vw1.src = vw2.dest and vw1.dest = vw2.src
where vw2.src is null or vw1.dest > vw1.src;