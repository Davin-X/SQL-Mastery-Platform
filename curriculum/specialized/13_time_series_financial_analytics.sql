-- 13_time_series_financial_analytics.sql
-- FINANCIAL TIME SERIES MASTER CLASS
-- Advanced time series analysis for financial data and business metrics

-- ===========================================
-- MYSQL VERSION
-- ===========================================

USE sample_hr;

-- ===========================================
-- FINANCIAL TIME SERIES FUNDAMENTALS
-- ===========================================

-- Define financial metrics table structure
DROP TABLE IF EXISTS financial_metrics;

CREATE TABLE financial_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    metric_date DATE,
    metric_type ENUM(
        'revenue',
        'costs',
        'profit',
        'investment',
        'cash_flow',
        'assets',
        'liabilities'
    ),
    metric_value DECIMAL(15, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    fiscal_period VARCHAR(10), -- Q1-2024, FY2024, etc.
    source_system VARCHAR(50),
    confidence_level DECIMAL(3, 2), -- 0.00 to 1.00
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_metric_date_type (metric_date, metric_type),
    INDEX idx_period_type (fiscal_period, metric_type)
);

-- Sample financial data insertion
INSERT INTO
    financial_metrics (
        metric_date,
        metric_type,
        metric_value,
        fiscal_period,
        confidence_level
    )
VALUES (
        '2024-01-01',
        'revenue',
        1500000.00,
        'Q1-2024',
        0.98
    ),
    (
        '2024-01-02',
        'revenue',
        1650000.00,
        'Q1-2024',
        0.95
    ),
    (
        '2024-01-03',
        'revenue',
        1580000.00,
        'Q1-2024',
        0.97
    ),
    (
        '2024-02-01',
        'costs',
        950000.00,
        'Q1-2024',
        0.92
    ),
    (
        '2024-02-02',
        'costs',
        980000.00,
        'Q1-2024',
        0.89
    ),
    (
        '2024-02-03',
        'costs',
        935000.00,
        'Q1-2024',
        0.94
    );

-- ===========================================
-- MOVING AVERAGES & TREND ANALYSIS
-- ===========================================

-- Complex moving averages for financial trend identification
SELECT metric_date, metric_type, metric_value,

-- Simple Moving Averages (SMA)
AVG(metric_value) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 6 PRECEDING
        AND CURRENT ROW
) AS sma_7day,
AVG(metric_value) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 29 PRECEDING
        AND CURRENT ROW
) AS sma_30day,

-- Exponential Moving Average (EMA) approximation
AVG(
    metric_value * POW(0.9, datediff)
) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 29 PRECEDING
        AND CURRENT ROW
) / AVG(POW(0.9, datediff)) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 29 PRECEDING
        AND CURRENT ROW
) AS ema_30day,

-- Weighted Moving Average (more recent values have higher weight)
SUM(
    metric_value * (
        ROW_NUMBER() OVER (
            PARTITION BY
                metric_type
            ORDER BY metric_date DESC
        )
    )
) / SUM(
    ROW_NUMBER() OVER (
        PARTITION BY
            metric_type
        ORDER BY metric_date DESC
    )
) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 9 PRECEDING
        AND CURRENT ROW
) AS weighted_ma_10day,

-- Trend direction indicators
CASE
    WHEN metric_value > LAG(metric_value, 7) OVER (
        PARTITION BY
            metric_type
        ORDER BY metric_date
    ) THEN 'Increasing'
    WHEN metric_value < LAG(metric_value, 7) OVER (
        PARTITION BY
            metric_type
        ORDER BY metric_date
    ) THEN 'Decreasing'
    ELSE 'Stable'
END AS weekly_trend,

-- Volatility measures
STDDEV_POP(metric_value) OVER (
    PARTITION BY
        metric_type
    ORDER BY
        metric_date ROWS BETWEEN 29 PRECEDING
        AND CURRENT ROW
) AS volatility_30day,

