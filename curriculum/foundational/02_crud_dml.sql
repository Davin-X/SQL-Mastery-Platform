-- 02_crud_dml.sql
-- Topic: DML / CRUD — INSERT, SELECT, UPDATE, DELETE
-- Goal: Practice common data manipulation tasks and safe updates.

USE sample_hr;

-- Sample dataset (employee table created in previous file)
INSERT INTO
    department (dept_name)
VALUES ('HR'),
    ('Sales'),
    ('Engineering');

INSERT INTO
    employee (
        first_name,
        last_name,
        hire_date,
        department,
        dept_id
    )
VALUES (
        'Alice',
        'Kumar',
        '2020-01-15',
        'HR',
        1
    ),
    (
        'Bob',
        'Sharma',
        '2019-11-21',
        'Engineering',
        3
    ),
    (
        'Carol',
        'Das',
        '2021-06-01',
        'Sales',
        2
    );

-- Basic SELECT
SELECT employee_id, first_name, last_name, department FROM employee;

-- UPDATE examples
-- Give all Sales department employees a 10% salary increase (if salary column exists)
-- UPDATE employee SET salary = salary * 1.10 WHERE department = 'Sales';

-- DELETE example (safe deletion pattern)
-- DELETE FROM employee WHERE employee_id = 999; -- use a transaction when deleting many rows

-- Exercises:
-- 1) Insert 3 new employees (use INSERT INTO ... VALUES)
-- 2) Update all employees in Engineering to department = 'R&D'
-- 3) Delete employees hired before 2019-01-01 (wrap in transaction to test)