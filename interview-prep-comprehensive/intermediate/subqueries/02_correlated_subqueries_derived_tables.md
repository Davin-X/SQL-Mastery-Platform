# Problem 02: Correlated Subqueries and Derived Tables

## Business Context
Correlated subqueries and derived tables enable complex analytical queries that reference outer query data and create temporary result sets. These advanced SQL constructs are essential for sophisticated reporting, ranking within groups, and multi-level aggregations that traditional JOINs cannot easily achieve.

## Requirements
Write SQL queries using correlated subqueries and derived tables to solve complex business analysis problems involving intra-group comparisons, running calculations, and hierarchical aggregations.

## Sample Data Setup
```sql
-- Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    dept_id INT,
    hire_date DATE NOT NULL,
    manager_id INT
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12, 2) NOT NULL
);

CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending'
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(20) DEFAULT 'Standard'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    base_price DECIMAL(8, 2) NOT NULL
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert sample data
INSERT INTO departments (dept_id, dept_name, budget) VALUES
(1, 'IT', 500000.00),
(2, 'Sales', 750000.00),
(3, 'HR', 300000.00),
(4, 'Finance', 600000.00);

INSERT INTO employees (emp_id, first_name, last_name, salary, dept_id, hire_date, manager_id) VALUES
(1, 'John', 'Doe', 75000.00, 1, '2020-01-15', NULL),
(2, 'Jane', 'Smith', 80000.00, 1, '2019-03-20', 1),
(3, 'Bob', 'Wilson', 72000.00, 1, '2021-06-10', 1),
(4, 'Alice', 'Brown', 65000.00, 2, '2018-11-05', NULL),
(5, 'Charlie', 'Davis', 75000.00, 2, '2020-08-15', 4),
(6, 'Diana', 'Evans', 72000.00, 2, '2019-12-01', 4),
(7, 'Eve', 'Foster', 55000.00, 3, '2022-02-20', NULL),
(8, 'Frank', 'Garcia', 60000.00, 3, '2021-08-10', 7),
(9, 'Grace', 'Hill', 85000.00, 4, '2017-09-10', NULL),
(10, 'Henry', 'Adams', 78000.00, 4, '2019-05-25', 9);

INSERT INTO customers (customer_id, customer_name, region, customer_segment) VALUES
(1, 'TechCorp', 'North', 'Enterprise'),
(2, 'DataSys', 'South', 'Enterprise'),
(3, 'WebFlow', 'East', 'Standard'),
(4, 'CloudNet', 'West', 'Standard'),
(5, 'InnovateIT', 'North', 'Enterprise'),
(6, 'DevTools', 'South', 'Standard'),
(7, 'CodeMasters', 'East', 'Standard'),
(8, 'DataFlow', 'West', 'Enterprise');

INSERT INTO products (product_id, product_name, category, base_price) VALUES
(1, 'Laptop Pro', 'Hardware', 1200.00),
(2, 'Software Suite', 'Software', 500.00),
(3, 'Cloud Storage', 'Services', 100.00),
(4, 'Monitor 4K', 'Hardware', 400.00),
(5, 'Keyboard Wireless', 'Hardware', 80.00),
(6, 'Consulting Services', 'Services', 200.00),
(7, 'Training Package', 'Services', 150.00),
(8, 'Support Contract', 'Services', 300.00);

INSERT INTO sales_orders (order_id, customer_id, salesperson_id, order_date, total_amount, status) VALUES
(1, 1, 5, '2024-01-15', 2400.00, 'Completed'),
(2, 2, 6, '2024-01-20', 900.00, 'Completed'),
(3, 3, 5, '2024-02-01', 1280.00, 'Completed'),
(4, 4, 6, '2024-02-10', 400.00, 'Completed'),
(5, 5, 5, '2024-02-15', 2000.00, 'Completed'),
(6, 6, 6, '2024-03-01', 750.00, 'Completed'),
(7, 7, 5, '2024-03-05', 300.00, 'Pending'),
(8, 8, 6, '2024-03-10', 1800.00, 'Completed'),
(9, 1, 5, '2024-03-15', 1600.00, 'Shipped'),
(10, 3, 6, '2024-03-20', 600.00, 'Completed');

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 2, 1200.00, 0.00),
(2, 2, 2, 1, 500.00, 100.00),
(3, 2, 3, 2, 100.00, 0.00),
(4, 3, 1, 1, 1200.00, 0.00),
(5, 3, 4, 1, 400.00, 80.00),
(6, 4, 5, 5, 80.00, 0.00),
(7, 5, 6, 10, 200.00, 0.00),
(8, 6, 7, 5, 150.00, 0.00),
(9, 8, 8, 6, 300.00, 0.00),
(10, 9, 2, 2, 500.00, 200.00),
(11, 9, 4, 1, 400.00, 100.00),
(12, 10, 3, 6, 100.00, 0.00);
```

