-- Active: 1671859768936@@127.0.0.1@3306@complex
CREATE DATABASE IF NOT EXISTS complex ;

---------------------------------------------
create database if not exists complex_qr ; 
use complex_qr;
---------------------------------------------
-- Derive Points table for ICC tournament
---------------------------------------------
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);

INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;

with winner as (
SELECT  Team_1 as team , 
CASE  when Team_1 = winner then 1 else 0 end as win_flag from icc_world_cup 
union all 
SELECT  Team_2 as team , 
CASE  when Team_2 = winner then 1 else 0 end as win_flag from icc_world_cup 
)

select  team, 
COUNT(1) as match_played,
SUM(win_flag) as wins, 
( COUNT(1)- SUM(win_flag) ) as losses  
from winner group by team ; 

------------------------------------------------
-- find new and repeat customers
------------------------------------------------
create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values
(1,100,cast('2022-01-01' as date),2000),
(2,200,cast('2022-01-01' as date),2500),
(3,300,cast('2022-01-01' as date),2100),
(4,100,cast('2022-01-02' as date),2000),
(5,400,cast('2022-01-02' as date),2200),
(6,500,cast('2022-01-02' as date),2700),
(7,100,cast('2022-01-03' as date),3000),
(8,400,cast('2022-01-03' as date),1000),
(9,600,cast('2022-01-03' as date),3000);

select * from customer_orders;

with visits as (
        SELECT
            co.*, fv.first_visit
        from  customer_orders co
            join (
                SELECT customer_id, MIN(order_date) as first_visit
                from customer_orders
                GROUP BY customer_id
            ) fv on co.customer_id = fv.customer_id
    ),
    visits_flag as (
      select
        customer_id,order_date,
        CASE
            WHEN order_date = FIRST_VISIT THEN 1 ELSE 0 END as New_customer_flag,
        CASE
            WHEN order_date <> FIRST_VISIT THEN 1 ELSE 0 END as Repeat_customer_flag
    from visits
    )
select order_date , 
SUM(New_customer_flag) as NEW_customer,
SUM(Repeat_customer_flag) as Repeat_customer
FROM visits_flag GROUP BY order_date 
;

with visits as (
        SELECT
            co.*, fv.first_visit
        from  customer_orders co
            join (
                SELECT customer_id, MIN(order_date) as first_visit
                from customer_orders
                GROUP BY customer_id
            ) fv on co.customer_id = fv.customer_id
    )

      select
        order_date,
        sum (CASE WHEN order_date = FIRST_VISIT THEN 1 ELSE 0 END  ) as New_customer_flag,
        sum (CASE  WHEN order_date <> FIRST_VISIT THEN 1 ELSE 0 END ) as Repeat_customer_flag
    from visits GROUP BY order_date 
;

------------------------------------------------
-- find out total visits for a person,
-- the floor he visited the most and number of visits
------------------------------------------------

create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries values 
('A','Bangalore','A@gmail.com',1,'CPU'),
('A','Bangalore','A1@gmail.com',1,'CPU'),
('A','Bangalore','A2@gmail.com',2,'DESKTOP'),
('B','Bangalore','B@gmail.com',2,'DESKTOP'),
('B','Bangalore','B1@gmail.com',2,'DESKTOP'),
('B','Bangalore','B2@gmail.com',1,'MONITOR');


 with total_visits as (
    SELECT name , count(1) as total_visit, 
     group_concat(distinct resources) as RESOURCES_USED 
    FROM entries GROUP BY name 
),
floor_visits as (
    select name , floor, count(1)  as fl_vsits,
    RANK() over (PARTITION BY NAME order by count(1) desc ) as rn 
    from entries GROUP BY name , floor 
)
SELECT fv.name , 
tv.total_visit,
fv.floor as most_visited_floor ,
tv.RESOURCES_USED 
from total_visits tv 
inner join 
floor_visits fv
on tv.name = fv.name where fv.rn = 1   ;

----------------------------------------------------------
-----------------------------------------------------------
-- write  a query to provide the date for nth occurance of sunday from  given date
-- datepart
-- sunday- 1
-- monday- 2
-- friday- 6
-- saturday- 7

set @today_date='2023-07-11';
set @n =5 ;

SELECT DATE_ADD(@today_date, INTERVAL (8 - DAYOFWEEK(@today_date) +  7 * (@n - 1)) DAY) AS sunday_date;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--
/* The Pareto principle states that for many outcomes, roughly 80% of consequences come from 20% of causes.
eg:
80 % of the productivity come from 20 % of the employees.
80 % of your sales come from 20 % of your clients.
80 % of decisions in a meeting are made in 20 % of the time
80 % of your sales comes from 20 % of your products or services.
*/
CREATE TABLE IF NOT EXISTS  `superstore_orders` (
  `Row_ID` int DEFAULT NULL,
  `Order_ID` text,
  `Order_Date` text,
  `Ship_Date` text,
  `Ship_Mode` text,
  `Customer_ID` text,
  `Customer_Name` text,
  `Segment` text,
  `Country/Region` text,
  `City` text,
  `State` text,
  `Postal_Code` int DEFAULT NULL,
  `Region` text,
  `Product_ID` text,
  `Category` text,
  `Sub_Category` text,
  `Product_Name` text,
  `Sales` double DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Discount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

select * from superstore_orders limit 3 ;

select SUM(sales) * 0.8 from superstore_orders ;

with product_wise_sales as (
    SELECT product_id , sum(Sales) as product_sale 
FROM superstore_orders 
GROUP BY `Product_ID` ORDER BY `Product_sale` desc 
),
cal_sales as ( 
SELECT SUM(product_sale) over (order by `product_sale` desc ROWS BETWEEN UNBOUNDED PRECEDING AND 0 PRECEDING) as running_sales , 
 0.8 * SUM(`product_sale`) over() as total_sales
FROM product_wise_sales 
)

select * FROM cal_sales where running_sales <= total_sales ; 

--------------------------------------------------------------------------------------
--- Scenario based on join, group by and having clauses 
/* write a query to find PersonID, Name, number of friends, sum of marks
of person who have friends with total score greater than 100. * /

*/
--------------------------------------------------------------------------------------
CREATE TABLE Persons (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    Score INT
);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (1, 'Alice', 'alice2018@hotmail.com', 88);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (2, 'Bob', 'bob2018@hotmail.com', 11);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (3, 'Davis', 'davis2018@hotmail.com', 27);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (4, 'Tara', 'tara2018@hotmail.com', 45);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (5, 'John', 'john2018@hotmail.com', 63);

CREATE TABLE PersonFriends (
    PersonID INT,
    FriendID INT
   );
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (1, 2);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (1, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (2, 1);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (2, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (3, 5);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 2);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 5);

with score_details as (
    SELECT pf.PersonID, 
    COUNT(1) as num_of_friend,
    SUM(P.Score) as Total_friens_score 
    FROM persons P 
    join  PersonFriends pf 
    on P.PersonID = pf.FriendID
    GROUP BY pf.PersonID  having SUM(P.Score) > 100
) 

select s.* , P.name 
from persons P 
join score_details s
 ON p.PersonID = s.PersonID ;
;

--------------------------------------------------------------------------------------
--- Trips and Users

/* Write a SQL query to find the cancellation rate of requests with unbanned users
(both client and driver must not be banned) each day between "2913-10-01" and "2013-1903" .
Round Cancelation Rate to two decimal points.
The cancellation rate is computed by dividing the number of canceled (by client or driver)
requests with unbanned users by the total number of requests with unbanned users on that day.
*/
--------------------------------------------------------------------------------------
Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table Users;
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');



SELECT  request_at ,
COUNT(1) as total_trips,
count( case WHEN status in ('cancelled_by_client','cancelled_by_driver') then 1 else null end ) as cancelled_trips_count,
count( case WHEN status in ('cancelled_by_client','cancelled_by_driver') then 1 else null end ) / count(1) * 100 as cancel_percentage
from trips t 
join Users u on t.client_id = u.users_id
join users d on t.driver_id = d.users_id 
where u.banned = 'NO' and d.banned='NO'
group by request_at ;

--------------------------------------------------------------------------------------------
-- Write an SQL query to find the winner in each group.
-- The winner in each group is the player who scored the maximum total points within the group. In the case of a tie,
-- the lowest player_id wins in case of tie.
------------------------------------------------------------------------------------------------


create table players
(player_id int,
group_id int)
;
insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);

create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)
;

insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);

with P_scores as (
select first_player as player , first_score as score from matches 
UNION ALL  
select second_player as player , second_score as score from matches 
)
,final_scores as (
select p.group_id,  ps.player , sum(score) as total_score 
 from P_scores ps
join players p on p.player_id = ps.player
group by p.group_id, ps.player order by total_score desc
)
, final_ranking as (
SELECT * , rank() over (partition by group_id  ORDER BY total_score desc, player desc ) as rnk 
from final_scores
)
select * from final_ranking where rnk = 1;

 ;
------------------------------------------------------------------------------------------------
/* MARKET ANALYSIS : Write an SQL query to find for each seller, whether the brand of the second item (by date) they
sold is their favorite brand.
note :- If a seller sold less than two items, report the answer for that seller as no. 
o/ p :- 
seller_id   2nd item fav brand
1            yes/no
2            yes/no
*/
;
------------------------------------------------------------------------------------------------
create table market_users (
user_id         int     ,
 join_date       date    ,
 favorite_brand  varchar(50));

 create table orders (
 order_id       int     ,
 order_date     date    ,
 item_id        int     ,
 buyer_id       int     ,
 seller_id      int 
 );

 create table items
 (
 item_id        int     ,
 item_brand     varchar(50)
 );


 insert into market_users values 
 (1,'2019-01-01','Lenovo'),
 (2,'2019-02-09','Samsung'),
 (3,'2019-01-19','LG'),
 (4,'2019-05-21','HP');

 insert into items values 
 (1,'Samsung'),
 (2,'Lenovo'),
 (3,'LG'),
 (4,'HP');

 insert into orders values 
 (1,'2019-08-01',4,1,2),
 (2,'2019-08-02',2,1,3),
 (3,'2019-08-03',3,2,3),
 (4,'2019-08-04',1,4,2),
 (5,'2019-08-04',1,3,4),
 (6,'2019-08-05',2,2,4);

with rnk_orders as (
    select *, rank() over (partition by seller_id order by order_date asc )as rnk
    FROM orders
)
 select ro.order_id,
  CASE 
    WHEN  i.item_brand = u.favorite_brand THEN  "YES"
    ELSE  "NO"
 END as SECOND_item_is_favorit_brand 
  from market_users  u  
 left join rnk_orders ro  on ro.seller_id = u.user_id and  ro.rnk =2
 left join items i on i.item_id = ro.item_id
  
;

-------------------------------------------------------------------------------------------------
--- An Awesome Tricky SQL Logic | Complex SQL 10
-------------------------------------------------------------------------------------------------

create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values 
('2019-01-01','success'),
('2019-01-02','success'),
('2019-01-03','success'),
('2019-01-04','fail'),
('2019-01-05','fail'),
('2019-01-06','success') ;


with all_dates as (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY date_value) AS ro,
    DATE_ADD(date_value, INTERVAL -1.0 * (ROW_NUMBER() OVER (PARTITION BY state ORDER BY date_value)) DAY) AS group_date
FROM 
    tasks
ORDER BY 
    date_value
)
select  min (date_value) as start_date, state  , max(date_value) as end_date 
from all_dates GROUP BY GROUP_DATE , state 
;

