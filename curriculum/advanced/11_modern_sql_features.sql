-- 11_modern_sql_features.sql
-- MASTER CLASS: Modern SQL Features — JSON, Arrays, Full-Text Search, Time Series, Graph Queries

USE sample_hr;

-- ===========================================
-- MYSQL VERSION - ADVANCED JSON OPERATIONS
-- ===========================================

USE sample_hr;

-- Create sophisticated JSON storage for employee analytics data
DROP TABLE IF EXISTS employee_analytics;

CREATE TABLE employee_analytics (
    emp_id INT PRIMARY KEY,
    performance_data JSON,
    skills_matrix JSON,
    time_series_metrics JSON, -- Store monthly metrics
    social_graph JSON, -- Store relationships and networks
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- Insert rich JSON performance data
INSERT INTO
    employee_analytics (
        emp_id,
        performance_data,
        skills_matrix,
        time_series_metrics,
        social_graph
    )
VALUES (
        3,
        '{
    "quarterly_ratings": [4.2, 4.5, 4.7, 4.8],
    "goals_achieved": 95,
    "impact_score": 4.6,
    "peer_reviews": [
        {"reviewer": "John Doe", "rating": 4.8, "comments": "Exceptional leadership"},
        {"reviewer": "Jane Smith", "rating": 4.5, "comments": "Strong mentor"}
    ],
    "development_areas": ["Strategic Planning", "Data Science"]
}',
        '{
    "technical": {"SQL": 5, "Python": 4, "AWS": 4, "Salesforce": 5},
    "soft_skills": {"leadership": 5, "communication": 4, "mentoring": 5},
    "business": {"strategy": 4, "analytics": 4, "domain_expertise": 5}
}',
        '{
    "2024-01": {"productivity": 95, "quality": 4.2, "engagement": 85},
    "2024-02": {"productivity": 98, "quality": 4.5, "engagement": 90},
    "2024-03": {"productivity": 96, "quality": 4.6, "engagement": 92}
}',
        '{
    "collaborators": ["Sarah Williams", "Michael Johnson", "David Brown"],
    "mentorees": ["Karen Martin", "Lisa Davis"],
    "influence_network": ["VP Sales", "Director Analytics"]
}'
    ),
    (
        6,
        '{
    "quarterly_ratings": [4.8, 4.9, 4.6, 4.9],
    "goals_achieved": 98,
    "impact_score": 4.9,
    "peer_reviews": [
        {"reviewer": "Adam Wilson", "rating": 4.9, "comments": "Technical excellence"},
        {"reviewer": "Rachel Lee", "rating": 4.7, "comments": "Innovation leader"}
    ],
    "competencies": ["System Architecture", "Cloud Migration", "DevOps"]
}',
        '{
    "technical": {"Python": 5, "AWS": 5, "Docker": 5, "JavaScript": 4, "SQL": 4},
    "soft_skills": {"problem_solving": 5, "innovation": 5, "collaboration": 4},
    "business": {"technical_strategy": 5, "cost_optimization": 5, "risk_management": 4}
}',
        '{
    "2024-01": {"productivity": 99, "quality": 4.8, "engagement": 95},
    "2024-02": {"productivity": 97, "quality": 4.9, "engagement": 94},
    "2024-03": {"productivity": 98, "quality": 4.7, "engagement": 96}
}',
        '{
    "collaborators": ["Jennifer Wilson", "Robert Miller", "Patricia Thomas"],
    "mentorees": ["Charles Harris"],
    "innovation_partners": ["IT Director", "Product Manager", "Data Team"]
}'
    );

-- Advanced JSON Querying: Extract nested performance data
SELECT
    e.first_name,
    e.last_name,
    JSON_EXTRACT(
        ea.performance_data,
        '$.impact_score'
    ) AS impact_score,
    JSON_EXTRACT(
        ea.performance_data,
        '$.goals_achieved'
    ) AS goals_achieved,
    JSON_LENGTH(
        JSON_EXTRACT(
            ea.performance_data,
            '$.quarterly_ratings'
        )
    ) AS rating_count,
    JSON_EXTRACT(
        ea.performance_data,
        '$.quarterly_ratings[0]'
    ) AS latest_quarter_rating,
    ROUND(
        AVG(
            JSON_EXTRACT_DOUBLE (
                ea.performance_data,
                CONCAT(
                    '$.quarterly_ratings[',
                    num,
                    ']'
                )
            )
        ),
        2
    ) AS avg_quarterly_rating
FROM
    employee e
    JOIN employee_analytics ea ON e.emp_id = ea.emp_id
    CROSS JOIN (
        SELECT 0 AS num
        UNION
        SELECT 1
        UNION
        SELECT 2
        UNION
        SELECT 3
    ) numbers
GROUP BY
    e.emp_id,
    e.first_name,
    e.last_name,
    ea.performance_data;

