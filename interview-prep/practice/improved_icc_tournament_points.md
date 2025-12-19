# 🎯 ICC Tournament Points Table Analysis

## Question
Given ICC World Cup match results, derive a comprehensive points table showing team standings, win/loss records, net run rate, and rankings for tournament qualification.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE icc_world_cup (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    team_1 VARCHAR(50),
    team_2 VARCHAR(50),
    winner VARCHAR(50),
    margin VARCHAR(20),
    venue VARCHAR(50),
    match_date DATE
);

INSERT INTO icc_world_cup (team_1, team_2, winner, margin, venue, match_date) VALUES
('India', 'Australia', 'India', '5 wickets', 'Melbourne', '2023-10-15'),
('England', 'Pakistan', 'England', '8 wickets', 'London', '2023-10-16'),
('South Africa', 'New Zealand', 'South Africa', '7 runs', 'Johannesburg', '2023-10-17'),
('Australia', 'England', 'Australia', '3 wickets', 'Perth', '2023-10-18'),
('India', 'Pakistan', 'India', '6 wickets', 'Ahmedabad', '2023-10-19'),
('New Zealand', 'England', 'New Zealand', '5 runs', 'Auckland', '2023-10-20'),
('South Africa', 'Australia', 'South Africa', '120 runs', 'Cape Town', '2023-10-21'),
('India', 'New Zealand', 'India', '4 wickets', 'Mumbai', '2023-10-22'),
('Pakistan', 'South Africa', 'Pakistan', '3 wickets', 'Lahore', '2023-10-23'),
('England', 'India', 'India', '7 runs', 'Birmingham', '2023-10-24');
```

## Answer: Comprehensive Points Table

```sql
WITH match_results AS (
    SELECT 
        match_id,
        team_1,
        team_2,
        winner,
        CASE WHEN winner = team_1 THEN team_2 ELSE team_1 END AS loser,
        margin,
        venue,
        match_date
    FROM icc_world_cup
),
team_stats AS (
    SELECT 
        team,
        COUNT(*) AS matches_played,
        SUM(CASE WHEN is_winner = 1 THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN is_winner = 0 THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN is_winner = 1 THEN 2 ELSE 0 END) AS points
    FROM (
        SELECT team_1 AS team, CASE WHEN winner = team_1 THEN 1 ELSE 0 END AS is_winner FROM match_results
        UNION ALL
        SELECT team_2 AS team, CASE WHEN winner = team_2 THEN 1 ELSE 0 END AS is_winner FROM match_results
    ) team_results
    GROUP BY team
)
SELECT 
    team,
    matches_played,
    wins,
    losses,
    points,
    ROUND(wins * 100.0 / matches_played, 1) AS win_percentage,
    DENSE_RANK() OVER (ORDER BY points DESC, win_percentage DESC) AS position
FROM team_stats
ORDER BY position;
```

**How it works**: 
- CTE breaks down match results into winners/losers
- Aggregates team statistics across all matches
- Calculates win percentage and rankings
- Uses DENSE_RANK for proper tie-breaking

## Alternative: Detailed Match Statistics

```sql
SELECT 
    team,
    matches_played,
    wins,
    losses,
    ties,
    points,
    win_percentage,
    ROUND(runs_scored / matches_played, 1) AS avg_runs_scored,
    ROUND(runs_conceded / matches_played, 1) AS avg_runs_conceded,
    ROUND((runs_scored - runs_conceded) / matches_played, 3) AS net_run_rate,
    ROW_NUMBER() OVER (ORDER BY points DESC, net_run_rate DESC) AS world_ranking
FROM (
    SELECT 
        team,
        COUNT(*) AS matches_played,
        SUM(wins) AS wins,
        SUM(losses) AS losses,
        SUM(ties) AS ties,
        SUM(points) AS points,
        ROUND(SUM(wins) * 100.0 / COUNT(*), 1) AS win_percentage,
        SUM(runs_scored) AS runs_scored,
        SUM(runs_conceded) AS runs_conceded
    FROM (
        -- Team batting statistics
        SELECT 
            team_batting AS team,
            1 AS matches_played,
            CASE WHEN winner = team_batting THEN 1 ELSE 0 END AS wins,
            CASE WHEN winner = team_bowling THEN 1 ELSE 0 END AS losses,
            0 AS ties,
            CASE WHEN winner = team_batting THEN 2 ELSE 0 END AS points,
            runs_batting AS runs_scored,
            runs_bowling AS runs_conceded
        FROM match_detailed_stats
        
        UNION ALL
        
        -- Team bowling statistics  
        SELECT 
            team_bowling AS team,
            1 AS matches_played,
            CASE WHEN winner = team_bowling THEN 1 ELSE 0 END AS wins,
            CASE WHEN winner = team_batting THEN 1 ELSE 0 END AS losses,
            0 AS ties,
            CASE WHEN winner = team_bowling THEN 2 ELSE 0 END AS points,
            runs_bowling AS runs_scored,
            runs_batting AS runs_conceded
        FROM match_detailed_stats
    ) combined_stats
    GROUP BY team
) final_stats
ORDER BY world_ranking;
```

**How it works**: Includes detailed statistics like net run rate, batting/bowling stats, and proper world ranking calculations.

## Performance Optimization

```sql
-- Create indexes for better performance
CREATE INDEX idx_icc_matches ON icc_world_cup(match_date, team_1, team_2);
CREATE INDEX idx_icc_winner ON icc_world_cup(winner);

-- Materialized view for points table (if supported)
CREATE MATERIALIZED VIEW points_table AS
SELECT * FROM [above complex query];
```

## Interview Tips

- **Business context**: Points tables are critical for tournament management
- **Data integrity**: Ensure all matches have proper winners recorded
- **Performance**: Complex aggregations need proper indexing
- **Tie-breaking**: Understand ranking rules (points, then NRR, etc.)
- **Scalability**: Design for large tournaments with many teams

## Real-World Applications

- **Sports analytics**: Tournament standings and qualification
- **League management**: Points tables for soccer, cricket, etc.
- **Business KPIs**: Performance dashboards and rankings
- **Gaming**: Leaderboards and competitive rankings
- **Education**: Grade calculations and rankings

## Tournament Rules

- **Win**: 2 points
- **Tie/No result**: 1 point each (simplified)
- **Loss**: 0 points
- **Qualification**: Top teams advance based on points, then tie-breakers

## Key SQL Concepts

- **UNION ALL**: Combining batting and bowling statistics
- **Window functions**: ROW_NUMBER for rankings
- **Complex aggregations**: Multiple levels of grouping
- **Case statements**: Conditional logic for points calculation
- **CTE usage**: Breaking down complex business logic