-------------------------------------------------------------------------------------------------
---  User Purchase Platform | Complex SQL
/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only
and both mobile and desktop together for each date.
*/
-------------------------------------------------------------------------------------------------

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values
(1,'2019-07-01','mobile',100),
(1,'2019-07-01','desktop',100),
(2,'2019-07-01','mobile',100),
(2,'2019-07-02','mobile',100),
(3,'2019-07-01','desktop',100),
(3,'2019-07-02','desktop',100);


/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/

with all_spend as (
SELECT 
    spend_date ,
    user_id,  
    SUM(amount) as amount , 
    max(platform) as platform
 FROM spending 
  GROUP BY spend_date , user_id HAVING COUNT(DISTINCT platform)=1 
  
  UNION  
  SELECT 
    spend_date ,
    user_id,  
    SUM(amount) as amount , 
    "Both" as platform
 FROM spending 
  GROUP BY spend_date , user_id HAVING COUNT(DISTINCT platform)=2 
 UNION  
 SELECT DISTINCT
    spend_date , 
    NULL as user_id , 
    0 as amount,
    "Both" as platform 
     FROM spending  
)
SELECT spend_date ,platform , SUM(amount) as total_amt,
COUNT(DISTINCT user_id ) as total_user 
from all_spend 
GROUP BY spend_date ,platform 
ORDER BY spend_date , platform desc 
  ;

-------------------------------------------------------------------------------------------------
--- Recursive CTE | Leetcode Hard SQL Problem 5 | Complex SQL 12
--- total sales by year 
-------------------------------------------------------------------------------------------------
--recursive CTE
WITH RECURSIVE cte_numbers AS (
  SELECT 1 AS num -- anchor query
  UNION ALL
  SELECT num + 1 -- recursive query
  FROM cte_numbers
  WHERE num < 6 -- filter to stop the recursion
)

SELECT num FROM cte_numbers;

create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into sales values
(1,'2019-01-25','2019-02-28',100),
(2,'2018-12-01','2020-01-01',10),
(3,'2019-12-01','2020-01-31',1);

SET max_sp_recursion_depth = 1000; -- Set the maximum recursion limit to 500


WITH RECURSIVE cte as 
(
  SELECT MIN(period_start) as dates ,
  MAX(period_end) as max_date 
  from sales 
  UNION ALL 
  SELECT  DATE_ADD(dates,INTERVAL 1 DAY) as dates , max_date 
  FROM cte  where dates < max_date 
)
select product_id,
YEAR(dates) as reported_year, 
SUM(average_daily_sales) as total_amount from cte 
JOIN
sales on dates BETWEEN period_start and period_end
GROUP BY product_id,YEAR(dates)
order by product_id ,YEAR(dates)
;

-------------------------------------------------------------------------------------------------
--Data Science SQL Interview Question | Recommendation System | Complex SQL 13
-------------------------------------------------------------------------------------------------
create table orders_re
(
order_id int,
customer_id int,
product_id int
);

insert into orders_re VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

create table products (
id int,
name varchar(10)
);
insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

SELECT CONCAT (pr1.name," " ,pr2.name) as pair, COUNT(1) as purchase_freq
FROM orders_re o1 
join orders_re o2 
on o1.order_id = o2.order_id  
join products pr1 on pr1.id = o1.product_id 
join products pr2 on pr2.id = o2.product_id 
where  o1.product_id > o2.product_id
GROUP BY pr1.name , pr2.name 

;

-------------------------------------------------------------------------------------------------
/*Prime subscription rate by product action
Given the following two tables, return the fraction of users, rounded to two decimal places,
who accessed Amzon music and upgraded to prime mebership within the first 3B days of signing up. */
-------------------------------------------------------------------------------------------------
create table users_amz
(
user_id integer,
name varchar(20),
join_date date
);
INSERT INTO users_amz
VALUES
  (1, 'Jon', '2020-02-14'),
  (2, 'Jane', '2020-02-14'),
  (3, 'Jill', '2020-02-15'),
  (4, 'Josh', '2020-02-15'),
  (5, 'Jean', '2020-02-16'),
  (6, 'Justin', '2020-02-17'),
  (7, 'Jeremy', '2020-02-18');


create table events
(
user_id integer,
type varchar(10),
access_date date
);

INSERT INTO events
VALUES
  (1, 'Pay', '2020-03-01'),
  (2, 'Music', '2020-03-02'),
  (2, 'P', '2020-03-12'),
  (3, 'Music', '2020-03-15'),
  (4, 'Music', '2020-03-15'),
  (1, 'P', '2020-03-16'),
  (3, 'P', '2020-03-22');


--*,DATEDIFF(e.access_date,ua.join_date)
 SELECT  
 count( DISTINCT ua.user_id ) as total_user ,
 count( DISTINCT case WHEN DATEDIFF(ua.join_date,e.access_date) <=30 then ua.user_id end ) as p,
 1.0 * count( DISTINCT case WHEN DATEDIFF(ua.join_date,e.access_date) <=30 then ua.user_id end ) / count( DISTINCT ua.user_id ) * 100
from users_amz ua
 left join events e on ua.user_id = e.user_id
 and  e.type ='P' 
 where ua.user_id  in ( select user_id from events where type = 'Music')
 ;

-------------------------------------------------------------------------------------------------
--customer retention
/* Customer retention and customer churn metrics

customer retention refers to a company's ability to turn customers into repeat buyers
and prevent them from switching to a competitor.
It indicates whether your product and the quality of your service please your existing customers
reward programs (cc companies)
wallet cash back (paytm/gpay)
zomato pro / swiggy super
retention period
*/

create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);
delete from transactions;
insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;


SELECT month(this_month.order_date) as month_date,
count(DISTINCT last_month.cust_id)
FROM transactions this_month 
left join transactions last_month
on this_month.cust_id = last_month.cust_id 
and TIMESTAMPDIFF(MONTH, last_month.order_date , this_month.order_date) =1
group by month(this_month.order_date)
;


SELECT month(last_month.order_date) as month_date,
count(DISTINCT last_month.cust_id)
FROM transactions  last_month
left join transactions this_month
on this_month.cust_id = last_month.cust_id 
and TIMESTAMPDIFF(MONTH, last_month.order_date , this_month.order_date) =1
where this_month.cust_id is NULL
group by month(last_month.order_date)
;

SELECT 
    MONTH(last_month.order_date) AS month_date,
    COUNT(DISTINCT CASE WHEN last_month.cust_id IS NOT NULL THEN last_month.cust_id END) AS count
FROM 
    transactions last_month
LEFT JOIN 
    transactions this_month ON this_month.cust_id = last_month.cust_id 
    AND TIMESTAMPDIFF(MONTH, last_month.order_date, this_month.order_date) = 1
WHERE 
    this_month.cust_id IS NULL
GROUP BY 
    MONTH(last_month.order_date);
;;
-------------------------------------------------------------------------------------------------
--- Second Most Recent Activity | SQL Window Analytical Functions
-------------------------------------------------------------------------------------------------
create table UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);

insert into UserActivity values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');

with cte as (
  SELECT *, count(1) over (PARTITION BY username ) as total_activities ,
  RANK() over (PARTITION BY username ORDER BY `startDate` desc) as rnk
  from useractivity
  ) SELECT * FROM cte where total_activities =1 or rnk = 2;

-------------------------------------------------------------------------------------------------
-- Scenario Based SQL Question | Solving Using SCD Type 2 Concept | SQL Interview Question
--- total charges as per billing rate 
-------------------------------------------------------------------------------------------------
create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from billings;
/*
insert into billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;
*/

INSERT INTO billings
VALUES
    ('Sachin', '1990-01-01', 25),
    ('Sehwag', '1989-01-01', 15),
    ('Dhoni', '1989-01-01', 20),
    ('Sachin', '1991-02-05', 30);



create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
/*insert into HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)
*/
INSERT INTO HoursWorked 
VALUES
    ('Sachin', '1990-07-01', 3),
    ('Sachin', '1990-08-01', 5),
    ('Sehwag', '1990-07-01', 2),
    ('Sachin', '1991-07-01', 4);

with date_range as (
  SELECT *,
  LEAD(DATE_ADD( bill_date, INTERVAL -1 day ) ,1,'9999-12-31') over (PARTITION BY emp_name ORDER BY bill_date asc) as bill_date_end
  FROM billings 
  ) 
   select hw.emp_name ,sum(dr.bill_rate * hw.bill_hrs )FROM date_range dr 
   join hoursworked hw 
   on dr.emp_name = hw.emp_name 
   And  hw.work_date BETWEEN dr.bill_date and dr.bill_date_end
   GROUP BY hw.emp_name 
   ;

-------------------------------------------------------------------------------------------------
 -- -- the activity table shows the app-installed and app purchase acrivities for spotify app along with country details
-------------------------------------------------------------------------------------------------
CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values
 (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

/*Question 1: find total active users each day */

select event_date, count( distinct user_id) as active_user
from activity GROUP BY event_date;

-- Question 2: find total active user each week ADD

select  WEEK(event_date)+1 , count(DISTINCT user_id)
from activity GROUP BY (WEEK(event_date)+1) ;

--- date wise total number of user who made the purchase same day they installed the app 
with cte as (
 SELECT user_id,event_date,
 case when  count(DISTINCT event_name) =2 then user_id else null end as  new_users
 FROM activity 
 GROUP BY user_id,event_date 
 
)
SELECT event_date , count(new_users) as total_user 
from cte
GROUP BY event_date ;

--- percentage of paid users in india , USA and any other country shhould be tagged as other country
with cte as (
SELECT 
CASE WHEN  country in ('USA','India') THEN  country  else 'other' END as new_country,
COUNT(DISTINCT user_id) as user_count 
FROM activity 
WHERE event_name = 'app-purchase'
GROUP BY CASE 
    WHEN  country in ('USA','India') THEN  country  else 'other' END
)
,
total as 
( 
    SELECT sum(user_count) as total_user FROM cte 
)
SELECT new_country,user_count/total_user as perc_user FROM cte , total;

----- Among  all the users who installed the ap on a given DAY
-- how many did app purchase on the very next day 
-- day wise results are expected 
with pre_data as (
    SELECT *,
    LAG(event_name, 1) over (PARTITION BY user_id order by event_date) as pre_event_name,
    LAG(event_date, 1) over (PARTITION BY user_id order by event_date) as pre_event_date
    from activity
)
select event_date,
count(DISTINCT user_id) from pre_data 
where event_name='app-purchase'
and pre_event_name='app-installed'
and DATEDIFF(event_date, pre_event_date) = 1
GROUP BY event_date
;

with pre_data as (
    SELECT *,
    LAG(event_name, 1) over (PARTITION BY user_id order by event_date) as pre_event_name,
    LAG(event_date, 1) over (PARTITION BY user_id order by event_date) as pre_event_date
    from activity
)
select event_date,
count(case when event_name = 'app-purchase' 
                  and pre_event_name= 'app-installed' 
                  and DATEDIFF(event_date , pre_event_date) = 1 then event_date else null end ) as cnt_users
    from pre_data
GROUP BY event_date
; 

-------------------------------------------------------------------------------------------------
--- How to Write Advance SQL Queries | Consecutive Empty Seats | SQL Interview Questions
--- 3 or more consecutive empty set 
-- method 1 - lead , LAG
-- method 2 - advanced AGGREGATION 
-- method 3 - analytical row number function --?
-------------------------------------------------------------------------------------------------

create table bms (seat_no int ,is_empty varchar(10));
insert into bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');

--- 3 comsecutive empty using lead lag 
with cte as (
    SELECT *,
        LAG(is_empty,1) OVER(ORDER BY seat_no) as prev_1,
        LAG(is_empty,2) OVER(ORDER BY seat_no) as prev_2,
        LEAD(is_empty,1) OVER(ORDER BY seat_no) as next_1,
        LEAD(is_empty,2) OVER(ORDER BY seat_no) as next_2
 FROM bms )
 SELECT * FROM cte WHERE is_empty='Y' and prev_1 ='Y' and prev_2 ='Y'
 or ( is_empty='Y' and next_1 ='Y' and next_2 ='Y')
 or ( is_empty='Y' and prev_1 ='Y' and next_1 ='Y') 
 ORDER BY seat_no;

 --- 3 consecutive empty using advanced AGGREGATION
WITH cte AS (
    SELECT *,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS prev_2,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS prev_next_1,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN CURRENT ROW and 2 FOLLOWING) AS next_2
    FROM bms
)
SELECT * FROM cte where prev_2 = 3 or prev_next_1 = 3 or next_2=3 ;


