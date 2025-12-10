-- seed_sample_hr.sql
-- Realistic sample data for HR and business analytics practice
-- This seed file creates a complete sample_hr database with employees, departments, projects, and transactions

DROP DATABASE IF EXISTS sample_hr;

CREATE DATABASE IF NOT EXISTS sample_hr;

USE sample_hr;

-- ============================================================================
-- SCHEMA DEFINITION
-- ============================================================================

-- Department table
CREATE TABLE department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100),
    budget DECIMAL(15, 2)
);

-- Employee table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES department (dept_id),
    FOREIGN KEY (manager_id) REFERENCES employee (emp_id)
);

-- Project table
CREATE TABLE project (
    proj_id INT PRIMARY KEY AUTO_INCREMENT,
    proj_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    budget DECIMAL(15, 2),
    status VARCHAR(20) DEFAULT 'Active'
);

-- Project assignment (M:M between employee and project)
CREATE TABLE assignment (
    assign_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    proj_id INT NOT NULL,
    role VARCHAR(50),
    hours_allocated INT,
    start_date DATE,
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id),
    FOREIGN KEY (proj_id) REFERENCES project (proj_id),
    UNIQUE KEY (emp_id, proj_id)
);

-- Activity log for tracking daily work
CREATE TABLE activity_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    activity_date DATE NOT NULL,
    activity_type VARCHAR(50),
    hours_worked DECIMAL(5, 2),
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- Salary history
CREATE TABLE salary_history (
    hist_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    salary DECIMAL(10, 2),
    effective_date DATE,
    reason VARCHAR(100),
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- ============================================================================
-- DATA INSERTION
-- ============================================================================

-- Insert departments
INSERT INTO
    department (dept_name, location, budget)
VALUES (
        'Administration',
        'New York',
        500000.00
    ),
    (
        'Sales',
        'New York',
        1200000.00
    ),
    (
        'IT',
        'San Francisco',
        2000000.00
    ),
    ('HR', 'Chicago', 300000.00),
    (
        'Finance',
        'New York',
        800000.00
    ),
    (
        'Operations',
        'Dallas',
        900000.00
    );

-- Insert employees with hierarchy
INSERT INTO
    employee (
        first_name,
        last_name,
        gender,
        hire_date,
        salary,
        dept_id,
        manager_id
    )
VALUES (
        'John',
        'Doe',
        'Male',
        '2015-01-15',
        95000.00,
        1,
        NULL
    ),
    (
        'Jane',
        'Smith',
        'Female',
        '2016-03-22',
        85000.00,
        1,
        1
    ),
    (
        'Michael',
        'Johnson',
        'Male',
        '2017-06-10',
        120000.00,
        2,
        NULL
    ),
    (
        'Sarah',
        'Williams',
        'Female',
        '2018-08-05',
        95000.00,
        2,
        3
    ),
    (
        'David',
        'Brown',
        'Male',
        '2018-01-20',
        92000.00,
        2,
        3
    ),
    (
        'Emily',
        'Davis',
        'Female',
        '2019-02-14',
        110000.00,
        3,
        NULL
    ),
    (
        'Robert',
        'Miller',
        'Male',
        '2019-05-30',
        88000.00,
        3,
        6
    ),
    (
        'Jennifer',
        'Wilson',
        'Female',
        '2019-07-15',
        88000.00,
        3,
        6
    ),
    (
        'James',
        'Moore',
        'Male',
        '2020-09-12',
        75000.00,
        4,
        NULL
    ),
    (
        'Mary',
        'Taylor',
        'Female',
        '2020-10-01',
        68000.00,
        4,
        9
    ),
    (
        'William',
        'Anderson',
        'Male',
        '2021-02-08',
        125000.00,
        5,
        NULL
    ),
    (
        'Patricia',
        'Thomas',
        'Female',
        '2021-04-20',
        95000.00,
        5,
        11
    ),
    (
        'Richard',
        'Jackson',
        'Male',
        '2021-06-15',
        85000.00,
        6,
        NULL
    ),
    (
        'Lisa',
        'White',
        'Female',
        '2021-08-01',
        80000.00,
        6,
        13
    ),
    (
        'Charles',
        'Harris',
        'Male',
        '2022-01-10',
        78000.00,
        3,
        6
    ),
    (
        'Karen',
        'Martin',
        'Female',
        '2022-03-20',
        72000.00,
        2,
        3
    );

-- Insert projects
INSERT INTO
    project (
        proj_name,
        start_date,
        end_date,
        budget,
        status
    )
VALUES (
        'Website Redesign',
        '2024-01-01',
        '2024-06-30',
        250000.00,
        'Completed'
    ),
    (
        'Mobile App Dev',
        '2024-02-15',
        NULL,
        400000.00,
        'Active'
    ),
    (
        'Data Migration',
        '2024-03-01',
        '2024-09-30',
        150000.00,
        'Active'
    ),
    (
        'Cloud Infrastructure',
        '2024-04-01',
        NULL,
        300000.00,
        'Active'
    ),
    (
        'CRM Implementation',
        '2024-05-01',
        NULL,
        350000.00,
        'In Progress'
    ),
    (
        'Security Audit',
        '2024-06-01',
        '2024-08-31',
        80000.00,
        'Completed'
    );

-- Insert assignments
INSERT INTO
    assignment (
        emp_id,
        proj_id,
        role,
        hours_allocated,
        start_date
    )
VALUES (
        6,
        1,
        'Lead Developer',
        40,
        '2024-01-01'
    ),
    (
        7,
        1,
        'Junior Developer',
        30,
        '2024-01-15'
    ),
    (
        8,
        1,
        'QA Engineer',
        25,
        '2024-02-01'
    ),
    (
        6,
        2,
        'Lead Developer',
        40,
        '2024-02-15'
    ),
    (
        15,
        2,
        'Junior Developer',
        35,
        '2024-02-20'
    ),
    (
        7,
        3,
        'Database Admin',
        30,
        '2024-03-01'
    ),
    (
        14,
        3,
        'Data Analyst',
        25,
        '2024-03-10'
    ),
    (
        6,
        4,
        'DevOps Engineer',
        35,
        '2024-04-01'
    ),
    (
        3,
        5,
        'Project Manager',
        20,
        '2024-05-01'
    ),
    (
        4,
        5,
        'Sales Lead',
        15,
        '2024-05-01'
    ),
    (
        11,
        5,
        'Finance Analyst',
        10,
        '2024-05-10'
    ),
    (
        13,
        6,
        'Security Expert',
        40,
        '2024-06-01'
    );

-- Insert activity logs (sample week)
INSERT INTO
    activity_log (
        emp_id,
        activity_date,
        activity_type,
        hours_worked
    )
VALUES (
        3,
        '2024-12-02',
        'Meetings',
        3.5
    ),
    (
        3,
        '2024-12-02',
        'Sales Call',
        4.0
    ),
    (
        3,
        '2024-12-03',
        'Meetings',
        2.0
    ),
    (
        3,
        '2024-12-03',
        'Proposal Writing',
        5.5
    ),
    (
        4,
        '2024-12-02',
        'Project Work',
        6.0
    ),
    (
        4,
        '2024-12-02',
        'Meetings',
        2.0
    ),
    (
        4,
        '2024-12-03',
        'Project Work',
        7.0
    ),
    (
        6,
        '2024-12-02',
        'Development',
        8.0
    ),
    (
        6,
        '2024-12-03',
        'Code Review',
        3.0
    ),
    (
        6,
        '2024-12-03',
        'Development',
        5.0
    ),
    (
        7,
        '2024-12-02',
        'Development',
        7.5
    ),
    (
        7,
        '2024-12-02',
        'Testing',
        1.5
    ),
    (
        7,
        '2024-12-03',
        'Development',
        8.0
    ),
    (
        11,
        '2024-12-02',
        'Analysis',
        6.0
    ),
    (
        11,
        '2024-12-02',
        'Reporting',
        2.0
    ),
    (
        11,
        '2024-12-03',
        'Analysis',
        8.0
    ),
    (
        13,
        '2024-12-02',
        'Audit',
        8.0
    ),
    (
        13,
        '2024-12-03',
        'Compliance Review',
        8.0
    );

-- Insert salary history
INSERT INTO
    salary_history (
        emp_id,
        salary,
        effective_date,
        reason
    )
VALUES (
        3,
        100000.00,
        '2017-06-10',
        'Initial Hire'
    ),
    (
        3,
        110000.00,
        '2019-01-15',
        'Promotion to Sales Director'
    ),
    (
        3,
        120000.00,
        '2023-01-01',
        'Annual Raise'
    ),
    (
        6,
        95000.00,
        '2019-02-14',
        'Initial Hire'
    ),
    (
        6,
        105000.00,
        '2021-06-01',
        'Promotion to Lead Developer'
    ),
    (
        6,
        110000.00,
        '2024-01-01',
        'Annual Raise'
    );

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_emp_dept_id ON employee (dept_id);

CREATE INDEX idx_emp_manager_id ON employee (manager_id);

CREATE INDEX idx_assignment_emp_id ON assignment (emp_id);

CREATE INDEX idx_assignment_proj_id ON assignment (proj_id);

CREATE INDEX idx_activity_emp_id ON activity_log (emp_id);

CREATE INDEX idx_activity_date ON activity_log (activity_date);

CREATE INDEX idx_salary_emp_id ON salary_history (emp_id);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify data loaded
SELECT COUNT(*) AS dept_count FROM department;

SELECT COUNT(*) AS emp_count FROM employee;

SELECT COUNT(*) AS proj_count FROM project;

SELECT COUNT(*) AS assign_count FROM assignment;

SELECT COUNT(*) AS activity_count FROM activity_log;

SELECT COUNT(*) AS salary_count FROM salary_history;

-- Sample query: Employee and department info
SELECT e.emp_id, e.first_name, e.last_name, e.salary, d.dept_name
FROM employee e
    LEFT JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;