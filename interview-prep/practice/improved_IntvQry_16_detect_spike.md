# 🎯 Statistical Spike Detection Interview Question

## Question
Given a table of daily sales data, identify days where sales spiked significantly above normal levels (statistical outliers). A spike is defined as sales more than 2 standard deviations above the mean.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    total_sales DECIMAL(10,2),
    transaction_count INT
);

INSERT INTO daily_sales VALUES
('2024-01-01', 15000.00, 120),
('2024-01-02', 18000.00, 145),
('2024-01-03', 16500.00, 132),
('2024-01-04', 22000.00, 180),  -- Potential spike
('2024-01-05', 14000.00, 110),
('2024-01-06', 19000.00, 155),
('2024-01-07', 25000.00, 200),  -- Clear spike
('2024-01-08', 16000.00, 128),
('2024-01-09', 17500.00, 140),
('2024-01-10', 30000.00, 250);  -- Major spike
```

## Answer: Using Window Functions for Statistical Analysis

```sql
WITH sales_stats AS (
    SELECT 
        sale_date,
        total_sales,
        transaction_count,
        AVG(total_sales) OVER () AS mean_sales,
        STDDEV(total_sales) OVER () AS stddev_sales,
        (total_sales - AVG(total_sales) OVER ()) / NULLIF(STDDEV(total_sales) OVER (), 0) AS z_score
    FROM daily_sales
)
SELECT 
    sale_date,
    total_sales,
    transaction_count,
    ROUND(mean_sales, 2) AS avg_sales,
    ROUND(stddev_sales, 2) AS std_deviation,
    ROUND(z_score, 2) AS z_score,
    CASE 
        WHEN z_score > 2 THEN 'High Spike'
        WHEN z_score > 1.5 THEN 'Moderate Spike'
        WHEN z_score < -2 THEN 'Low Dip'
        WHEN z_score < -1.5 THEN 'Moderate Dip'
        ELSE 'Normal'
    END AS anomaly_type
FROM sales_stats
ORDER BY sale_date;
```

**How it works**: 
- Calculate mean and standard deviation across all data
- Compute Z-score: (value - mean) / standard_deviation
- Z-score > 2 indicates statistical outlier (spike)
- Categorize anomalies by severity

## Alternative: Moving Average Spike Detection

```sql
WITH moving_avg AS (
    SELECT 
        sale_date,
        total_sales,
        AVG(total_sales) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND 6 FOLLOWING
        ) AS moving_avg_13day,
        STDDEV(total_sales) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND 6 FOLLOWING
        ) AS moving_stddev
    FROM daily_sales
)
SELECT 
    sale_date,
    total_sales,
    ROUND(moving_avg_13day, 2) AS moving_average,
    ROUND(moving_stddev, 2) AS moving_stddev,
    ROUND((total_sales - moving_avg_13day) / NULLIF(moving_stddev, 0), 2) AS z_score_vs_trend,
    CASE 
        WHEN (total_sales - moving_avg_13day) / NULLIF(moving_stddev, 0) > 2 THEN 'Spike vs Trend'
        ELSE 'Normal vs Trend'
    END AS trend_anomaly
FROM moving_avg
ORDER BY sale_date;
```

**How it works**: 
- Uses 13-day moving window for local trend analysis
- Detects spikes relative to recent performance
- Better for detecting changes in established patterns

## Advanced: Multiple Anomaly Detection Methods

```sql
WITH comprehensive_analysis AS (
    SELECT 
        sale_date,
        total_sales,
        transaction_count,
        
        -- Overall statistics
        AVG(total_sales) OVER () AS global_mean,
        STDDEV(total_sales) OVER () AS global_stddev,
        
        -- Recent trend (7-day window)
        AVG(total_sales) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND 6 FOLLOWING
        ) AS trend_mean,
        STDDEV(total_sales) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND 6 FOLLOWING
        ) AS trend_stddev,
        
        -- Day-of-week patterns
        AVG(total_sales) OVER (
            PARTITION BY DAYOFWEEK(sale_date)
        ) AS dow_mean,
        STDDEV(total_sales) OVER (
            PARTITION BY DAYOFWEEK(sale_date)
        ) AS dow_stddev,
        
        -- Previous day comparison
        LAG(total_sales) OVER (ORDER BY sale_date) AS prev_day_sales
    FROM daily_sales
)
SELECT 
    sale_date,
    total_sales,
    
    -- Global outlier detection
    CASE WHEN (total_sales - global_mean) / global_stddev > 2 THEN 'Global Spike' ELSE 'Normal' END AS global_anomaly,
    
    -- Trend-based detection
    CASE WHEN (total_sales - trend_mean) / NULLIF(trend_stddev, 0) > 1.5 THEN 'Trend Spike' ELSE 'Normal' END AS trend_anomaly,
    
    -- Day-of-week anomaly
    CASE WHEN ABS(total_sales - dow_mean) / NULLIF(dow_stddev, 0) > 2 THEN 'DOW Anomaly' ELSE 'Normal' END AS dow_anomaly,
    
    -- Day-over-day change
    CASE 
        WHEN prev_day_sales IS NOT NULL AND (total_sales - prev_day_sales) / prev_day_sales > 0.5 THEN 'Sudden Increase'
        WHEN prev_day_sales IS NOT NULL AND (total_sales - prev_day_sales) / prev_day_sales < -0.5 THEN 'Sudden Decrease'
        ELSE 'Normal Change'
    END AS day_change
    
