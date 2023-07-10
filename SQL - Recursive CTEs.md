# Recursive CTEs

### 571. Find Median Given Frequency of Numbers
https://leetcode.com/problems/find-median-given-frequency-of-numbers/

```sql
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

- So, I initially failed case 7 due to an incorrect partition (the lag was missing a PARTITION BY and instead I put the ORDER BY id, month) 
- Without parititioning it by id, the lagged variable will take the previous id / month even if it's a different person
- ie, with id 3 and month 1 , the lag actually grabbed the later rows of id 2  

```sql
# recursive to generate the missing months (1 through 12 whether or not the employee worked) 
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
# join the months into the recursive query so we can get 0 for the months not currently in the table 
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
# create the lagged variables, lagging 1 month and lagging 2 month
SELECT 
    id, month, salary,
    IFNULL(LAG(salary, 1) OVER(PARTITION BY id ORDER BY month),0) as lag1_salary,
    ifnull(LAG(salary, 2) OVER(PARTITION BY id ORDER BY month),0) as lag2_salary
FROM decompressed 
)
,
filter AS (
# create another row number to remove the max / most recent date 
    SELECT
        row_number() OVER(PARTITION BY id ORDER BY month DESC) as rn, 
        id, 
        month, 
        salary
    FROM Employee 
)

SELECT 
    f.id,
    f.month,
    (l.salary + lag1_salary + lag2_salary) as Salary
FROM filter f
LEFT JOIN LAGGED l 
    ON l.id = f.id
    AND l.month = f.month
WHERE rn <> 1 
ORDER BY id ASC, month DESC
```

### 1767. Find the Subtasks That Did Not Execute
https://leetcode.com/problems/find-the-subtasks-that-did-not-execute/

also found in : 
[Advanced leetcode 50 - Window Function and CTEs](https://github.com/AngryDataGirl/Leetcode_SQL/blob/main/Advanced%20SQL%2050%20-%20Window%20Function%20and%20CTE.md)

```sql
#recursive substask generator
WITH RECURSIVE subtask_list AS (
    
    #anchor member
    SELECT 1 as subtask_id
    UNION ALL
    
    #recursive member
    SELECT subtask_id + 1 
    FROM subtask_list
    
    #terminator
    WHERE subtask_id < (SELECT MAX(subtasks_count) FROM Tasks)
 )
 ,
 
#list of tasks and subtasks
cte2 AS (
SELECT task_id, subtask_id 
FROM Tasks, subtask_list
WHERE subtask_id <= subtasks_count 
ORDER BY task_id, subtasks_count
)

#left join and return nulls (since those would be the ones that did not execute)
SELECT c2.task_id, c2.subtask_id 
FROM cte2 c2
LEFT JOIN Executed e 
    ON c2.task_id = e.task_id 
    AND c2.subtask_id = e.subtask_id
WHERE e.subtask_id is NULL
ORDER by task_id, subtask_id
```