--- 3 3 comsecutive empty using analytical row num function 

with diff_num as (
    SELECT * , ROW_NUMBER() over (ORDER BY seat_no) as rn ,
    seat_no - ROW_NUMBER() over (ORDER BY seat_no) as diff
    FROM bms 
    WHERE is_empty = "Y"
),
cnt as(
    SELECT diff , COUNT(1) as c from diff_num
    GROUP BY diff HAVING COUNT(1) >=3
)
SELECT * FROM diff_num where diff in ( SELECT diff from cnt)
;

-------------------------------------------------------------------------------------------------
 -- for each store find the quarter in which that store was closed fro maintenence
-------------------------------------------------------------------------------------------------

-- DDL and DML:
CREATE TABLE STORES (
Store varchar(10),
Quarter varchar(10),
Amount int);

INSERT INTO STORES (Store, Quarter, Amount) VALUES 
('S1', 'Q1', 200),
('S1', 'Q2', 300),
('S1', 'Q4', 400),
('S2', 'Q1', 500),
('S2', 'Q3', 600),
('S2', 'Q4', 700),
('S3', 'Q1', 800),
('S3', 'Q2', 750),
('S3', 'Q3', 900);

--- method 1 
SELECT store, CONCAT('Q' , 10-SUM(CAST(RIGHT(QUARTER, 1) AS UNSIGNED)) ) AS Missing_Quarter
FROM stores
GROUP BY store;


--- method 2 using recusrsive CTE 
with RECURSIVE  cte as (
    SELECT DISTINCT store , 1 as q_no FROM stores
    UNION ALL 
    SELECT store,q_no + 1 as q_no from cte
    where q_no <4
)
,
Q as (
    SELECT store , CONCAT('Q',cast(q_no as char)) as q_no 
    FROM cte order by store
)   
select q.*
 from Q q
 LEFT join stores s on Q.store = s.store 
 and Q.q_no = s.Quarter 
 where s.`Store` is null ;

 -- ALTER TABLE stores CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
 
 --- mrthod 3 using cross join 
WITH cte AS (
    SELECT DISTINCT s1.store, s2.`QUARTER`
    FROM stores s1, stores s2
)
SELECT q.*
FROM cte q
LEFT JOIN stores s ON q.store = s.store AND q.`QUARTER` = s.`QUARTER`
WHERE s.`Store` IS NULL;

------------------------------------------------------------------------------------------------------
 --- Deadly Combination of Group By and Having Clause in SQL | SQL Interview Questions and Answers
 ------------------------------------------------------------------------------------------------------
 create table exams (student_id int, subject varchar(20), marks int);
delete from exams;
insert into exams values
 (1,'Chemistry',91),
 (1,'Physics',91),
 (2,'Chemistry',80),
(2,'Physics',90),
(3,'Chemistry',80),
(4,'Chemistry',71),
(4,'Physics',54);


SELECT student_id 
FROM exams 
WHERE subject in ('Chemistry','Physics')
GROUP BY student_id 
HAVING COUNT(DISTINCT subject) = 2 
and COUNT(DISTINCT marks) = 1 ;

-----------------------------------------------------------------------------
--- Beauty of SQL RANK Function | SQL Interview Question and Answers | Covid Cases
-----------------------------------------------------------------------------


create table covid(city varchar(50),days date,cases int);
delete from covid;
insert into covid values
('DELHI','2022-01-01',100),
('DELHI','2022-01-02',200),
('DELHI','2022-01-03',300),
('MUMBAI','2022-01-01',100),
('MUMBAI','2022-01-02',100),
('MUMBAI','2022-01-03',300),
('CHENNAI','2022-01-01',100),
('CHENNAI','2022-01-02',200),
('CHENNAI','2022-01-03',150),
('BANGALORE','2022-01-01',100),
('BANGALORE','2022-01-02',300),
('BANGALORE','2022-01-03',200),
('BANGALORE','2022-01-04',400);

/*
WITH cte AS (
    SELECT *,
        RANK() OVER (PARTITION BY city ORDER BY days ASC) AS rn,
        RANK() OVER (PARTITION BY city ORDER BY cases ASC) AS rn_cases,
        RANK() OVER (PARTITION BY city ORDER BY days ASC) -
            RANK() OVER (PARTITION BY city ORDER BY cases ASC) AS diff
    FROM covid
    ORDER BY city, days
)
SELECT *
FROM cte;

*/
WITH cte AS (
    SELECT *,
        CAST(RANK() OVER (PARTITION BY city ORDER BY days) AS SIGNED) AS rn,
        CAST(RANK() OVER (PARTITION BY city ORDER BY cases) AS SIGNED) AS rn_cases,
        CAST(RANK() OVER (PARTITION BY city ORDER BY days) AS SIGNED) -
            CAST(RANK() OVER (PARTITION BY city ORDER BY cases) AS SIGNED) AS diff
    FROM covid
    ORDER BY city, days
)
SELECT city 
FROM cte
GROUP BY city 
HAVING COUNT(DISTINCT diff) = 1 
and min(diff) = 0;

--------------------------------------------------------------------------------------------------
--Coog1e SQL interview question
--find companies who have atleast 2 users who speaks English and German both the languages
---------------------------------------------------------------------------------------------------

create table company_users 
(
company_id int,
user_id int,
language varchar(20)
);

insert into company_users values 
(1,1,'English')
,(1,1,'German')
,(1,2,'English')
,(1,3,'German')
,(1,3,'English')
,(1,4,'English')
,(2,5,'English')
,(2,5,'German')
,(2,5,'Spanish')
,(2,6,'German')
,(2,6,'Spanish')
,(2,7,'English');

with cte as (
    SELECT company_id , user_id, COUNT(1) as Lc
    FROM company_users 
    WHERE language in("English","German")
    GROUP BY company_id,user_id 
    having COUNT(1) = 2
)
SELECT company_id, COUNT(1) 
FROM cte
GROUP BY company_id HAVING COUNT(user_id) >= 2;
--------------------------------------------------------------------------------------------------
----- MEESHO HACKERRANK ONLINE SQL TEST
-- find how many products falls into customer budget along with list of products
-- In case of clash choose the less costly product
----------------------------------------------------------------------------------------------------
create table products_Mesho (product_id varchar(20) ,cost int);
insert into products_Mesho values 
('P1',200),
('P2',300),
('P3',500),
('P4',800);

create table customer_budget(customer_id int,budget int);

insert into customer_budget values (100,400),(200,800),(300,1500);

with running_cost as (
SELECT *,
SUM(cost) over (order BY cost) as r_cost 
from products_Mesho
)
 SELECT customer_id ,budget, COUNT(1) as num_products ,
 GROUP_CONCAT(product_id) as list_of_products
  FROM customer_budget cb 
 LEFT JOIN running_cost rc
 on rc.r_cost < cb.budget
GROUP BY customer_id ,budget
;

--------------------------------------------------------------------------------------------------
 --- Horizontal Sorting in SQL | Amazon Interview Question for BIE position
-- Amazon SQL Inteview question for BIE position
-- find total no of messages exchanged between each person per day
----------------------------------------------------------------------------------------------------
CREATE TABLE subscriber (
 sms_date date ,
 sender varchar(20) ,
 receiver varchar(20) ,
 sms_no int
);
-- insert some values
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Vibhor',10);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Pawan',30);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Pawan',5);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Vibhor',8);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Deepak',50);

with cte as (
    select sms_date,
    CASE WHEN sender < receiver THEN  sender     ELSE  receiver  END as p1, 
    CASE WHEN sender > receiver THEN  sender     ELSE  receiver  END as p2 ,
    sms_no
    from subscriber
)
SELECT sms_date , p1, p2 , SUM(sms_no) as total_sms 
FROM cte GROUP BY sms_date, p1,p2
  ;
--------------------------------------------------------------------------------------------------
--- Solving 4 Tricky SQL Problems
----------------------------------------------------------------------------------------------------
CREATE TABLE students(
 studentid int NULL,
 studentname nvarchar(255) NULL,
 subject nvarchar(255) NULL,
 marks int NULL,
 testid int NULL,
 testdate date NULL
);

insert into students values
(2,'Max Ruin','Subject1',63,1,'2022-01-02'),
(3,'Arnold','Subject1',95,1,'2022-01-02'),
(4,'Krish Star','Subject1',61,1,'2022-01-02'),
(5,'John Mike','Subject1',91,1,'2022-01-02'),
(4,'Krish Star','Subject2',71,1,'2022-01-02'),
(3,'Arnold','Subject2',32,1,'2022-01-02'),
(5,'John Mike','Subject2',61,2,'2022-11-02'),
(1,'John Deo','Subject2',60,1,'2022-01-02'),
(2,'Max Ruin','Subject2',84,1,'2022-01-02'),
(2,'Max Ruin','Subject3',29,3,'2022-01-03'),
(5,'John Mike','Subject3',98,2,'2022-11-02');

--- 1- write as SQL query to get the list of the students who scored 
--- above the average marks in each subject

with avg_cte as (
    SELECT SUBJECT , AVG( marks) as avg_marks 
    from students GROUP BY subject
)

select s.* , ac.* from students s 
join avg_cte ac 
on s.subject = ac.subject 
where s.marks > ac.avg_marks
;

--- write a sql query o get the percentage of students who score more than 90 in 
--- any subject amongst the total students

SELECT 
COUNT ( DISTINCT CASE WHEN  marks > 90 THEN studentid  ELSE null   END ) / count(DISTINCT studentid) * 100 as PERCENTAGE
FROM students ;


--- write a sql query to get second highest and SECOND lowest marks for each subject 
with ranked as (
    SELECT 
    subject , marks,
    DENSE_RANK() over ( PARTITION BY subject ORDER BY marks desc) as rnk_desc ,
    DENSE_RANK() over ( PARTITION BY subject ORDER BY marks asc) as rnk_asc
    from students 
)
 SELECT subject,
 SUM( CASE     WHEN rnk_desc =2  THEN marks     ELSE  null  END )as SECOND_highest_marks ,
 SUM( CASE     WHEN rnk_asc =2  THEN marks     ELSE  null  END ) as SECOND_Lowest_marks 
 
 FROM ranked  GROUP BY subject ;

 --- for EACH student and test , identify if their marks incresed or descreded from the previous test 
with cte as (
    SELECT * ,
    LAG(marks,1) over (PARTITION BY studentid order by testdate,subject) as prev_marks
    FROM students
)
  SELECT  * ,
  CASE 
    WHEN marks > prev_marks THEN  "inc"     
    WHEN marks < prev_marks THEN  "dec"  
    else null  END
  FROM cte ;