-- JSON Table Unnesting: Extract skills and proficiency levels
SELECT e.first_name, e.last_name, skill_data.skill_category, skill_data.skill_name, skill_data.proficiency
FROM
    employee e
    JOIN employee_analytics ea ON e.emp_id = ea.emp_id
    CROSS JOIN JSON_TABLE(
        JSON_KEYS(ea.skills_matrix),
        '$[*]' COLUMNS (
            skill_category VARCHAR(50) PATH '$'
        )
    ) cats
    CROSS JOIN JSON_TABLE(
        JSON_EXTRACT(
            ea.skills_matrix,
            CONCAT('$.', cats.skill_category)
        ),
        '$.*' COLUMNS (
            skill_name VARCHAR(50) PATH '$.name',
            proficiency INT PATH '$.level'
        )
    ) skill_data
WHERE
    skill_data.proficiency >= 4
ORDER BY e.first_name, skill_data.proficiency DESC;

-- ===========================================
-- FULL-TEXT SEARCH & SEMANTIC SEARCH (MySQL, PostgreSQL)
-- ===========================================

-- Create advanced full-text search table for employee knowledge base
DROP TABLE IF EXISTS employee_knowledge;

CREATE TABLE employee_knowledge (
    emp_id INT,
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200),
    content TEXT,
    tags JSON, -- Store searchable tags as JSON array
    document_type ENUM(
        'project_doc',
        'research',
        'meeting_notes',
        'presentation',
        'code_sample'
    ),
    access_level ENUM(
        'public',
        'internal',
        'confidential'
    ),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FULLTEXT ft_content (title, content),
    FULLTEXT ft_tags (tags),
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- Insert comprehensive knowledge base entries
INSERT INTO
    employee_knowledge (
        emp_id,
        title,
        content,
        tags,
        document_type,
        access_level
    )
VALUES (
        3,
        'Q4 Sales Strategy 2024',
        '
Comprehensive Q4 sales strategy focusing on enterprise client acquisition.
Key highlights:
- Identified 150 high-value enterprise prospects
- Implemented predictive analytics for lead scoring
- Automated follow-up sequences resulting in 35% conversion increase
- Revenue forecast: $2.8M for Q4
- Team expansion plan for Q1 2025',
        '["sales", "strategy", "enterprise", "forecasting", "analytics"]',
        'project_doc',
        'internal'
    ),
    (
        6,
        'Cloud Migration Framework',
        '
Enterprise cloud migration framework and best practices.
Technical approach:
- Assessment phase: Current infrastructure analysis
- Migration strategies: Lift-and-shift vs re-architecting
- Cost optimization: Reserved instances and spot instances
- Security considerations: Zero-trust architecture
- Monitoring and alerting with CloudWatch
- Disaster recovery implementation
Code samples included in appendices.',
        '["cloud", "migration", "aws", "architecture", "devops", "monitoring"]',
        'code_sample',
        'internal'
    ),
    (
        11,
        'Financial Optimization Report',
        '
Analysis of cost reduction opportunities across IT operations.
Key findings:
- Identified $2.1M annual savings in cloud infrastructure
- Recommended migration from on-premises servers
- Analysis of software license utilization (45% underutilized)
- Proposed vendor consolidation reducing contract overhead by 20%
- ROI projections for automation initiatives',
        '["finance", "optimization", "cost_savings", "roi", "analysis"]',
        'research',
        'confidential'
    );

-- Advanced Full-Text Search with relevance scoring
SELECT
    e.first_name,
    e.last_name,
    ek.title,
    ek.document_type,
    ek.access_level,
    MATCH(ek.title, ek.content) AGAINST (
        'cloud migration strategy' IN NATURAL LANGUAGE MODE
    ) AS title_content_score,
    MATCH(ek.tags) AGAINST (
        '"cloud" "strategy"' IN BOOLEAN MODE
    ) AS tag_score,
    (
        MATCH(ek.title, ek.content) AGAINST (
            'cloud migration strategy' IN NATURAL LANGUAGE MODE
        ) + MATCH(ek.tags) AGAINST (
            '"cloud" "strategy"' IN BOOLEAN MODE
        )
    ) / 2 AS combined_score
FROM
    employee_knowledge ek
    JOIN employee e ON ek.emp_id = e.emp_id
WHERE
    MATCH(ek.title, ek.content) AGAINST (
        'cloud OR migration OR strategy' IN BOOLEAN MODE
    )
ORDER BY combined_score DESC;

-- Semantic search using query expansion
CREATE TABLE search_synonyms (
    keyword VARCHAR(50) PRIMARY KEY,
    synonyms JSON
);

INSERT INTO
    search_synonyms
VALUES (
        'database',
        '["sql", "data", "storage", "rdbms", "warehouse"]'
    ),
    (
        'cloud',
        '["aws", "azure", "gcp", "infrastructure", "hosting"]'
    );

