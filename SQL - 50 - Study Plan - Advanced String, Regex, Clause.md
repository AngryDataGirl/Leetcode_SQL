# SQL 50

## Advanced String Functions / Regex / Clause

### 1667. Fix Names in a Table
https://leetcode.com/problems/fix-names-in-a-table/

```sql
SELECT 
  user_id as user_id, 
  INITCAP(name) as name
FROM Users
ORDER BY user_id
```