--------------------------------------------------------------------------------------------------
--- Brilliant SQL Interview Question | Solve it without using CTE, Sub Query, Window functions
/* Find the largest order by value for each salesperson and display order details
Get the result without using sub query , cte, window functions, temp tables */
----------------------------------------------------------------------------------------------------
CREATE TABLE int_orders(
 order_number int NOT NULL,
 order_date date NOT NULL,
 cust_id int NOT NULL,
 salesperson_id int NOT NULL,
 amount float NOT NULL
);

INSERT INTO int_orders (order_number, order_date, cust_id, salesperson_id, amount) 
VALUES 
  (30, CAST('1995-07-14' AS Date), 9, 1, 460),
  (10, CAST('1996-08-02' AS Date), 4, 2, 540),
  (40, CAST('1998-01-29' AS Date), 7, 2, 2400),
  (50, CAST('1998-02-03' AS Date), 6, 7, 600),
  (60, CAST('1998-03-02' AS Date), 6, 7, 720),
  (70, CAST('1998-05-06' AS Date), 9, 7, 150),
  (20, CAST('1999-01-30' AS Date), 4, 8, 1800);

SELECT a.order_number, a.order_date ,a.cust_id,
a.amount
FROM int_orders a 
LEFT join int_orders b 
on a.salesperson_id = b.salesperson_id
GROUP BY a.order_number, a.order_date ,a.cust_id ,a.amount
HAVING a.amount >= max(b.amount)
;

--------------------------------------------------------------------------------------------------
--- Solving A Hard SQL Problem | SQL ON OFF Problem | Magic of SQL
----------------------------------------------------------------------------------------------------
create table event_status
(
event_time varchar(10),
status varchar(10)
);
insert into event_status values
('10:01','on'),
('10:02','on'),
('10:03','on'),
('10:04','off'),
('10:07','on'),
('10:08','on'),
('10:09','off'),
('10:11','on'),
('10:12','off')
;

 WITH cte1 AS (
    SELECT *,
           LAG(status, 1, status) OVER (ORDER BY event_time) AS prev_status
    FROM event_status
)
,cte2 as (
SELECT *,
       SUM(CASE WHEN status = 'on' AND prev_status = 'off' THEN 1 ELSE 0 END)
           OVER (ORDER BY event_time) AS groupkey
FROM cte1
)
 SELECT MIN(event_time) AS login_
 ,MAX(event_time) AS logout_
 ,COUNT(1) - 1 AS on_count 
 FROM cte2 GROUP BY groupkey
 ;

--------------------------------------------------------------------------------------------------
--LeetCode Hard SQL problem | Students Reports By Geography | Pivot Ka Baap
--------------------------------------------------------------------------------------------------
create table players_location ( name varchar(20), city varchar(20) );

delete from players_location;

insert into players_location
values ('Sachin', 'Mumbai')
, ('Virat', 'Delhi')
, ('Rahul', 'Bangalore')
, ('Rohit', 'Mumbai')
, ('Mayank', 'Bangalore')
;

WITH cte as (
    SELECT *
    ,ROW_NUMBER() OVER (PARTITION BY city ORDER BY name asc) as player_group
    FROM players_location
)
SELECT 
MAX(CASE WHEN city='Bangalore' THEN  name END )AS Bangalore
,MAX(CASE WHEN city='Mumbai' THEN  name END) AS Mumbai
,MAX(CASE WHEN city='Delhi' THEN  name END )AS Delhi
 FROM cte 
 GROUP BY player_group
 ORDER BY player_group;

--------------------------------------------------------------------------------------------------
---- -- write a SQL query to find the median salary of each company.
--Bonus points if you can solve it without using any built-in SQL functions.
--------------------------------------------------------------------------------------------------
create table employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into employee values 
(1,'A',2341)
,(2,'A',341)
,(3,'A',15)
,(4,'A',15314)
,(5,'A',451)
,(6,'A',513)
,(7,'B',15)
,(8,'B',13)
,(9,'B',1154)
,(10,'B',1345)
,(11,'B',1221)
,(12,'B',234)
,(13,'C',2345)
,(14,'C',2645)
,(15,'C',2645)
,(16,'C',2652)
,(17,'C',65)
;

WITH cte as (
    SELECT * 
        ,ROW_NUMBER() OVER (PARTITION BY company ORDER BY salary ASC ) AS rn
        ,COUNT(1) OVER (PARTITION BY company) AS total_cnt
    FROM employee 
)
SELECT company,AVG(salary) AS Med_sal
FROM cte
WHERE rn BETWEEN total_cnt /2 AND total_cnt/2 +1
GROUP BY company
;

--------------------------------------------------------------------------------------------------
-- Groww SQL Interview Question based on Stock Market Transactions
--------------------------------------------------------------------------------------------------

Create Table Buy (
Date Int,
Time Int,
Qty Int,
per_share_price int,
total_value int );

Create Table sell(
Date Int,
Time Int,
Qty Int,
per_share_price int,
total_value int );

INSERT INTO Buy (date, time, qty, per_share_price, total_value)
VALUES
(15, 10, 10, 10, 100),
(15, 14, 20, 10, 200);

INSERT INTO Sell(date, time, qty, per_share_price, total_value)
VALUES (15, 15, 15, 20, 300);

WITH cte AS (
    SELECT
        buy.`Time` AS buy_time,
        buy.`Qty` AS buy_qty,
        sell.`Qty` AS sell_qty,
        SUM(buy.`Qty`) OVER (ORDER BY buy.`Time`) AS r_buy_qty,
        COALESCE(SUM(buy.`Qty`) OVER (ORDER BY buy.`Time` ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS r_buy_qty_prev
    FROM buy
    JOIN sell ON buy.`Date` = sell.`Date` AND buy.`Time` < sell.`Time`
) 
SELECT buy_time,
    r_buy_qty -sell_qty as buy_qty ,
    '' AS sell_qty
 from cte where sell_qty < r_buy_qty
 UNION ALL
SELECT buy_time,
    CASE WHEN sell_qty >= r_buy_qty THEN  buy_qty  ELSE  sell_qty - r_buy_qty_prev END AS buy_qty,
    CASE WHEN sell_qty >= r_buy_qty THEN  buy_qty  ELSE  sell_qty - r_buy_qty_prev END AS shell_qty
From cte 
 
   ;

--------------------------------------------------------------------------------------------------
-- window functions 
-- write an sql to find details of employees with 3rd highest salary in each department,
-- in ase there are less then 3 employees in a department then return employee details with lowest salary in that dep.
--------------------------------------------------------------------------------------------------
CREATE TABLE emp (
  emp_id int,
  emp_name varchar(50),
  salary int,
  manager_id int,
  emp_age int,
  dep_id int,
  dep_name varchar(20),
  gender varchar(10)
);

INSERT INTO emp VALUES
(1, 'Ankit', 14300, 4, 39, 100, 'Analytics', 'Female'),
(2, 'Mohit', 14000, 5, 48, 200, 'IT', 'Male'),
(3, 'Vikas', 12100, 4, 37, 100, 'Analytics', 'Female'),
(4, 'Rohit', 7260, 2, 16, 100, 'Analytics', 'Female'),
(5, 'Mudit', 15000, 6, 55, 200, 'IT', 'Male'),
(6, 'Agam', 15600, 2, 14, 200, 'IT', 'Male'),
(7, 'Sanjay', 12000, 2, 13, 200, 'IT', 'Male'),
(8, 'Ashish', 7200, 2, 12, 200, 'IT', 'Male'),
(9, 'Mukesh', 7000, 6, 51, 300, 'HR', 'Male'),
(10, 'Rakesh', 8000, 6, 50, 300, 'HR', 'Male'),
(11, 'Akhil', 4000, 1, 31, 500, 'Ops', 'Male');

WITH cte as (
    SELECT emp_id, 
        emp_name,
        salary,
        dep_id,
        dep_name,
        rank() OVER(PARTITION BY dep_id ORDER BY salary desc )as rn,
        COUNT(1) OVER(PARTITION BY dep_id) AS cnt
    FROM emp 
) 
  SELECT * FROM cte WHERE rn = 3 
  OR ( cnt < 3 and rn = cnt) ;
  
--------------------------------------------------------------------------------------------------
-- Leetcode Hard SQL Problem | Human Traffic of Stadium
-- write a query to display the records which have 3 or more consecutive rows
-- with the amount of people mare than 100(inclusive) each day

--------------------------------------------------------------------------------------------------
create table stadium (
    id int,
    visit_date date,
    no_of_people int
);

insert into stadium
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);

WITH group_nums as (
    SELECT * ,
        ROW_NUMBER() OVER (ORDER BY visit_date ) as rn ,
        id - ROW_NUMBER() OVER (ORDER BY visit_date ) AS grps
    FROM stadium 
    WHERE no_of_people >= 100
)
 SELECT * FROM group_nums 
 WHERE grps in (
        SELECT grps
        FROM group_nums 
        GROUP BY grps
        HAVING COUNT(1) > 3
 )
     ; 

--------------------------------------------------------------------------------------------------
--- business_city table has data from the day udaan has started operation
--- write a SQL to identify yearwise count of new cities where udaan started their operations
--------------------------------------------------------------------------------------------------
create table business_city (
    business_date date,
    city_id int
);
delete from business_city;
insert into business_city
values(cast('2020-01-02' as date),3)
,(cast('2020-07-01' as date),7)
,(cast('2021-01-01' as date),3)
,(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3)
,(cast('2022-12-15' as date),3)
,(cast('2022-02-28' as date),12);

WITH cte AS (
    SELECT 
        YEAR(business_date)  as bus_year,
        city_id
    FROM business_city 
) 
    SELECT 
        c1.bus_year,
        COUNT(DISTINCT CASE 
          WHEN c2.city_id is NULL  THEN  c1.city_id  END) as no_of_new_cities
    FROM cte c1 
    LEFT JOIN cte c2 
    ON c1.bus_year > c2.bus_year 
        AND c1.city_id = c2.city_id
    GROUP BY bus_year;

--------------------------------------------------------------------------------------------------
--- PharmEasy SQL Interview Question | Consecutive Seats in a Movie Theatre | Data Analytics
---  there are 3 rows in a movie hall each with 18 seats in each row
---  write a SQL to find 4 consecutive empty seats
--------------------------------------------------------------------------------------------------
CREATE TABLE movie (
  seat varchar(50),
  occupancy int
);

INSERT INTO movie (seat, occupancy)
VALUES
  ('a1', 1), ('a2', 1), ('a3', 0), ('a4', 0), ('a5', 0),
  ('a6', 0), ('a7', 1), ('a8', 1), ('a9', 0), ('a10', 0),
  ('b1', 0), ('b2', 0), ('b3', 0), ('b4', 1), ('b5', 1),
  ('b6', 1), ('b7', 1), ('b8', 0), ('b9', 0), ('b10', 0),
  ('c1', 0), ('c2', 1), ('c3', 0), ('c4', 1), ('c5', 1),
  ('c6', 0), ('c7', 1), ('c8', 0), ('c9', 0), ('c10', 1);


WITH cte1 as(
    SELECT *,
       LEFT(seat, 1) AS row_id,
       CAST(SUBSTR(seat, 2, 2) AS SIGNED) AS seat_id
    FROM movie

)
, cte2 as (
    SELECT *,
        MAX(occupancy) OVER(PARTITION BY row_id ORDER BY seat_id ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) as is_4_empty
        ,COUNT(occupancy) OVER(PARTITION BY row_id ORDER BY seat_id ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) as cnt
 FROM cte1 
)
, cte3 AS   (
    SELECT * FROM cte2 WHERE is_4_empty = 0 and cnt =4 
)
   
   SELECT cte2.* 
   FROM cte2 
   join cte3 
   on cte2.row_id = cte3.row_id AND cte2.seat_id BETWEEN cte3.seat_id and cte3.seat_id +3 

   ;


--------------------------------------------------------------------------------------------------
--- Bosch Scenario Based SQL Interview Question | Solving Using 3 Methods | Data Analytics
--- write a sq to etermrne phone numbers that satisfy beoow conditions
-- 1- the numbers have both incoming and outgoing calls
-- 2- the sum of duration of outgoing calls should be greater than sum of duration of incoming calls 
--------------------------------------------------------------------------------------------------

create table call_details  (
    call_type varchar(10),
    call_number varchar(12),
    call_duration int
);

insert into call_details
values ('OUT','181868',13)
,('OUT','2159010',8)
,('OUT','2159010',178)
,('SMS','4153810',1)
,('OUT','2159010',152)
,('OUT','9140152',18)
,('SMS','4162672',1)
,('SMS','9168204',1)
,('OUT','9168204',576)
,('INC','2159010',5)
,('INC','2159010',4)
,('SMS','2159010',1)
,('SMS','4535614',1)
,('OUT','181868',20)
,('INC','181868',54)
,('INC','218748',20)
,('INC','2159010',9)
,('INC','197432',66)
,('SMS','2159010',1)
,('SMS','4535614',1);


--- method -1 using cte and filter , case when 
with cte as (
    SELECT call_number,
    SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) as out_dur
    ,SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) as in_dur
