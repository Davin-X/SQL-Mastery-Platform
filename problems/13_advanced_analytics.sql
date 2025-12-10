-- 13_advanced_analytics.sql
-- ADVANCED ANALYTICS MASTER CLASS
-- NTILE, PERCENT_RANK, CUME_DIST, CORR with Real Business Scenarios

USE sample_hr;

-- ===========================================
-- SALARY DISTRIBUTION & PERFORMANCE TIERS
-- ===========================================

-- Executive Summary: Department salary distributions with statistical analysis
SELECT
    'EXECUTIVE SUMMARY - SALARY DISTRIBUTIONS' AS analysis_type,
    COUNT(*) AS total_employees,
    ROUND(AVG(salary), 0) AS company_avg_salary,
    ROUND(MIN(salary), 0) AS min_salary,
    ROUND(MAX(salary), 0) AS max_salary,
    ROUND(STDDEV_POP(salary), 0) AS salary_std_dev,
    ROUND(
        MAX(salary) / NULLIF(MIN(salary), 0),
        2
    ) AS pay_ratio_max_min,
    COUNT(
        CASE
            WHEN PERCENT_RANK() OVER (
                ORDER BY salary DESC
            ) <= 0.1 THEN 1
        END
    ) AS top_10pct_count,
    ROUND(
        AVG(
            CASE
                WHEN PERCENT_RANK() OVER (
                    ORDER BY salary DESC
                ) <= 0.25 THEN salary
            END
        ),
        0
    ) AS top_quarter_avg
FROM employee;

-- Detailed Salary Quartiles by Department with Statistical Measures
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS dept_size,
    NTILE(4) OVER (
        ORDER BY COUNT(e.emp_id) DESC
    ) AS dept_size_quartile,

-- Salary Statistics
ROUND(MIN(e.salary), 0) AS dept_min_salary,
ROUND(MAX(e.salary), 0) AS dept_max_salary,
ROUND(AVG(e.salary), 0) AS dept_avg_salary,
ROUND(STDDEV_POP(e.salary), 0) AS dept_salary_std,
ROUND(
    MAX(e.salary) / NULLIF(MIN(e.salary), 0),
    2
) AS dept_pay_ratio,

-- Department Rankings
PERCENT_RANK() OVER (
    ORDER BY AVG(e.salary) DESC
) AS dept_avg_percentile,
RANK() OVER (
    ORDER BY AVG(e.salary) DESC
) AS avg_salary_rank,
NTILE(3) OVER (
    ORDER BY AVG(e.salary) DESC
) AS salary_tier,

-- Employee Distribution within Department
COUNT(
    CASE
        WHEN NTILE(4) OVER (
            PARTITION BY
                d.dept_name
            ORDER BY e.salary DESC
        ) = 1 THEN 1
    END
) AS dept_top_quarter_count,
COUNT(
    CASE
        WHEN NTILE(4) OVER (
            PARTITION BY
                d.dept_name
            ORDER BY e.salary DESC
        ) = 4 THEN 1
    END
) AS dept_bottom_quarter_count,

-- Comparative Analysis
ROUND(
    AVG(e.salary) / AVG(AVG(e.salary)) OVER () * 100 - 100,
    1
) AS pct_vs_company_avg,
CASE
    WHEN AVG(e.salary) > AVG(AVG(e.salary)) OVER () * 1.1 THEN 'High-Paying Department'
    WHEN AVG(e.salary) < AVG(AVG(e.salary)) OVER () * 0.9 THEN 'Budget-Constrained Department'
    ELSE 'Average Department'
END AS department_category
FROM department d
    JOIN employee e ON d.dept_id = e.dept_id
GROUP BY
    d.dept_name
ORDER BY avg_salary_rank;

-- ===========================================
-- INDIVIDUAL EMPLOYEE PERFORMANCE ANALYSIS
-- ===========================================

