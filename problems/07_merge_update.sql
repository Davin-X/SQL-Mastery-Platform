-- SQL MERGE EXAMPLE

-- Create source table

CREATE TABLE source ( id INT PRIMARY KEY, value VARCHAR(50) );

-- Create target table
CREATE TABLE target ( id INT PRIMARY KEY, value VARCHAR(50) );

-- Insert data into source table
INSERT INTO
    source (id, value)
VALUES (1, 'foo'),
    (2, 'bar'),
    (3, 'baz');

-- Insert some data into target table
INSERT INTO
    target (id, value)
VALUES (1, 'initial value'),
    (4, 'extra value');

-- Merge data from source table into target table (MySQL UPSERT example)
INSERT INTO
    target (id, value)
SELECT id, value
FROM source
ON DUPLICATE KEY UPDATE
    value = VALUES(value);

select * from target;