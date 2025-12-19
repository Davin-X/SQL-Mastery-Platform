# 12 — Misc Interview (complex patterns)

## Problem A: Unique name matching

Find names that have a specific id (e.g., id=2) AND appear only once across the table.

Starter dataset / schema

```sql
CREATE TABLE my_table (name VARCHAR(1), id INT);INSERT INTO my_table VALUES('A',1),('A',2),('A',3),('B',2),('C',3),('C',1);
```

### Solution A

Show solution

Using window functions:

```sql
SELECT name, idFROM (  SELECT name, id, COUNT(name) OVER (PARTITION BY name) AS name_count  FROM my_table) tWHERE id = 2 AND name_count = 1;
```

Result: `B | 2` (B appears once and has id=2)

---

## Problem B: Activity periods with state transitions

Given an activity log with on/off states and times, identify continuous "on" periods and compute their durations.

Starter dataset / schema

```sql
CREATE TABLE activity_log ( time TIME, activity VARCHAR(3) );INSERT INTO activity_log VALUES('10:01:00','on'),('10:02:00','on'),('10:03:00','on'),('10:04:00','off'),('10:05:00','on'),('10:06:00','on'),('10:07:00','off'),('10:08:00','off'),('10:09:00','off'),('10:10:00','on'),('10:11:00','off'),('10:12:00','on'),('10:13:00','on'),('10:14:00','on'),('10:15:00','off');
```

### Solution B

Show solution

Using CTEs to pair "on" states with next "off" state:

```sql
WITH starts AS (  SELECT time AS start_time  FROM activity_log  WHERE activity = 'on'),periods AS (  SELECT start_time,    (SELECT MIN(time)     FROM activity_log     WHERE time > start_time AND activity = 'off'    ) AS end_time  FROM starts)SELECT start_time, end_time,       TIMEDIFF(end_time, start_time) AS durationFROM periodsWHERE end_time IS NOT NULL;
```

Expected result:

-   `10:01:00 | 10:04:00 | 00:03:00`
-   `10:05:00 | 10:07:00 | 00:02:00`
-   `10:10:00 | 10:11:00 | 00:01:00`
-   `10:12:00 | 10:15:00 | 00:03:00`