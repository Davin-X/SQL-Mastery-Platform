# 🎯 Building Floor Visit Pattern Analysis

## Question
Given building entry logs, analyze visitor patterns including total visits per person, most visited floor, and visit frequency analysis.

## SQL Setup (Tables and Sample Data)

```sql
CREATE DATABASE IF NOT EXISTS complex_queries;
USE complex_queries;

CREATE TABLE entries (
    name VARCHAR(20),
    address VARCHAR(20),
    email VARCHAR(20),
    floor INTEGER,
    resources VARCHAR(50)
);

INSERT INTO entries VALUES
('Alice', '123 Main St', 'alice@email.com', 5, 'Meeting Room'),
('Bob', '456 Oak Ave', 'bob@email.com', 3, 'Conference Room'),
('Alice', '123 Main St', 'alice@email.com', 5, 'Restroom'),
('Charlie', '789 Pine St', 'charlie@email.com', 7, 'Cafeteria'),
('Bob', '456 Oak Ave', 'bob@email.com', 3, 'Printer'),
('Alice', '123 Main St', 'alice@email.com', 8, 'Office'),
('Diana', '321 Elm St', 'diana@email.com', 2, 'Reception'),
('Alice', '123 Main St', 'alice@email.com', 5, 'Meeting Room'),
('Bob', '456 Oak Ave', 'bob@email.com', 4, 'Training Room'),
('Charlie', '789 Pine St', 'charlie@email.com', 7, 'Restroom');
```

## Answer: Comprehensive Visit Pattern Analysis

```sql
WITH person_visit_summary AS (
    SELECT 
        name,
        COUNT(*) AS total_visits,
        COUNT(DISTINCT floor) AS floors_visited,
        GROUP_CONCAT(DISTINCT floor ORDER BY floor) AS floors_list,
        GROUP_CONCAT(resources ORDER BY floor) AS resources_used
    FROM entries
    GROUP BY name
),
floor_popularity AS (
    SELECT 
        floor,
        COUNT(*) AS visit_count,
        COUNT(DISTINCT name) AS unique_visitors,
        GROUP_CONCAT(DISTINCT name) AS visitors_list
    FROM entries
    GROUP BY floor
),
most_visited_floor AS (
    SELECT 
        name,
        floor,
        COUNT(*) AS visits_to_floor,
        ROW_NUMBER() OVER (PARTITION BY name ORDER BY COUNT(*) DESC) AS rn
    FROM entries
    GROUP BY name, floor
)
SELECT 
    pvs.name,
    pvs.total_visits,
    pvs.floors_visited,
    pvs.floors_list,
    mvf.floor AS most_visited_floor,
    mvf.visits_to_floor AS visits_to_most_floor,
    fp.visit_count AS total_visits_to_most_floor,
    fp.unique_visitors AS unique_visitors_to_most_floor,
    
    CASE 
        WHEN pvs.total_visits >= 5 THEN 'Frequent Visitor'
        WHEN pvs.total_visits >= 3 THEN 'Regular Visitor'
        ELSE 'Occasional Visitor'
    END AS visitor_category
    
FROM person_visit_summary pvs
JOIN most_visited_floor mvf ON pvs.name = mvf.name AND mvf.rn = 1
LEFT JOIN floor_popularity fp ON mvf.floor = fp.floor
ORDER BY pvs.total_visits DESC, pvs.name;
```

**How it works**: 
- Analyzes individual visitor patterns
- Identifies most visited floor per person
- Provides comprehensive visit analytics

## Alternative: Floor-by-Floor Visit Analysis

