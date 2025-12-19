# 🎯 SQL Practice 6: Advanced JOIN Operations and NULL Handling

## Question
Complete the following SQL exercises using the Movies and MovieTheaters tables to practice JOIN operations, NULL value handling, subqueries, and data manipulation.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE Movies (
  Code INTEGER PRIMARY KEY,
  Title VARCHAR(255) NOT NULL,
  Rating VARCHAR(255)
);

CREATE TABLE MovieTheaters (
  Code INTEGER PRIMARY KEY,
  Name VARCHAR(255) NOT NULL,
  Movie INTEGER,
  FOREIGN KEY (Movie) REFERENCES Movies(Code)
) ENGINE=INNODB;

INSERT INTO Movies(Code, Title, Rating) VALUES
(1, 'Citizen Kane', 'PG'),
(2, 'Singin'' in the Rain', 'G'),
(3, 'The Wizard of Oz', 'G'),
(4, 'The Quiet Man', NULL),
(5, 'North by Northwest', NULL),
(6, 'The Last Tango in Paris', 'NC-17'),
(7, 'Some Like it Hot', 'PG-13'),
(8, 'A Night at the Opera', NULL);

INSERT INTO MovieTheaters(Code, Name, Movie) VALUES
(1, 'Odeon', 5),
(2, 'Imperial', 1),
(3, 'Majestic', NULL),
(4, 'Royale', 6),
(5, 'Paraiso', 3),
(6, 'Nickelodeon', NULL);
```

## Query 4.1: Select the title of all movies

```sql
SELECT Title FROM Movies;
```

**Expected Output**: All movie titles (Citizen Kane, Singin' in the Rain, etc.)

## Query 4.2: Show all the distinct ratings in the database

```sql
SELECT DISTINCT Rating FROM Movies;
```

**Expected Output**: Unique ratings (PG, G, NC-17, PG-13, NULL)

## Query 4.3: Show all unrated movies

```sql
SELECT *
FROM Movies
WHERE Rating IS NULL;
```

**Expected Output**: Movies with NULL rating (The Quiet Man, North by Northwest, A Night at the Opera)

## Query 4.4: Select all movie theaters that are not currently showing a movie

```sql
SELECT * FROM MovieTheaters
WHERE Movie IS NULL;
```

**Expected Output**: Theaters with NULL movie (Majestic, Nickelodeon)

## Query 4.5: Select all data from all movie theaters and, additionally, the data from the movie that is being shown in the theater (if one is being shown)

```sql
-- This query below would fail as it will only return the theaters with movies shown.
-- We need to use LEFT OUTER JOIN instead.
-- This is a great example to demonstrate why we need to use LEFT JOIN rather than INNER JOIN sometimes.
SELECT *
FROM MovieTheaters JOIN Movies
ON MovieTheaters.Movie = Movies.Code;

-- Correct query
SELECT *
FROM MovieTheaters LEFT JOIN Movies
ON MovieTheaters.Movie = Movies.Code;
```

**Expected Output**: All theaters with movie data where available (NULL for theaters not showing movies)

## Query 4.6: Select all data from all movies and, if that movie is being shown in a theater, show the data from the theater

```sql
-- The query below would fail
SELECT *
FROM Movies RIGHT JOIN MovieTheaters
ON Movies.Code = MovieTheaters.Movie;

-- Correct solution
SELECT *
FROM MovieTheaters RIGHT JOIN Movies
ON MovieTheaters.Movie = Movies.Code;

-- OR
SELECT *
FROM Movies LEFT JOIN MovieTheaters
ON Movies.Code = MovieTheaters.Movie;
```

**Expected Output**: All movies with theater data where available (NULL for movies not being shown)

## Query 4.7: Show the titles of movies not currently being shown in any theaters

```sql
-- VERY IMPORTANT!!!

-- The query below would FAIL due to the NULL value returned by the subquery
SELECT Title
FROM Movies
WHERE Code NOT IN (
  SELECT Movie FROM MovieTheaters
);

