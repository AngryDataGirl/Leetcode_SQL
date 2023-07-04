# Advanced SQL 50

## Subqueries

### 1350. Students With Invalid Departments
https://leetcode.com/problems/students-with-invalid-departments/

```sql
SELECT 
    s.id, 
    s.name
FROM Students s
LEFT JOIN Departments d ON d.id = s.department_id
WHERE d.name IS NULL
```

### 1303. Find the Team Size
https://leetcode.com/problems/find-the-team-size/

```sql
WITH team_size AS
(
    SELECT team_id, COUNT(employee_id) as team_size
    FROM Employee 
    GROUP BY team_id
)

SELECT employee_id, team_size
FROM Employee e JOIN team_size t ON t.team_id = e.team_id
```
