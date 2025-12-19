-- Active: 1671859768936@@127.0.0.1@3306@exercise
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

INSERT INTO Movies(Code,Title,Rating) VALUES
(1,'Citizen Kane','PG'),
(2,'Singin'' in the Rain','G'),
(3,'The Wizard of Oz','G'),
(4,'The Quiet Man',NULL),
(5,'North by Northwest',NULL),
(6,'The Last Tango in Paris','NC-17'),
(7,'Some Like it Hot','PG-13'),
(8,'A Night at the Opera',NULL);
 
 INSERT INTO MovieTheaters(Code,Name,Movie) VALUES(1,'Odeon',5);
(2,'Imperial',1),
(3,'Majestic',NULL),
(4,'Royale',6),
(5,'Paraiso',3),
(6,'Nickelodeon',NULL);

-- 4.1
-- Select the title of all movies.
select title from movies;
 
-- 4.2
-- Show all the distinct ratings in the database.
select distinct rating from movies;

-- 4.3 
-- Show all unrated movies.
select * 
from movies
where rating is NULL;

-- 4.4
-- Select all movie theaters that are not currently showing a movie.
select * from MovieTheaters
where Movie is NULL;

-- 4.5
-- Select all data from all movie theaters 
-- and, additionally, the data from the movie that is being shown in the theater (if one is being shown).

-- This query below would fail as it will only return the theaters with movies shown.
-- we need to use left outer join instead.
-- This is a great example to demonstrate why we need to use left join rather than inner join sometimes.
select * 
from MovieTheaters join Movies 
on MovieTheaters.movie = Movies.code;

-- correct query
SELECT *
   FROM MovieTheaters LEFT JOIN Movies
   ON MovieTheaters.Movie = Movies.Code;


-- 4.6
-- Select all data from all movies and, if that movie is being shown in a theater, show the data from the theater.

-- the query below would fail
select *
from movies right join movietheaters 
on movies.code = movietheaters.movie;

-- Correct solution
 SELECT *
   FROM MovieTheaters RIGHT JOIN Movies
   ON MovieTheaters.Movie = Movies.Code;
 -- or 
 SELECT *
   FROM Movies LEFT JOIN MovieTheaters
   ON Movies.Code = MovieTheaters.Movie;

-- 4.7
-- Show the titles of movies not currently being shown in any theaters.
-- VERY IMPORTANT!!!

-- the query below would FAIL due to the NULL value returned by the subquery
select title 
from movies
where code not in ( 
select movie from movietheaters
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
 

 -- 4.8
-- Add the unrated movie "One, Two, Three".

INSERT INTO Movies(Title,Rating) VALUES('One, Two, Three',NULL);


-- 4.9
-- Set the rating of all unrated movies to "G".
UPDATE Movies
SET Rating = 'G'
WHERE Rating is NULL;

-- 4.10
-- Remove movie theaters projecting movies rated "NC-17".
delete from MovieTheaters 
where Movie in (
select Code from Movies where Rating = 'NC-17'
);
