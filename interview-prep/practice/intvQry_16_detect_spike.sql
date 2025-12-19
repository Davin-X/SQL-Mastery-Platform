-- Active: 1671859768936@@127.0.0.1@3306@practice

-- GIven a table with daily price of a stock (bitcoin).
-- Need to find the day in which spike was observed.
/*
Daily_price
===========
-------------- 
| Day| Price |
--------------
| 1  | 10    |
| 2  | 12    |
| 3  | 55    |
| 4  | 12    | 
| 5  | 77    | 
| 6  | 10    | 
--------------

Output
=========

| Day| 
------
| 3  |
| 5  |
*/
;
-- Create table
CREATE TABLE Daily_price (
    Day INT PRIMARY KEY,
    Price INT
);

-- Insert data
INSERT INTO Daily_price (Day, Price) VALUES
(1, 10),
(2, 12),
(3, 55),
(4, 12),
(5, 77),
(6, 10);

select * from daily_price ; 


WITH DailyPriceWithPrevNext AS (
    SELECT
        Day,
        Price,
        LAG(Price) OVER (ORDER BY Day) AS PrevPrice,
        LEAD(Price) OVER (ORDER BY Day) AS NextPrice
    FROM
        Daily_price 
)
SELECT Day
FROM DailyPriceWithPrevNext
WHERE Price > PrevPrice AND Price > NextPrice;

------------------------------------------------------