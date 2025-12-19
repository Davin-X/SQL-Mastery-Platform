# 🎯 SQL Practice 8: Research Project Management

## Question
Complete the following SQL exercises using the Scientists, Projects, and AssignedTo tables to practice project management queries, resource allocation, and research workload analysis.

## SQL Setup (Tables and Sample Data)

```sql
CREATE TABLE Scientists (
  SSN INT,
  Name CHAR(30) NOT NULL,
  PRIMARY KEY (SSN)
);

CREATE TABLE Projects (
  Code CHAR(4),
  Name CHAR(50) NOT NULL,
  Hours INT,
  PRIMARY KEY (Code)
);

CREATE TABLE AssignedTo (
  Scientist INT NOT NULL,
  Project CHAR(4) NOT NULL,
  PRIMARY KEY (Scientist, Project),
  FOREIGN KEY (Scientist) REFERENCES Scientists (SSN),
  FOREIGN KEY (Project) REFERENCES Projects (Code)
);

INSERT INTO Scientists(SSN, Name) VALUES
(123234877, 'Michael Rogers'),
(152934485, 'Anand Manikutty'),
(222364883, 'Carol Smith'),
(326587417, 'Joe Stevens'),
(332154719, 'Mary-Anne Foster'),
(332569843, 'George ODonnell'),
(546523478, 'John Doe'),
(631231482, 'David Smith'),
(654873219, 'Zacary Efron'),
(745685214, 'Eric Goldsmith'),
(845657245, 'Elizabeth Doe'),
(845657246, 'Kumar Swamy');

INSERT INTO Projects (Code, Name, Hours) VALUES
('AeH1', 'Winds: Studying Bernoullis Principle', 156),
('AeH2', 'Aerodynamics and Bridge Design', 189),
('AeH3', 'Aerodynamics and Gas Mileage', 256),
('AeH4', 'Aerodynamics and Ice Hockey', 789),
('AeH5', 'Aerodynamics of a Football', 98),
('AeH6', 'Aerodynamics of Air Hockey', 89),
('Ast1', 'A Matter of Time', 112),
('Ast2', 'A Puzzling Parallax', 299),
('Ast3', 'Build Your Own Telescope', 6546),
('Bte1', 'Juicy: Extracting Apple Juice with Pectinase', 321),
('Bte2', 'A Magnetic Primer Designer', 9684),
('Bte3', 'Bacterial Transformation Efficiency', 321),
('Che1', 'A Silver-Cleaning Battery', 545),
('Che2', 'A Soluble Separation Solution', 778);

INSERT INTO AssignedTo (Scientist, Project) VALUES
(123234877, 'AeH1'),
(152934485, 'AeH3'),
(222364883, 'Ast3'),
(326587417, 'Ast3'),
(332154719, 'Bte1'),
(546523478, 'Che1'),
(631231482, 'Ast3'),
(654873219, 'Che1'),
(745685214, 'AeH3'),
(845657245, 'Ast1'),
(845657246, 'Ast2'),
(332569843, 'AeH4');
```

## Query 6.1: List all the scientists' names, their projects' names, and the hours worked by that scientist on each project

```sql
SELECT S.Name, P.Name, P.Hours
FROM Scientists S
INNER JOIN AssignedTo A ON S.SSN = A.Scientist
INNER JOIN Projects P ON A.Project = P.Code
ORDER BY P.Name ASC, S.Name ASC;
```

**Expected Output**: Scientists, their assigned projects, and project hours, ordered by project name then scientist name

## Query 6.2: Select the project names which are not assigned yet

```sql
SELECT Name
FROM Projects
WHERE Code NOT IN
(
  SELECT Project
  FROM AssignedTo
);
```

**Expected Output**: Project names that have no scientists assigned

## Additional Practice Queries (Based on Schema)

### Resource Allocation Analysis

**6.3: Count how many scientists are assigned to each project**
```sql
SELECT P.Name AS Project_Name, COUNT(A.Scientist) AS Scientist_Count
FROM Projects P
LEFT JOIN AssignedTo A ON P.Code = A.Project
GROUP BY P.Code, P.Name
ORDER BY Scientist_Count DESC, P.Name;
```

**Expected Output**: Each project with its assigned scientist count

**6.4: Find scientists who are not assigned to any project**
```sql
SELECT S.Name
FROM Scientists S
LEFT JOIN AssignedTo A ON S.SSN = A.Scientist
WHERE A.Project IS NULL;
```

**Expected Output**: Scientists with no project assignments