## Query Requirements

### Query 1: Employees with above-average performance in their department (correlated subquery)
```sql
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary,
    dept_avg.avg_salary AS dept_avg_salary,
    e.salary - dept_avg.avg_salary AS above_avg_amount
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN (
    SELECT 
        dept_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) dept_avg ON e.dept_id = dept_avg.dept_id
WHERE e.salary > (
    SELECT AVG(salary) 
    FROM employees e2 
    WHERE e2.dept_id = e.dept_id
)
ORDER BY e.salary DESC;
```

**Expected Result:**
| emp_id | first_name | last_name | dept_name | salary   | dept_avg_salary | above_avg_amount |
|--------|------------|-----------|-----------|----------|-----------------|------------------|
| 9      | Grace      | Hill      | Finance   | 85000.00 | 81500.00        | 3500.00          |
| 2      | Jane       | Smith     | IT        | 80000.00 | 75666.67        | 4333.33          |
| 5      | Charlie    | Davis     | Sales     | 75000.00 | 70666.67        | 4333.33          |

### Query 2: Top salesperson per region using derived table
```sql
SELECT 
    salesperson_info.region,
    salesperson_info.first_name,
    salesperson_info.last_name,
    salesperson_info.total_sales,
    salesperson_info.sales_rank_in_region
FROM (
    SELECT 
        c.region,
        e.first_name,
        e.last_name,
        SUM(so.total_amount) AS total_sales,
        RANK() OVER (
            PARTITION BY c.region 
            ORDER BY SUM(so.total_amount) DESC
        ) AS sales_rank_in_region
    FROM sales_orders so
    INNER JOIN customers c ON so.customer_id = c.customer_id
    INNER JOIN employees e ON so.salesperson_id = e.emp_id
    WHERE so.status = 'Completed'
    GROUP BY c.region, e.first_name, e.last_name, e.emp_id
) salesperson_info
WHERE salesperson_info.sales_rank_in_region = 1
ORDER BY salesperson_info.total_sales DESC;
```

**Expected Result:**
| region | first_name | last_name | total_sales | sales_rank_in_region |
|--------|------------|-----------|-------------|----------------------|
| North  | Charlie    | Davis     | 6000.00     | 1                    |
| South  | Diana      | Evans     | 1650.00     | 1                    |
| East   | Charlie    | Davis     | 1280.00     | 1                    |
| West   | Diana      | Evans     | 2200.00     | 1                    |

### Query 3: Customer order frequency ranking with correlated subquery
```sql
SELECT 
    c.customer_name,
    c.region,
    order_counts.total_orders,
    order_counts.avg_order_value,
    (
        SELECT COUNT(*) 
        FROM customers c2 
        WHERE (
            SELECT COUNT(*) 
            FROM sales_orders so2 
            WHERE so2.customer_id = c2.customer_id 
            AND so2.status = 'Completed'
        ) > order_counts.total_orders
    ) + 1 AS order_frequency_rank
FROM customers c
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        AVG(total_amount) AS avg_order_value
    FROM sales_orders
    WHERE status = 'Completed'
    GROUP BY customer_id
) order_counts ON c.customer_id = order_counts.customer_id
ORDER BY order_counts.total_orders DESC NULLS LAST, c.customer_name;
```

