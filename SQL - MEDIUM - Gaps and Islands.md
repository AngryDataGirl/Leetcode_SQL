- [1285. Find the Start and End Number of Continuous Ranges](#1285find-the-start-and-end-number-of-continuous-ranges)
  
---

# 1285. Find the Start and End Number of Continuous Ranges
https://leetcode.com/problems/find-the-start-and-end-number-of-continuous-ranges/

- key: create the row number because we only have a single column
- value: log id

```sql
WITH CTE_row_number AS 
(
SELECT 
    log_id, 
    row_number() over() AS row_num 
FROM Logs
),
CTE_difference AS
(
SELECT 
    log_id, 
    (log_id - row_num) AS diff 
FROM CTE_row_number
)

SELECT min(log_id) AS start_id, max(log_id) AS end_id
FROM CTE_difference
group by diff
```