FROM call_details 
GROUP BY call_number
)
    SELECT call_number from cte 
        where in_dur is not null 
        AND out_dur is not null 
        AND out_dur > in_dur
;       


---- method 2 using having clause 

SELECT call_number 
 FROM call_details
 GROUP BY call_number 
 having SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) > SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) 
    AND SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) > 0
    AND SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) > 0
;
---- method 3 using cte ang join 

with cte_out as (
    SELECT call_number,
         SUM (call_duration ) as duration
    FROM call_details 
    WHERE call_type = 'OUT'
    GROUP BY call_number
),
 cte_in as (
        SELECT call_number,
            SUM (call_duration ) as duration
        FROM call_details 
        WHERE call_type = 'INC'
        GROUP BY call_number
    )
    SELECT cte_out.call_number from cte_out
    join cte_in 
        ON cte_out.call_number = cte_in.call_number
    WHERE cte_out.duration > cte_in.duration
    ;

--------------------------------------------------------------------------------------------------
--- Cricket Analytics with SQL | Find Sachin's Milestone Matches | Advance SQL
--------------------------------------------------------------------------------------------------

CREATE TABLE sachin_batting_scores (
  `Match` VARCHAR(255),
  Innings INT,
  match_date VARCHAR(255),
  Versus VARCHAR(255),
  Ground VARCHAR(255),
  How_Dismissed TEXT,
  Runs INT,
  Balls_faced INT,
  strike_rate DOUBLE
);

LOAD DATA INFILE "C:\\Users\\dev30\\Downloads\\sachin_batting_scores.csv"
INTO TABLE sachin_batting_scores
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 
-- To skip the header row if present

SELECT COUNT(*) FROM sachin_batting_scores ;

WITH cte1 AS (
    SELECT
        `Match`,
        `Innings`,
        `Runs`,
        SUM(`Runs`) OVER (ORDER BY `Match` ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rolling_sum
    FROM sachin_batting_scores 
),
cte2 AS (
    SELECT 1 AS milestone_num, 1000 as milestone_runs
    UNION ALL 
    SELECT 2 AS milestone_num, 5000 as milestone_runs
    UNION ALL
    SELECT 3 AS milestone_num, 10000 as milestone_runs
    UNION ALL
    SELECT 4 AS milestone_num, 15000 as milestone_runs
) 
SELECT
    cte2.milestone_num,
    cte2.milestone_runs,
    MIN(cte1.`Match`) as milestone_match,
    (SELECT cte1_inner.`Innings` FROM cte1 cte1_inner WHERE cte1_inner.rolling_sum > cte2.milestone_runs LIMIT 1) as milestone_innings
FROM cte2 
INNER JOIN cte1 ON cte1.rolling_sum > cte2.milestone_runs 
GROUP BY cte2.milestone_num, cte2.milestone_runs
ORDER BY cte2.milestone_num;


----------------------------------------------------------------------------------------------------------------
--- This SQL Problem I Could Not Answer in Deloitte Interview | Last Not Null Value | Data Analytics
--- write a sq1 to populate category values to the last not null value
-----------------------------------------------------------------------------------------------------------------
create table brands (
    category varchar(20),
    brand_name varchar(20)
);

insert into brands values
('chocolates','5-star')
,(null,'dairy milk')
,(null,'perk')
,(null,'eclair')
,('Biscuits','britannia')
,(null,'good day')
,(null,'boost');
---------------------------------------
with cte1 AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY (SELECT null)) as rn
    FROM brands 
)
, cte2 as (
        SELECT *, 
             LEAD(rn, 1 ) OVER(ORDER BY rn) as next_rn
        FROM cte1 WHERE category is NOT NULL

) 
     SELECT cte2.category
     ,cte1.brand_name
     FROM cte1 
     JOIN cte2 ON cte1.rn >= cte2.rn 
     and (cte1.rn <= cte2.next_rn-1
     or cte2.next_rn is NULL )
;

----------------------------------------------------------------------------------------------------------------
--- - Write an SQL query to report the students (student id, student _ name) being "quietl in ALL exams.
-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score in any of the exam.
-- Don't return the student who has never taken any exam. Return the result table ordered by student id.
-----------------------------------------------------------------------------------------------------------------
create table students
(
student_id int,
student_name varchar(20)
);
insert into students values
(1,'Daniel'),(2,'Jade'),(3,'Stella'),(4,'Jonathan'),(5,'Will');

create table exams_q(
    exam_id int,
    student_id int,
    score int
    );

insert into exams_q values
(10,1,70),(10,2,80),
(10,3,90),(20,1,80),
(30,1,70),(30,3,80),
(30,4,90),(40,1,60),
(40,2,70),(40,4,80)
;

WITH cte as (    
    SELECT exam_id ,
        MIN(score) as min_score,
        MAX(score) as max_score
    FROM exams_q GROUP BY exam_id 
) 
    SELECT exams_q.student_id
    FROM exams_q 
    JOIN cte 
    ON exams_q.exam_id = cte.exam_id
    GROUP BY student_id 
    having max(case WHEN score = min_score or score = max_score then 1 else 0 end ) = 0
   
    ;

---------------------------------------------------------------------------------------------------
---    Walmart Labs SQL Interview Question for Senior Data Analyst Position | Data Analytics
/*there is a phonelog table that has information about callers' call history.
write a SQL to find out callers whose first and last call was to the same person on a given day.*/
----------------------------------------------------------------------------------------------------

create table phonelog(
    Callerid int, 
    Recipientid int,
    Datecalled datetime
);

insert into phonelog(Callerid, Recipientid, Datecalled)
values(1, 2, '2019-01-01 09:00:00.000'),
       (1, 3, '2019-01-01 17:00:00.000'),
       (1, 4, '2019-01-01 23:00:00.000'),
       (2, 5, '2019-07-05 09:00:00.000'),
       (2, 3, '2019-07-05 17:00:00.000'),
       (2, 3, '2019-07-05 17:20:00.000'),
       (2, 5, '2019-07-05 23:00:00.000'),
       (2, 3, '2019-08-01 09:00:00.000'),
       (2, 3, '2019-08-01 17:00:00.000'),
       (2, 5, '2019-08-01 19:30:00.000'),
       (2, 4, '2019-08-02 09:00:00.000'),
       (2, 5, '2019-08-02 10:00:00.000'),
       (2, 5, '2019-08-02 10:45:00.000'),
       (2, 4, '2019-08-02 11:00:00.000');

WITH calls as (
    SELECT `Callerid`, 
        CAST(`Datecalled` as date) as called_date,
        MIN(`Datecalled`) as first_call,
        MAX(`Datecalled`) as last_call 
    FROM phonelog
    GROUP BY `Callerid`,CAST(`Datecalled` as date)
) 
SELECT c.*,
    p1.`Recipientid` as first_recipient
FROM calls c
INNER JOIN phonelog p1 
    on c.`Callerid` = p1.`Callerid` and c.first_call=p1.`Datecalled`
INNER JOIN phonelog p2 
    ON c.`Callerid` = p2.`Callerid` and c.last_call=p2.`Datecalled`
where p1.`Recipientid` = p2.`Recipientid`
;

---------------------------------------------------------------------------------------------------
---Microsoft SQL Interview Question for Data Engineer Position | Data Analytics
/*A company wants to hire new employees. The budget of the company for the salaries is $70000.
The company's criteria for hiring are:
Keep hiring the senior with the smallest salary until you cannot hire any more seniors.
Use the remaining budget to hire the junior with the smallest salary.
Keep hiring the junior with the smallest salary until you cannot hire any more juniors.
Write an SQL query to find the seniors and juniors hired under the mentioned criteria.*/
---------------------------------------------------------------------------------------------------


create table candidates (
emp_id int,
experience varchar(20),
salary int
);

delete from candidates;

insert into candidates values
(1,'Junior',10000)
,(2,'Junior',15000)
,(3,'Junior',40000)
,(4,'Senior',16000)
,(5,'Senior',20000)
,(6,'Senior',50000);

with cte as (
    select * 
         ,sum(salary) over (partition by experience order by salary  rows between UNBOUNDED PRECEDING and CURRENT row) as running_sal
    from candidates 
),
seniors as (
    select * from   cte 
    where experience ='Senior' 
    and running_sal <= 70000
)
select * from cte 
where  experience ='Junior' 
and running_sal <= 70000 - (select sum(salary) from seniors)
union all 
select * from seniors 
;

---------------------------------------------------------------------------------------------------
--Double Self Join in SQL | Amazon Interview Question | Excel Explanation Included | Data Analytics
--write a SQL to list emp name along with thier manager and senior manager name
--senior manager is manager's manager
---------------------------------------------------------------------------------------------------

create table emp_n(
    emp_id int,
    emp_name varchar(20),
    department_id int,
    salary int,
    manager_id int,
    emp_age int
    );

INSERT INTO emp_n VALUES 
(1, 'Ankit', 100, 10000, 4, 39),
(2, 'Mohit', 100, 15000, 5, 48),
(3, 'Vikas', 100, 12000, 4, 37),
(4, 'Rohit', 100, 14000, 2, 16),
(5, 'Mudit', 200, 20000, 6, 55),
(6, 'Agam', 200, 12000, 2, 14),
(7, 'Sanjay', 200, 9000, 2, 13),
(8, 'Ashish', 200, 5000, 2, 12),
(9, 'Mukesh', 300, 6000, 6, 51),
(10, 'Rakesh', 500, 7000, 6, 50);

select 
    e.emp_id,
    e.emp_name,
    e.salary,
    m.emp_name as manager_name ,
    sm.emp_name as senior_manager,
    m.salary as manager_salary,
    sm.salary as Senior_manager_salary
from emp_n e 
LEFT join emp_n m 
on e.manager_id = m.emp_id
left join emp_n sm
on m.manager_id = sm.emp_id
;

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Create the rental_amenities table
CREATE TABLE rental_amenities (
    rental_id INT,
    amenity VARCHAR(50)
);