**6.5: Calculate total hours allocated per scientist**
```sql
SELECT S.Name, SUM(P.Hours) AS Total_Hours_Allocated
FROM Scientists S
INNER JOIN AssignedTo A ON S.SSN = A.Scientist
INNER JOIN Projects P ON A.Project = P.Code
GROUP BY S.SSN, S.Name
ORDER BY Total_Hours_Allocated DESC;
```

**Expected Output**: Each scientist's total allocated project hours

### Project Workload Analysis

**6.6: Find projects with above-average hours**
```sql
SELECT Name, Hours
FROM Projects
WHERE Hours > (SELECT AVG(Hours) FROM Projects);
```

**Expected Output**: Projects with hours above the average

**6.7: List all project assignments with scientist and project details**
```sql
SELECT 
    S.Name AS Scientist_Name,
    P.Name AS Project_Name,
    P.Hours AS Project_Hours,
    CASE 
        WHEN P.Hours > 1000 THEN 'High Effort'
        WHEN P.Hours > 500 THEN 'Medium Effort'
        ELSE 'Low Effort'
    END AS Effort_Level
FROM Scientists S
INNER JOIN AssignedTo A ON S.SSN = A.Scientist
INNER JOIN Projects P ON A.Project = P.Code
ORDER BY P.Hours DESC, S.Name;
```

**Expected Output**: Complete assignment details with effort categorization

## Key Concepts Demonstrated

### Research Project Management
- **Resource allocation**: Scientists assigned to projects
- **Workload balancing**: Hours distribution across assignments
- **Project tracking**: Assignment status and completion

### Complex JOIN Patterns
- **Multi-table relationships**: Scientists ↔ Assignments ↔ Projects
- **LEFT JOIN for missing data**: Finding unassigned items
- **INNER JOIN for existing relationships**: Active assignments only

### Aggregation and Analysis
- **Workload analysis**: Hours per scientist/project
- **Assignment statistics**: Project participation counts
- **Performance metrics**: High/low effort categorization

## Interview Tips

- **Resource management**: Common in project management interviews
- **Complex JOINs**: Understanding multi-table relationships
- **NULL handling**: Finding missing assignments
- **Business logic**: Project allocation and workload balancing
- **Performance**: Efficient queries for large research organizations

## Real-World Applications

These patterns are essential for:
- **Research institutions**: Scientist project assignments
- **Consulting firms**: Consultant client allocations
- **IT project management**: Developer task assignments
- **Manufacturing**: Worker station assignments
- **Education**: Teacher course assignments

## Common Query Patterns

### Assignment Management
```sql
-- Add new assignment
INSERT INTO AssignedTo (Scientist, Project) VALUES (123234877, 'AeH2');

-- Remove assignment
DELETE FROM AssignedTo WHERE Scientist = 123234877 AND Project = 'AeH1';

-- Transfer assignment
UPDATE AssignedTo SET Project = 'AeH2' WHERE Scientist = 123234877 AND Project = 'AeH1';
```

### Reporting Queries
```sql
-- Project status report
SELECT 
    P.Name,
    COUNT(A.Scientist) AS Assigned_Scientists,
    P.Hours,
    CASE WHEN COUNT(A.Scientist) > 0 THEN 'Active' ELSE 'Unassigned' END AS Status
FROM Projects P
LEFT JOIN AssignedTo A ON P.Code = A.Project
GROUP BY P.Code, P.Name, P.Hours;
```

### Workload Analysis
```sql
-- Overloaded scientists (too many projects)
SELECT S.Name, COUNT(A.Project) AS Project_Count
FROM Scientists S
LEFT JOIN AssignedTo A ON S.SSN = A.Scientist
GROUP BY S.SSN, S.Name
HAVING COUNT(A.Project) > 2;
```

## Best Practices

1. **Composite primary keys**: (Scientist, Project) prevents duplicate assignments
2. **Foreign key constraints**: Maintains data integrity
3. **LEFT JOIN for reporting**: Include items with no assignments
4. **INDEX on foreign keys**: Performance for JOIN operations
5. **Audit trail**: Consider logging assignment changes

## Performance Considerations

- **Index strategy**: Foreign keys and frequently queried columns
- **Query optimization**: Use appropriate JOIN types
- **Batch operations**: For bulk assignment changes
- **Constraint checking**: Foreign key validation overhead

## Business Logic Examples

- **Capacity planning**: Scientist availability and project requirements
- **Load balancing**: Distributing work evenly across team members
- **Skill matching**: Assigning appropriate scientists to projects
- **Deadline tracking**: Project completion timelines
- **Resource optimization**: Maximizing research output
