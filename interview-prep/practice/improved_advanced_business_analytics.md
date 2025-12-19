# 🎯 Complex SQL Query Master Class

## Question
Demonstrate advanced SQL techniques by solving a comprehensive business analytics problem that requires multiple complex operations: recursive hierarchies, window functions, conditional aggregations, and advanced JOIN patterns.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    department VARCHAR(30),
    salary DECIMAL(10,2),
    hire_date DATE
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    emp_id INT,
    sale_date DATE,
    amount DECIMAL(10,2),
    product_category VARCHAR(30)
);

CREATE TABLE departments (
    dept_id VARCHAR(10) PRIMARY KEY,
    dept_name VARCHAR(50),
    budget DECIMAL(12,2)
);

INSERT INTO employees VALUES
(1, 'Alice CEO', NULL, 'EXEC', 250000.00, '2020-01-01'),
(2, 'Bob VP', 1, 'ENG', 180000.00, '2020-02-01'),
(3, 'Carol VP', 1, 'SALES', 175000.00, '2020-03-01'),
(4, 'David Mgr', 2, 'ENG', 120000.00, '2021-01-15'),
(5, 'Eve Mgr', 2, 'ENG', 115000.00, '2021-02-01'),
(6, 'Frank Dev', 4, 'ENG', 95000.00, '2021-06-01'),
(7, 'Grace Dev', 4, 'ENG', 90000.00, '2021-07-01'),
(8, 'Henry Sales', 3, 'SALES', 85000.00, '2021-03-15');

INSERT INTO sales VALUES
(101, 6, '2024-01-15', 5000.00, 'Software'),
(102, 6, '2024-02-20', 7500.00, 'Software'),
(103, 7, '2024-01-25', 6200.00, 'Software'),
(104, 8, '2024-02-10', 8500.00, 'Hardware'),
(105, 8, '2024-03-05', 9200.00, 'Hardware'),
(106, 6, '2024-03-15', 6800.00, 'Software');

INSERT INTO departments VALUES
('ENG', 'Engineering', 500000.00),
('SALES', 'Sales', 300000.00),
('EXEC', 'Executive', 100000.00);
```

## Complex Query 1: Hierarchical Sales Performance with Running Totals

```sql
WITH RECURSIVE emp_hierarchy AS (
    -- Base: Top-level executives
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        department,
        salary,
        0 AS hierarchy_level,
        CAST(emp_name AS VARCHAR(1000)) AS management_chain
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: All subordinates
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.department,
        e.salary,
        eh.hierarchy_level + 1,
        CONCAT(eh.management_chain, ' → ', e.emp_name)
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.emp_id
),
sales_summary AS (
    SELECT 
        s.emp_id,
        YEAR(s.sale_date) AS sale_year,
        MONTH(s.sale_date) AS sale_month,
        SUM(s.amount) AS monthly_sales,
        COUNT(*) AS transaction_count
    FROM sales s
    GROUP BY s.emp_id, YEAR(s.sale_date), MONTH(s.sale_date)
),
comprehensive_report AS (
    SELECT 
        eh.*,
        ss.sale_year,
        ss.sale_month,
        COALESCE(ss.monthly_sales, 0) AS monthly_sales,
        COALESCE(ss.transaction_count, 0) AS transaction_count,
        
        -- Running total by employee
        SUM(COALESCE(ss.monthly_sales, 0)) OVER (
            PARTITION BY eh.emp_id 
            ORDER BY ss.sale_year, ss.sale_month
        ) AS employee_running_total,
        
        -- Department running total
        SUM(COALESCE(ss.monthly_sales, 0)) OVER (
            PARTITION BY eh.department 
            ORDER BY ss.sale_year, ss.sale_month
        ) AS dept_running_total,
        
        -- Rank within department by monthly sales
        DENSE_RANK() OVER (
            PARTITION BY eh.department, ss.sale_year, ss.sale_month 
            ORDER BY COALESCE(ss.monthly_sales, 0) DESC
        ) AS monthly_dept_rank
        
    FROM emp_hierarchy eh
    LEFT JOIN sales_summary ss ON eh.emp_id = ss.emp_id
)
SELECT 
    emp_name,
    department,
    hierarchy_level,
    management_chain,
    sale_year,
    sale_month,
    monthly_sales,
    employee_running_total,
    dept_running_total,
    monthly_dept_rank,
    
    -- Performance category
    CASE 
        WHEN monthly_sales > 8000 THEN 'High Performer'
        WHEN monthly_sales > 6000 THEN 'Good Performer'
        WHEN monthly_sales > 0 THEN 'Developing'
        ELSE 'No Sales'
    END AS performance_category
    
