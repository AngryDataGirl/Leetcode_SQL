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

### 579. Find Cumulative Salary of an Employee
https://leetcode.com/problems/find-cumulative-salary-of-an-employee/

```sql
# Write your MySQL query statement below

# recursive to generate the missing months
WITH RECURSIVE sal_months AS 
(
    SELECT 
        id, 
        1 as month    
    FROM Employee 

    UNION

    SELECT 
        id,
        month + 1
    FROM sal_months
    WHERE month < 12
)
,
decompressed AS 
(
SELECT sm.id, sm.month, IFNULL(e.salary,0) as salary
FROM sal_months sm
LEFT JOIN Employee e 
    ON e.id = sm.id
    AND e.month = sm.month
ORDER BY id, month
)
,
LAGGED as 
(
SELECT 
    id, month, salary,
    IFNULL(LAG(salary, 1) OVER(PARTITION BY id ORDER BY month),0) as lag1_salary,
    ifnull(LAG(salary, 2) OVER(PARTITION BY id ORDER BY month),0) as lag2_salary
FROM decompressed 
)
,
filter AS (
    SELECT
        row_number() OVER(PARTITION BY id ORDER BY month DESC) as rn, 
        id, 
        month, 
        salary
    FROM Employee 
)

SELECT f.id, f.month, 
# l.salary, lag1_salary, lag2_salary, 
(l.salary + lag1_salary + lag2_salary) as Salary
FROM filter f
LEFT JOIN LAGGED l 
    ON l.id = f.id
    AND l.month = f.month
WHERE rn <> 1 
# AND f.id = 3
ORDER BY id ASC, month DESC
```
