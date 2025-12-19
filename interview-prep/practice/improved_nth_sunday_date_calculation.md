# 🎯 Nth Occurrence Sunday Date Calculation

## Question
Write a SQL query to find the date of the nth occurrence of Sunday from a given start date. For example, find the 3rd Sunday from January 1, 2024.

## SQL Setup (Tables and Sample Data)

```sql
-- No specific table needed for this calculation
-- We'll use MySQL date functions
```

## Answer: Nth Sunday Calculation

```sql
-- Set variables for the calculation
SET @start_date = '2024-01-01';  -- Starting date
SET @n = 3;  -- Which occurrence (3rd Sunday)

-- Calculate the date
SELECT DATE_ADD(@start_date, INTERVAL (8 - DAYOFWEEK(@start_date) + 7 * (@n - 1)) DAY) AS nth_sunday_date;
```

**How it works**: 
- `DAYOFWEEK(date)` returns 1 for Sunday, 2 for Monday, etc.
- `8 - DAYOFWEEK(@start_date)` calculates days to first Sunday
- `7 * (@n - 1)` adds weeks for subsequent occurrences
- `DATE_ADD` provides the final date

## Alternative: More Readable Version

```sql
DELIMITER //

CREATE FUNCTION get_nth_sunday(start_date DATE, n INT)
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE first_sunday DATE;
    DECLARE days_to_first_sunday INT;
    
    -- Find how many days to add to get to first Sunday
    SET days_to_first_sunday = 8 - DAYOFWEEK(start_date);
    
    -- If start_date is Sunday, we need to adjust
    IF days_to_first_sunday = 8 THEN
        SET days_to_first_sunday = 1;
    END IF;
    
    -- Calculate first Sunday
    SET first_sunday = DATE_ADD(start_date, INTERVAL days_to_first_sunday - 1 DAY);
    
    -- Add weeks for nth occurrence
    RETURN DATE_ADD(first_sunday, INTERVAL (n - 1) WEEK);
END //

DELIMITER ;

-- Usage
SELECT get_nth_sunday('2024-01-01', 3) AS third_sunday;
```

**How it works**: Creates a stored function for reusable Sunday calculations with clear logic and comments.

## PostgreSQL Version

```sql
-- PostgreSQL uses different day numbering (0=Sunday, 1=Monday)
CREATE OR REPLACE FUNCTION get_nth_sunday(start_date DATE, n INTEGER)
RETURNS DATE AS $$
DECLARE
    days_to_first_sunday INTEGER;
    first_sunday DATE;
BEGIN
    -- Extract day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
    days_to_first_sunday := (8 - EXTRACT(DOW FROM start_date)::INTEGER) % 7;
    
    -- If start_date is Sunday, days_to_first_sunday will be 0
    IF days_to_first_sunday = 0 THEN
        days_to_first_sunday := 7;  -- Next Sunday
    END IF;
    
    -- Calculate first Sunday
    first_sunday := start_date + INTERVAL '1 day' * (days_to_first_sunday - 1);
    
    -- Add weeks for nth occurrence
    RETURN first_sunday + INTERVAL '1 week' * (n - 1);
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT get_nth_sunday('2024-01-01'::DATE, 3) AS third_sunday;
```

**How it works**: PostgreSQL version using different day numbering system and INTERVAL syntax.

## SQL Server Version

```sql
CREATE FUNCTION dbo.GetNthSunday(@start_date DATE, @n INT)
RETURNS DATE
AS
BEGIN
    DECLARE @first_sunday DATE;
    DECLARE @days_to_first_sunday INT;
    
    -- DATEPART(WEEKDAY) returns 1=Sunday, 2=Monday, ..., 7=Saturday
    SET @days_to_first_sunday = 8 - DATEPART(WEEKDAY, @start_date);
    
    -- If start_date is Sunday, adjust
    IF @days_to_first_sunday = 8 THEN
        SET @days_to_first_sunday = 1;
    END IF;
    
    -- Calculate first Sunday
    SET @first_sunday = DATEADD(DAY, @days_to_first_sunday - 1, @start_date);
    
    -- Add weeks for nth occurrence
    RETURN DATEADD(WEEK, @n - 1, @first_sunday);
END;

-- Usage
SELECT dbo.GetNthSunday('2024-01-01', 3) AS third_sunday;
```

**How it works**: SQL Server version using DATEPART and DATEADD functions.

## Practical Examples

### Business Use Cases

```sql
-- Find next 3 Sundays for scheduling
SELECT 
    '1st Sunday' AS occurrence,
    DATE_ADD(CURDATE(), INTERVAL (8 - DAYOFWEEK(CURDATE()) + 7 * 0) DAY) AS sunday_date
UNION ALL
SELECT 
    '2nd Sunday' AS occurrence,
    DATE_ADD(CURDATE(), INTERVAL (8 - DAYOFWEEK(CURDATE()) + 7 * 1) DAY) AS sunday_date
UNION ALL
SELECT 
    '3rd Sunday' AS occurrence,
    DATE_ADD(CURDATE(), INTERVAL (8 - DAYOFWEEK(CURDATE()) + 7 * 2) DAY) AS sunday_date;
```

