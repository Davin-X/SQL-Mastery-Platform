# 09 — Scheduling / elapsed times

Problem
- Given a train schedule table with stops and times, compute elapsed travel time from previous station and time to next station (skip `Non Stop` entries where appropriate).

Starter dataset / schema
```sql
CREATE TABLE train_schedule (
    Train_id VARCHAR(10),
    Station VARCHAR(10),
    Time VARCHAR(20)
);

INSERT INTO train_schedule VALUES
('E110','SBC','10:00:00'),('E110','KGI','10:54:00'),('E110','BID','11:02:00'),('E110','MYA','12:35:00'),
('E120','SBC','11:00:00'),('E120','KGI','Non Stop'),('E120','BID','12:49:00'),('E120','MYA','13:30:00');
```

Hints
- Use self-joins to find previous/next times per train, or use `LAG()`/`LEAD()` window functions if available. Handle `Non Stop` specially.

### Solution
<details><summary>Show solution</summary>

Example using joins and aggregation (works in MySQL):

```sql
SELECT
  t1.Train_id,
  t1.Station,
  t1.Time,
  TIMEDIFF(t1.Time, COALESCE(MAX(t2.Time), t1.Time)) AS elapsed_travel_time,
  TIMEDIFF(COALESCE(MIN(t3.Time), t1.Time), t1.Time) AS time_to_next_station
FROM train_schedule t1
  LEFT JOIN train_schedule t2 ON t1.Train_id = t2.Train_id AND t1.Time > t2.Time
  LEFT JOIN train_schedule t3 ON t1.Train_id = t3.Train_id AND t1.Time < t3.Time AND t3.Time <> 'Non Stop'
GROUP BY t1.Train_id, t1.Station, t1.Time
ORDER BY t1.Train_id, t1.Time;
```

Window-function alternative (if times are consistent type and `Non Stop` filtered):

```sql
SELECT Train_id, Station, Time,
       TIMEDIFF(Time, LAG(Time) OVER (PARTITION BY Train_id ORDER BY Time)) AS elapsed_travel_time,
       TIMEDIFF(LEAD(Time) OVER (PARTITION BY Train_id ORDER BY Time), Time) AS time_to_next_station
FROM train_schedule
WHERE Time <> 'Non Stop'
ORDER BY Train_id, Time;
```

Notes
- Convert times to proper `TIME` types where possible for reliable `TIMEDIFF` arithmetic.

</details>
