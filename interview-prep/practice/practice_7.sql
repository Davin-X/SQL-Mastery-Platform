-- Active: 1671859768936@@127.0.0.1@3306@exercise
CREATE TABLE Pieces (
 Code INTEGER PRIMARY KEY NOT NULL,
 Name TEXT NOT NULL
 );
CREATE TABLE Providers (
 Code VARCHAR(40) 
 PRIMARY KEY NOT NULL,  
 Name TEXT NOT NULL 
 );
CREATE TABLE Provides (
 Piece INTEGER, 
 FOREIGN KEY (Piece) REFERENCES Pieces(Code),
 Provider VARCHAR(40), 
 FOREIGN KEY (Provider) REFERENCES Providers(Code),  
 Price INTEGER NOT NULL,
 PRIMARY KEY(Piece, Provider) 
 );
 
-- alternative one for SQLite
  /* 
 CREATE TABLE Provides (
 Piece INTEGER,
 Provider VARCHAR(40),  
 Price INTEGER NOT NULL,
 PRIMARY KEY(Piece, Provider) 
 );
 */
 
 
INSERT INTO Providers(Code, Name) VALUES
('HAL','Clarke Enterprises'),
('RBT','Susan Calvin Corp.'),
('TNBC','Skellington Supplies');

INSERT INTO Pieces(Code, Name) VALUES
(1,'Sprocket'),
(2,'Screw'),
(3,'Nut'),
(4,'Bolt');

INSERT INTO Provides(Piece, Provider, Price) VALUES
(1,'HAL',10),
(1,'RBT',15),
(2,'HAL',20),
(2,'RBT',15),
(2,'TNBC',14),
(3,'RBT',50),
(3,'TNBC',45),
(4,'HAL',5),
(4,'RBT',7);

show tables;

select * from Pieces;
select * from Providers;
select * from provides; 


-- 5.1
-- Select the name of all the pieces. 
select Name from Pieces;

-- 5.2 
-- Select all the providers' data. 
select * from providers;
 
-- 5.3
-- Obtain the average price of each piece (show only the piece code and the average price).
select piece, avg(price) 
from Provides 
group by piece;

-- 5.4 
-- Obtain the names of all providers who supply piece 1.
select Name 
from Providers
where Code in (
select  Provider from provides where Piece = 1
); 

select Providers.Name 
from Providers join Provides
on Providers.Code = Provides.Provider
where Provides.Piece = 1;

/* Without subquery */
 SELECT Providers.Name
   FROM Providers INNER JOIN Provides
          ON Providers.Code = Provides.Provider
             AND Provides.Piece = 1;
             
/* With subquery */
 SELECT Name
   FROM Providers
  WHERE Code IN
   (SELECT Provider FROM Provides WHERE Piece = 1);



-- 5.5
-- Select the name of pieces provided by provider with code "HAL".
select Name from Pieces
where Code in (
select Piece from Provides where Provider = 'HAL'
);

select Pieces.Name
from Pieces join Provides
on (Pieces.code = Provides.Piece)
where Provides.Provider = 'HAL';

/* With EXISTS subquery */   
-- Interesting clause
SELECT Name
  FROM Pieces
  WHERE EXISTS
  (
    SELECT * FROM Provides
      WHERE Provider = 'HAL'
        AND Piece = Pieces.Code
  );


-- 5.6
-- ---------------------------------------------
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Intereting and important one.
-- For each piece, find the most expensive offering of that piece and include the piece name, provider name, and price 
-- (note that there could be two providers who supply the same piece at the most expensive price).

-- WRONG solution .
select a.name, a.code, b.price, c.Name
from Pieces a join Provides b
on a.Code = b.Piece
join Providers c
on b.provider = c.Code
group by a.code;
-- this is wrong since when I group by a.code, SQL will automatically select the first c.Name in each group to return,
-- which is not what we expected.

-- CORRECT SOLUTION
SELECT Pieces.Name, Providers.Name, Price
  FROM Pieces INNER JOIN Provides ON Pieces.Code = Piece
              INNER JOIN Providers ON Providers.Code = Provider
  WHERE Price =
  (
    SELECT MAX(Price) FROM Provides
    WHERE Piece = Pieces.Code
  );
-- This is worthwhile to look into again
-- --------------------------------------------------------------
 

-- 5.7
-- Add an entry to the database to indicate that "Skellington Supplies" (code "TNBC") will provide sprockets (code "1") for 7 cents each.
INSERT INTO Provides(Piece, Provider, Price) VALUES (1, 'TNBC', 7);

-- 5.8
-- Increase all prices by one cent.
UPDATE Provides
SET Price = Price + 1;

-- 5.9
-- Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply bolts (code 4).
DELETE FROM Provides WHERE provider = 'RBT' AND Piece = 4;


-- 5.10
-- Update the database to reflect that "Susan Calvin Corp." (code "RBT") will not supply any pieces 
-- (the provider should still remain in the database).
DELETE FROM provides
WHERE Provider = 'RBT';
