# Problem
https://leetcode.com/problems/employee-bonus/

# Solution
```sql
SELECT e.name, b.bonus 
FROM Employee e
LEFT JOIN Bonus b ON b.empId = e.empId
WHERE b.bonus < 1000 or bonus IS NULL
```
