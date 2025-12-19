-- Active: 1671859768936@@127.0.0.1@3306@practice

'''
write a query to get the following results ===

Input
c1 c2 c3
a  2  2020-01-02
b  1  2020-01-01
c  5  2020-01-05


Output
c1 c2 c3
a  1  2020-01-02
a  2  2020-01-03
b  1  2020-01-01
c  1  2020-01-05
c  2  2020-01-06
c  3  2020-01-07
c  4  2020-01-08
c  5  2020-01-09
'''
;

CREATE TABLE input (
  c1 VARCHAR(1),
  c2 INT,
  c3 DATE
);

INSERT INTO input VALUES
  ('a', 2, '2020-01-02'),
  ('b', 1, '2020-01-01'),
  ('c', 5, '2020-01-05');

 ---------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------

SELECT t1.c1, 
       t2.n, 
       DATE_ADD(t1.c3, INTERVAL (t2.n - 1) DAY) AS c3
FROM input t1
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) t2
ON t2.n <= t1.c2
ORDER BY t1.c1, c3;
 ---------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------

WITH RECURSIVE temp (c1, c2, c3) AS (
  SELECT c1, 1, c3
  FROM input
  UNION ALL
  SELECT temp.c1, temp.c2+1, temp.c3+INTERVAL 1 DAY
  FROM temp
  JOIN input ON input.c1=temp.c1 AND input.c2>temp.c2
)
SELECT c1, c2, c3
FROM temp
ORDER BY c1, c3;
 ---------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------
'''
import findspark
findspark.init()

from pyspark.sql import SparkSession
spark = SparkSession.builder.appName('app1').getOrCreate()
from pyspark.sql.functions import *
# create input DataFrame
input_df = spark.createDataFrame([
    ('a', 2, '2020-01-02'),
    ('b', 1, '2020-01-01'),
    ('c', 5, '2020-01-05')
], ['c1', 'c2', 'c3'])

# convert c3 column to date type
input_df = input_df.withColumn('c3', expr("TO_DATE(c3)"))
spark.sql(""" 
SELECT c1, 
       seq AS c2, 
       DATE_ADD(c3, cast (seq - 1 as int )) AS c3
FROM input
LATERAL VIEW EXPLODE(sequence(1, c2)) s AS seq
ORDER BY c1, c3 """).show()

'''