/* With JOIN */
SELECT Movies.Title
FROM MovieTheaters RIGHT JOIN Movies
ON MovieTheaters.Movie = Movies.Code
WHERE MovieTheaters.Movie IS NULL;

/* With subquery */
SELECT Title FROM Movies
WHERE Code NOT IN
(
  SELECT Movie FROM MovieTheaters
  WHERE Movie IS NOT NULL
);
```

**Expected Output**: Movies not being shown (Citizen Kane, Singin' in the Rain, The Quiet Man, Some Like it Hot, A Night at the Opera)

## Query 4.8: Add the unrated movie "One, Two, Three"

```sql
INSERT INTO Movies(Title, Rating) VALUES('One, Two, Three', NULL);
```

**Result**: New movie added with NULL rating

## Query 4.9: Set the rating of all unrated movies to "G"

```sql
UPDATE Movies
SET Rating = 'G'
WHERE Rating IS NULL;
```

**Result**: All movies with NULL rating updated to 'G'

## Query 4.10: Remove movie theaters projecting movies rated "NC-17"

```sql
DELETE FROM MovieTheaters
WHERE Movie IN (
  SELECT Code FROM Movies WHERE Rating = 'NC-17'
);
```

**Result**: Theaters showing NC-17 movies removed (Royale theater)

- **INNER JOIN**: Only matching rows
- **LEFT JOIN**: All left table rows + matches
- **RIGHT JOIN**: All right table rows + matches

### NULL Handling
- **IS NULL**: Checking for NULL values
- **NOT IN with NULL**: Potential pitfalls with NULL in subqueries
- **LEFT JOIN for missing data**: Preserving all records

### Subquery Challenges
- **NULL in NOT IN**: How NULL affects set operations
- **Correlated vs non-correlated**: Different subquery types
- **Subquery in WHERE**: Filtering with nested queries

### Data Manipulation
- **INSERT**: Adding new records
- **UPDATE**: Modifying existing data
- **DELETE with subquery**: Removing based on related data

## Critical Learning Points

### 1. JOIN Type Selection
```sql
-- INNER JOIN: Only shows theaters WITH movies
SELECT * FROM MovieTheaters JOIN Movies ON MovieTheaters.Movie = Movies.Code;

-- LEFT JOIN: Shows ALL theaters, with movie data where available
SELECT * FROM MovieTheaters LEFT JOIN Movies ON MovieTheaters.Movie = Movies.Code;
```

### 2. NULL in Subqueries (Critical!)
```sql
-- This FAILS because subquery returns NULL
SELECT Title FROM Movies 
WHERE Code NOT IN (SELECT Movie FROM MovieTheaters);

-- This WORKS by excluding NULL from subquery
SELECT Title FROM Movies 
WHERE Code NOT IN (SELECT Movie FROM MovieTheaters WHERE Movie IS NOT NULL);
```

### 3. RIGHT JOIN vs LEFT JOIN
```sql
-- These are equivalent:
SELECT * FROM A RIGHT JOIN B ON A.id = B.id;
SELECT * FROM B LEFT JOIN A ON B.id = A.id;
```


- **JOIN Selection**: Always explain why you chose a particular JOIN type
- **NULL Awareness**: Be careful with NULL values in subqueries and JOINs
- **Performance**: Understand when different approaches are more efficient
- **Business Logic**: Ensure queries match real-world requirements
- **Edge Cases**: Test with NULL values and empty result sets


These patterns are essential for:
- **Content management**: Movies/shows and their venues
- **E-commerce**: Products and their categories/locations
- **HR systems**: Employees and their departments/locations
- **Inventory**: Items and their storage locations
- **Any one-to-many relationship** with optional associations


- **Index foreign keys**: Movie column in MovieTheaters should be indexed
- **LEFT vs INNER JOIN**: LEFT JOIN can be more expensive
- **Subquery optimization**: NOT IN can be slow with large datasets
- **JOIN order**: Optimizer may rearrange, but understanding helps