-- Performance Scoring Framework using Statistical Distributions
WITH employee_performance AS (
    SELECT
        e.*,
        d.dept_name,

-- Company-wide percentiles
PERCENT_RANK() OVER (
    ORDER BY e.salary DESC
) AS company_salary_percentile,
PERCENT_RANK() OVER (
    ORDER BY e.hire_date ASC
) AS company_tenure_percentile,

-- Department percentiles
PERCENT_RANK() OVER (
    PARTITION BY
        d.dept_name
    ORDER BY e.salary DESC
) AS dept_salary_percentile,

-- Statistical measures
e.salary - AVG(e.salary) OVER () AS salary_vs_company_avg,
e.salary - AVG(e.salary) OVER (
    PARTITION BY
        d.dept_name
) AS salary_vs_dept_avg,

-- Experience-based performance (simulated)
TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS years_experience,
        CASE
            WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) >= 8 THEN 4.8
            WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) >= 5 THEN 4.5
            WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) >= 3 THEN 4.2
            WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) >= 1 THEN 3.9
            ELSE 3.5
        END AS estimated_performance_score

    FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
),
performance_tiers AS (
    SELECT *,
        CASE
            WHEN company_salary_percentile >= 0.9 THEN 'Elite Performer (Top 10%)'
            WHEN company_salary_percentile >= 0.75 THEN 'High Performer (Top 25%)'
            WHEN company_salary_percentile >= 0.5 THEN 'Solid Performer (Above Median)'
            WHEN company_salary_percentile >= 0.25 THEN 'Developing Performer (75th+)'
            ELSE 'Early Career Performer'
        END AS performance_tier,

-- Statistical outlier detection
CASE
            WHEN salary_vs_company_avg > STDDEV_POP(salary_vs_company_avg) OVER () THEN 'High Performer Outlier'
            WHEN salary_vs_company_avg < -STDDEV_POP(salary_vs_company_avg) OVER () THEN 'Low Performer Outlier'
            ELSE 'Within Normal Range'
        END AS statistical_outlier_status

    FROM employee_performance
)
SELECT
    first_name,
    last_name,
    dept_name,
    salary,
    estimated_performance_score,
    years_experience,
    performance_tier,
    statistical_outlier_status,
    ROUND(company_salary_percentile * 100, 1) AS company_salary_percentile_pct,
    ROUND(company_tenure_percentile * 100, 1) AS tenure_percentile_pct,

-- Performance-to-Salary correlation within department
ROUND(
    estimated_performance_score / MAX(estimated_performance_score) OVER (
        PARTITION BY
            dept_name
    ),
    3
) AS performance_ratio_in_dept,

-- Leadership potential indicator
CASE
    WHEN years_experience >= 5
    AND company_salary_percentile >= 0.8 THEN 'High Leadership Potential'
    WHEN years_experience >= 3
    AND company_salary_percentile >= 0.6 THEN 'Moderate Leadership Potential'
    WHEN years_experience >= 1 THEN 'Emerging Leadership Potential'
    ELSE 'Developing Professional'
END AS leadership_potential
FROM performance_tiers
ORDER BY company_salary_percentile DESC;

-- ===========================================
-- CORRELATION ANALYSIS: Performance vs Experience
-- ===========================================

