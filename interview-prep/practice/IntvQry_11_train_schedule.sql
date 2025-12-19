-- Active: 1671859768936@@127.0.0.1@3306@practice
"""
write a query to get following output ADD	
table = train_schedule 
 Train_id    Station           Time
E110       SBC                10:00:00
E110       KGI             	  10:54:00        44
E110       BID                11:02:00
E110       MYA                12:35:00

E120       SBC                11:00:00
E120       KGI                Non Stop
E120       BID                12:49:00
E120       MYA                13:30:00

OUTPUT ==

Train_id    Station           Time         elapsed_travel_time  time_to_next_station  

E110       SBC                10:00:00      00:00:00                  00:54:00
E110       KGI                10:54:00      00:54:00                  00:08:00
E110       BID                11:02:00      01:02:00                  01:33:00
"""
;
CREATE TABLE train_schedule (
  Train_id VARCHAR(10),
  Station VARCHAR(10),
  Time VARCHAR(20)
);

INSERT INTO train_schedule VALUES
('E110', 'SBC', '10:00:00'),
('E110', 'KGI', '10:54:00'),
('E110', 'BID', '11:02:00'),
('E110', 'MYA', '12:35:00'),
('E120', 'SBC', '11:00:00'),
('E120', 'KGI', 'Non Stop'),
('E120', 'BID', '12:49:00'),
('E120', 'MYA', '13:30:00');

SELECT 
    t1.Train_id,
    t1.Station,
    t1.Time,
    TIMEDIFF(t1.Time, COALESCE(MAX(t2.Time), t1.Time)) AS elapsed_travel_time,
    TIMEDIFF(COALESCE(MIN(t3.Time), t1.Time), t1.Time) AS time_to_next_station
FROM 
    train_schedule t1
LEFT JOIN 
    train_schedule t2 ON t1.Train_id = t2.Train_id AND t1.Time > t2.Time
LEFT JOIN 
    train_schedule t3 ON t1.Train_id = t3.Train_id AND t1.Time < t3.Time AND t3.Time <> 'Non Stop'
GROUP BY 
    t1.Train_id, t1.Station, t1.Time
ORDER BY 
    t1.Train_id, t1.Time;

SELECT 
  train_schedule.Train_id, 
  train_schedule.Station, 
  train_schedule.Time, 
  TIMEDIFF(train_schedule.Time, COALESCE(LAG(train_schedule.Time) OVER partitioned_schedule, train_schedule.Time)) AS elapsed_travel_time,
  TIMEDIFF(COALESCE(LEAD(train_schedule.Time) OVER partitioned_schedule, train_schedule.Time), train_schedule.Time) AS time_to_next_station
FROM 
  train_schedule
WINDOW 
  partitioned_schedule AS (PARTITION BY train_schedule.Train_id ORDER BY train_schedule.Time)
ORDER BY 
  train_schedule.Train_id, 
  train_schedule.Time;
