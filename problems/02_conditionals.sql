--Get department wise male, female and total employees in each department
--- tbEmployeeMaster (EmployeeId     , EmployeeName  ,gender   ,    Department)
-- output = department , female  , male , total_employees

CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);

-- Insert departments first
INSERT INTO
    department (dept_name)
VALUES ('Administration'),
    ('Sales'),
    ('HR'),
    ('Finance');

INSERT INTO
    employee (
        first_name,
        last_name,
        gender,
        dept_id
    )
VALUES ('Arjun', 'Sharma', 'Male', 1),
    ('Rohan', 'Verma', 'Male', 2),
    ('Ishita', 'Singh', NULL, 3),
    ('Aadi', 'Kumar', 'Male', 2),
    ('Preetam', 'Gupta', 'Male', 3),
    ('Anjan', 'Patel', 'Male', 1),
    ('Rajesh', 'Yadav', NULL, 3),
    ('Ankur', 'Jain', 'Male', 3),
    (
        'Robin',
        'Malhotra',
        'Male',
        NULL
    ),
    (
        'Mayank',
        'Agarwal',
        'Male',
        2
    ),
    (
        'Manisha',
        'Chopra',
        'Female',
        3
    ),
    (
        'Sonam',
        'Bhatia',
        'Female',
        3
    ),
    ('Rajan', 'Shah', 'Male', 3),
    ('Kapil', 'Mehta', NULL, 2),
    ('Ritika', 'Nair', 'Female', 3),
    ('Akshay', 'Reddy', 'Male', 4),
    ('Aryan', 'Kapoor', 'Male', 3),
    ('Anju', 'Pillai', 'Female', 4),
    ('Sapna', 'Joshi', 'Female', 4),
    (
        'Ruhi',
        'Desai',
        'Female',
        NULL
    ),
    ('Robin', 'Iyer', 'Male', 2),
    ('Neelam', 'Rao', 'Female', 3),
    ('Rajni', 'Khan', 'Female', 1),
    (
        'Sonakshi',
        'Sinha',
        'Female',
        4
    );

--Check data in table
SELECT e.emp_id, e.first_name, e.last_name, e.gender, d.dept_name
FROM employee e
    LEFT JOIN department d ON e.dept_id = d.dept_id;

--Get department wise male, female and total employees in each department
SELECT
    COALESCE(d.dept_name, 'Not Assigned') AS Department,
    TB.Male,
    TB.Female,
    (TB.Male + TB.Female) AS Total_Employees
FROM (
        SELECT dept_id, COUNT(
                CASE
                    WHEN UPPER(gender) = 'MALE' THEN 1
                END
            ) AS Male, COUNT(
                CASE
                    WHEN UPPER(gender) = 'FEMALE' THEN 1
                END
            ) AS Female
        FROM employee
        GROUP BY
            dept_id
    ) AS TB
    LEFT JOIN department d ON TB.dept_id = d.dept_id
ORDER BY
    CASE
        WHEN d.dept_name IS NULL THEN 1
        ELSE 0
    END;