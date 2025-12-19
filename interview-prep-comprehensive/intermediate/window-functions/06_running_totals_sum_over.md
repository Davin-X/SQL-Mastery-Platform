# Problem 06: Running Totals with SUM() OVER() - Cumulative Calculations

## Business Context
Financial analysts and business managers need to track cumulative metrics like running totals, year-to-date calculations, and progressive sums. Running totals help identify trends, calculate balances, and monitor progress against targets over time.

## Requirements
Write SQL queries using SUM() OVER() with different window frame specifications to calculate running totals, moving sums, and cumulative aggregations.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE daily_transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL
);

CREATE TABLE monthly_revenue (
    revenue_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    month_year DATE NOT NULL,
    monthly_revenue DECIMAL(12, 2) NOT NULL,
    monthly_units INT NOT NULL
);

-- Insert sample data
INSERT INTO daily_transactions (transaction_id, account_id, transaction_date, amount, transaction_type, category) VALUES
(1, 1001, '2024-01-01', 1000.00, 'Deposit', 'Salary'),
(2, 1001, '2024-01-02', -200.00, 'Withdrawal', 'Groceries'),
(3, 1001, '2024-01-03', -150.00, 'Withdrawal', 'Utilities'),
(4, 1001, '2024-01-04', 500.00, 'Deposit', 'Bonus'),
(5, 1001, '2024-01-05', -75.00, 'Withdrawal', 'Entertainment'),
(6, 1001, '2024-01-06', 250.00, 'Deposit', 'Interest'),
(7, 1002, '2024-01-01', 800.00, 'Deposit', 'Salary'),
(8, 1002, '2024-01-02', -300.00, 'Withdrawal', 'Rent'),
(9, 1002, '2024-01-03', -100.00, 'Withdrawal', 'Food'),
(10, 1002, '2024-01-04', 200.00, 'Deposit', 'Refund');

