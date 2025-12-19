-- Misc interview problems (combined)

-- Problem from interview_query_12.sql
CREATE TABLE my_table (name VARCHAR(1), id INT);

INSERT INTO
    my_table
VALUES ('A', 1),
    ('A', 2),
    ('A', 3),
    ('B', 2),
    ('C', 3),
    ('C', 1);

-- Example solution: find names with unique id=2
CREATE TABLE result AS
SELECT name, id
FROM (
        SELECT name, id, COUNT(name) OVER (
                PARTITION BY
                    name
            ) AS name_count
        FROM my_table
    ) t
WHERE
    id = 2
    AND name_count = 1;

-- Problem from interview_query_16.sql (activity on/off grouping)
CREATE TABLE activity_log ( time TIME, activity VARCHAR(3) );

INSERT INTO
    activity_log
VALUES ('10:01:00', 'on'),
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

-- Example: identify on-periods and durations
WITH
    starts AS (
        SELECT time AS start_time
        FROM activity_log
        WHERE
            activity = 'on'
    ),
    periods AS (
        SELECT start_time, (
                SELECT MIN(time)
                FROM activity_log
                WHERE
                    time > start_time
                    AND activity = 'off'
            ) AS end_time
        FROM starts
    )
SELECT start_time, end_time, TIMEDIFF(end_time, start_time) AS duration
FROM periods
WHERE
    end_time IS NOT NULL;