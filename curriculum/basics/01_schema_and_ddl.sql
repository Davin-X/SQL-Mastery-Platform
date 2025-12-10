-- 01_schema_and_ddl.sql
-- Topic: DDL — create/alter/drop tables, constraints, simple schema design
-- Goal: Learn how to create a schema and tables, add constraints, and change structure safely.

-- Sample: create a small HR schema and tables
CREATE DATABASE IF NOT EXISTS sample_hr;

USE sample_hr;

DROP TABLE IF EXISTS employee;

CREATE TABLE employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE,
    department VARCHAR(50)
);

DROP TABLE IF EXISTS department;

CREATE TABLE department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) UNIQUE NOT NULL
);

-- Add a foreign key example
ALTER TABLE employee ADD COLUMN dept_id INT;

ALTER TABLE employee
ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES department (dept_id);

-- Exercises:
-- 1) Add a NOT NULL constraint on hire_date (answer: ALTER TABLE ... MODIFY ... NOT NULL)
-- 2) Create an index on department for faster lookups (answer: CREATE INDEX idx_emp_dept ON employee(department))
-- 3) Drop the fk constraint and then remove the column

-- Hints: Use ALTER TABLE to change structure; back up data before destructive changes.