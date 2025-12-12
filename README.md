# SQL Mastery Platform

Complete SQL learning curriculum from basics to advanced analytics and interview preparation.

## Learning Path

| Phase | Focus | Duration | Topics |
|-------|--------|----------|--------|
| **Foundational** | Core SQL | 8 weeks | DDL, CRUD, JOINs, aggregations |
| **Intermediate** | Advanced Features | 4 weeks | Window functions, CTEs, transactions |
| **Advanced** | Analytics | 4 weeks | Stored procedures, analytics, modern SQL |
| **Interview Prep** | Problem Solving | 4 weeks | Algorithmic problems, optimization |

## Repository Structure

```
SQL-Mastery-Platform/
├── syntax/                    # Database-specific syntax guides
│   ├── mysql/                # MySQL syntax & setup
│   ├── postgresql/           # PostgreSQL syntax & setup
│   └── sql-server/           # SQL Server syntax & setup
├── curriculum/               # Learning curriculum by topic
│   ├── foundational/         # Basic SQL concepts
│   ├── intermediate/         # Advanced SQL features
│   ├── advanced/            # Complex queries and analytics
│   └── specialized/          # Domain-specific applications
├── problems/                 # 14 interview problem sets
├── examples/                 # Sample data & runnable scripts
├── guides/                   # Setup and learning guides
└── README.md                # This file
```

## Quick Start

### Choose Your Path

#### Single Database Focus (Recommended)
```bash
# Pick one database
cd syntax/mysql/        # or postgresql/ or sql-server/

# Follow setup guide
cat README.md           # Installation instructions

# Load sample data
./examples/load_sample_data.sh -u root -p your_password -d sample_hr
```

#### Multi-Database Comparison
```bash
# Study differences across databases
cat MULTI_DATABASE_SUPPORT.md

# Compare syntax in curriculum files
cd curriculum/foundational/
# Each file shows examples for all 3 databases
```

### Prerequisites
- SQL Database: MySQL 8.0+, PostgreSQL 12+, or SQL Server 2017+
- Text editor or SQL client (DBeaver, DataGrip recommended)

## Learning Curriculum

### Phase 1: Foundations (Weeks 1-8)

| Week | Topic | Key Concepts | Problems |
|------|--------|--------------|----------|
| 1 | Schema & DDL | CREATE/ALTER/DROP, constraints, indexes | 1-2 |
| 2 | CRUD/DML | INSERT/UPDATE/DELETE operations | 1-2 |
| 3 | SELECT & JOINs | INNER/LEFT/RIGHT/FULL joins | 1, 7, 8 |
| 4 | Aggregations | GROUP BY, HAVING, statistical functions | 3, 6 |
| 5 | Window Functions | ROW_NUMBER, RANK, LEAD/LAG | 5-6 |
| 6 | CTEs & Recursion | WITH clauses, recursive queries | 4, 9-12 |
| 7 | Transactions & DCL | COMMIT/ROLLBACK, GRANT/REVOKE | 7-8 |
| 8 | Performance Tuning | Indexing, EXPLAIN, optimization | All previous |

### Phase 2: Advanced Analytics (Weeks 9-12)

| Week | Topic | Applications |
|------|--------|--------------|
| 9 | Statistical Functions | NTILE, PERCENT_RANK, CUME_DIST, CORR |
| 10 | Modern SQL | JSON operations, arrays, full-text search |
| 11-12 | Business Intelligence | CLV analysis, churn prediction, market insights |

## Problem Sets

### Technical Problems (1-12)
- **01 Joins**: Complex multi-table queries
- **02 Conditionals**: CASE statements and logic
- **03 Aggregation**: String concatenation, grouping
- **04 Recursive CTEs**: Tree traversal, sequences
- **05 Window Functions**: Partitioning and ordering
- **06 Ranking**: Top-N and percentile problems
- **07 Merge/Upsert**: Source-target synchronization
- **08 Set Operations**: Anti-joins and set logic
- **09 Scheduling**: Time-based analysis and gaps
- **10 Matching**: Deduplication and fuzzy matching
- **11 Spike Detection**: Anomaly detection algorithms
- **12 Advanced Patterns**: Complex multi-table scenarios

### Business Intelligence (13-14)
- **13 Advanced Analytics**: Statistical distributions, performance tiers
- **14 E-commerce Analytics**: Customer lifetime value, churn modeling

## Database Support

### Multi-Database Compatibility
- **MySQL**: Most popular for web applications
- **PostgreSQL**: Advanced features, JSON support
- **SQL Server**: Enterprise environments, Windows integration

Each curriculum file includes examples for all three databases with detailed syntax differences.

## Getting Started Guide

```bash
# 1. Choose your database
cd syntax/mysql/           # MySQL setup
# or cd syntax/postgresql/  # PostgreSQL setup
# or cd syntax/sql-server/  # SQL Server setup

# 2. Follow installation guide
cat README.md

# 3. Load sample database
./examples/load_sample_data.sh -u username -p password -d database_name

# 4. Start learning
cd ../../curriculum/foundational/
# Run 01_schema_and_ddl.sql in your database
```

## Sample Database

The repository includes a realistic HR schema with:
- **6 tables**: employees, departments, jobs, locations, etc.
- **200+ rows** of sample data
- **Real-world scenarios**: Salaries, hierarchies, performance data

## Interview Preparation

### Algorithmic SQL Problems
- 14 comprehensive problem sets
- Multiple solution approaches
- Performance optimization techniques
- Real interview scenarios

### Business Intelligence Cases
- Customer analytics and segmentation
- Churn prediction modeling
- Market basket analysis
- Time series forecasting

## Contributing

Contributions welcome! Areas for help:
- Additional database support (Oracle, SQLite)
- More advanced problem sets
- Performance optimization examples
- Real-world business scenarios

## License

MIT License - see LICENSE file for details.

---

**Start your SQL mastery journey with [getting started guide](guides/quick-start.md)**