-- Detailed Correlation Matrix
WITH employee_metrics AS (
    SELECT
        first_name,
        last_name,
        salary,
        TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_experience,
        CASE
            WHEN salary > 100000 THEN 4.8
            WHEN salary > 80000 THEN 4.5
            WHEN salary > 60000 THEN 4.0
            ELSE 3.5
        END AS performance_banding
    FROM employee
),
correlation_analysis AS (
    SELECT
        COUNT(*) AS sample_size,
        CORR(salary, years_experience) AS salary_tenure_correlation,
        CORR(performance_banding, years_experience) AS performance_tenure_correlation,
        CORR(salary, performance_banding) AS salary_performance_correlation,

-- Statistical significance indicators
ROUND(
    SQRT(sample_size - 1) * CORR (salary, years_experience) / SQRT(
        1 - POWER(
            CORR (salary, years_experience),
            2
        )
    ),
    2
) AS salary_correlation_t_stat,
ROUND(
    SQRT(sample_size - 1) * CORR (
        performance_banding,
        years_experience
    ) / SQRT(
        1 - POWER(
            CORR (
                performance_banding,
                years_experience
            ),
            2
        )
    ),
    2
) AS perf_correlation_t_stat,

-- Enterprise Insights
CASE
            WHEN CORR(salary, years_experience) > 0.7 THEN 'Strong Experience-Salary Relationship'
            WHEN CORR(salary, years_experience) > 0.5 THEN 'Moderate Experience-Salary Relationship'
            WHEN CORR(salary, years_experience) > 0.3 THEN 'Weak Experience-Salary Relationship'
            ELSE 'No Significant Experience-Salary Link'
        END AS salary_tenure_relationship,

        CASE
            WHEN CORR(performance_banding, years_experience) > 0.6 THEN 'Performance Improves Significantly with Experience'
            WHEN CORR(performance_banding, years_experience) > 0.4 THEN 'Performance Improves Moderately with Experience'
            WHEN CORR(performance_banding, years_experience) > 0.2 THEN 'Performance Improves Slightly with Experience'
            ELSE 'Limited Performance-Experience Correlation'
        END AS experience_performance_insights

    FROM employee_metrics
)
SELECT
    sample_size,
    ROUND(salary_tenure_correlation, 3) AS salary_tenure_correlation,
    ROUND(performance_tenure_correlation, 3) AS performance_tenure_correlation,
    ROUND(salary_performance_correlation, 3) AS salary_performance_correlation,
    salary_tenure_relationship,
    experience_performance_insights,

-- Interpretation matrix
CASE
    WHEN ABS(salary_tenure_correlation) > 0.5
    AND ABS(
        performance_tenure_correlation
    ) > 0.5 THEN 'Strong Meritocracy: Experience drives both salary and performance'
    WHEN ABS(salary_tenure_correlation) > 0.5
    AND ABS(
        performance_tenure_correlation
    ) < 0.3 THEN 'Salary Inflation: Tenure drives compensation more than performance'
    WHEN ABS(
        performance_tenure_correlation
    ) > 0.5
    AND ABS(salary_tenure_correlation) < 0.3 THEN 'Performance-Driven Culture: Results matter more than time served'
    ELSE 'Hybrid Model: Balanced consideration of experience and performance'
END AS organizational_culture_interpretation
FROM correlation_analysis;

-- ===========================================
-- DEPARTMENT COMPARATIVE ANALYSIS
-- ===========================================

-- Department Performance Matrix: Statistical Comparison
SELECT d.dept_name, COUNT(e.emp_id) AS headcount,

-- Salary Distribution Metrics
ROUND(AVG(e.salary), 0) AS avg_salary,
ROUND(MIN(e.salary), 0) AS min_salary,
ROUND(MAX(e.salary), 0) AS max_salary,
ROUND(STDDEV_POP(e.salary), 0) AS salary_spread,
ROUND(
    MAX(e.salary) / NULLIF(MIN(e.salary), 0),
    2
) AS pay_ratio,

-- Department Quartile Analysis
SUM(
    CASE
        WHEN NTILE(4) OVER (
            ORDER BY e.salary DESC
        ) = 1 THEN 1
        ELSE 0
    END
) AS company_top_quarter_count,
SUM(
    CASE
        WHEN NTILE(4) OVER (
            ORDER BY e.salary DESC
        ) = 4 THEN 1
        ELSE 0
    END
) AS company_bottom_quarter_count,

-- Experience Distribution
ROUND(
    AVG(
        TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
    ),
    1
) AS avg_tenure_years,
ROUND(
    STDDEV_POP(
        TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
    ),
    1
) AS tenure_spread,

-- Comparative Rankings
PERCENT_RANK() OVER (
    ORDER BY AVG(e.salary) DESC
) * 100 AS salary_percentile_rank,
RANK() OVER (
    ORDER BY COUNT(e.emp_id) DESC
) AS headcount_rank,
RANK() OVER (
    ORDER BY AVG(
            TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
        ) DESC
) AS senior_rank,

