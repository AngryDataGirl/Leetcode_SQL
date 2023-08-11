
# SQL 

## Easy - Filtering

### 577. Employee Bonus

https://leetcode.com/problems/employee-bonus/

```sql
SELECT e.name, b.bonus 
FROM Employee e
LEFT JOIN Bonus b ON b.empId = e.empId
WHERE b.bonus < 1000 or bonus IS NULL
```