FROM comprehensive_analysis
ORDER BY sale_date;
```

**How it works**: 
- Combines multiple detection methods
- Global statistics, trend analysis, day-of-week patterns, day-over-day changes
- Comprehensive anomaly detection using different perspectives

## Percentile-Based Anomaly Detection

```sql
WITH percentile_analysis AS (
    SELECT 
        sale_date,
        total_sales,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) OVER () AS median_sales,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_sales) OVER () AS p95_sales,
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY total_sales) OVER () AS p5_sales
    FROM daily_sales
)
SELECT 
    sale_date,
    total_sales,
    median_sales,
    p95_sales,
    CASE 
        WHEN total_sales > p95_sales THEN 'Top 5% Outlier'
        WHEN total_sales < p5_sales THEN 'Bottom 5% Outlier'
        ELSE 'Normal Range'
    END AS percentile_status
FROM percentile_analysis
ORDER BY sale_date;
```

**How it works**: 
- Uses percentiles instead of standard deviation
- More robust to skewed distributions
- Identifies values in the extreme 5% of the distribution

## Performance Considerations

- **Window functions**: Can be expensive on large datasets
- **Index on date column**: Critical for time-based analysis
- **Pre-computed statistics**: Consider materialized views for frequent analysis
- **Sampling**: For very large datasets, analyze recent data only

## Common Interview Patterns

1. **Fraud detection**: Identifying unusual transaction patterns
2. **Quality monitoring**: Detecting manufacturing defects or system issues
3. **Sales analysis**: Finding promotional campaign impacts
4. **System monitoring**: Detecting performance anomalies

## Interview Tips

- **Statistical knowledge**: Explain Z-scores and standard deviations
- **Business context**: Why detecting spikes matters for the business
- **Multiple methods**: Different approaches for different scenarios
- **Parameter tuning**: How to adjust sensitivity (2σ vs 3σ)
- **False positives**: Balance between catching anomalies and avoiding noise

## Real-World Applications

- **E-commerce**: Detecting fraudulent orders or promotional spikes
- **Finance**: Identifying unusual trading patterns or money laundering
- **Manufacturing**: Quality control and defect detection
- **System monitoring**: Performance anomaly detection
- **Healthcare**: Disease outbreak detection or vital sign monitoring

## Database-Specific Notes

- **Statistical functions**: STDDEV vs STDDEV_SAMP vs STDDEV_POP
- **Window frame support**: Not all databases support all window frame options
- **Percentile functions**: PERCENTILE_CONT vs PERCENTILE_DISC
- **Performance**: Some databases optimize window functions better than others

## Testing and Validation

```sql
-- Verify statistical calculations
SELECT 
    AVG(total_sales) AS mean,
    STDDEV(total_sales) AS stddev,
    MIN(total_sales) AS min_val,
    MAX(total_sales) AS max_val
FROM daily_sales;

-- Check for data quality
SELECT 
    COUNT(*) AS total_days,
    COUNT(CASE WHEN total_sales > 0 THEN 1 END) AS valid_sales_days
FROM daily_sales;

-- Test edge cases
SELECT * FROM daily_sales 
WHERE total_sales = (SELECT MAX(total_sales) FROM daily_sales);
```

## Best Practices

1. **Define clear thresholds**: 2σ, 3σ, or percentile-based detection
2. **Consider seasonality**: Day-of-week, month-of-year patterns
3. **Use multiple methods**: Combine statistical and business rules
4. **Monitor false positives**: Tune parameters based on business impact
5. **Historical context**: Compare against similar time periods
6. **Alert thresholds**: Different severity levels for different responses
