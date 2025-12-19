# 🎯 Sliding Window Analysis Interview Question

## Question
Given a `sales` table with daily sales amounts, calculate the 3-day moving average and identify days where the sales amount was above the 3-day moving average.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE sales (
    sale_date DATE PRIMARY KEY,
    amount DECIMAL(10,2)
);

INSERT INTO sales VALUES
('2024-01-01', 1000.00),
('2024-01-02', 1200.00),
('2024-01-03', 800.00),
('2024-01-04', 1500.00),
('2024-01-05', 900.00),
('2024-01-06', 1100.00),
('2024-01-07', 1300.00);
```

## Answer: 3-Day Moving Average with Above-Average Detection

```sql
SELECT 
    sale_date,
    amount,
    ROUND(AVG(amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3day,
    CASE 
        WHEN amount > AVG(amount) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance
FROM sales
ORDER BY sale_date;
```

**How it works**: 
- `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` creates a 3-day sliding window
- AVG() calculates the moving average over this window
- CASE statement compares current day against the moving average

## Alternative: 7-Day Moving Average

```sql
SELECT 
    sale_date,
    amount,
    ROUND(AVG(amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_7day
FROM sales
WHERE sale_date >= '2024-01-07'  -- Need 7 days of data
ORDER BY sale_date;
```

**How it works**: Extends the window to 7 days for longer-term trend analysis.

## Window Frame Concepts

- **ROWS BETWEEN**: Physical number of rows in the window
- **RANGE BETWEEN**: Logical range (based on ORDER BY column values)
- **PRECEDING**: Rows before current row
- **FOLLOWING**: Rows after current row
- **CURRENT ROW**: The current row being processed

## Common Patterns

1. **Moving Averages**: `ROWS BETWEEN n PRECEDING AND CURRENT ROW`
2. **Centered Windows**: `ROWS BETWEEN n PRECEDING AND n FOLLOWING`
3. **Year-to-Date**: `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
4. **Future Projections**: `ROWS BETWEEN CURRENT ROW AND n FOLLOWING`

## Performance Considerations

- **Index on ORDER BY column**: Essential for performance
- **Window size impact**: Larger windows = more computation
- **Data volume**: Sliding windows work well with time-series data
- **NULL handling**: NULL values affect averages


- **Explain frame clauses**: ROWS vs RANGE differences
- **Boundary conditions**: What happens at the beginning of the dataset
- **Performance**: When sliding windows become expensive
- **Alternatives**: Self-joins for simple moving averages in older SQL versions


- **Financial analysis**: Moving averages for stock trends
- **Sales forecasting**: Rolling averages for demand planning
- **Quality monitoring**: Detecting anomalies against recent averages
- **User behavior**: Session analysis with time windows