**Expected Result:**
| customer_name | region | total_orders | avg_order_value | order_frequency_rank |
|---------------|--------|--------------|-----------------|----------------------|
| TechCorp      | North  | 1            | 2400.00         | 2                    |
| WebFlow       | East   | 1            | 1280.00         | 2                    |
| InnovateIT    | North  | 1            | 2000.00         | 2                    |
| CloudNet      | West   | 1            | 400.00          | 2                    |
| DevTools      | South  | 1            | 750.00          | 2                    |
| DataFlow      | West   | 1            | 1800.00         | 2                    |
| DataSys       | South  | 1            | 900.00          | 2                    |
| CodeMasters   | East   |              |                 | 8                    |

### Query 4: Product performance vs category average using correlated subquery
```sql
SELECT 
    p.product_name,
    p.category,
    product_stats.total_sold,
    product_stats.total_revenue,
    category_avg.avg_category_revenue,
    product_stats.total_revenue - category_avg.avg_category_revenue AS vs_category_avg,
    CASE 
        WHEN product_stats.total_revenue > category_avg.avg_category_revenue THEN 'Above Average'
        WHEN product_stats.total_revenue < category_avg.avg_category_revenue THEN 'Below Average'
        ELSE 'At Average'
    END AS performance_vs_category
FROM products p
LEFT JOIN (
    SELECT 
        product_id,
        SUM(oi.quantity) AS total_sold,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_revenue
    FROM order_items oi
    INNER JOIN sales_orders so ON oi.order_id = so.order_id AND so.status = 'Completed'
    GROUP BY product_id
) product_stats ON p.product_id = product_stats.product_id
LEFT JOIN (
    SELECT 
        category,
        AVG(product_revenue.total_revenue) AS avg_category_revenue
    FROM (
        SELECT 
            p2.category,
            p2.product_id,
            COALESCE(SUM(oi2.quantity * oi2.unit_price * (1 - oi2.discount/100)), 0) AS total_revenue
        FROM products p2
        LEFT JOIN order_items oi2 ON p2.product_id = oi2.product_id
        LEFT JOIN sales_orders so2 ON oi2.order_id = so2.order_id AND so2.status = 'Completed'
        GROUP BY p2.category, p2.product_id
    ) product_revenue
    GROUP BY category
) category_avg ON p.category = category_avg.category
ORDER BY p.category, product_stats.total_revenue DESC NULLS LAST;
```

**Expected Result:**
| product_name    | category  | total_sold | total_revenue | avg_category_revenue | vs_category_avg | performance_vs_category |
|-----------------|-----------|------------|---------------|----------------------|-----------------|------------------------|
| Laptop Pro      | Hardware | 3          | 3600.00       | 2000.00             | 1600.00         | Above Average          |
| Monitor 4K      | Hardware | 2          | 720.00        | 2000.00             | -1280.00        | Below Average          |
| Keyboard Wireless| Hardware | 5          | 400.00        | 2000.00             | -1600.00        | Below Average          |
| Software Suite  | Software | 3          | 800.00        | 800.00              | 0.00            | At Average             |
| Support Contract| Services | 6          | 1800.00       | 1375.00             | 425.00           | Above Average          |
| Consulting Services| Services | 10      | 2000.00       | 1375.00             | 625.00           | Above Average          |
| Training Package| Services | 5          | 750.00        | 1375.00             | -625.00          | Below Average          |
| Cloud Storage   | Services | 8          | 800.00        | 1375.00             | -575.00          | Below Average          |

### Query 5: Department budget utilization with nested derived tables
```sql
SELECT 
    dept_analysis.dept_name,
    dept_analysis.total_employees,
    dept_analysis.total_salary_budget,
    dept_analysis.budget_utilization_pct,
    dept_analysis.budget_rank,
    CASE 
        WHEN dept_analysis.budget_utilization_pct > 80 THEN 'High Utilization'
        WHEN dept_analysis.budget_utilization_pct > 60 THEN 'Moderate Utilization'
        ELSE 'Low Utilization'
    END AS utilization_category
FROM (
    SELECT 
        d.dept_name,
        emp_count.total_employees,
        emp_count.total_salary_budget,
        d.budget AS dept_budget,
        ROUND((emp_count.total_salary_budget / d.budget) * 100, 2) AS budget_utilization_pct,
        RANK() OVER (ORDER BY emp_count.total_salary_budget DESC) AS budget_rank
    FROM departments d
    LEFT JOIN (
        SELECT 
            dept_id,
            COUNT(*) AS total_employees,
            SUM(salary) AS total_salary_budget
        FROM employees
        GROUP BY dept_id
    ) emp_count ON d.dept_id = emp_count.dept_id
) dept_analysis
ORDER BY dept_analysis.total_salary_budget DESC NULLS LAST;
```

