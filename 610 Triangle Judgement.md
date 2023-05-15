# Problem
https://leetcode.com/problems/triangle-judgement/

# Solution
```sql
# Write your MySQL query statement below
SELECT t.*, 
    CASE WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
    ELSE 'No'
    END AS triangle
FROM Triangle t
```
