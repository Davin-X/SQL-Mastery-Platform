-- 03_select_joins.sql
-- Topic: Joins and set operations
-- Goal: Learn INNER, LEFT, RIGHT, FULL joins and set operators (UNION, EXCEPT/NOT IN patterns)

USE sample_hr;

-- INNER JOIN: match rows in both tables
SELECT e.emp_id, e.first_name, e.last_name, d.dept_name, e.salary
FROM employee e
    JOIN department d ON e.dept_id = d.dept_id;

-- LEFT JOIN: all rows from left table
SELECT e.emp_id, e.first_name, e.last_name, d.dept_name, e.salary
FROM employee e
    LEFT JOIN department d ON e.dept_id = d.dept_id;

-- Anti-join pattern: find employees without departments
SELECT e.*
FROM employee e
    LEFT JOIN department d ON e.dept_id = d.dept_id
WHERE
    d.dept_id IS NULL;

-- Exercises:
-- 1) Show department counts including departments with zero employees.
-- 2) Use UNION to combine two SELECTs and remove duplicates.