-- Statistical Outlier Department
CASE
    WHEN AVG(e.salary) > AVG(AVG(e.salary)) OVER () + STDDEV_POP(AVG(e.salary)) OVER () THEN 'High-Salary Outlier'
    WHEN AVG(e.salary) < AVG(AVG(e.salary)) OVER () - STDDEV_POP(AVG(e.salary)) OVER () THEN 'Low-Salary Outlier'
    ELSE 'Within Normal Range'
END AS salary_outlier_status,

-- Department Power Index (salary × experience × headcount)
ROUND(
    AVG(e.salary) * AVG(
        TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
    ) * COUNT(e.emp_id) / 1000000,
    2
) AS department_power_index
FROM department d
    JOIN employee e ON d.dept_id = e.dept_id
GROUP BY
    d.dept_name,
    d.dept_id
ORDER BY department_power_index DESC;

-- ===========================================
-- TRENDING ANALYSIS: Salary Growth Patterns
-- ===========================================

-- Multi-Year Salary Trends Simulation (using performance bonuses)
WITH salary_progression AS (
    SELECT
        emp_id,
        first_name,
        last_name,
        hire_date,
        salary AS current_salary,

-- Projected salary growth based on performance
ROUND(salary * 1.08, 0) AS year1_salary, -- 8% raise
ROUND(salary * 1.08 * 1.07, 0) AS year2_salary, -- +7% on year1
ROUND(
    salary * 1.08 * 1.07 * 1.06,
    0
) AS year3_salary, -- +6% on year2

-- Department context
dept_id

    FROM employee
),
growth_analysis AS (
    SELECT *,
        -- Cumulative growth rates
        ROUND((year1_salary - current_salary) / current_salary * 100, 1) AS year1_growth,
        ROUND((year3_salary - current_salary) / current_salary * 100, 1) AS three_year_growth,

-- Peer comparison
PERCENT_RANK() OVER (PARTITION BY dept_id ORDER BY year3_salary DESC) AS dept_future_salary_rank,
        PERCENT_RANK() OVER (ORDER BY year3_salary DESC) AS company_future_salary_rank

    FROM salary_progression
),
department_growth_summary AS (
    SELECT
        d.dept_name,
        COUNT(ga.emp_id) AS dept_size,

-- Current salary statistics
ROUND(AVG(ga.current_salary), 0) AS current_avg,
ROUND(
    STDDEV_POP(ga.current_salary),
    0
) AS current_std_dev,

-- Projected growth statistics
ROUND(AVG(ga.three_year_growth), 1) AS projected_3yr_growth_pct,
ROUND(MIN(ga.three_year_growth), 1) AS min_projected_growth,
ROUND(MAX(ga.three_year_growth), 1) AS max_projected_growth,

-- Future salary statistics
ROUND(AVG(ga.year3_salary), 0) AS projected_3yr_avg,
ROUND(
    STDDEV_POP(ga.year3_salary),
    0
) AS projected_std_dev,

-- Department growth ranking
PERCENT_RANK() OVER (ORDER BY AVG(ga.three_year_growth) DESC) AS growth_rate_percentile

    FROM growth_analysis ga
    JOIN department d ON ga.dept_id = d.dept_id
    GROUP BY d.dept_name, d.dept_id
)
SELECT *,
    CASE
        WHEN projected_3yr_growth_pct > AVG(projected_3yr_growth_pct) OVER () + 2 THEN 'High-Growth Department'
        WHEN projected_3yr_growth_pct < AVG(projected_3yr_growth_pct) OVER () - 2 THEN 'Slow-Growth Department'
        ELSE 'Average Growth'
    END AS growth_trend_category
FROM department_growth_summary
ORDER BY projected_3yr_growth_pct DESC;

-- ===========================================
-- PREDICTIVE ANALYTICS: Employee Churn Risk
-- ===========================================