FROM comprehensive_report
WHERE sale_year IS NOT NULL  -- Only show months with data
ORDER BY department, hierarchy_level, emp_name, sale_year, sale_month;
```

**How it works**: Combines recursive CTE for hierarchy, window functions for running totals, and complex JOINs with aggregations.

## Complex Query 2: Multi-Level Performance Analytics with Conditional Aggregations

```sql
WITH quarterly_sales AS (
    SELECT 
        s.emp_id,
        YEAR(s.sale_date) AS sale_year,
        QUARTER(s.sale_date) AS sale_quarter,
        SUM(s.amount) AS quarterly_sales,
        COUNT(*) AS quarterly_transactions,
        COUNT(DISTINCT s.product_category) AS categories_sold
    FROM sales s
    GROUP BY s.emp_id, YEAR(s.sale_date), QUARTER(s.sale_date)
),
performance_metrics AS (
    SELECT 
        qs.*,
        e.emp_name,
        e.department,
        e.salary,
        
        -- Year-over-year growth
        LAG(qs.quarterly_sales) OVER (
            PARTITION BY qs.emp_id 
            ORDER BY qs.sale_year, qs.sale_quarter
        ) AS prev_quarter_sales,
        
        -- Department average
        AVG(qs.quarterly_sales) OVER (
            PARTITION BY e.department, qs.sale_year, qs.sale_quarter
        ) AS dept_avg_quarterly,
        
        -- Company total
        SUM(qs.quarterly_sales) OVER (
            PARTITION BY qs.sale_year, qs.sale_quarter
        ) AS company_quarterly_total
        
    FROM quarterly_sales qs
    JOIN employees e ON qs.emp_id = e.emp_id
)
SELECT 
    emp_name,
    department,
    salary,
    sale_year,
    sale_quarter,
    quarterly_sales,
    quarterly_transactions,
    categories_sold,
    
    -- Growth calculation
    CASE 
        WHEN prev_quarter_sales > 0 
        THEN ROUND(((quarterly_sales - prev_quarter_sales) / prev_quarter_sales) * 100, 2)
        ELSE NULL
    END AS qoq_growth_percent,
    
    -- Performance vs department
    CASE 
        WHEN quarterly_sales > dept_avg_quarterly THEN 'Above Dept Avg'
        WHEN quarterly_sales = dept_avg_quarterly THEN 'At Dept Avg'
        ELSE 'Below Dept Avg'
    END AS dept_performance,
    
    -- Market share
    ROUND((quarterly_sales / company_quarterly_total) * 100, 2) AS company_market_share,
    
    -- Bonus eligibility (conditional logic)
    CASE 
        WHEN quarterly_sales > 7000 AND categories_sold >= 2 THEN 'Full Bonus'
        WHEN quarterly_sales > 5000 AND categories_sold >= 1 THEN 'Half Bonus'
        ELSE 'No Bonus'
    END AS bonus_eligibility
    