INSERT INTO monthly_revenue (revenue_id, product_id, product_name, month_year, monthly_revenue, monthly_units) VALUES
(1, 1, 'Laptop Pro', '2024-01-01', 25000.00, 100),
(2, 1, 'Laptop Pro', '2024-02-01', 27500.00, 110),
(3, 1, 'Laptop Pro', '2024-03-01', 22000.00, 88),
(4, 1, 'Laptop Pro', '2024-04-01', 30000.00, 120),
(5, 2, 'Tablet Air', '2024-01-01', 15000.00, 200),
(6, 2, 'Tablet Air', '2024-02-01', 18000.00, 240),
(7, 2, 'Tablet Air', '2024-03-01', 12000.00, 160),
(8, 2, 'Tablet Air', '2024-04-01', 20000.00, 250),
(9, 3, 'Phone X', '2024-01-01', 35000.00, 175),
(10, 3, 'Phone X', '2024-02-01', 42000.00, 210),
(11, 3, 'Phone X', '2024-03-01', 28000.00, 140),
(12, 3, 'Phone X', '2024-04-01', 49000.00, 245);
```

## Query Requirements

### Query 1: Daily running balance for account
```sql
SELECT 
    transaction_id,
    account_id,
    transaction_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY account_id 
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM daily_transactions
ORDER BY account_id, transaction_date, transaction_id;
```

**Expected Result:**
| transaction_id | account_id | transaction_date | amount  | running_balance |
|----------------|------------|------------------|---------|-----------------|
| 1              | 1001       | 2024-01-01       | 1000.00 | 1000.00         |
| 2              | 1001       | 2024-01-02       | -200.00 | 800.00          |
| 3              | 1001       | 2024-01-03       | -150.00 | 650.00          |
| 4              | 1001       | 2024-01-04       | 500.00  | 1150.00         |
| 5              | 1001       | 2024-01-05       | -75.00  | 1075.00         |
| 6              | 1001       | 2024-01-06       | 250.00  | 1325.00         |
| 7              | 1002       | 2024-01-01       | 800.00  | 800.00          |
| 8              | 1002       | 2024-01-02       | -300.00 | 500.00          |
| 9              | 1002       | 2024-01-03       | -100.00 | 400.00          |
| 10             | 1002       | 2024-01-04       | 200.00  | 600.00          |

### Query 2: Monthly cumulative revenue by product
```sql
SELECT 
    product_name,
    month_year,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY product_name 
        ORDER BY month_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue,
    SUM(monthly_units) OVER (
        PARTITION BY product_name 
        ORDER BY month_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_units
FROM monthly_revenue
ORDER BY product_name, month_year;
```

**Expected Result:**
| product_name | month_year | monthly_revenue | cumulative_revenue | cumulative_units |
|--------------|------------|-----------------|-------------------|------------------|
| Laptop Pro   | 2024-01-01 | 25000.00        | 25000.00          | 100              |
| Laptop Pro   | 2024-02-01 | 27500.00        | 52500.00          | 210              |
| Laptop Pro   | 2024-03-01 | 22000.00        | 74500.00          | 298              |
| Laptop Pro   | 2024-04-01 | 30000.00        | 104500.00         | 418              |
| Phone X      | 2024-01-01 | 35000.00        | 35000.00          | 175              |
| Phone X      | 2024-02-01 | 42000.00        | 77000.00          | 385              |
| Phone X      | 2024-03-01 | 28000.00        | 105000.00         | 525              |
| Phone X      | 2024-04-01 | 49000.00        | 154000.00         | 770              |
| Tablet Air   | 2024-01-01 | 15000.00        | 15000.00          | 200              |
| Tablet Air   | 2024-02-01 | 18000.00        | 33000.00          | 440              |
| Tablet Air   | 2024-03-01 | 12000.00        | 45000.00          | 600              |
| Tablet Air   | 2024-04-01 | 20000.00        | 65000.00          | 850              |

### Query 3: 3-month moving revenue average
```sql
SELECT 
    product_name,
    month_year,
    monthly_revenue,
    ROUND(
        AVG(monthly_revenue) OVER (
            PARTITION BY product_name 
            ORDER BY month_year
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS three_month_avg_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY product_name 
        ORDER BY month_year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_sum_revenue
FROM monthly_revenue
ORDER BY product_name, month_year;
```

**Expected Result:**
| product_name | month_year | monthly_revenue | three_month_avg_revenue | three_month_sum_revenue |
|--------------|------------|-----------------|-------------------------|-------------------------|
| Laptop Pro   | 2024-01-01 | 25000.00        | 25000.00                | 25000.00                |
| Laptop Pro   | 2024-02-01 | 27500.00        | 26250.00                | 52500.00                |
| Laptop Pro   | 2024-03-01 | 22000.00        | 24833.33                | 74500.00                |
| Laptop Pro   | 2024-04-01 | 30000.00        | 26500.00                | 79500.00                |
| Phone X      | 2024-01-01 | 35000.00        | 35000.00                | 35000.00                |
| Phone X      | 2024-02-01 | 42000.00        | 38500.00                | 77000.00                |
| Phone X      | 2024-03-01 | 28000.00        | 35000.00                | 105000.00               |
| Phone X      | 2024-04-01 | 49000.00        | 39666.67                | 119000.00               |
| Tablet Air   | 2024-01-01 | 15000.00        | 15000.00                | 15000.00                |
| Tablet Air   | 2024-02-01 | 18000.00        | 16500.00                | 33000.00                |
| Tablet Air   | 2024-03-01 | 12000.00        | 15000.00                | 45000.00                |
| Tablet Air   | 2024-04-01 | 20000.00        | 16666.67                | 50000.00                |

### Query 4: Year-to-date revenue with monthly comparison
```sql
SELECT 
    product_name,
    month_year,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY product_name, EXTRACT(YEAR FROM month_year)
        ORDER BY month_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_revenue,
    monthly_revenue - LAG(monthly_revenue) OVER (
        PARTITION BY product_name 
        ORDER BY month_year
    ) AS month_over_month_change,
    ROUND(
        (SUM(monthly_revenue) OVER (
            PARTITION BY product_name, EXTRACT(YEAR FROM month_year)
            ORDER BY month_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(monthly_revenue) OVER (
            PARTITION BY product_name, EXTRACT(YEAR FROM month_year)
            ORDER BY month_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) * 100, 2
    ) AS ytd_percentage_of_annual
FROM monthly_revenue
ORDER BY product_name, month_year;
```

**Expected Result:**
| product_name | month_year | monthly_revenue | ytd_revenue | month_over_month_change | ytd_percentage_of_annual |
|--------------|------------|-----------------|-------------|------------------------|---------------------------|
| Laptop Pro   | 2024-01-01 | 25000.00        | 25000.00    |                        | 23.92                     |
| Laptop Pro   | 2024-02-01 | 27500.00        | 52500.00    | 2500.00                | 50.24                     |
| Laptop Pro   | 2024-03-01 | 22000.00        | 74500.00    | -5500.00               | 71.39                     |
| Laptop Pro   | 2024-04-01 | 30000.00        | 104500.00   | 8000.00                | 100.00                    |
| Phone X      | 2024-01-01 | 35000.00        | 35000.00    |                        | 22.73                     |
| Phone X      | 2024-02-01 | 42000.00        | 77000.00    | 7000.00                | 50.00                     |
| Phone X      | 2024-03-01 | 28000.00        | 105000.00   | -14000.00              | 68.18                     |
| Phone X      | 2024-04-01 | 49000.00        | 154000.00   | 21000.00               | 100.00                    |
| Tablet Air   | 2024-01-01 | 15000.00        | 15000.00    |                        | 23.08                     |
| Tablet Air   | 2024-02-01 | 18000.00        | 33000.00    | 3000.00                | 50.77                     |
| Tablet Air   | 2024-03-01 | 12000.00        | 45000.00    | -6000.00               | 69.23                     |
| Tablet Air   | 2024-04-01 | 20000.00        | 65000.00    | 8000.00                | 100.00                    |

### Query 5: Running balance with transaction categorization
```sql
SELECT 
    account_id,
    transaction_date,
    category,
    amount,
    CASE WHEN amount > 0 THEN 'Credit' ELSE 'Debit' END AS transaction_type,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) OVER (
        PARTITION BY account_id 
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_credits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) OVER (
        PARTITION BY account_id 
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_debits,
    SUM(amount) OVER (
        PARTITION BY account_id 
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM daily_transactions
ORDER BY account_id, transaction_date, transaction_id;
```

**Expected Result:**
| account_id | transaction_date | category     | amount  | transaction_type | total_credits | total_debits | running_balance |
|------------|------------------|--------------|---------|------------------|---------------|--------------|-----------------|
| 1001       | 2024-01-01       | Salary       | 1000.00 | Credit           | 1000.00       | 0.00         | 1000.00         |
| 1001       | 2024-01-02       | Groceries    | -200.00 | Debit            | 1000.00       | 200.00       | 800.00          |
| 1001       | 2024-01-03       | Utilities    | -150.00 | Debit            | 1000.00       | 350.00       | 650.00          |
| 1001       | 2024-01-04       | Bonus        | 500.00  | Credit           | 1500.00       | 350.00       | 1150.00         |
| 1001       | 2024-01-05       | Entertainment| -75.00  | Debit            | 1500.00       | 425.00       | 1075.00         |
| 1001       | 2024-01-06       | Interest     | 250.00  | Credit           | 1750.00       | 425.00       | 1325.00         |
| 1002       | 2024-01-01       | Salary       | 800.00  | Credit           | 800.00        | 0.00         | 800.00          |
| 1002       | 2024-01-02       | Rent         | -300.00 | Debit            | 800.00        | 300.00       | 500.00          |
| 1002       | 2024-01-03       | Food         | -100.00 | Debit            | 800.00        | 400.00       | 400.00          |
| 1002       | 2024-01-04       | Refund       | 200.00  | Credit           | 1000.00       | 400.00       | 600.00          |

## Key Learning Points
- **SUM() OVER()**: Creates running totals and cumulative sums
- **ROWS BETWEEN**: Controls the window frame for calculations
- **UNBOUNDED PRECEDING**: Include all previous rows
- **CURRENT ROW**: Include the current row in calculation
- **Running balances**: Financial cumulative calculations
- **Moving averages**: Rolling period calculations

## Common Running Total Applications
- **Financial balances**: Account balances, running totals
- **Sales tracking**: Cumulative revenue, year-to-date figures
- **Inventory**: Running stock levels, cumulative consumption
- **Progress tracking**: Project completion percentages
- **Performance metrics**: Cumulative KPIs over time

## Performance Notes
- Running totals can be expensive with large datasets
- Proper indexing on partition and order columns crucial
- Consider pre-calculated summary tables for large volumes
- ROWS BETWEEN is generally more efficient than RANGE BETWEEN

## Extension Challenge
Create a comprehensive financial dashboard that shows running balances, monthly spending trends, and alerts when account balances fall below certain thresholds.
