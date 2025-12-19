-- Active: 1671859768936@@127.0.0.1@3306@practice
/*

input -
time	activity
10:01:00	on
10:02:00	on
10:03:00	on
10:04:00	off
10:05:00	on
10:06:00	on
10:07:00	off
10:08:00	off
10:09:00	off
10:10:00	on
10:11:00	off
10:12:00	on
10:13:00	on
10:14:00	on
10:15:00	off

output 
10:01:00	10:04:00	3
10:05:00	10:07:00	2
10:10:00	10:11:00	1
10:12:00    10:15:00    3
*/
;
CREATE TABLE activity_log (
  time TIME,
  activity VARCHAR(3)
);

INSERT INTO activity_log VALUES
('10:01:00', 'on'),
('10:02:00', 'on'),
('10:03:00', 'on'),
('10:04:00', 'off'),
('10:05:00', 'on'),
('10:06:00', 'on'),
('10:07:00', 'off'),
('10:08:00', 'off'),
('10:09:00', 'off'),
('10:10:00', 'on'),
('10:11:00', 'off'),
('10:12:00', 'on'),
('10:13:00', 'on'),
('10:14:00', 'on'),
('10:15:00', 'off');


with cte as (

SELECT start_time, end_time, TIME_TO_SEC(TIMEDIFF(end_time, start_time))/60 AS duration,
LAG(end_time) over( ORDER BY start_time) as PREV
FROM (
  SELECT 
    a.time AS start_time,
    MIN(b.time) AS end_time
  FROM activity_log a
  LEFT JOIN activity_log b ON a.time < b.time AND b.activity = 'off'
  WHERE a.activity = 'on'
  GROUP BY a.time
) AS periods
)

SELECT start_time ,end_time , duration from cte where prev <> end_time or prev is null
;


with cte as (
  SELECT start_time, end_time, TIME_TO_SEC(TIMEDIFF(end_time, start_time))/60 AS duration,
LAG(end_time) over( ORDER BY start_time) as PREV
FROM (
  SELECT 
    time AS start_time,
    IF(activity = 'on', 
       (SELECT MIN(time) FROM activity_log WHERE time > start_time AND activity = 'off' AND time NOT IN (SELECT time FROM activity_log WHERE activity = 'on' AND time > start_time AND time < (SELECT MIN(time) FROM activity_log WHERE time > start_time AND activity = 'off'))), 
       NULL) AS end_time
  FROM activity_log
) AS periods
WHERE end_time IS NOT NULL
) 

SELECT start_time ,end_time , duration from cte where prev <> end_time or prev is null

;


--SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));