FROM performance_metrics
ORDER BY sale_year DESC, sale_quarter DESC, quarterly_sales DESC;
```

**How it works**: Complex window functions with multiple partitioning, conditional aggregations, and business logic calculations.

## Complex Query 3: Advanced Cross-Department Analytics

```sql
WITH dept_performance AS (
    SELECT 
        e.department,
        d.dept_name,
        COUNT(DISTINCT e.emp_id) AS employee_count,
        SUM(e.salary) AS total_salary_cost,
        AVG(e.salary) AS avg_salary,
        SUM(s.amount) AS total_dept_sales,
        COUNT(s.sale_id) AS total_dept_transactions
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.department
    LEFT JOIN sales s ON e.emp_id = s.emp_id 
        AND YEAR(s.sale_date) = 2024
    GROUP BY e.department, d.dept_id, d.dept_name
),
ranked_departments AS (
    SELECT 
        *,
        DENSE_RANK() OVER (ORDER BY total_dept_sales DESC) AS sales_rank,
        DENSE_RANK() OVER (ORDER BY total_dept_sales / NULLIF(employee_count, 0) DESC) AS sales_per_employee_rank,
        SUM(total_dept_sales) OVER () AS company_total_sales,
        SUM(total_salary_cost) OVER () AS company_total_salary
    FROM dept_performance
)
SELECT 
    dept_name,
    employee_count,
    ROUND(total_salary_cost, 2) AS total_salary_cost,
    ROUND(avg_salary, 2) AS avg_salary,
    ROUND(total_dept_sales, 2) AS total_dept_sales,
    total_dept_transactions,
    
    -- Productivity metrics
    ROUND(total_dept_sales / NULLIF(employee_count, 0), 2) AS sales_per_employee,
    ROUND(total_dept_transactions / NULLIF(employee_count, 0), 2) AS transactions_per_employee,
    
    -- Rankings
    sales_rank,
    sales_per_employee_rank,
    
    -- Company contribution
    ROUND((total_dept_sales / company_total_sales) * 100, 2) AS sales_contribution_pct,
    ROUND((total_salary_cost / company_total_salary) * 100, 2) AS salary_cost_pct,
    
    -- ROI calculation
    CASE 
        WHEN total_salary_cost > 0 
        THEN ROUND((total_dept_sales / total_salary_cost), 2)
        ELSE 0
    END AS sales_to_salary_ratio
    
FROM ranked_departments
ORDER BY sales_rank;
```

**How it works**: Multi-table analytics with complex aggregations, rankings, and business KPI calculations.

## Performance Optimization Techniques

1. **Composite Indexes**: 
   ```sql
   CREATE INDEX idx_emp_dept_mgr ON employees(department, manager_id);
   CREATE INDEX idx_sales_emp_date ON sales(emp_id, sale_date);
   ```

2. **Query Execution Plan Analysis**:
   - Check for proper index usage
   - Monitor temporary table creation
   - Optimize window function performance

3. **Materialized Views for Complex Aggregations**:
   ```sql
   CREATE MATERIALIZED VIEW monthly_dept_performance AS
   SELECT ... FROM complex_query_above;
   ```

## Interview Tips

- **Break down complexity**: Explain each CTE/window function separately
- **Performance awareness**: Discuss optimization strategies
- **Business context**: Connect technical solution to business needs
- **Alternative approaches**: Compare CTE vs subqueries vs temp tables
- **Scalability**: How query performs with larger datasets

## Real-World Applications

- **Executive dashboards**: Complex KPI calculations
- **Performance analytics**: Multi-level organizational metrics
- **Sales forecasting**: Trend analysis with hierarchical data
- **Financial reporting**: Complex aggregations with business rules

## Key SQL Concepts Demonstrated

- **Recursive CTEs**: Hierarchical data processing
- **Advanced Window Functions**: Multiple partitioning and ordering
- **Complex JOINs**: Multi-table relationships
- **Conditional Aggregations**: Business logic in SQL
- **Performance Optimization**: Indexing and query tuning
- **Data Analysis**: KPI calculations and rankings