```sql
WITH floor_visit_details AS (
    SELECT 
        floor,
        COUNT(*) AS total_visits,
        COUNT(DISTINCT name) AS unique_visitors,
        GROUP_CONCAT(DISTINCT name ORDER BY name) AS visitor_names,
        GROUP_CONCAT(DISTINCT resources ORDER BY resources) AS resources_list,
        AVG(floor) AS avg_floor_number  -- Not meaningful but demonstrates aggregation
    FROM entries
    GROUP BY floor
),
peak_floor_analysis AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_visits DESC) AS popularity_rank,
        total_visits * 1.0 / (SELECT SUM(total_visits) FROM floor_visit_details) * 100 AS visit_percentage
    FROM floor_visit_details
)
SELECT 
    floor,
    total_visits,
    unique_visitors,
    ROUND(total_visits * 1.0 / unique_visitors, 2) AS avg_visits_per_person,
    visit_percentage,
    popularity_rank,
    visitor_names,
    resources_list,
    
    CASE 
        WHEN popularity_rank = 1 THEN 'Most Popular Floor'
        WHEN popularity_rank <= 3 THEN 'Popular Floor'
        ELSE 'Less Popular Floor'
    END AS popularity_category
    
FROM peak_floor_analysis
ORDER BY popularity_rank;
```

**How it works**: 
- Analyzes floor popularity and usage patterns
- Calculates visit distribution and rankings
- Provides insights into building utilization

## Advanced: Time-Based Visit Pattern Analysis

```sql
-- Assuming we add entry_time column
ALTER TABLE entries ADD COLUMN entry_time DATETIME DEFAULT CURRENT_TIMESTAMP;

WITH hourly_patterns AS (
    SELECT 
        name,
        HOUR(entry_time) AS visit_hour,
        COUNT(*) AS visits_in_hour,
        floor
    FROM entries
    WHERE entry_time IS NOT NULL
    GROUP BY name, HOUR(entry_time), floor
),
peak_hours AS (
    SELECT 
        visit_hour,
        COUNT(*) AS total_visits,
        COUNT(DISTINCT name) AS unique_visitors,
        AVG(floor) AS avg_floor_visited
    FROM hourly_patterns
    GROUP BY visit_hour
)
SELECT 
    visit_hour,
    CONCAT(LPAD(visit_hour, 2, '0'), ':00-', LPAD(visit_hour + 1, 2, '0'), ':00') AS time_range,
    total_visits,
    unique_visitors,
    ROUND(total_visits * 1.0 / unique_visitors, 2) AS avg_visits_per_person,
    ROUND(avg_floor_visited, 1) AS avg_floor_level,
    
    CASE 
        WHEN visit_hour BETWEEN 9 AND 17 THEN 'Business Hours'
        WHEN visit_hour BETWEEN 18 AND 22 THEN 'Evening Hours'
        ELSE 'Off Hours'
    END AS time_category
    
FROM peak_hours
ORDER BY total_visits DESC;
```

**How it works**: 
- Analyzes visit patterns by time of day
- Identifies peak usage hours
- Provides temporal usage insights

## Resource Utilization Analysis

```sql
WITH resource_usage AS (
    SELECT 
        resources,
        COUNT(*) AS usage_count,
        COUNT(DISTINCT name) AS unique_users,
        COUNT(DISTINCT floor) AS floors_where_used,
        GROUP_CONCAT(DISTINCT floor ORDER BY floor) AS floor_distribution
    FROM entries
    GROUP BY resources
),
resource_popularity AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY usage_count DESC) AS popularity_rank,
        ROUND(usage_count * 100.0 / SUM(usage_count) OVER (), 1) AS usage_percentage
    FROM resource_usage
)
SELECT 
    resources,
    usage_count,
    unique_users,
    floors_where_used,
    floor_distribution,
    usage_percentage,
    popularity_rank,
    
    CASE 
        WHEN popularity_rank <= 2 THEN 'High Demand Resource'
        WHEN popularity_rank <= 4 THEN 'Medium Demand Resource'
        ELSE 'Low Demand Resource'
    END AS demand_category
    
FROM resource_popularity
ORDER BY popularity_rank;
```

**How it works**: 
- Analyzes resource utilization patterns
- Identifies most/least used facilities
- Provides resource allocation insights

