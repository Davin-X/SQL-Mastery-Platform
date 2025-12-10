-- Activity spike detection / grouping on status transitions

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

-- Example: identify on-periods and duration
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