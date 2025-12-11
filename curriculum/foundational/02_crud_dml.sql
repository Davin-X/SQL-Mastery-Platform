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
        gender,
        hire_date,
        salary,
        dept_id
    )
VALUES (
        'Alice',
        'Kumar',
        'Female',
        '2020-01-15',
        55000.00,
        1
    ),
    (
        'Bob',
        'Sharma',
        'Male',
        '2019-11-21',
        75000.00,
        3
    ),
    (
        'Carol',
        'Das',
        'Female',
        '2021-06-01',
        65000.00,
        2
    );

-- Basic SELECT
SELECT emp_id, first_name, last_name, salary, dept_id FROM employee;

-- UPDATE examples
-- Give all Sales department employees a 10% salary increase
UPDATE employee SET salary = salary * 1.10 WHERE dept_id = 2;

-- UPDATE with JOIN example
-- UPDATE employee e JOIN department d ON e.dept_id = d.dept_id
-- SET e.salary = e.salary * 1.10 WHERE d.dept_name = 'Sales';

-- DELETE example (safe deletion pattern)
DELETE FROM employee WHERE emp_id = 999;
-- use a transaction when deleting many rows

-- Exercises:
-- 1) Insert 3 new employees (use INSERT INTO ... VALUES)
-- 2) Update all employees in Engineering department to have 5% salary increase
-- 3) Delete employees hired before 2019-01-01 (wrap in transaction to test)