**Result**: Next 3 Sundays for scheduling purposes

### Monthly Reporting

```sql
-- Find Sundays in current month for weekly report scheduling
SELECT 
    DATE_ADD(LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, 
             INTERVAL (8 - DAYOFWEEK(LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) + 7 * n) DAY) AS monthly_sundays
FROM (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
) numbers
WHERE DATE_ADD(LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, 
               INTERVAL (8 - DAYOFWEEK(LAST_DAY(CURDATE() - INTERVAL 1 MONTH) + INTERVAL 1 DAY) + 7 * n) DAY)
       <= LAST_DAY(CURDATE())
ORDER BY monthly_sundays;
```

**How it works**: Generates all Sundays in the current month for report scheduling.

## Interview Tips

- **Date functions vary by database**: Know the differences (DAYOFWEEK vs EXTRACT(DOW) vs DATEPART)
- **Day numbering conventions**: Sunday as 1, 0, or 7 depending on database
- **Edge cases**: When start date is already a Sunday
- **Business applications**: Report scheduling, deadline calculations
- **Performance**: Simple calculations, no complex queries needed

## Real-World Applications

- **Report scheduling**: Weekly reports on Sundays
- **Deadline calculations**: Nth business day calculations
- **Calendar applications**: Finding specific weekdays
- **Project planning**: Milestone date calculations
- **Event scheduling**: Recurring event dates

## Key Concepts Demonstrated

- **Date arithmetic**: DATE_ADD, DATE_SUB operations
- **Day of week calculations**: DAYOFWEEK, EXTRACT(DOW), DATEPART
- **Conditional logic**: CASE statements for date adjustments
- **Reusable functions**: UDFs for complex date calculations
- **Cross-database compatibility**: Different approaches for different RDBMS

## Testing and Validation

```sql
-- Test the calculation
SET @test_date = '2024-01-01';
SET @test_n = 3;

-- Verify it's actually a Sunday
SELECT 
    DATE_ADD(@test_date, INTERVAL (8 - DAYOFWEEK(@test_date) + 7 * (@test_n - 1)) DAY) AS calculated_date,
    DAYOFWEEK(DATE_ADD(@test_date, INTERVAL (8 - DAYOFWEEK(@test_date) + 7 * (@test_n - 1)) DAY)) AS day_of_week,
    DAYNAME(DATE_ADD(@test_date, INTERVAL (8 - DAYOFWEEK(@test_date) + 7 * (@test_n - 1)) DAY)) AS day_name;
```

**Expected Result**: Day of week should be 1 (Sunday), day name should be "Sunday"

## Performance Considerations

- **No table access**: Pure calculation functions
- **Index not applicable**: Date calculations don't use indexes
- **CPU intensive**: Minimal computational overhead
- **Caching**: Results can be cached for repeated calculations

## Best Practices

1. **Create UDFs**: For reusable date calculations
2. **Handle edge cases**: Start date is Sunday, month boundaries
3. **Validate results**: Always verify calculated dates are correct
4. **Document logic**: Complex date math needs clear comments
5. **Test thoroughly**: Different start dates and n values

## Alternative Approaches

### Simple Loop Method (Procedural)
```sql
-- For understanding the logic step by step
SET @current_date = '2024-01-01';
SET @target_n = 3;
SET @sunday_count = 0;
SET @found_date = NULL;

WHILE @sunday_count < @target_n DO
    IF DAYOFWEEK(@current_date) = 1 THEN
        SET @sunday_count = @sunday_count + 1;
        IF @sunday_count = @target_n THEN
            SET @found_date = @current_date;
        END IF;
    END IF;
    SET @current_date = DATE_ADD(@current_date, INTERVAL 1 DAY);
END WHILE;

SELECT @found_date AS nth_sunday;
```

### Calendar Table Approach
```sql
-- Using a calendar table for complex date calculations
WITH calendar AS (
    SELECT 
        DATE_ADD('2024-01-01', INTERVAL n DAY) AS calendar_date,
        DAYOFWEEK(DATE_ADD('2024-01-01', INTERVAL n DAY)) AS day_of_week
    FROM (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    ) numbers
)
SELECT calendar_date
FROM (
    SELECT 
        calendar_date,
        ROW_NUMBER() OVER (ORDER BY calendar_date) AS sunday_number
    FROM calendar
    WHERE day_of_week = 1
) numbered_sundays
WHERE sunday_number = 3;
```

**How it works**: Uses a calendar table approach for more complex date range analysis.