-- Growth rates
ROUND(
    100.0 * (
        metric_value - LAG(metric_value, 1) OVER (
            PARTITION BY
                metric_type
            ORDER BY metric_date
        )
    ) / NULLIF(
        LAG(metric_value, 1) OVER (
            PARTITION BY
                metric_type
            ORDER BY metric_date
        ),
        0
    ),
    2
) AS daily_growth_pct,
ROUND(
    100.0 * (
        metric_value - LAG(metric_value, 7) OVER (
            PARTITION BY
                metric_type
            ORDER BY metric_date
        )
    ) / NULLIF(
        LAG(metric_value, 7) OVER (
            PARTITION BY
                metric_type
            ORDER BY metric_date
        ),
        0
    ),
    2
) AS weekly_growth_pct
FROM (
        SELECT
            metric_date, metric_type, metric_value, DATEDIFF(
                metric_date, MIN(metric_date) OVER (
                    PARTITION BY
                        metric_type
                )
            ) AS datediff
        FROM financial_metrics
    ) dated_metrics
WHERE
    metric_type IN ('revenue', 'costs')
ORDER BY metric_type, metric_date;

-- ===========================================
-- FINANCIAL KPIS & RATIOS CALCULATION
-- ===========================================

WITH monthly_financials AS (
    SELECT
        DATE_FORMAT(metric_date, '%Y-%m') AS month_year,
        SUM(CASE WHEN metric_type = 'revenue' THEN metric_value ELSE 0 END) AS total_revenue,
        SUM(CASE WHEN metric_type = 'costs' THEN metric_value ELSE 0 END) AS total_costs,
        SUM(CASE WHEN metric_type = 'profit' THEN metric_value ELSE 0 END) AS total_profit,
        SUM(CASE WHEN metric_type = 'investment' THEN metric_value ELSE 0 END) AS total_investment,
        SUM(CASE WHEN metric_type = 'cash_flow' THEN metric_value ELSE 0 END) AS operating_cash_flow
    FROM financial_metrics
    GROUP BY DATE_FORMAT(metric_date, '%Y-%m')
),
financial_ratios AS (
    SELECT
        month_year,
        total_revenue,
        total_costs,
        total_profit,
        total_investment,
        operating_cash_flow,

-- Profitability Ratios
ROUND(
    total_profit / NULLIF(total_revenue, 0) * 100,
    2
) AS profit_margin_pct,
ROUND(
    (total_revenue - total_costs) / NULLIF(total_revenue, 0) * 100,
    2
) AS gross_margin_pct,

-- Efficiency Ratios
ROUND(
    total_revenue / NULLIF(total_costs, 0),
    2
) AS revenue_to_cost_ratio,
ROUND(
    operating_cash_flow / NULLIF(total_revenue, 0) * 100,
    2
) AS cash_flow_margin_pct,

-- Investment Ratios
ROUND(
    total_profit / NULLIF(total_investment, 0) * 100,
    2
) AS roi_pct,

-- Growth Metrics (Month-over-Month)
ROUND(
    100.0 * (
        total_revenue - LAG(total_revenue) OVER (
            ORDER BY month_year
        )
    ) / NULLIF(
        LAG(total_revenue) OVER (
            ORDER BY month_year
        ),
        0
    ),
    2
) AS revenue_growth_mom,
ROUND(
    100.0 * (
        total_profit - LAG(total_profit) OVER (
            ORDER BY month_year
        )
    ) / NULLIF(
        LAG(total_profit) OVER (
            ORDER BY month_year
        ),
        0
    ),
    2
) AS profit_growth_mom,

-- Trend Classification


CASE
            WHEN total_revenue > AVG(total_revenue) OVER (ORDER BY month_year ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                 THEN 'Above_Average'
            ELSE 'Below_Average'
        END AS performance_trend

    FROM monthly_financials
)
SELECT * FROM financial_ratios ORDER BY month_year;

-- ===========================================
-- SEASONALITY & CYCLE ANALYSIS
-- ===========================================

-- Seasonal decomposition using window functions
WITH daily_metrics AS (
    SELECT
        metric_date,
        metric_type,
        metric_value,
        EXTRACT(DAY FROM metric_date) AS day_of_month,
        EXTRACT(MONTH FROM metric_date) AS month,
        EXTRACT(YEAR FROM metric_date) AS year,
        DATE_FORMAT(metric_date, '%Y-%W') AS week_of_year
    FROM financial_metrics
    WHERE metric_type = 'revenue'
),
seasonal_analysis AS (
    SELECT
        *,
        -- Overall average
        AVG(metric_value) OVER () AS overall_avg,

-- Monthly seasonality
AVG(metric_value) OVER (
    PARTITION BY
        month
) AS month_avg,
metric_value - AVG(metric_value) OVER (
    PARTITION BY
        month
) AS month_deviation,

-- Daily patterns within month
AVG(metric_value) OVER (
    PARTITION BY
        month,
        day_of_month
) AS day_of_month_avg,
metric_value - AVG(metric_value) OVER (
    PARTITION BY
        month,
        day_of_month
) AS daily_deviation,

-- Weekly patterns
AVG(metric_value) OVER ( PARTITION BY week_of_year ) AS weekly_avg,

-- Seasonality indices


ROUND(
            AVG(metric_value) OVER (PARTITION BY month) /
            AVG(metric_value) OVER () * 100,
            2
        ) AS monthly_seasonality_index,

        ROUND(
            AVG(metric_value) OVER (PARTITION BY day_of_month) /
            AVG(metric_value) OVER () * 100,
            2
        ) AS daily_seasonality_index

    FROM daily_metrics
)
SELECT
    metric_date,
    metric_value,

-- Seasonal components
ROUND(
    overall_avg + month_deviation + daily_deviation,
    2
) AS seasonal_adjusted_value,

-- Seasonality strength indicators
CASE
    WHEN ABS(
        monthly_seasonality_index - 100
    ) > 15 THEN 'Strong_Monthly_Seasonality'
    WHEN ABS(
        monthly_seasonality_index - 100
    ) > 5 THEN 'Moderate_Monthly_Seasonality'
    ELSE 'Weak_Monthly_Seasonality'
END AS monthly_seasonality_strength,
CASE
    WHEN ABS(daily_seasonality_index - 100) > 10 THEN 'Strong_Daily_Seasonality'
    WHEN ABS(daily_seasonality_index - 100) > 3 THEN 'Moderate_Daily_Seasonality'
    ELSE 'Weak_Daily_Seasonality'
END AS daily_seasonality_strength,

-- Anomaly detection
CASE
    WHEN ABS(daily_deviation) > 2 * STDDEV_POP(daily_deviation) OVER (
        PARTITION BY
            month
    ) THEN 'Statistical_Outlier'
    ELSE 'Within_Normal_Range'
END AS anomaly_flag
FROM seasonal_analysis
ORDER BY metric_date;

-- ===========================================
-- VOLATILITY & RISK ANALYSIS
-- ===========================================

-- Financial volatility measures using advanced window functions
SELECT
    DATE_FORMAT(metric_date, '%Y-%m') AS month_year,
    metric_type,
    COUNT(*) AS data_points,

-- Central tendency measures
ROUND(AVG(metric_value), 2) AS mean_value,
ROUND(MEDIAN (metric_value), 2) AS median_value,
ROUND(STDDEV_POP(metric_value), 2) AS standard_deviation,

-- Risk measures
ROUND(
    STDDEV_POP(metric_value) / NULLIF(AVG(metric_value), 0),
    4
) AS coefficient_of_variation,
ROUND(
    (
        MAX(metric_value) - MIN(metric_value)
    ) / NULLIF(AVG(metric_value), 0),
    4
) AS range_coefficient,

-- Skewness approximation (simplified)
ROUND(
    AVG(
        POW(
            (
                metric_value - AVG(metric_value)
            ) / NULLIF(STDDEV_POP(metric_value), 0),
            3
        )
    ) OVER (
        PARTITION BY
            DATE_FORMAT(metric_date, '%Y-%m'),
            metric_type
    ),
    4
) AS skewness,

-- Kurtosis approximation (simplified)
ROUND(
    AVG(
        POW(
            (
                metric_value - AVG(metric_value)
            ) / NULLIF(STDDEV_POP(metric_value), 0),
            4
        )
    ) OVER (
        PARTITION BY
            DATE_FORMAT(metric_date, '%Y-%m'),
            metric_type
    ) - 3,
    4
) AS excess_kurtosis,

-- Value at Risk approximation (95% confidence)
ROUND(
    AVG(metric_value) - 1.645 * STDDEV_POP(metric_value),
    2
) AS var_95_pct,

-- Risk-adjusted returns
CASE
    WHEN metric_type IN ('profit', 'revenue') THEN ROUND(
        AVG(metric_value) / NULLIF(STDDEV_POP(metric_value), 0),
        4
    )
    ELSE NULL
END AS sharpe_ratio_proxy
FROM financial_metrics
GROUP BY
    DATE_FORMAT(metric_date, '%Y-%m'),
    metric_type
ORDER BY month_year, metric_type;

-- ===========================================
-- PREDICTIVE FORECASTING
-- ===========================================

-- Time series forecasting using moving averages and linear regression
WITH time_series_data AS (
    SELECT
        DATE_FORMAT(metric_date, '%Y-%m') AS month_year,
        metric_type,
        SUM(metric_value) AS monthly_total,
        COUNT(*) AS days_with_data,
        ROW_NUMBER() OVER (PARTITION BY metric_type ORDER BY DATE_FORMAT(metric_date, '%Y-%m')) AS time_index
    FROM financial_metrics
    GROUP BY DATE_FORMAT(metric_date, '%Y-%m'), metric_type
),
forecast_model AS (
    SELECT
        *,
        -- Linear regression slope (simplified)
        ROUND(
            COVAR_POP(time_index, monthly_total) / NULLIF(VAR_POP(time_index), 0),
            2
        ) AS trend_slope,

-- Linear regression intercept (simplified)
ROUND(
    AVG(monthly_total) - (
        COVAR_POP (time_index, monthly_total) / NULLIF(VAR_POP(time_index), 0)
    ) * AVG(time_index),
    2
) AS trend_intercept,

-- Moving average forecast (3-period)
AVG(monthly_total) OVER (
    PARTITION BY
        metric_type
    ORDER BY time_index ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
) AS ma_3_forecast,

-- Exponential smoothing forecast


ROUND(
            0.3 * monthly_total +
            0.4 * LAG(monthly_total, 1) OVER (PARTITION BY metric_type ORDER BY time_index) +
            0.3 * LAG(monthly_total, 2) OVER (PARTITION BY metric_type ORDER BY time_index),
            2
        ) AS exponential_smooth_forecast

    FROM time_series_data
)
SELECT
    month_year,
    metric_type,
    monthly_total AS actual_value,
    trend_intercept + (trend_slope * (time_index + 1)) AS linear_regression_forecast,
    ma_3_forecast,
    exponential_smooth_forecast,

-- Forecast accuracy comparison
ROUND(
    ABS(monthly_total - ma_3_forecast) / NULLIF(monthly_total, 0) * 100,
    2
) AS ma_forecast_error_pct,
ROUND(
    ABS(
        monthly_total - exponential_smooth_forecast
    ) / NULLIF(monthly_total, 0) * 100,
    2
) AS es_forecast_error_pct,

-- Best forecast selection
CASE
    WHEN ABS(monthly_total - ma_3_forecast) < ABS(
        monthly_total - exponential_smooth_forecast
    ) THEN 'Moving_Average'
    ELSE 'Exponential_Smoothing'
END AS best_forecast_method,

-- Forecast confidence intervals
ROUND(ma_3_forecast * 0.95, 2) AS ma_lower_bound,
ROUND(ma_3_forecast * 1.05, 2) AS ma_upper_bound
FROM forecast_model
ORDER BY metric_type, time_index;

-- ===========================================
-- FINANCIAL DASHBOARD & KPIs
-- ===========================================

-- Comprehensive financial dashboard with KPIs


WITH kpi_calculations AS (
    SELECT
        DATE_FORMAT(metric_date, '%Y-%m') AS period,
        metric_type,

        SUM(metric_value) AS total_value,
        AVG(metric_value) AS avg_daily_value,
        COUNT(*) AS data_points,

-- Rolling calculations
SUM(metric_value) OVER (
    PARTITION BY
        metric_type
    ORDER BY DATE_FORMAT(metric_date, '%Y-%m') ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
) AS rolling_3month_sum,
AVG(metric_value) OVER (
    PARTITION BY
        metric_type
    ORDER BY DATE_FORMAT(metric_date, '%Y-%m') ROWS BETWEEN 11 PRECEDING
        AND CURRENT ROW
) AS avg_12month,

-- Period-over-period calculations
SUM(metric_value) - LAG(SUM(metric_value)) OVER (
    PARTITION BY
        metric_type
    ORDER BY DATE_FORMAT(metric_date, '%Y-%m')
) AS pop_change,
ROUND(
    100.0 * (
        SUM(metric_value) - LAG(SUM(metric_value)) OVER (
            PARTITION BY
                metric_type
            ORDER BY DATE_FORMAT(metric_date, '%Y-%m')
        )
    ) / NULLIF(
        LAG(SUM(metric_value)) OVER (
            PARTITION BY
                metric_type
            ORDER BY DATE_FORMAT(metric_date, '%Y-%m')
        ),
        0
    ),
    2
) AS pop_growth_pct,

-- Statistical measures


ROUND(STDDEV_POP(metric_value), 2) AS volatility,
        ROUND(
            STDDEV_POP(metric_value) / NULLIF(AVG(metric_value), 0),
            4
        ) AS volatility_ratio

    FROM financial_metrics
    GROUP BY DATE_FORMAT(metric_date, '%Y-%m'), metric_type
),
kpi_dashboard AS (
    SELECT
        period,
        metric_type,
        total_value,
        avg_daily_value,

-- KPI Classifications
CASE
    WHEN pop_growth_pct > 10 THEN 'Strong_Growth'
    WHEN pop_growth_pct > 5 THEN 'Moderate_Growth'
    WHEN pop_growth_pct > -5 THEN 'Stable'
    WHEN pop_growth_pct > -10 THEN 'Moderate_Decline'
    ELSE 'Strong_Decline'
END AS growth_category,
CASE
    WHEN volatility_ratio > 0.3 THEN 'High_Volatility'
    WHEN volatility_ratio > 0.15 THEN 'Moderate_Volatility'
    ELSE 'Low_Volatility'
END AS risk_category,

-- Performance vs benchmark (assuming 5% growth target)
CASE
    WHEN pop_growth_pct >= 5 THEN 'Above_Target'
    WHEN pop_growth_pct >= 0 THEN 'Meeting_Target'
    WHEN pop_growth_pct >= -5 THEN 'Below_Target'
    ELSE 'Significantly_Below_Target'
END AS target_performance,

-- Trend strength
CASE
    WHEN ABS(pop_growth_pct) >= 15 THEN 'Strong_Trend'
    WHEN ABS(pop_growth_pct) >= 8 THEN 'Moderate_Trend'
    WHEN ABS(pop_growth_pct) >= 3 THEN 'Weak_Trend'
    ELSE 'No_Clear_Trend'
END AS trend_strength,

-- Risk-adjusted growth


ROUND(pop_growth_pct / NULLIF(volatility_ratio, 0), 2) AS risk_adjusted_growth

    FROM kpi_calculations
)
SELECT * FROM kpi_dashboard
ORDER BY metric_type, period DESC;

-- ===========================================
-- POSTGRESQL VERSION
-- ===========================================

/*
-- PostgreSQL equivalent syntax for financial time series analytics:

\c sample_hr;

-- Create financial metrics table (PostgreSQL)
DROP TABLE IF EXISTS financial_metrics;

CREATE TABLE financial_metrics (
metric_id SERIAL PRIMARY KEY,
metric_date DATE,
metric_type VARCHAR(20) CHECK (metric_type IN ('revenue', 'costs', 'profit', 'investment', 'cash_flow', 'assets', 'liabilities')),
metric_value DECIMAL(15, 2),
currency VARCHAR(3) DEFAULT 'USD',
fiscal_period VARCHAR(10),
source_system VARCHAR(50),
confidence_level DECIMAL(3, 2),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_metric_date_type ON financial_metrics (metric_date, metric_type);
CREATE INDEX idx_period_type ON financial_metrics (fiscal_period, metric_type);

-- Moving averages and trend analysis (PostgreSQL)
SELECT
metric_date,
metric_type,
metric_value,
-- Simple Moving Averages
AVG(metric_value) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS sma_7day,
AVG(metric_value) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) AS sma_30day,
-- Exponential Moving Average approximation
AVG(metric_value * POWER(0.9, datediff)) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) / AVG(POWER(0.9, datediff)) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) AS ema_30day
FROM (
SELECT
metric_date,
metric_type,
metric_value,
(metric_date - MIN(metric_date) OVER (PARTITION BY metric_type))::INTEGER AS datediff
FROM financial_metrics
) dated_metrics
WHERE metric_type IN ('revenue', 'costs')
ORDER BY metric_type, metric_date;

-- Financial KPIs and ratios (PostgreSQL)
WITH monthly_financials AS (
SELECT
TO_CHAR(metric_date, 'YYYY-MM') AS month_year,
SUM(CASE WHEN metric_type = 'revenue' THEN metric_value ELSE 0 END) AS total_revenue,
SUM(CASE WHEN metric_type = 'costs' THEN metric_value ELSE 0 END) AS total_costs,
SUM(CASE WHEN metric_type = 'profit' THEN metric_value ELSE 0 END) AS total_profit,
SUM(CASE WHEN metric_type = 'investment' THEN metric_value ELSE 0 END) AS total_investment,
SUM(CASE WHEN metric_type = 'cash_flow' THEN metric_value ELSE 0 END) AS operating_cash_flow
FROM financial_metrics
GROUP BY TO_CHAR(metric_date, 'YYYY-MM')
)
SELECT
month_year,
total_revenue,
total_costs,
total_profit,
ROUND(total_profit / NULLIF(total_revenue, 0) * 100, 2) AS profit_margin_pct,
ROUND((total_revenue - total_costs) / NULLIF(total_revenue, 0) * 100, 2) AS gross_margin_pct,
ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month_year)) /
NULLIF(LAG(total_revenue) OVER (ORDER BY month_year), 0), 2) AS revenue_growth_mom
FROM monthly_financials
ORDER BY month_year;

-- Volatility and risk analysis (PostgreSQL)
SELECT
TO_CHAR(metric_date, 'YYYY-MM') AS month_year,
metric_type,
COUNT(*) AS data_points,
ROUND(AVG(metric_value), 2) AS mean_value,
ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY metric_value), 2) AS median_value,
ROUND(STDDEV_POP(metric_value), 2) AS standard_deviation,
ROUND(STDDEV_POP(metric_value) / NULLIF(AVG(metric_value), 0), 4) AS coefficient_of_variation,
ROUND(AVG(metric_value) - 1.645 * STDDEV_POP(metric_value), 2) AS var_95_pct
FROM financial_metrics
GROUP BY TO_CHAR(metric_date, 'YYYY-MM'), metric_type
ORDER BY month_year, metric_type;

-- PostgreSQL Notes:
-- - SERIAL instead of AUTO_INCREMENT
-- - CHECK constraints instead of ENUM
-- - TO_CHAR() instead of DATE_FORMAT()
-- - PERCENTILE_CONT() WITHIN GROUP instead of MEDIAN()
-- - POWER() instead of POW()
-- - Date arithmetic with ::INTEGER casting
-- - Same window function syntax
*/

-- ===========================================
-- SQL SERVER VERSION
-- ===========================================

/*
-- SQL Server equivalent syntax for financial time series analytics:

USE sample_hr;

-- Create financial metrics table (SQL Server)
DROP TABLE IF EXISTS financial_metrics;

CREATE TABLE financial_metrics (
metric_id INT IDENTITY(1,1) PRIMARY KEY,
metric_date DATE,
metric_type VARCHAR(20) CHECK (metric_type IN ('revenue', 'costs', 'profit', 'investment', 'cash_flow', 'assets', 'liabilities')),
metric_value DECIMAL(15, 2),
currency VARCHAR(3) DEFAULT 'USD',
fiscal_period VARCHAR(10),
source_system VARCHAR(50),
confidence_level DECIMAL(3, 2),
created_at DATETIME2 DEFAULT GETDATE()
);

-- Create indexes
CREATE INDEX idx_metric_date_type ON financial_metrics (metric_date, metric_type);
CREATE INDEX idx_period_type ON financial_metrics (fiscal_period, metric_type);

-- Moving averages and trend analysis (SQL Server)
SELECT
metric_date,
metric_type,
metric_value,
-- Simple Moving Averages
AVG(metric_value) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS sma_7day,
AVG(metric_value) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) AS sma_30day,
-- Exponential Moving Average approximation
AVG(metric_value * POWER(0.9, datediff)) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) / AVG(POWER(0.9, datediff)) OVER (
PARTITION BY metric_type
ORDER BY metric_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) AS ema_30day,
-- Trend indicators
CASE
WHEN metric_value > LAG(metric_value, 7) OVER (PARTITION BY metric_type ORDER BY metric_date)
THEN 'Increasing'
WHEN metric_value < LAG(metric_value, 7) OVER (PARTITION BY metric_type ORDER BY metric_date)
THEN 'Decreasing'
ELSE 'Stable'
END AS weekly_trend
FROM (
SELECT
metric_date,
metric_type,
metric_value,
DATEDIFF(DAY, MIN(metric_date) OVER (PARTITION BY metric_type), metric_date) AS datediff
FROM financial_metrics
) dated_metrics
WHERE metric_type IN ('revenue', 'costs')
ORDER BY metric_type, metric_date;

-- Financial KPIs and ratios (SQL Server)
WITH monthly_financials AS (
SELECT
FORMAT(metric_date, 'yyyy-MM') AS month_year,
SUM(CASE WHEN metric_type = 'revenue' THEN metric_value ELSE 0 END) AS total_revenue,
SUM(CASE WHEN metric_type = 'costs' THEN metric_value ELSE 0 END) AS total_costs,
SUM(CASE WHEN metric_type = 'profit' THEN metric_value ELSE 0 END) AS total_profit,
SUM(CASE WHEN metric_type = 'investment' THEN metric_value ELSE 0 END) AS total_investment,
SUM(CASE WHEN metric_type = 'cash_flow' THEN metric_value ELSE 0 END) AS operating_cash_flow
FROM financial_metrics
GROUP BY FORMAT(metric_date, 'yyyy-MM')
)
SELECT
month_year,
total_revenue,
total_costs,
total_profit,
ROUND(total_profit / NULLIF(total_revenue, 0) * 100, 2) AS profit_margin_pct,
ROUND((total_revenue - total_costs) / NULLIF(total_revenue, 0) * 100, 2) AS gross_margin_pct,
ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month_year)) /
NULLIF(LAG(total_revenue) OVER (ORDER BY month_year), 0), 2) AS revenue_growth_mom
FROM monthly_financials
ORDER BY month_year;

-- Volatility and risk analysis (SQL Server)
SELECT
FORMAT(metric_date, 'yyyy-MM') AS month_year,
metric_type,
COUNT(*) AS data_points,
ROUND(AVG(metric_value), 2) AS mean_value,
ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY metric_value) OVER (
PARTITION BY FORMAT(metric_date, 'yyyy-MM'), metric_type
), 2) AS median_value,
ROUND(STDEV(metric_value), 2) AS standard_deviation,
ROUND(STDEV(metric_value) / NULLIF(AVG(metric_value), 0), 4) AS coefficient_of_variation,
ROUND(AVG(metric_value) - 1.645 * STDEV(metric_value), 2) AS var_95_pct
FROM financial_metrics
GROUP BY FORMAT(metric_date, 'yyyy-MM'), metric_type, metric_value
ORDER BY month_year, metric_type;

-- SQL Server Notes:
-- - IDENTITY(1,1) instead of AUTO_INCREMENT
-- - CHECK constraints instead of ENUM
-- - FORMAT() instead of DATE_FORMAT()
-- - PERCENTILE_CONT() OVER() instead of MEDIAN()
-- - POWER() instead of POW()
-- - DATEDIFF(DAY, start, end) for date differences
-- - GETDATE() instead of CURRENT_TIMESTAMP
-- - STDEV() instead of STDDEV_POP() (approximation)
*/