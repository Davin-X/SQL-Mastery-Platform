# 11 — Spike Detection (on/off activity periods)

Problem
- Given an activity log with timestamps and on/off states, identify continuous "on" periods and their durations.

Starter dataset / schema
```sql
CREATE TABLE activity_log ( time TIME, activity VARCHAR(3) );
INSERT INTO activity_log VALUES
('10:01:00','on'),('10:02:00','on'),('10:03:00','on'),('10:04:00','off'),
('10:05:00','on'),('10:06:00','on'),('10:07:00','off'),('10:08:00','off'),
('10:09:00','off'),('10:10:00','on'),('10:11:00','off'),('10:12:00','on'),
('10:13:00','on'),('10:14:00','on'),('10:15:00','off');
```

Hints
- Find all "on" transitions, then match each with the next "off" state. Use CTEs or window functions.

### Solution
<details><summary>Show solution</summary>

Using CTEs to find on-periods and their matching off times:

```sql
WITH starts AS (
  SELECT time AS start_time
  FROM activity_log
  WHERE activity = 'on'
),
periods AS (
  SELECT start_time,
    (SELECT MIN(time)
     FROM activity_log
     WHERE time > start_time AND activity = 'off'
    ) AS end_time
  FROM starts
)
SELECT start_time, end_time,
       TIMEDIFF(end_time, start_time) AS duration
FROM periods
WHERE end_time IS NOT NULL;
```

Window-function alternative using gaps-and-islands:

```sql
WITH numbered AS (
  SELECT time, activity,
         ROW_NUMBER() OVER (ORDER BY time) AS rn
  FROM activity_log
),
islands AS (
  SELECT time, activity,
         SUM(CASE WHEN activity <> LAG(activity) OVER (ORDER BY time) THEN 1 ELSE 0 END)
         OVER (ORDER BY time ROWS UNBOUNDED PRECEDING) AS island
  FROM numbered
)
SELECT activity, MIN(time) AS start_time, MAX(time) AS end_time,
       TIMEDIFF(MAX(time), MIN(time)) AS duration
FROM islands
WHERE activity = 'on'
GROUP BY activity, island;
```

Notes
- The CTE approach is simpler; gaps-and-islands scales better for many state changes.

</details>
