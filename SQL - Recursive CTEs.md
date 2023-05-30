# Recursive CTEs

### 571. Find Median Given Frequency of Numbers
https://leetcode.com/problems/find-median-given-frequency-of-numbers/

```sql
# Write your MySQL query statement below
WITH RECURSIVE base AS
(
    select
        num,
        1 as iteration, 
        frequency
    from Numbers
    
    union all
    
    select
        num,
        iteration + 1, # add 1 to rk 
        frequency
    from base
    where iteration < frequency # limits the iteration
)
, 
ranked AS 
(
SELECT 
  num, 
  frequency,
  row_number() OVER(ORDER BY num) as rn,
  count(1) OVER() as total
FROM base
)

SELECT 
    round(avg(num), 1) as median
FROM ranked
WHERE rn BETWEEN total/2 AND total/2 + 1
```
