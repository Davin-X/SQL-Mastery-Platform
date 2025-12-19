-- Active: 1671859768936@@127.0.0.1@3306@practice

---- SQL MERGE EXAMPLE

'''
-- Create source table

CREATE TABLE source (
  id INT PRIMARY KEY,
  value VARCHAR(50)
);

-- Create target table
CREATE TABLE target (
  id INT PRIMARY KEY,
  value VARCHAR(50)
);

-- Insert data into source table
INSERT INTO source (id, value)
VALUES (1, 'foo'), (2, 'bar'), (3, 'baz');

-- Insert some data into target table
INSERT INTO target (id, value)
VALUES (1, 'initial value'), (4, 'extra value');

-- View the source and target tables
SELECT * FROM source;
SELECT * FROM target;

-- Merge data from source table into target table
MERGE INTO target
USING source
ON (target.id = source.id)
WHEN MATCHED THEN
  UPDATE SET target.value = source.value
WHEN NOT MATCHED THEN
  INSERT (id, value) VALUES (source.id, source.value);

-- View the updated target table
SELECT * FROM target;


''';


CREATE TABLE source_table (
  id INT PRIMARY KEY,
  value VARCHAR(50)
);

CREATE TABLE target_table (
  id INT PRIMARY KEY,
  value VARCHAR(50)
);

INSERT INTO source_table VALUES (1, 'value_1'), (2, 'value_2'), (3, 'value_3');

INSERT INTO target_table VALUES (1, 'value_1'), (2, 'old_value'), (4, 'value_4');

INSERT INTO target_table (id, value)
SELECT id, value
FROM source_table
ON DUPLICATE KEY UPDATE value = VALUES(value);


select * from target_table;