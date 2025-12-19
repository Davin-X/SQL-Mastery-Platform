-- Used SQLite3 for this example

-- table PEOPLE: containing unique ID and corresponding names.
CREATE TABLE PEOPLE (id INTEGER, name CHAR);

INSERT INTO PEOPLE VALUES
(1, "A"),
(2, "B"),
(3, "C"),
(4, "D");

-- ADDRESS: containing the history of address information of each ID.
CREATE TABLE ADDRESS (id INTEGER, address VARCHAR(20), updatedate date);

INSERT INTO ADDRESS VALUES
(1, "address-1-1", "2016-01-01"),
(1, "address-1-2", "2016-09-02"),
(2, "address-2-1", "2015-11-01"),
(3, "address-3-1", "2016-12-01"),
(3, "address-3-2", "2014-09-11"),
(3, "address-3-3", "2015-01-01"),
(4, "address-4-1", "2010-05-21"),
(4, "address-4-2", "2012-02-11"),
(4, "address-4-3", "2015-04-27"),
(4, "address-4-4", "2014-01-01");


-- Used SQLite3 for this example

-- 10.1 Join table PEOPLE and ADDRESS, but keep only one address information for each person (we don't mind which record we take for each person). 
-- i.e., the joined table should have the same number of rows as table PEOPLE

SELECT
PEOPLE.id, PEOPLE.name, TEMP.address
FROM
PEOPLE
LEFT JOIN
(
SELECT id, MAX(address) as address 
FROM ADDRESS
GROUP BY id
)
AS TEMP
ON PEOPLE.id = TEMP.id; 


-- 10.2 Join table PEOPLE and ADDRESS, but ONLY keep the LATEST address information for each person. 
-- i.e., the joined table should have the same number of rows as table PEOPLE

SELECT
PEOPLE.id, PEOPLE.name, TEMP.address
FROM
PEOPLE
LEFT JOIN
(
SELECT id, address, MAX(updatedate)
FROM ADDRESS
GROUP BY id
)
AS TEMP
ON PEOPLE.id = TEMP.id; 

