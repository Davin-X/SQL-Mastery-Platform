# Problem 02: String Functions Basics - Name Formatting and Text Processing

## Business Context
HR systems often need to manipulate text data for reporting, data cleansing, and user interface display. String functions are essential for formatting names, validating emails, and processing textual information.

## Requirements
Write SQL queries using basic string functions to format names, extract text components, and perform text transformations.

## Sample Data Setup
```sql
-- Create table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    job_title VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200)
);

-- Insert sample data
INSERT INTO employee (emp_id, first_name, last_name, email, job_title, phone, address) VALUES
(1, 'john', 'doe', 'john.doe@company.com', 'Software Engineer', '555-0101', '123 Main St, Anytown, NY 12345'),
(2, 'JANE', 'SMITH', 'jane.smith@company.com', 'Senior Developer', '555-0102', '456 Oak Ave, Somewhere, CA 98765'),
(3, 'bob', 'wilson', 'bob.wilson@company.com', 'Database Administrator', '555-0103', '789 Pine Rd, Elsewhere, TX 45678'),
(4, 'alice', 'brown', 'alice.brown@company.com', 'Sales Manager', '555-0104', '321 Elm St, Nowhere, FL 11223'),
(5, 'charlie', 'davis', 'charlie.davis@company.com', 'Sales Representative', NULL, '654 Maple Dr, Anywhere, WA 33445'),
(6, 'diana', 'evans', 'diana.evans@company.com', 'Account Executive', '555-0106', '987 Cedar Ln, Everywhere, IL 55667');
```

## Query Requirements

### Query 1: Name formatting (proper case)
```sql
SELECT 
    emp_id,
    INITCAP(first_name) AS formatted_first_name,
    INITCAP(last_name) AS formatted_last_name,
    INITCAP(first_name || ' ' || last_name) AS full_name_proper
FROM employee
ORDER BY last_name, first_name;
```

**Expected Result:**
| emp_id | formatted_first_name | formatted_last_name | full_name_proper  |
|--------|----------------------|---------------------|-------------------|
| 4      | Alice               | Brown              | Alice Brown      |
| 5      | Charlie             | Davis              | Charlie Davis    |
| 1      | John                | Doe                | John Doe         |
| 6      | Diana               | Evans              | Diana Evans      |
| 2      | Jane                | Smith              | Jane Smith       |
| 3      | Bob                 | Wilson             | Bob Wilson       |

### Query 2: String length and case conversion
```sql
SELECT 
    emp_id,
    first_name,
    LENGTH(first_name) AS first_name_length,
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower,
    LENGTH(email) AS email_length
FROM employee
ORDER BY first_name_length DESC, first_name;
```

**Expected Result:**
| emp_id | first_name | first_name_length | first_name_upper | last_name_lower | email_length |
|--------|------------|-------------------|------------------|-----------------|--------------|
| 5      | charlie    | 7                | CHARLIE         | davis          | 23          |
| 4      | alice      | 5                | ALICE           | brown          | 22          |
| 6      | diana      | 5                | DIANA           | evans          | 21          |
| 1      | john       | 4                | JOHN            | doe            | 19          |
| 2      | JANE       | 4                | JANE            | smith          | 21          |
| 3      | bob        | 3                | BOB             | wilson         | 20          |

### Query 3: Substring extraction (area codes from phone)
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    phone,
    SUBSTRING(phone, 1, 3) AS area_code,
    SUBSTRING(phone, 5) AS local_number
FROM employee
WHERE phone IS NOT NULL
ORDER BY area_code, local_number;
```

**Expected Result:**
| emp_id | first_name | last_name | phone     | area_code | local_number |
|--------|------------|-----------|-----------|-----------|--------------|
| 1      | john       | doe       | 555-0101  | 555       | 0101         |
| 2      | JANE       | SMITH     | 555-0102  | 555       | 0102         |
| 3      | bob        | wilson    | 555-0103  | 555       | 0103         |
| 4      | alice      | brown     | 555-0104  | 555       | 0104         |
| 6      | diana      | evans     | 555-0106  | 555       | 0106         |

### Query 4: Email domain extraction
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    email,
    SPLIT_PART(email, '@', 2) AS domain,
    POSITION('@' IN email) AS at_position
FROM employee
ORDER BY domain, last_name;
```

**Expected Result:**
| emp_id | first_name | last_name | email                   | domain        | at_position |
|--------|------------|-----------|-------------------------|---------------|------------|
| 4      | alice      | brown     | alice.brown@company.com | company.com   | 12         |
| 5      | charlie    | davis     | charlie.davis@company.com| company.com  | 15         |
| 1      | john       | doe       | john.doe@company.com    | company.com   | 9          |
| 6      | diana      | evans     | diana.evans@company.com | company.com   | 11         |
| 2      | JANE       | SMITH     | jane.smith@company.com  | company.com   | 11         |
| 3      | bob        | wilson    | bob.wilson@company.com  | company.com   | 10         |

### Query 5: Address parsing (city and state)
```sql
SELECT 
    emp_id,
    first_name,
    last_name,
    address,
    SPLIT_PART(address, ', ', 2) AS city,
    RIGHT(address, 2) AS state,
    SUBSTRING(address, LENGTH(address) - 4, 5) AS zip_code
FROM employee
ORDER BY state, city;
```

**Expected Result:**
| emp_id | first_name | last_name | address                      | city       | state | zip_code |
|--------|------------|-----------|------------------------------|------------|-------|----------|
| 4      | alice      | brown     | 321 Elm St, Nowhere, FL 11223| Nowhere    | FL    | 11223   |
| 6      | diana      | evans     | 987 Cedar Ln, Everywhere, IL 55667| Everywhere| IL    | 55667   |
| 1      | john       | doe       | 123 Main St, Anytown, NY 12345| Anytown    | NY    | 12345   |
| 3      | bob        | wilson    | 789 Pine Rd, Elsewhere, TX 45678| Elsewhere  | TX    | 45678   |
| 5      | charlie    | davis     | 654 Maple Dr, Anywhere, WA 33445| Anywhere   | WA    | 33445   |
| 2      | JANE       | SMITH     | 456 Oak Ave, Somewhere, CA 98765| Somewhere  | CA    | 98765   |

## Key Learning Points
- **INITCAP()**: Capitalizes first letter of each word
- **UPPER()/LOWER()**: Case conversion functions
- **LENGTH()**: Returns string length
- **SUBSTRING()**: Extracts portion of string
- **SPLIT_PART()**: Splits string by delimiter
- **POSITION()**: Finds position of substring
- **RIGHT()**: Extracts from end of string

## Common String Functions
- **CONCAT()**: Concatenate strings
- **TRIM()**: Remove whitespace
- **REPLACE()**: Replace substrings
- **SUBSTRING()**: Extract substrings
- **LENGTH()**: String length
- **UPPER()/LOWER()**: Case conversion

## Performance Notes
- String functions can be expensive on large datasets
- Consider storing computed values in additional columns
- Some functions prevent index usage in WHERE clauses
- Be aware of encoding and collation settings

## Extension Challenge
Create a query that validates email format and identifies potentially invalid email addresses.