SELECT DISTINCT
    ek.title,
    ek.content,
    'database' as searched_for,
    MATCH(ek.content) AGAINST (
        (
            SELECT GROUP_CONCAT(
                    JSON_UNQUOTE(
                        JSON_EXTRACT(
                            synonyms, CONCAT('$[', nums.n, ']')
                        )
                    )
                ) AS syns
            FROM search_synonyms ss
                CROSS JOIN (
                    SELECT 0 n
                    UNION
                    SELECT 1
                    UNION
                    SELECT 2
                    UNION
                    SELECT 3
                    UNION
                    SELECT 4
                ) nums
            WHERE
                keyword = 'database'
                AND JSON_EXTRACT(
                    synonyms,
                    CONCAT('$[', nums.n, ']')
                ) IS NOT NULL
        ) IN BOOLEAN MODE
    ) AS relevance
FROM employee_knowledge ek
WHERE
    MATCH(ek.content) AGAINST (
        (
            SELECT GROUP_CONCAT(
                    JSON_UNQUOTE(
                        JSON_EXTRACT(
                            synonyms, CONCAT('$[', nums.n, ']')
                        )
                    )
                ) AS syns
            FROM search_synonyms ss
                CROSS JOIN (
                    SELECT 0 n
                    UNION
                    SELECT 1
                    UNION
                    SELECT 2
                    UNION
                    SELECT 3
                    UNION
                    SELECT 4
                ) nums
            WHERE
                keyword = STUFF
                AND JSON_EXTRACT(
                    synonyms,
                    CONCAT('$[', nums.n, ']')
                ) IS NOT NULL
        ) IN BOOLEAN MODE
    ) > 0
ORDER BY relevance DESC;

-- ===========================================
-- VALUES CONSTRUCTOR & ADVANCED CTE PATTERNS
-- ===========================================

-- Create dynamic test data sets using VALUES
WITH
    sample_metrics AS (
        SELECT *
        FROM (
                VALUES (
                        1, 'Revenue', '2024-01', 2500000.00, 2400000.00, 'Monthly Sales'
                    ), (
                        2, 'Revenue', '2024-02', 2750000.00, 2450000.00, 'Monthly Sales'
                    ), (
                        3, 'Revenue', '2024-03', 2600000.00, 2350000.00, 'Monthly Sales'
                    ), (
                        4, 'Costs', '2024-01', 1800000.00, 1900000.00, 'Operating Expenses'
                    ), (
                        5, 'Costs', '2024-02', 1850000.00, 1950000.00, 'Operating Expenses'
                    ), (
                        6, 'Costs', '2024-03', 1750000.00, 1850000.00, 'Operating Expenses'
                    ), (
                        7, 'Profit', '2024-01', 700000.00, 500000.00, 'Net Income'
                    ), (
                        8, 'Profit', '2024-02', 900000.00, 500000.00, 'Net Income'
                    ), (
                        9, 'Profit', '2024-03', 850000.00, 500000.00, 'Net Income'
                    )
            ) AS metrics (
                id, metric_type, period, actual, budget, description
            )
    ),
    trend_analysis AS (
        SELECT
            metric_type,
            period,
            actual,
            budget,
            actual - budget AS variance,
            ROUND(
                (
                    (actual - budget) / NULLIF(budget, 0)
                ) * 100,
                2
            ) AS variance_pct,
            LAG(actual) OVER (
                PARTITION BY
                    metric_type
                ORDER BY period
            ) AS prev_actual,
            ROUND(
                (
                    (
                        actual - LAG(actual) OVER (
                            PARTITION BY
                                metric_type
                            ORDER BY period
                        )
                    ) / NULLIF(
                        LAG(actual) OVER (
                            PARTITION BY
                                metric_type
                            ORDER BY period
                        ),
                        0
                    )
                ) * 100,
                2
            ) AS mom_growth_pct
        FROM sample_metrics
    ),
    performance_bands AS (
        SELECT
            *,
            CASE
                WHEN metric_type = 'Revenue'
                AND variance_pct > 5 THEN 'Exceptional'
                WHEN metric_type = 'Revenue'
                AND variance_pct > 0 THEN 'Good'
                WHEN metric_type = 'Revenue'
                AND variance_pct > -5 THEN 'Below Target'
                WHEN metric_type = 'Revenue' THEN 'Poor'
                WHEN metric_type = 'Costs'
                AND variance_pct < -5 THEN 'Excellent Control'
                WHEN metric_type = 'Costs'
                AND variance_pct < 0 THEN 'Good Control'
                WHEN metric_type = 'Costs'
                AND variance_pct < 5 THEN 'Slightly Over'
                WHEN metric_type = 'Costs' THEN 'Poor Control'
                WHEN metric_type = 'Profit'
                AND variance_pct > 10 THEN 'Outstanding'
                WHEN metric_type = 'Profit'
                AND variance_pct > 0 THEN 'Above Target'
                WHEN metric_type = 'Profit' THEN 'Below Target'
            END AS performance_rating
        FROM trend_analysis
    )