-- Insert data into the rental_amenities table
INSERT INTO rental_amenities (rental_id, amenity)
VALUES
    (1, 'Pool'),
    (1, 'Gym'),
    (1, 'Balcony'),
    (2, 'Gym'),
    (3, 'Pool'),
    (3, 'Balcony'),
    (4, 'Gym'),
    (4, 'Balcony'),
    (5, 'Pool'),
    (5, 'Gym'),
    (6, 'Gym'),
    (7, 'Pool'),
    (8, 'Gym'),
    (9, 'Balcony'),
    (10, 'Pool');

-- The query

DELIMITER //
CREATE FUNCTION factorial(n INT)
RETURNS INT
BEGIN
    DECLARE result INT;
    DECLARE i INT;
    
    SET result = 1;
    SET i = 1;
    
    WHILE i <= n DO
        SET result = result * i;
        SET i = i + 1;
    END WHILE;
    
    RETURN result;
END;
//
DELIMITER ;


SELECT CAST(SUM(factorial(cnt) / (factorial(cnt - 2) * factorial(2))) AS SIGNED) AS result
FROM (
    SELECT amenity_list, COUNT(rental_id) AS cnt
    FROM (
        SELECT rental_id, GROUP_CONCAT(amenity ORDER BY amenity) AS amenity_list
        FROM rental_amenities
        GROUP BY rental_id
    ) AS A
    GROUP BY amenity_list
    HAVING COUNT(rental_id) > 1
) AS B;

---------------------------------------------------------------------------------------------------
--Uber Very Interesting SQL Interview Problem | Solving Using 2 Methods | Data Analytics
--write a query to print total rides and profit rides for each driver
--profit ride is when the end location of current ride is same as start location on next ride
---------------------------------------------------------------------------------------------------
create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
insert into drivers values
('dri_1', '09:00', '09:30', 'a','b')
,('dri_1', '09:30', '10:30', 'b','c')
,('dri_1','11:00','11:30', 'd','e');

insert into drivers values
('dri_1', '12:00', '12:30', 'f','g'),
('dri_1', '13:30', '14:30', 'c','h');
insert into drivers values
('dri_2', '12:15', '12:30', 'f','g'),
('dri_2', '13:30', '14:30', 'c','h');

-- method 1 using lead window function 
with cte as (
SELECT *, 
LEAD(start_loc,1) OVER(PARTITION BY id ORDER BY start_time) as next_start_loc
FROM drivers
) 
SELECT id, COUNT(1) as total_rides,
SUM( case WHEN end_loc = next_start_loc then 1 else 0 end ) profit_ride
from cte GROUP BY id
;

-- method 1 using self join 
with rides as (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY start_time ) as rn
 FROM drivers
)
  SELECT r1.id , 
  count(1) as total_rides,
  count(r2.id ) as profit_ride
  FROM rides r1 
  LEFT JOIN rides r2 
  ON r1.id = r2.id and r1.end_loc = r2.start_loc and r1.rn +1 = r2.rn
  GROUP BY r1.id 
;

---------------------------------------------------------------------------------------------------
-- Write a sql query to find users who purchased different products on different dates
--ie products purchased on any given day are not repeated on any other day
---------------------------------------------------------------------------------------------------

create table purchase_history
(userid int
,productid int
,purchasedate date
);

INSERT INTO purchase_history 
(userid, productid, purchasedate) VALUES
(1, 1, '2012-01-23'),
(1, 2, '2012-01-23'),
(1, 3, '2012-01-25'),
(2, 1, '2012-01-23'),
(2, 2, '2012-01-23'),
(2, 2, '2012-01-25'),
(2, 4, '2012-01-25'),
(3, 4, '2012-01-23'),
(3, 1, '2012-01-23'),
(4, 1, '2012-01-23'),
(4, 2, '2012-01-25');

WITH cte as (
    SELECT
    userid,
    COUNT(DISTINCT purchasedate) no_of_dates,
    COUNT(productid) cnt_product,
    COUNT(DISTINCT productid) count_dist_product
 FROM purchase_history 
 GROUP BY userid
)
  SELECT * FROM cte WHERE no_of_dates > 1 
  AND  cnt_product = count_dist_product
  ;


  SELECT
    userid,
    COUNT(DISTINCT purchasedate) no_of_dates,
    COUNT(productid) cnt_product,
    COUNT(DISTINCT productid) count_dist_product
 FROM purchase_history 
 GROUP BY userid
 HAVING COUNT(DISTINCT purchasedate) >1
 AND COUNT(productid) = COUNT(DISTINCT productid);

 ---------------------------------------------------------------------------------------------------
 --- Marketing Campaign Success SQL Advanced Problem | Step by Step Solution using CTEs
/* Marketing Campaign Success:
You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in
a marketing campaign where they see call-to-actions for more in-app purchases.
Find the number of users that made additional in-app purchases due to the success of the marketing campaign.
The marketing campaign doesn't start unt•l one day after the initial in-app purchase so users that only
made one or multiple purchases on the first day do not count, nor do we count users that over time purchase
only the products they purchased on the first day.*/
--------------------------------------------------------------------------------------------------- 

 CREATE TABLE marketing_campaign (
    user_id INT NULL,
    created_at DATE NULL,
    product_id INT NULL,
    quantity INT NULL,
    price INT NULL
);

insert into marketing_campaign values (10,'2019-01-01',101,3,55),
(10,'2019-01-02',119,5,29),
(10,'2019-03-31',111,2,149),
(11,'2019-01-02',105,3,234),
(11,'2019-03-31',120,3,99),
(12,'2019-01-02',112,2,200),
(12,'2019-03-31',110,2,299),
(13,'2019-01-05',113,1,67),
(13,'2019-03-31',118,3,35),
(14,'2019-01-06',109,5,199),
(14,'2019-01-06',107,2,27),
(14,'2019-03-31',112,3,200),
(15,'2019-01-08',105,4,234),
(15,'2019-01-09',110,4,299),
(15,'2019-03-31',116,2,499),
(16,'2019-01-10',113,2,67),
(16,'2019-03-31',107,4,27),
(17,'2019-01-11',116,2,499),
(17,'2019-03-31',104,1,154),
(18,'2019-01-12',114,2,248),
(18,'2019-01-12',113,4,67),
(19,'2019-01-12',114,3,248),
(20,'2019-01-15',117,2,999),
(21,'2019-01-16',105,3,234),
(21,'2019-01-17',114,4,248),
(22,'2019-01-18',113,3,67),
(22,'2019-01-19',118,4,35),
(23,'2019-01-20',119,3,29),
(24,'2019-01-21',114,2,248),
(25,'2019-01-22',114,2,248),
(25,'2019-01-22',115,2,72),
(25,'2019-01-24',114,5,248),
(25,'2019-01-27',115,1,72),
(26,'2019-01-25',115,1,72),
(27,'2019-01-26',104,3,154),
(28,'2019-01-27',101,4,55),
(29,'2019-01-27',111,3,149),
(30,'2019-01-29',111,1,149),
(31,'2019-01-30',104,3,154),
(32,'2019-01-31',117,1,999),
(33,'2019-01-31',117,2,999),
(34,'2019-01-31',110,3,299),
(35,'2019-02-03',117,2,999),
(36,'2019-02-04',102,4,82),
(37,'2019-02-05',102,2,82),
(38,'2019-02-06',113,2,67),
(39,'2019-02-07',120,5,99),
(40,'2019-02-08',115,2,72),
(41,'2019-02-08',114,1,248),
(42,'2019-02-10',105,5,234),
(43,'2019-02-11',102,1,82),
(43,'2019-03-05',104,3,154),
(44,'2019-02-12',105,3,234),
(44,'2019-03-05',102,4,82),
(45,'2019-02-13',119,5,29),
(45,'2019-03-05',105,3,234),
(46,'2019-02-14',102,4,82),
(46,'2019-02-14',102,5,29),
(46,'2019-03-09',102,2,35),
(46,'2019-03-10',103,1,199),
(46,'2019-03-11',103,1,199),
(47,'2019-02-14',110,2,299),
(47,'2019-03-11',105,5,234),
(48,'2019-02-14',115,4,72),
(48,'2019-03-12',105,3,234),
(49,'2019-02-18',106,2,123),
(49,'2019-02-18',114,1,248),
(49,'2019-02-18',112,4,200),
(49,'2019-02-18',116,1,499),
(50,'2019-02-20',118,4,35),
(50,'2019-02-21',118,4,29),
(50,'2019-03-13',118,5,299),
(50,'2019-03-14',118,2,199),
(51,'2019-02-21',120,2,99),
(51,'2019-03-13',108,4,120),
(52,'2019-02-23',117,2,999),
(52,'2019-03-18',112,5,200),
(53,'2019-02-24',120,4,99),
(53,'2019-03-19',105,5,234),
(54,'2019-02-25',119,4,29),
(54,'2019-03-20',110,1,299),
(55,'2019-02-26',117,2,999),
(55,'2019-03-20',117,5,999),
(56,'2019-02-27',115,2,72),
(56,'2019-03-20',116,2,499),
(57,'2019-02-28',105,4,234),
(57,'2019-02-28',106,1,123),
(57,'2019-03-20',108,1,120),
(57,'2019-03-20',103,1,79),
(58,'2019-02-28',104,1,154),
(58,'2019-03-01',101,3,55),
(58,'2019-03-02',119,2,29),
(58,'2019-03-25',102,2,82),
(59,'2019-03-04',117,4,999),
(60,'2019-03-05',114,3,248),
(61,'2019-03-26',120,2,99),
(62,'2019-03-27',106,1,123),
(63,'2019-03-27',120,5,99),
(64,'2019-03-27',105,3,234),
(65,'2019-03-27',103,4,79),
(66,'2019-03-31',107,2,27),
(67,'2019-03-31',102,5,82) ;

WITH rnk_data as (
    SELECT *,
        RANK() OVER (PARTITION BY user_id ORDER BY created_at asc) rn 
    FROM marketing_campaign
),
  first_app_purchase as (
    SELECT * FROM rnk_data where rn = 1 
  ),
   except_1st_app_purchases as(
    SELECT * FROM rnk_data WHERE rn > 1 
   )
   SELECT A.user_id 
   FROM except_1st_app_purchases  A 
    LEFT JOIN first_app_purchase B 
     ON A.user_id = B.user_id
     AND A.product_id = B.product_id 
 where B.product_id is null ;
 
---------------------------------------------------------------------------------------------------
-- Complex SQL Problem Asked in a Fintech Startup | SQL For Data Analytics
/* Write SQL to find all couples of trade for same stock that happened in the range of 10 seconds
and having price difference by more than 10 %.
Output result should also list the percentage of price difference between the 2 trade */
---------------------------------------------------------------------------------------------------
Create Table Trade_tbl(
    TRADE_ID varchar(20),
    Trade_Timestamp time,
    Trade_Stock varchar(20),
    Quantity int,
    Price Float
)

Insert into Trade_tbl Values
('TRADE1','10:01:05','ITJunction4All',100,20)
,('TRADE2','10:01:06','ITJunction4All',20,15)
,('TRADE3','10:01:08','ITJunction4All',150,30)
,('TRADE4','10:01:09','ITJunction4All',300,32)
,('TRADE5','10:10:00','ITJunction4All',-100,19)
,('TRADE6','10:10:01','ITJunction4All',-300,19)
;