-- Churn Risk Scoring Model using Statistical Distributions
WITH employee_churn_factors AS (
    SELECT
        e.*,
        d.dept_name,

-- Tenure-based risk factor
TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS years_tenure,

-- Performance-based risk factor (salary as proxy)
PERCENT_RANK() OVER ( ORDER BY e.salary DESC ) AS salary_percentile,

-- Department stability score
COUNT(*) OVER ( PARTITION BY d.dept_name ) AS dept_stability_score,

-- Age of service distribution
NTILE(3) OVER (
    PARTITION BY
        d.dept_name
    ORDER BY TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) DESC
) AS dept_seniority_tier,

-- Statistical measures for risk scoring
ROUND(AVG(e.salary) OVER () - e.salary, 0) AS salary_deviation_from_mean,
        e.salary - AVG(e.salary) OVER (PARTITION BY d.dept_name) AS salary_deviation_from_dept_avg

    FROM employee e
    JOIN department d ON e.dept_id = d.dept_id
),
churn_risk_model AS (
    SELECT *,
        -- Multi-factor risk scoring algorithm
        (
            -- Tenure risk: New employees more likely to churn
            CASE WHEN years_tenure <= 1 THEN 25 ELSE 0 END +

-- Low performer risk: Bottom quartile salary more likely to churn
CASE WHEN salary_percentile <= 0.25 THEN 20 ELSE 0 END +

-- Department instability: Small departments more volatile
CASE WHEN dept_stability_score <= 2 THEN 15 ELSE 0 END +

-- Statistical outliers: Significantly under-compensated employees
CASE
    WHEN salary_deviation_from_mean < - STDDEV_POP(salary_deviation_from_mean) OVER () THEN 20
    ELSE 0
END +

-- Department pay inequality
CASE WHEN salary_deviation_from_dept_avg < -5000 THEN 15 ELSE 0 END +

-- Newcomer risk in senior departments
CASE WHEN dept_seniority_tier = 3 AND years_tenure <= 2 THEN 10 ELSE 0 END

        ) AS churn_risk_score

    FROM employee_churn_factors
)
SELECT
    first_name,
    last_name,
    dept_name,
    salary,
    years_tenure,
    ROUND(salary_percentile * 100, 1) AS salary_percentile_pct,
    churn_risk_score,

-- Risk categories for HR action
CASE
    WHEN churn_risk_score >= 60 THEN 'CRITICAL: Immediate Retention Risk - Executive Intervention Required'
    WHEN churn_risk_score >= 40 THEN 'HIGH: Elevated Churn Risk - Manager Intervention Recommended'
    WHEN churn_risk_score >= 25 THEN 'MODERATE: Monitor Closely - Proactive Retention Measures'
    WHEN churn_risk_score >= 15 THEN 'LOW: Minimal Risk - Standard Retention Practices'
    ELSE 'VERY LOW: No Immediate Concern - Continue Normal Development'
END AS risk_category,

-- Recommended actions
CASE
    WHEN churn_risk_score >= 60 THEN 'Immediate meeting with executive HR, compensation review, career path discussion'
    WHEN churn_risk_score >= 40 THEN 'Schedule manager one-on-one, review compensation vs peers, discuss growth opportunities'
    WHEN churn_risk_score >= 25 THEN 'Include in retention program, provide development opportunities, check engagement'
    ELSE 'Continue performance management and development planning'
END AS recommended_actions,

-- Statistical significance
CASE
    WHEN ABS(salary_deviation_from_mean) > STDDEV_POP(
        ABS(salary_deviation_from_mean)
    ) OVER () THEN 'Compensation Significantly Below Average'
    WHEN dept_seniority_tier = 1
    AND salary_percentile < 0.5 THEN 'Underperforming in Senior-Expected Role'
    WHEN years_tenure <= 1
    AND dept_name IN ('Administration', 'Finance') THEN 'High-Turnover Department for New Hires'
    ELSE 'Standard Risk Profile'
END AS risk_factors
FROM churn_risk_model
ORDER BY churn_risk_score DESC, salary DESC;