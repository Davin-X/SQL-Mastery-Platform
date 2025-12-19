/* We have below table in SQL
date,sales
18-10-2021, 1000
19-10-2021, 2000
26-10-2021, 3000
29-10-2021, 2000
31-10-2021, 4000
We want to get the Weekly_sales and as 18-10 is first row, 
we will get 1000 as First row and for new week we will do the sum. 
The output should look like below.
date.  , sales,   weekly_sale
18-Oct , 1000,  1000
19-Oct , 2000,  3000
26-Oct , 3000 , 5000
29-Oct , 2000 , 5000
31-Oct , 4000 , 9000


*/


DROP TABLE IF EXISTS sales;
CREATE TABLE `sales` (
  `date` date DEFAULT NULL,
  `sales` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO sales(date,sales) 
VALUES('2021-10-18',1000),
('2021-10-19',2000),
('2021-10-26',3000),
('2021-10-29',2000),
('2021-10-31',4000);

SELECT date ,sales,
SUM(sales) OVER (ORDER BY date RANGE BETWEEN interval 7 day preceding AND current row)
 as weekly_sum FROM sales ;