Insert into Trade_tbl Values
('TRADE1','10:01:05','infosys',100,20)
,('TRADE2','10:01:06','infosys',20,15)
,('TRADE5','10:10:00','infosys',-100,19)
,('TRADE6','10:10:01','infosys',-300,19)
;

SELECT
    t1.`TRADE_ID`,
    t2.`TRADE_ID`,
    t1.`Trade_Stock`,
    t1.`Trade_Timestamp`,
    t2.`Trade_Timestamp`,
    t1.`Price`,
    t2.`Price`,
    ABS(t1.`Price` - t2.`Price`) / t1.`Price` * 100
FROM trade_tbl t1
    join trade_tbl t2 ON t1.`Trade_Stock` = t2.`Trade_Stock`
WHERE
    t1.`TRADE_ID` != t2.`TRADE_ID`
    AND t1.`Trade_Timestamp` < t2.`Trade_Timestamp`
    AND TIMESTAMPDIFF(
        SECOND,
        t1.`Trade_Timestamp`,
        t2.`Trade_Timestamp`
    ) < 10
    AND ABS(t1.`Price` - t2.`Price`) / t1.`Price` * 100 > 10
ORDER BY t1.`TRADE_ID`;


---------------------------------------------------------------------------------------------------
-- Tricky SQL Challenge | SQL For Data Analytics
-- 
/* Problem statement : we have a table which stores data of multiple sections. 
every section has 3 numberswe have to find top 4 numbers from any 2 sections(2 numbers each) whose addition should be maximum
so in this case we will choose section b where we have 19(10+9) then we need to choose either C or D
because both has sum of 18 but in D we have 10 which is big from 9 so we will give priority to D.
*/
---------------------------------------------------------------------------------------------------
create table
    section_data (
        section varchar(5),
        number integer
    )
    ;
insert into section_data
values ('A', 5), ('A', 7), ('A', 10), 
('B', 7), ('B', 9), ('B', 10), ('C', 9), 
('C', 7), ('C', 9), ('D', 10), ('D', 3), 
('D', 8);

;
WITH cte as (
    SELECT *,
    ROW_NUMBER() OVER ( PARTITION BY section order by number desc ) as rn 
    FROM section_data
) , 
   cte2 as(
    SELECT *,
        SUM(number) OVER(PARTITION BY section) AS total,
        max(number) OVER(PARTITION BY section) as sec_max
     FROM cte where rn <=2     
   )
   SELECT * FROM (
    SELECT * , 
        DENSE_RANK() OVER(ORDER BY total desc , sec_max desc) as rnk
    FROM cte2
   ) a WHERE rnk <= 2 
   ;;
    
Select section,
number from ( 
    select tab1.section,
        tab1.number,
        sum(number) over(partition by tab1.section) total , 
        max(number) over ( partition by section) Maxx 
    from ( 
        select section
        ,number,
        row_number() over (partition by section order by number desc) no
From section_data) tab1
where tab1.no<3 
order by total desc,Maxx desc limit 4) tab2
;

with summary as (
select *,
dense_rank() over (order by number desc) as num_rnk, -- finding the maximum number from all the data
rank() over (partition by section order by number desc) as in_rnk from section_data  -- utilized this to filter out the third number for each section
),
section_sum as (
select section,sum(number) as sm,
num_rnk -- finding the sum for each section
from summary 
where in_rnk < 3 -- removing third record for each section
group by section
),
top_2_sum as (
select section,sm from section_sum
order by sm desc ,num_rnk limit 2 -- ordered by sum of section and breaks tie based on rank of the numbers in each section since D has higher ranked number it is shown in the final output
)
select * from top_2_sum;;

---------------------------------------------------------------------------------------------------
-- Data Analyst Case Study by A Major Travel Company | SQL for Data Analytics
---------------------------------------------------------------------------------------------------
CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);

INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) 
VALUES ('b1','2022-03-23','u1','Flight')
,('b2','2022-03-27','u2','Flight')
,('b3','2022-03-28','u1','Hotel')
,('b4','2022-03-31','u4','Flight')
,('b5','2022-04-02','u1','Hotel')
,('b6','2022-04-02','u2','Flight')
,('b7','2022-04-06','u5','Flight')
,('b8','2022-04-06','u6','Hotel')
,('b9','2022-04-06','u2','Flight')
,('b10','2022-04-10','u1','Flight')
,('b11','2022-04-12','u4','Flight')
,('b12','2022-04-16','u1','Flight')
,('b13','2022-04-19','u2','Flight')
,('b14','2022-04-20','u5','Hotel')
,('b15','2022-04-22','u6','Flight')
,('b16','2022-04-26','u4','Hotel')
,('b17','2022-04-28','u2','Hotel')
,('b18','2022-04-30','u1','Hotel')
,('b19','2022-05-04','u4','Hotel')
,('b20','2022-05-06','u1','Flight')
;


CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);

INSERT INTO user_table(User_id,Segment) 
VALUES ('u1','s1')
,('u2','s1')
,('u3','s1')
,('u4','s2')
,('u5','s2')
,('u6','s3')
,('u7','s3')
,('u8','s3')
,('u9','s3')
,('u10','s3')
;;

SELECT * FROM booking_table ;

--- Question 1 - summery at segment level 
--  Segment   Total_user_count     User_who_booked_flight_in_apr2022

SELECT u.segment , 
count(DISTINCT u.`User_id`) as number_f_users,
count(DISTINCT CASE WHEN b.`Line_of_business`='Flight' AND b.`Booking_date` BETWEEN '2022-04-01'  and '2022-04-30' THEN  b.`User_id`   END )as user_who_booked_flight
FROM user_table u 
LEFT JOIN booking_table b 
ON u.`User_id`= b.`User_id` 
GROUP BY u.`Segment`
;

--- Question 2 - 
-- Write a query to identify all the users who's first booking was a flight booking

WITH cte as (
SELECT * ,
RANK() OVER (PARTITION BY `User_id` ORDER BY `Booking_date` asc ) as rn
FROM booking_table
)
 SELECT * FROM cte where rn =1 and `Line_of_business` = "Hotel";

 --- OR
 with cte as (
    SELECT * ,
    FIRST_VALUE(`Line_of_business`) OVER (PARTITION BY `User_id` ORDER BY `Booking_date` asc ) as First_booking
    FROM booking_table
 ) SELECT DISTINCT `User_id` FROM cte WHERE First_booking='Hotel'

 --- Question 3 
 --- WRITE a query to calculate the days BETWEEN first booking and LAST Booking 
SELECT
    `User_id`,
    min(`Booking_date`),
    max(`Booking_date`),
    ABS(DATEDIFF(min(`Booking_date`), max(`Booking_date`)) ) no_of_days
FROM booking_table
GROUP BY `User_id`;

--- Question 4 - 
--- Write a query to count the NUMBER of flight and hotel booking 
-- in each of the user segment for the year 2022 
--- user_id   segment   number_of_flight_booking    number_of_hotel_booking

SELECT
    `Segment`,
    SUM(CASE WHEN YEAR(Booking_date) = 2022 AND Line_of_business = 'Flight' THEN 1 ELSE 0 END) AS number_of_flight_booking,
    SUM(CASE WHEN YEAR(Booking_date) = 2022 AND Line_of_business = 'Hotel' THEN 1 ELSE 0 END) AS number_of_hotel_booking
FROM
    booking_table b 
JOIN user_table u 
ON u.`User_id` = b.`User_id`
WHERE
    YEAR(Booking_date) = 2022
GROUP BY
    `Segment`;

------------------------------------------------------------------------------------------
--- Amazon Data Engineer SQL Interview Problem | Leetcode Hard SQL 2494 | Recursive CTE
--- Merge overlapping events in the same Hall 
------------------------------------------------------------------------------------------

create table hall_events
(
    hall_id integer,
    start_date date,
    end_date date
);
delete from hall_events;

insert into hall_events values 
(1,'2023-01-13','2023-01-14')
,(1,'2023-01-14','2023-01-17')
,(1,'2023-01-15','2023-01-17')
,(1,'2023-01-18','2023-01-25')
,(2,'2022-12-09','2022-12-23')
,(2,'2022-12-13','2022-12-17')
,(3,'2022-12-01','2023-01-30');

with RECURSIVE cte as (
        SELECT
            *,
            ROW_NUMBER() OVER( ORDER BY hall_id,start_date ) as event_id
        FROM
            hall_events
    ),
     r_cte as (
        SELECT
            hall_id,
            start_date,
            end_date,
            event_id,
            '1' as flag
        FROM cte
        where event_id = 1
        UNION ALL
        SELECT
            cte.hall_id,
            cte.start_date,
            cte.end_date,
            cte.event_id,
            CASE
                WHEN cte.hall_id = r_cte.hall_id
                AND(
                    cte.start_date BETWEEN r_cte.start_date
                    and r_cte.end_date
                    OR r_cte.start_date BETWEEN cte.start_date
                    AND cte.end_date
                ) THEN 0
                ELSE 1
            END + flag as flag
        FROM r_cte
            INNER JOIN cte ON r_cte.event_id + 1 = cte.event_id
    )
    select hall_id,
        flag,
        min(start_date) as start_date,
        max(end_date) as end_date
    from r_cte
    group by hall_id ,flag
    order by hall_id, flag 
    ;;

with cte as(
        select
            hall_id,
            start_date,
            end_date,
            lag(end_date) over(
                partition by hall_id
                order by
                    start_date
            ) as prev_end_date
        from hall_events
    )
select
    hall_id,
    min(start_date) as start_date,
    max(end_date) as end_date
from cte
where
    prev_end_date is null
    or start_date < prev_end_date
group by hall_id
union
select
    hall_id,
    start_date,
    end_date
from cte
where
    start_date > prev_end_date
order by hall_id, start_date;

-----------------------------------------------------------------------------------------------------------
-- PayPal SQL Interview Problem (Level Hard) | Advanced SQL Problem
/* The question goes as follows: We need to obtain a list of departments with an average salary lower than the overall average salary of the company.
However, when calculating the company's average salary, you must exclude the salaries of the department you are comparing it with. For instance,
when comparing the average salary of the HR department with the company's average, the HR department's salaries shouldn't be taken into
consideration for the calculation of company average salary. Likewise, if you want to compare the average salary of the Finance department with the
company's average, the comkpny's average salary should not include the salaries of the Finance department, and so on. Essentially, the company's
average salary will be dynamic for each department.*/
-----------------------------------------------------------------------------------------------------------

create table emp_paypal(
    emp_id int,
    emp_name varchar(20),
    department_id int,
    salary int,
    manager_id int,
    emp_age int
    );

INSERT INTO emp_paypal (emp_id, emp_name, department_id, salary, manager_id, emp_age)
VALUES
    (1, 'Ankit', 100, 10000, 4, 39),
    (2, 'Mohit', 100, 15000, 5, 48),
    (3, 'Vikas', 100, 10000, 4, 37),
    (4, 'Rohit', 100, 5000, 2, 16),
    (5, 'Mudit', 200, 12000, 6, 55),
    (6, 'Agam', 200, 12000, 2, 14),
    (7, 'Sanjay', 200, 9000, 2, 13),
    (8, 'Ashish', 200, 5000, 2, 12),
    (9, 'Mukesh', 300, 6000, 6, 51),
    (10, 'Rakesh', 300, 7000, 6, 50);