**Expected Result:**
| dept_name | total_employees | total_salary_budget | budget_utilization_pct | budget_rank | utilization_category |
|-----------|-----------------|---------------------|-----------------------|-------------|---------------------|
| Finance   | 2               | 163000.00           | 27.17                 | 1           | Low Utilization     |
| IT        | 3               | 227000.00           | 45.40                 | 2           | Low Utilization     |
| Sales     | 3               | 212000.00           | 28.27                 | 3           | Low Utilization     |
| HR        | 2               | 115000.00           | 38.33                 | 4           | Low Utilization     |

### Query 6: Customer lifetime value analysis using correlated subquery ranking
```sql
SELECT 
    c.customer_name,
    c.region,
    customer_metrics.total_orders,
    customer_metrics.total_spent,
    customer_metrics.avg_order_value,
    customer_metrics.customer_rank,
    CASE 
        WHEN customer_metrics.customer_rank <= (
            SELECT COUNT(*) * 0.2 FROM customers
        ) THEN 'Top 20%'
        WHEN customer_metrics.customer_rank <= (
            SELECT COUNT(*) * 0.5 FROM customers
        ) THEN 'Top 50%'
        ELSE 'Bottom 50%'
    END AS percentile_group
FROM customers c
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(so.order_id) AS total_orders,
        SUM(so.total_amount) AS total_spent,
        ROUND(AVG(so.total_amount), 2) AS avg_order_value,
        RANK() OVER (ORDER BY SUM(so.total_amount) DESC) AS customer_rank
    FROM sales_orders so
    WHERE so.status = 'Completed'
    GROUP BY customer_id
) customer_metrics ON c.customer_id = customer_metrics.customer_id
ORDER BY customer_metrics.total_spent DESC NULLS LAST, c.customer_name;
```

**Expected Result:**
| customer_name | region | total_orders | total_spent | avg_order_value | customer_rank | percentile_group |
|---------------|--------|--------------|-------------|-----------------|---------------|-----------------|
| TechCorp      | North  | 1            | 2400.00     | 2400.00         | 1             | Top 20%         |
| InnovateIT    | North  | 1            | 2000.00     | 2000.00         | 2             | Top 20%         |
| DataFlow      | West   | 1            | 1800.00     | 1800.00         | 3             | Top 50%         |
| WebFlow       | East   | 1            | 1280.00     | 1280.00         | 4             | Top 50%         |
| DataSys       | South  | 1            | 900.00      | 900.00          | 5             | Bottom 50%      |
| DevTools      | South  | 1            | 750.00      | 750.00          | 6             | Bottom 50%      |
| CloudNet      | West   | 1            | 400.00      | 400.00          | 7             | Bottom 50%      |
| CodeMasters   | East   |              |             |                 |               |                 |

## Key Learning Points
- **Correlated subqueries**: Reference outer query columns
- **Derived tables**: Subqueries in FROM clause as virtual tables
- **Complex nesting**: Multi-level subquery structures
- **Performance implications**: When correlation affects execution
- **Readability trade-offs**: Derived tables vs complex joins

## Common Correlated Subquery Applications
- **Intra-group comparisons**: Compare against group aggregates
- **Conditional filtering**: Row-by-row validation logic
- **Ranking within groups**: Custom ranking algorithms
- **Existence with conditions**: Complex relationship checks

## Performance Notes
- Correlated subqueries execute once per outer row
- Derived tables can be more efficient for complex aggregations
- Consider window functions as alternatives to correlated subqueries
- Derived tables are often optimized better than correlated subqueries

## Extension Challenge
Create a comprehensive sales performance dashboard that combines correlated subqueries, derived tables, and window functions to analyze salesperson performance, customer segmentation, product profitability, and regional trends across multiple dimensions.
