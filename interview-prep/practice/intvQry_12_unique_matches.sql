-- Active: 1671859768936@@127.0.0.1@3306@practice
CREATE TABLE teams (
  team_id INT PRIMARY KEY,
  team_name VARCHAR(255) NOT NULL
);

INSERT INTO teams (team_id, team_name)
VALUES
  (1, 'Team A'),
  (2, 'Team B'),
  (3, 'Team C'),
  (4, 'Team D'),
  (5, 'Team E'),
  (6, 'Team F'),
  (7, 'Team G'),
  (8, 'Team H');

SELECT 
  t1.team_name AS home_team,
  t2.team_name AS away_team,
  CONCAT(t1.team_name, ' vs. ', t2.team_name) AS match_name
FROM teams t1
JOIN teams t2
ON t1.team_id < t2.team_id;

-- query to schedule unique matches
SELECT
  t1.team_name AS team1,
  t2.team_name AS team2
FROM
  teams t1
  JOIN teams t2 ON t1.team_id < t2.team_id
WHERE
  t1.team_id = LEAST(t1.team_id, t2.team_id)
  AND t2.team_id = GREATEST(t1.team_id, t2.team_id);