WITH cte as (    
    SELECT 
        department_id,
        AVG(salary) as dept_avg_sal,
        count(*) as num_of_emps,
        sum(salary) as total_dept_sal
    FROM emp_paypal
    GROUP BY department_id  
)
, cte2 as (
    SELECT 
        e1.department_id,
        e1.dept_avg_sal,
        sum( e2.num_of_emps) as no_of_emps,
        sum( e2.total_dept_sal) as total_sal,
        (sum( e2.total_dept_sal)/sum( e2.num_of_emps )) as cmp_avg_sal
    FROM cte e1 
    JOIN cte e2 
    ON e1.department_id != e2.department_id 
    GROUP BY e1.department_id ,e1.dept_avg_sal
    ORDER BY e1.department_id
) SELECT * FROM cte2 WHERE dept_avg_sal < cmp_avg_sal 
;;

-----------------------------------------------------------------------------------------------------------
--- PayPal Data Engineer SQL Interview Question (and a secret time saving trick)
--Write an sql code to find output table as below
-- employeeid ,employee_default_phone_number, totalentry,totallogin,totallogout,latestlogin,latestlogout
-----------------------------------------------------------------------------------------------------------

-- Create the employee_checkin_details table
CREATE TABLE employee_checkin_details (
    employeeid INT,
    entry_details VARCHAR(255),
    timestamp_details TIMESTAMP
);

-- Insert data into the employee_checkin_details table
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details)
VALUES
    (1000, 'login', '2023-06-16 01:00:15.34'),
    (1000, 'login', '2023-06-16 02:00:15.34'),
    (1000, 'login', '2023-06-16 03:00:15.34'),
    (1000, 'logout', '2023-06-16 12:00:15.34'),
    (1001, 'login', '2023-06-16 01:00:15.34'),
    (1001, 'login', '2023-06-16 02:00:15.34'),
    (1001, 'login', '2023-06-16 03:00:15.34'),
    (1001, 'logout', '2023-06-16 12:00:15.34');

-- Create the employee_details table
CREATE TABLE employee_details (
    employeeid INT,
    phone_number VARCHAR(255),
    isdefault BOOLEAN
);

-- Insert data into the employee_details table
INSERT INTO employee_details (employeeid, phone_number, isdefault)
VALUES
    (1001, '9999', false),
    (1001, '1111', false),
    (1001, '2222', true),
    (1003, '3333', false);

---Write an sql code to find output table as below
--- employeeid ,employee_default_phone_number, totalentry,totallogin,totallogout,latestlogin,latestlogout

SELECT * 
FROM employee_checkin_details 
JOIN employee_details
ON employee_checkin_details.employeeid= employee_details.employeeid;;

WITH logins AS (
    SELECT 
        employeeid,
        COUNT(*) AS total_logins,
        MAX(timestamp_details) AS latest_login
    FROM employee_checkin_details
    WHERE entry_details = 'login'
    GROUP BY employeeid
),
logouts AS (
    SELECT 
        employeeid,
        COUNT(*) AS total_logouts,
        MAX(timestamp_details) AS latest_logout
    FROM employee_checkin_details
    WHERE entry_details = 'logout'
    GROUP BY employeeid
)
SELECT a.employeeid,
    a.total_logins,
    a.latest_login,
    b.total_logouts,
    b.latest_logout,
    a.total_logins + b.total_logouts AS total_entries,
    c.phone_number,
    c.isdefault
FROM logins a 
JOIN logouts b ON a.employeeid = b.employeeid
LEFT JOIN employee_details c ON a.employeeid = c.employeeid
AND c.isdefault = true
; ;

--- or 

SELECT 
    a.employeeid,
    c.phone_number,
    COUNT(*) as total_enteries,
    COUNT(CASE WHEN entry_details='login' THEN  timestamp_details ELSE  NULL END ) as total_logins,
    COUNT(CASE WHEN entry_details='logout' THEN  timestamp_details ELSE  NULL END ) as total_logouts,
    MAX(CASE WHEN entry_details='login' THEN  timestamp_details ELSE  NULL END ) as latest_login,
    MAX(CASE WHEN entry_details='logout' THEN  timestamp_details ELSE  NULL END ) as latest_logout
FROM employee_checkin_details a
LEFT JOIN employee_details c ON a.employeeid = c.employeeid
AND c.isdefault = true
GROUP BY employeeid,phone_number
;;


-- Add the phone_no_added_date column to the employee_details table
ALTER TABLE employee_details
ADD COLUMN phone_no_added_date DATE;

-- Update the phone_no_added_date for each employee based on conditions
-- In this example, we set different dates based on the employee's phone_number
-- You can adjust the conditions and dates as needed for your specific data
UPDATE employee_details
SET phone_no_added_date =
    CASE
        WHEN phone_number = '9999' THEN '2023-09-11'  -- Example date for phone_number '9999'
        WHEN phone_number = '1111' THEN '2023-09-12'  -- Example date for phone_number '1111'
        WHEN phone_number = '2222' THEN '2023-09-13'  -- Example date for phone_number '2222'
        -- Add more conditions as needed
        ELSE '2023-09-10'  -- Default date for other cases
    END;

INSERT INTO employee_details (employeeid, phone_number, isdefault, phone_no_added_date)
VALUES (1000, '1234', false, '2023-09-10');


WITH phone_no AS (
    SELECT * FROM ( 
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY employeeid ORDER BY phone_no_added_date DESC) AS rn 
        FROM employee_details
        WHERE isdefault = FALSE
    ) a 
    WHERE rn = 1
),
default_phone AS (
    SELECT employeeid, phone_number
    FROM employee_details
    WHERE isdefault = TRUE
)
SELECT 
    a.employeeid,
    COALESCE(c.phone_number, d.phone_number) AS phone,
    COUNT(*) AS total_entries,
    COUNT(CASE WHEN entry_details = 'login' THEN timestamp_details ELSE NULL END) AS total_logins,
    COUNT(CASE WHEN entry_details = 'logout' THEN timestamp_details ELSE NULL END) AS total_logouts,
    MAX(CASE WHEN entry_details = 'login' THEN timestamp_details ELSE NULL END) AS latest_login,
    MAX(CASE WHEN entry_details = 'logout' THEN timestamp_details ELSE NULL END) AS latest_logout
FROM employee_checkin_details a
LEFT JOIN default_phone c ON a.employeeid = c.employeeid
LEFT JOIN phone_no d ON a.employeeid = d.employeeid
GROUP BY a.employeeid, COALESCE(c.phone_number, d.phone_number);

;;

-----------------------------------------------------------------------------------------------
--Uplers SQL Interview Problem (Senior Data Analyst) | Includes 4 Test Cases
/* Question : An organization is looking to hire employees /candidates for their junior and senior positions. They have a total quota/limit of 50000$ in all , they have to first fill up the
senior positions and then fill up the junior positions, There are 3 test cases , write a SQL query to satisfy all the testcases. To check whether your SQL query is correct or wrong you
can try with your own test case too */
-----------------------------------------------------------------------------------------------

-- Create the candidates table-- Create the candidates_2 table
CREATE TABLE candidates_2 (
    id INT PRIMARY KEY,
    positions VARCHAR(10) NOT NULL,
    salary INT NOT NULL
);

-- Test case 1
INSERT INTO candidates_2 VALUES (1, 'junior', 5000);
INSERT INTO candidates_2 VALUES (2, 'junior', 7000);
INSERT INTO candidates_2 VALUES (3, 'junior', 7000);
INSERT INTO candidates_2 VALUES (4, 'senior', 10000);
INSERT INTO candidates_2 VALUES (5, 'senior', 30000);
INSERT INTO candidates_2 VALUES (6, 'senior', 20000);
-----------------------------------------------------------------
SELECT * FROM candidates_2 ;

WITH cte as (
    SELECT  * , 
        SUM(salary) OVER(PARTITION BY positions ORDER BY salary asc ,id) as running_salary
    FROM candidates_2
 ), 
 senior_cte as ( 
  SELECT count(*) seniors ,
  SUM(salary) as s_salary
   FROM cte  WHERE positions = 'senior' 
   AND running_salary <=50000
 ) ,
 junior_cte as (
    SELECT count(*) as juniors 
    FROM cte 
    WHERE positions = 'junior' 
    AND running_salary <= 50000 -( SELECT s_salary from senior_cte)
 )
  SELECT seniors, juniors FROM senior_cte join junior_cte
 ;;
------------------------------------------------------------------
delete FROM candidates_2 ; 

-- Test case 2
INSERT INTO candidates_2 VALUES (7, 'junior', 10000);
INSERT INTO candidates_2 VALUES (8, 'senior', 15000);
INSERT INTO candidates_2 VALUES (9, 'senior', 30000);
--------------------------------------------------------------------------
SELECT * FROM candidates_2 ;

WITH cte as (
    SELECT  * , 
        SUM(salary) OVER(PARTITION BY positions ORDER BY salary asc ,id) as running_salary
    FROM candidates_2
 ), 
 senior_cte as ( 
  SELECT count(*) seniors ,
  SUM(salary) as s_salary
   FROM cte  WHERE positions = 'senior' 
   AND running_salary <=50000
 ) ,
 junior_cte as (
    SELECT count(*) as juniors 
    FROM cte 
    WHERE positions = 'junior' 
    AND running_salary <= 50000 -( SELECT s_salary from senior_cte)
 )
  SELECT seniors, juniors FROM senior_cte join junior_cte
 ;;

--------------------------------------------------------------------------
-- Test case 3
DELETE FROM candidates_2 ; 

INSERT INTO candidates_2 VALUES (10, 'junior', 15000);
INSERT INTO candidates_2 VALUES (11, 'junior', 15000);
INSERT INTO candidates_2 VALUES (12, 'junior', 20000);
INSERT INTO candidates_2 VALUES (13, 'senior', 60000);
-------------------------------------------------------------------
select * FROM candidates_2 ; 

WITH cte as (
    SELECT  * , 
        SUM(salary) OVER(PARTITION BY positions ORDER BY salary asc ,id) as running_salary
    FROM candidates_2
 ), 
 senior_cte as ( 
  SELECT count(*) seniors ,
  COALESCE(SUM(salary),0) as s_salary
   FROM cte  WHERE positions = 'senior' 
   AND running_salary <=50000
 ) ,
 junior_cte as (
    SELECT count(*) as juniors 
    FROM cte 
    WHERE positions = 'junior' 
    AND running_salary <= 50000 -( SELECT s_salary from senior_cte)
 )
  SELECT seniors, juniors FROM senior_cte join junior_cte
 ;;
--------------------------------------------------------------------------
-- Test case 4
DELETE FROM candidates_2 ;


INSERT INTO candidates_2 VALUES (14, 'junior', 10000);
INSERT INTO candidates_2 VALUES (15, 'junior', 10000);
INSERT INTO candidates_2 VALUES (16, 'senior', 15000);
INSERT INTO candidates_2 VALUES (17, 'senior', 30000);
INSERT INTO candidates_2 VALUES (18, 'senior', 15000);

SELECT * FROM candidates_2 ; 


WITH cte as (
    SELECT  * , 
        SUM(salary) OVER(PARTITION BY positions ORDER BY salary asc ,id) as running_salary
    FROM candidates_2
 ), 
 senior_cte as ( 
  SELECT count(*) seniors ,
  COALESCE(SUM(salary),0) as s_salary
   FROM cte  WHERE positions = 'senior' 
   AND running_salary <=50000
 ) ,
 junior_cte as (
    SELECT count(*) as juniors 
    FROM cte 
    WHERE positions = 'junior' 
    AND running_salary <= 50000 -( SELECT s_salary from senior_cte)
 )
  SELECT seniors, juniors FROM senior_cte join junior_cte
 ;;


 -------------------------------------------------------------------------------------------------------------