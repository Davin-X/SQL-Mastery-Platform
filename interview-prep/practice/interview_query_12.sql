"""
table 
name	id
A		1			
A		2			
A		3			
B		2			
C		3			
C		1			

output

name	id
B		2
"""
;

CREATE TABLE my_table (
  name VARCHAR(1),
  id INT
);

INSERT INTO my_table VALUES 
('A', 1),
('A', 2),
('A', 3),
('B', 2),
('C', 3),
('C', 1);


CREATE TABLE result AS
SELECT name, id
FROM (
  SELECT name, id, COUNT(name) OVER (PARTITION BY name) AS name_count
  FROM my_table
) t
WHERE id = 2 AND name_count = 1;


select * from result;


CREATE TABLE temp_table AS
SELECT name, COUNT(*) AS count_id
FROM my_table
GROUP BY name
HAVING COUNT(*) = 1;

SELECT t.name, t2.id
FROM temp_table t
JOIN my_table t2 ON t.name = t2.name AND t2.id = 2;