SELECT *
FROM performance_bands
ORDER BY metric_type, period;

-- ===========================================
-- ADVANCED WINDOW FUNCTIONS WITH FRAME SPECIFICATIONS
-- ===========================================

-- Complex window frame specifications for time series analysis
DROP TABLE IF EXISTS employee_time_tracking;

CREATE TABLE employee_time_tracking (
    emp_id INT,
    week_start DATE,
    hours_logged DECIMAL(5, 2),
    projects_worked INT,
    tickets_resolved INT,
    bugs_fixed INT,
    FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

INSERT INTO
    employee_time_tracking
VALUES (
        3,
        '2024-01-01',
        45.5,
        3,
        12,
        3
    ),
    (
        3,
        '2024-01-08',
        42.0,
        2,
        15,
        2
    ),
    (
        3,
        '2024-01-15',
        48.5,
        4,
        18,
        4
    ),
    (
        3,
        '2024-01-22',
        46.0,
        3,
        14,
        3
    ),
    (
        3,
        '2024-01-29',
        44.5,
        3,
        16,
        2
    ),
    (
        6,
        '2024-01-01',
        40.0,
        2,
        8,
        5
    ),
    (
        6,
        '2024-01-08',
        42.5,
        2,
        12,
        6
    ),
    (
        6,
        '2024-01-15',
        45.0,
        3,
        15,
        4
    ),
    (
        6,
        '2024-01-22',
        43.5,
        2,
        10,
        5
    ),
    (
        6,
        '2024-01-29',
        41.0,
        2,
        9,
        3
    );

-- Advanced rolling calculations with explicit frames
SELECT e.first_name, e.last_name, ett.week_start, ett.hours_logged,

-- 2-week moving average (current + previous week)
ROUND(
    AVG(ett.hours_logged) OVER (
        PARTITION BY
            ett.emp_id
        ORDER BY ett.week_start ROWS BETWEEN 1 PRECEDING
            AND CURRENT ROW
    ),
    2
) AS rolling_avg_2weeks,

-- Cumulative total with frame specification
SUM(ett.hours_logged) OVER (
    PARTITION BY
        ett.emp_id
    ORDER BY ett.week_start ROWS UNBOUNDED PRECEDING
) AS cumulative_hours,

-- Weighted efficiency score (tickets per hour, last 3 weeks)
ROUND(
    AVG(
        ett.tickets_resolved / NULLIF(ett.hours_logged, 0)
    ) OVER (
        PARTITION BY
            ett.emp_id
        ORDER BY ett.week_start ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
    ),
    3
) AS efficiency_metric,

-- Performance percentile (last 4 weeks only)
PERCENT_RANK() OVER (
    PARTITION BY
        ett.emp_id
    ORDER BY ett.tickets_resolved ROWS BETWEEN 3 PRECEDING
        AND CURRENT ROW
) AS recent_performance_percentile,

-- Trend direction (compare to 2 weeks ago)
CASE
    WHEN ett.hours_logged > LAG(ett.hours_logged, 2) OVER (
        PARTITION BY
            ett.emp_id
        ORDER BY ett.week_start
    ) THEN 'Increasing'
    WHEN ett.hours_logged < LAG(ett.hours_logged, 2) OVER (
        PARTITION BY
            ett.emp_id
        ORDER BY ett.week_start
    ) THEN 'Decreasing'
    ELSE 'Stable'
END AS workload_trend
FROM
    employee_time_tracking ett
    JOIN employee e ON ett.emp_id = e.emp_id
ORDER BY e.first_name, ett.week_start;

-- ===========================================
-- ARRAY FUNCTIONS & COMPLEX TYPE OPERATIONS
-- ===========================================

-- Create array-based tags system for multi-value attributes
DROP TABLE IF EXISTS project_tags;

CREATE TABLE project_tags (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    technologies JSON, -- Array of tech stack
    domains JSON, -- Array of business domains
    risk_factors JSON, -- Array of risk categories
    team_skills JSON, -- Array of required skills
    FOREIGN KEY (proj_id) REFERENCES project (proj_id)
);

INSERT INTO
    project_tags
VALUES (
        1,
        'Website Redesign',
        '["React", "Node.js", "PostgreSQL", "AWS", "Docker"]',
        '["Customer Experience", "Digital Marketing", "E-commerce"]',
        '["Tight Timeline", "High Visibility", "New Technology"]',
        '["JavaScript", "UI/UX", "Project Management", "Cloud Architecture"]'
    ),
    (
        2,
        'Mobile App Development',
        '["React Native", "Firebase", "MongoDB", "iOS", "Android"]',
        '["Mobile", "Consumer Apps", "Real-time Features"]',
        '["Cross-platform", "Scalability Requirements", "Market Competition"]',
        '["Mobile Development", "Firebase", "React", "API Design"]'
    ),
    (
        4,
        'Cloud Infrastructure',
        '["Terraform", "Kubernetes", "AWS", "Docker", "Python"]',
        '["Infrastructure", "DevOps", "Scalability"]',
        '["Security Compliance", "Zero Downtime", "Complex Migration"]',
        '["DevOps", "AWS", "Infrastructure as Code", "Security"]'
    );

-- Advanced array operations and matching
SELECT
    pt.proj_name,
    JSON_ARRAY_INTERSECT (
        pt.technologies,
        pt.team_skills
    ) AS skill_matches,

-- Find projects requiring specific technologies
CASE
    WHEN JSON_CONTAINS(
        pt.technologies,
        JSON_ARRAY('React', 'Node.js')
    ) THEN 'Full Stack React'
    WHEN JSON_CONTAINS(
        pt.technologies,
        JSON_ARRAY('Python', 'AWS')
    ) THEN 'Cloud Python'
    ELSE 'Specialized'
END AS tech_category,

-- Count matching available skills
(
    SELECT COUNT(*)
    FROM
        employee e
        JOIN employee_analytics ea ON e.emp_id = ea.emp_id
    WHERE
        JSON_CONTAINS(
            JSON_KEYS(ea.skills_matrix),
            JSON_EXTRACT(pt.team_skills, '$[0]')
        )
) AS available_experts,

-- Risk assessment based on team capabilities
CASE
    WHEN JSON_ARRAY_LENGTH (
        JSON_ARRAY_INTERSECT (
            pt.risk_factors,
            JSON_ARRAY(
                'Tight Timeline',
                'New Technology'
            )
        )
    ) >= 2 THEN 'High Risk - Requires Experienced Team'
    WHEN JSON_ARRAY_LENGTH (pt.domains) >= 3 THEN 'Medium Risk - Complex Scope'
    ELSE 'Low Risk - Standard Project'
END AS risk_assessment,

-- Technology stack diversity score
ROUND(
    JSON_ARRAY_LENGTH (pt.technologies) / 3.0,
    2
) AS tech_diversity_score
FROM project_tags pt;

-- ===========================================
-- TIME SERIES & TEMPORAL QUERIES
-- ===========================================

-- Generate date series for gap analysis
WITH
    date_series AS (
        SELECT DATE(
                DATE('2024-01-01') + INTERVAL(a.n + b.n * 10 + c.n * 100) DAY
            ) AS generated_date
        FROM (
                SELECT 0 n
                UNION
                SELECT 1
                UNION
                SELECT 2
                UNION
                SELECT 3
                UNION
                SELECT 4
                UNION
                SELECT 5
                UNION
                SELECT 6
                UNION
                SELECT 7
                UNION
                SELECT 8
                UNION
                SELECT 9
            ) a
            CROSS JOIN (
                SELECT 0 n
                UNION
                SELECT 1
                UNION
                SELECT 2
                UNION
                SELECT 3
                UNION
                SELECT 4
                UNION
                SELECT 5
                UNION
                SELECT 6
                UNION
                SELECT 7
                UNION
                SELECT 8
                UNION
                SELECT 9
            ) b
            CROSS JOIN (
                SELECT 0 n
                UNION
                SELECT 1
                UNION
                SELECT 2
            ) c
        WHERE
            DATE(
                DATE('2024-01-01') + INTERVAL(a.n + b.n * 10 + c.n * 100) DAY
            ) <= DATE('2024-03-31')
    ),
    activity_dates AS (
        SELECT DISTINCT
            DATE(activity_date) AS activity_date
        FROM activity_log
        WHERE
            activity_date BETWEEN '2024-01-01' AND '2024-03-31'
    ),
    missing_dates AS (
        SELECT ds.generated_date
        FROM
            date_series ds
            LEFT JOIN activity_dates ad ON ds.generated_date = ad.activity_date
        WHERE
            ad.activity_date IS NULL
            AND DAYOFWEEK(ds.generated_date) NOT IN(1, 7) -- Exclude weekends
    )
SELECT
    generated_date,
    DAYNAME(generated_date) AS day_name,
    DATE_FORMAT(generated_date, '%Y-%m') AS month_year,
    COUNT(*) OVER (
        ORDER BY
            generated_date ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS cumulative_missing_days
FROM missing_dates
ORDER BY generated_date;

-- ===========================================
-- MASTER EXERCISES: Applied Modern SQL
-- ===========================================

-- EXERCISE 1: Advanced Employee Analytics Dashboard
-- Build a comprehensive JSON-based analytics query
WITH employee_dashboard AS (
    SELECT
        e.first_name,
        e.last_name,
        ea.performance_data,

-- Extract latest quarterly rating
JSON_EXTRACT_DOUBLE (
    ea.performance_data,
    '$.quarterly_ratings[3]'
) AS latest_rating,

-- Calculate peer review average
(
    SELECT AVG(
            JSON_EXTRACT_DOUBLE (review.value, '$.rating')
        )
    FROM JSON_TABLE(
            JSON_EXTRACT(
                ea.performance_data, '$.peer_reviews'
            ), '$[*]' COLUMNS (review JSON PATH '$')
        ) reviews
) AS avg_peer_rating,

-- Skills above threshold
(
    SELECT GROUP_CONCAT(skill_data.skill_name)
    FROM JSON_TABLE(
            JSON_EXTRACT(
                ea.skills_matrix, '$.technical'
            ), '$' COLUMNS (
                skill_name VARCHAR(50) PATH '$.*', skill_value INT PATH '$.*'
            )
        ) skill_data
    WHERE
        skill_data.skill_value >= 4
) AS top_skills,

-- Month-over-month engagement trend
JSON_EXTRACT_DOUBLE (
    ea.time_series_metrics,
    '$.2024-03.engagement'
) - JSON_EXTRACT_DOUBLE (
    ea.time_series_metrics,
    '$.2024-02.engagement'
) AS engagement_change,

-- Network influence score (based on collaborators)


JSON_LENGTH(JSON_EXTRACT(ea.social_graph, '$.collaborators')) +
        JSON_LENGTH(JSON_EXTRACT(ea.social_graph, '$.mentorees')) AS influence_score

    FROM employee e
    LEFT JOIN employee_analytics ea ON e.emp_id = ea.emp_id
)
SELECT * FROM employee_dashboard ORDER BY latest_rating DESC;

-- EXERCISE 2: Intelligent Search with Relevance Ranking
-- Implement a sophisticated search system
WITH search_results AS (
    SELECT
        ek.title,
        ek.content,
        e.first_name,
        e.last_name,

-- Content relevance (title + content)
MATCH(ek.content) AGAINST (
    '+cloud +migration strategy' IN BOOLEAN MODE
) AS content_score,

-- Tag relevance
CASE
    WHEN JSON_CONTAINS(ek.tags, JSON_ARRAY('cloud')) THEN 2.0
    WHEN JSON_CONTAINS(
        ek.tags,
        JSON_ARRAY('migration')
    ) THEN 1.5
    WHEN JSON_CONTAINS(
        ek.tags,
        JSON_ARRAY('strategy')
    ) THEN 1.0
    ELSE 0.0
END AS tag_boost,

-- Document type relevance
CASE ek.document_type
    WHEN 'code_sample' THEN 1.5
    WHEN 'research' THEN 1.3
    WHEN 'project_doc' THEN 1.2
    WHEN 'presentation' THEN 1.1
    ELSE 1.0
END AS type_boost,

-- Recency boost (newer documents more relevant)
1.0 + (
    DATEDIFF(CURRENT_DATE, ek.created_date) / 365.0 * -0.1
) AS recency_boost,

-- Combined relevance score


(MATCH(ek.content) AGAINST('+cloud +migration strategy' IN BOOLEAN MODE) +
         CASE WHEN JSON_CONTAINS(ek.tags, JSON_ARRAY('cloud')) THEN 2.0
              WHEN JSON_CONTAINS(ek.tags, JSON_ARRAY('migration')) THEN 1.5
              WHEN JSON_CONTAINS(ek.tags, JSON_ARRAY('strategy')) THEN 1.0
              ELSE 0.0 END +
         CASE ek.document_type
             WHEN 'code_sample' THEN 1.5
             WHEN 'research' THEN 1.3
             WHEN 'project_doc' THEN 1.2
             WHEN 'presentation' THEN 1.1
             ELSE 1.0 END +
         1.0 + (DATEDIFF(CURRENT_DATE, ek.created_date) / 365.0 * -0.1)) / 4.0 AS total_score

    FROM employee_knowledge ek
    JOIN employee e ON ek.emp_id = e.emp_id
    WHERE MATCH(ek.content) AGAINST('+cloud +migration strategy' IN BOOLEAN MODE) > 0
       OR JSON_CONTAINS(ek.tags, JSON_ARRAY('cloud'))
       OR JSON_CONTAINS(ek.tags, JSON_ARRAY('migration'))
)
SELECT
    title,
    LEFT(content, 200) AS preview,
    first_name,
    last_name,
    ROUND(total_score, 3) AS relevance_score,
    CASE
        WHEN total_score > 1.5 THEN 'Highly Relevant'
        WHEN total_score > 1.0 THEN 'Relevant'
        WHEN total_score > 0.5 THEN 'Somewhat Relevant'
        ELSE 'Low Relevance'
    END AS relevance_category
FROM search_results
ORDER BY total_score DESC;

-- EXERCISE 3: Advanced Time Series Forecasting
-- Use window functions for predictive analytics
WITH monthly_trends AS (
    SELECT
        DATE_FORMAT(activity_date, '%Y-%m') AS month_year,
        COUNT(*) AS total_activities,
        SUM(hours_worked) AS total_hours,
        AVG(hours_worked) AS avg_hours_per_activity,

-- Rolling metrics
AVG(COUNT(*)) OVER (
    ORDER BY DATE_FORMAT(activity_date, '%Y-%m') ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
) AS rolling_avg_activities,
SUM(SUM(hours_worked)) OVER (
    ORDER BY DATE_FORMAT(activity_date, '%Y-%m') ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
) AS rolling_hours_3month,

-- Growth rates


(COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(activity_date, '%Y-%m'))) /
        NULLIF(LAG(COUNT(*), 1) OVER (ORDER BY DATE_FORMAT(activity_date, '%Y-%m')), 0) * 100 AS mom_growth_pct

    FROM activity_log
    GROUP BY DATE_FORMAT(activity_date, '%Y-%m')
),
forecast_model AS (
    SELECT
        month_year,
        total_activities,
        rolling_avg_activities,
        mom_growth_pct,

-- Linear regression slope for forecasting
AVG(mom_growth_pct) OVER (
    ORDER BY
        month_year ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
) AS avg_growth_rate,

-- Forecast next month (simple exponential smoothing)
ROUND(
    total_activities * (
        1 + AVG(mom_growth_pct / 100.0) OVER (
            ORDER BY
                month_year ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
        )
    ),
    0
) AS forecasted_activities,

-- Forecast confidence interval


ROUND(total_activities * (1 + (AVG(mom_growth_pct/100.0) OVER (
            ORDER BY month_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )) - 0.1), 0) AS forecast_lower_bound,

        ROUND(total_activities * (1 + (AVG(mom_growth_pct/100.0) OVER (
            ORDER BY month_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )) + 0.1), 0) AS forecast_upper_bound

    FROM monthly_trends
)
SELECT
    month_year,
    total_activities AS actual_activities,
    forecasted_activities,
    CONCAT('(', forecast_lower_bound, ' - ', forecast_upper_bound, ')') AS forecast_range,
    ROUND(avg_growth_rate, 2) AS trend_growth_pct,
    CASE
        WHEN forecasted_activities > total_activities * 1.1 THEN 'Strong Growth Expected'
        WHEN forecasted_activities > total_activities * 1.05 THEN 'Moderate Growth Expected'
        WHEN forecasted_activities < total_activities * 0.95 THEN 'Decline Expected'
        ELSE 'Stable Expected'
    END AS forecast_interpretation
FROM forecast_model
ORDER BY month_year DESC;

-- ===========================================
-- POSTGRESQL VERSION - ADVANCED JSON OPERATIONS
-- ===========================================

/*
-- PostgreSQL equivalent syntax for JSON operations:

\c sample_hr;

-- PostgreSQL uses JSONB for better performance and indexing
DROP TABLE IF EXISTS employee_analytics;

CREATE TABLE employee_analytics (
emp_id INTEGER PRIMARY KEY,
performance_data JSONB,
skills_matrix JSONB,
time_series_metrics JSONB,
social_graph JSONB,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- JSON extraction in PostgreSQL:
SELECT
e.first_name,
e.last_name,
ea.performance_data->>'impact_score' AS impact_score,
(ea.performance_data->>'goals_achieved')::INTEGER AS goals_achieved,
jsonb_array_length(ea.performance_data->'quarterly_ratings') AS rating_count,
ea.performance_data->'quarterly_ratings'->>0 AS latest_quarter_rating
FROM employee e
JOIN employee_analytics ea ON e.emp_id = ea.emp_id;

-- JSON path operations (PostgreSQL 12+):
SELECT
ea.performance_data #>> '{quarterly_ratings,0}' AS first_rating,
ea.skills_matrix #>> '{technical,SQL}' AS sql_skill_level
FROM employee_analytics ea;

-- JSON aggregation and manipulation:
SELECT
emp_id,
jsonb_object_keys(skills_matrix) AS skill_categories,
jsonb_agg(skill_name) AS all_skills
FROM (
SELECT
emp_id,
skill_category,
jsonb_object_keys(skills_matrix->skill_category) AS skill_name
FROM (
SELECT emp_id, jsonb_object_keys(skills_matrix) AS skill_category
FROM employee_analytics
) cats
CROSS JOIN employee_analytics ea
WHERE ea.emp_id = cats.emp_id
) skill_data
GROUP BY emp_id, skill_category;

-- Full-text search in PostgreSQL:
-- Create GIN index for JSONB
CREATE INDEX idx_employee_analytics_skills ON employee_analytics USING GIN (skills_matrix);

-- JSONB containment and existence queries:
SELECT * FROM employee_analytics
WHERE skills_matrix ? 'SQL'  -- Check if key exists
AND skills_matrix @> '{"technical": {"SQL": 4}}';  -- Check containment

-- PostgreSQL JSONB Notes:
-- - JSONB is binary JSON, faster than JSON
-- - -> extracts JSON object field as JSON
-- - ->> extracts JSON object field as text
-- - #> extracts by path array
-- - #>> extracts by path array as text
-- - ? checks key existence
-- - @> checks containment
-- - <@ checks containment (reverse)
-- - || concatenates JSON objects
-- - - removes key from JSON object
*/

-- ===========================================
-- SQL SERVER VERSION - ADVANCED JSON OPERATIONS
-- ===========================================

/*
-- SQL Server equivalent syntax for JSON operations (SQL Server 2016+):

USE sample_hr;

-- SQL Server uses NVARCHAR(MAX) with JSON content type
DROP TABLE IF EXISTS employee_analytics;

CREATE TABLE employee_analytics (
emp_id INT PRIMARY KEY,
performance_data NVARCHAR(MAX) CHECK (ISJSON(performance_data) = 1),
skills_matrix NVARCHAR(MAX) CHECK (ISJSON(skills_matrix) = 1),
time_series_metrics NVARCHAR(MAX) CHECK (ISJSON(time_series_metrics) = 1),
social_graph NVARCHAR(MAX) CHECK (ISJSON(social_graph) = 1),
created_at DATETIME2 DEFAULT GETDATE(),
FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

-- JSON value extraction in SQL Server:
SELECT
e.first_name,
e.last_name,
JSON_VALUE(ea.performance_data, '$.impact_score') AS impact_score,
CAST(JSON_VALUE(ea.performance_data, '$.goals_achieved') AS INT) AS goals_achieved,
(
SELECT COUNT(*)
FROM OPENJSON(ea.performance_data, '$.quarterly_ratings') ratings
) AS rating_count,
JSON_VALUE(ea.performance_data, '$.quarterly_ratings[0]') AS latest_quarter_rating
FROM employee e
JOIN employee_analytics ea ON e.emp_id = ea.emp_id;

-- JSON path queries with OPENJSON:
SELECT
e.first_name,
e.last_name,
tech_ratings.[key] AS skill_name,
tech_ratings.[value] AS skill_level
FROM employee e
JOIN employee_analytics ea ON e.emp_id = ea.emp_id
CROSS APPLY OPENJSON(ea.skills_matrix, '$.technical') AS tech_ratings
WHERE CAST(tech_ratings.[value] AS INT) >= 4;

-- JSON modification operations:
-- Add new skill
UPDATE employee_analytics
SET skills_matrix = JSON_MODIFY(skills_matrix, '$.technical.ML', 3)
WHERE emp_id = 3;

-- Modify existing value
UPDATE employee_analytics
SET performance_data = JSON_MODIFY(performance_data, '$.impact_score', 4.8)
WHERE emp_id = 6;

-- Full-text search with JSON in SQL Server:
-- Create full-text index on JSON columns
CREATE FULLTEXT INDEX ON employee_knowledge(content)
KEY INDEX PK_employee_knowledge;

-- JSON-based search queries:
SELECT *
FROM employee_knowledge
WHERE CONTAINS(content, 'cloud AND migration')
OR JSON_VALUE(tags, '$[0]') = 'cloud';

-- SQL Server JSON Notes:
-- - Uses NVARCHAR(MAX) with ISJSON() constraint
-- - JSON_VALUE() extracts single values
-- - JSON_QUERY() extracts objects/arrays
-- - OPENJSON() parses JSON into relational format
-- - JSON_MODIFY() updates JSON content
-- - JSON_PATH_EXISTS() checks path existence
-- - Full-text search works on JSON content
-- - Computed columns can index JSON paths
*/

-- ===========================================
-- CROSS-DATABASE JSON COMPATIBILITY SUMMARY
-- ===========================================

/*
JSON Operations Comparison:

| Operation | MySQL 8.0+ | PostgreSQL | SQL Server 2016+ |
|-----------|------------|------------|------------------|
| Storage | JSON | JSON/JSONB | NVARCHAR(MAX) + CHECK |
| Extract Value | JSON_EXTRACT(col, '$.path') | col->>'path' | JSON_VALUE(col, '$.path') |
| Extract Object | JSON_EXTRACT(col, '$.path') | col->'path' | JSON_QUERY(col, '$.path') |
| Array Length | JSON_LENGTH(col->'array') | jsonb_array_length(col) | (SELECT COUNT(*) FROM OPENJSON(col, '$.array')) |
| Path Exists | JSON_CONTAINS_PATH(col, 'one', '$.path') | col ? 'key' | JSON_PATH_EXISTS(col, '$.path') |
| Containment | JSON_CONTAINS(col, value) | col @> value | col LIKE '%value%' (limited) |
| Modification | JSON_SET/JSON_REPLACE | jsonb_set() | JSON_MODIFY() |
| Indexing | Generated columns | GIN indexes | Computed columns |
| Full-text | MATCH() AGAINST() | Full-text search | CONTAINS() |

Key Takeaways:
- PostgreSQL JSONB offers best performance and features
- MySQL 8.0+ has good JSON support but limited indexing
- SQL Server JSON is more limited, better for simple operations
- Always validate JSON structure in application layer when possible
*/