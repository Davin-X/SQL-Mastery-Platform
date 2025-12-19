# 🎯 Train Schedule Analysis Interview Question

## Question
Given train schedule data, find trains that run between specific stations within a given time window, and identify the shortest travel time for each route.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE train_schedules (
    train_id VARCHAR(10),
    departure_station VARCHAR(50),
    arrival_station VARCHAR(50),
    departure_time TIME,
    arrival_time TIME,
    distance_km INT,
    train_type VARCHAR(20)
);

INSERT INTO train_schedules VALUES
('T101', 'New York', 'Boston', '08:00:00', '11:30:00', 350, 'Express'),
('T102', 'New York', 'Boston', '10:00:00', '14:00:00', 350, 'Regular'),
('T103', 'New York', 'Boston', '12:00:00', '16:00:00', 350, 'Express'),
('T201', 'Boston', 'Washington', '09:00:00', '13:00:00', 450, 'Express'),
('T202', 'Boston', 'Washington', '11:00:00', '15:30:00', 450, 'Regular'),
('T301', 'New York', 'Washington', '08:30:00', '14:30:00', 400, 'Direct'),
('T302', 'New York', 'Washington', '13:00:00', '19:00:00', 400, 'Regular');
```

## Answer: Trains Between Stations with Time Analysis

```sql
SELECT 
    train_id,
    departure_station,
    arrival_station,
    departure_time,
    arrival_time,
    TIMEDIFF(arrival_time, departure_time) AS travel_duration,
    distance_km,
    ROUND(distance_km / (TIME_TO_SEC(TIMEDIFF(arrival_time, departure_time)) / 3600.0), 1) AS avg_speed_kmh,
    train_type
FROM train_schedules
WHERE departure_station = 'New York' 
  AND arrival_station = 'Boston'
  AND departure_time BETWEEN '08:00:00' AND '16:00:00'
ORDER BY travel_duration;
```

**How it works**: 
- Filters for specific route and time window
- Calculates travel duration using TIMEDIFF
- Computes average speed based on distance and time
- Orders by shortest travel time

## Alternative: Shortest Route Analysis

```sql
SELECT 
    departure_station,
    arrival_station,
    MIN(TIMEDIFF(arrival_time, departure_time)) AS shortest_duration,
    COUNT(*) AS total_trains,
    AVG(distance_km) AS avg_distance
FROM train_schedules
GROUP BY departure_station, arrival_station
ORDER BY shortest_duration;
```

**How it works**: Groups by route to find shortest travel time for each pair of stations.

## Advanced: Route Optimization with Multiple Criteria

```sql
WITH route_analysis AS (
    SELECT 
        departure_station,
        arrival_station,
        train_id,
        departure_time,
        arrival_time,
        TIMEDIFF(arrival_time, departure_time) AS duration,
        distance_km,
        train_type,
        ROW_NUMBER() OVER (
            PARTITION BY departure_station, arrival_station 
            ORDER BY TIMEDIFF(arrival_time, departure_time)
        ) AS fastest_rank,
        ROW_NUMBER() OVER (
            PARTITION BY departure_station, arrival_station 
            ORDER BY departure_time
        ) AS earliest_rank
    FROM train_schedules
    WHERE departure_time BETWEEN '06:00:00' AND '22:00:00'
)
SELECT 
    departure_station,
    arrival_station,
    train_id,
    departure_time,
    arrival_time,
    duration,
    train_type,
    CASE 
        WHEN fastest_rank = 1 THEN 'Fastest'
        WHEN earliest_rank = 1 THEN 'Earliest'
        ELSE 'Other'
    END AS route_type
FROM route_analysis
WHERE fastest_rank = 1 OR earliest_rank = 1
ORDER BY departure_station, arrival_station, departure_time;
```

**How it works**: Identifies both fastest and earliest trains for each route using window functions.

## Time Window Analysis

```sql
SELECT 
    CASE 
        WHEN HOUR(departure_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(departure_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(departure_time) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS time_period,
    COUNT(*) AS train_count,
    AVG(TIMEDIFF(arrival_time, departure_time)) AS avg_duration,
    MIN(TIMEDIFF(arrival_time, departure_time)) AS min_duration,
    MAX(TIMEDIFF(arrival_time, departure_time)) AS max_duration
FROM train_schedules
GROUP BY CASE 
    WHEN HOUR(departure_time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(departure_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(departure_time) BETWEEN 18 AND 23 THEN 'Evening'
    ELSE 'Night'
END
ORDER BY time_period;
```

**How it works**: Categorizes trains by departure time periods and analyzes duration statistics.

