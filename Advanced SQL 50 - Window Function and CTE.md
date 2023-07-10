# Advanced SQL 50

## Window Function and CTE

### 1077. Project Employees III
https://leetcode.com/problems/project-employees-iii/

```sql
WITH ranked AS (
  SELECT
    p.project_id,
    e.employee_id,
    rank() OVER (PARTITION BY project_id ORDER BY e.experience_years DESC) as p_rank
FROM Project p 
JOIN Employee e
  ON e.employee_id = p.employee_id
)

SELECT project_id, employee_id
FROM ranked 
WHERE p_rank = 1
```

### 1285. Find the Start and End Number of Continuous Ranges
https://leetcode.com/problems/find-the-start-and-end-number-of-continuous-ranges/

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

### 1596. The Most Frequently Ordered Products for Each Customer
https://leetcode.com/problems/the-most-frequently-ordered-products-for-each-customer/

```sql
#get total products per customer
WITH cte1 AS (
SELECT customer_id, product_id, count(order_id) as product_cnt
FROM Orders o 
GROUP BY customer_id, product_id
)
,
#ranked max orders per customer
cte2 AS (
SELECT *,
rank() OVER(PARTITION BY customer_id ORDER BY product_cnt DESC) as rnk
FROM cte1
GROUP BY customer_id, product_id
)

SELECT 
c2.customer_id, c2.product_id, p.product_name
FROM cte2 c2
JOIN Products p on p.product_id = c2.product_id
WHERE rnk = 1
```

### 1709. Biggest Window Between Visits
https://leetcode.com/problems/biggest-window-between-visits/

```sql
WITH next_dates AS (
SELECT *, 
    LEAD(visit_date) OVER (PARTITION BY user_id ORDER BY visit_date) AS next_date
FROM UserVisits
)
,
window_size AS
(
SELECT *,
    CASE WHEN visit_date IS NOT NULL AND next_date IS NOT NULL THEN DATEDIFF(next_date, visit_date)
    ELSE DATEDIFF(DATE('2021-1-1'), visit_date)
    END as window_size
FROM next_dates
)

SELECT user_id, max(window_size) as biggest_window
FROM window_size
GROUP BY user_id
```

### 1270. All People Report to the Given Manager
https://leetcode.com/problems/all-people-report-to-the-given-manager/

```sql
WITH direct_reports AS
(
SELECT employee_id
FROM Employees
WHERE manager_id = 1
)
,
indirect1 AS
(
    SELECT employee_id 
    FROM Employees
    WHERE manager_id IN (SELECT employee_id FROM direct_reports)
)
,
indirect2 AS
(
    SELECT employee_id 
    FROM Employees
    WHERE manager_id IN (SELECT employee_id FROM indirect1)
)
,
indirect3 AS
(
    SELECT employee_id 
    FROM Employees
    WHERE manager_id IN (SELECT employee_id FROM indirect2)
)
,
combined AS
(
SELECT employee_id FROM direct_reports
UNION
SELECT employee_id FROM indirect1
UNION
SELECT employee_id FROM indirect2
UNION
SELECT employee_id FROM indirect3
)
SELECT * FROM combined
WHERE employee_id <> 1
```

### 1412. Find the Quiet Students in All Exams
https://leetcode.com/problems/find-the-quiet-students-in-all-exams/

```sql
WITH scores AS 
(
SELECT 
  exam_id, 
  min(score) as min_score,
  max(score) as max_score
FROM Exam
GROUP BY exam_id
)

# | exam_id | min_score | max_score |
# | ------- | --------- | --------- |
# | 10      | 70        | 90        |
# | 20      | 80        | 80        |
# | 30      | 70        | 90        |
# | 40      | 60        | 80        |

, silent_flag AS 
(
SELECT DISTINCT
  sc.*,  
  e.student_id,
  e.score,
  CASE WHEN e.score = min_score THEN 1 
    WHEN e.score = max_score THEN 1
  END AS not_silent,
  COUNT(e.exam_id) OVER(PARTITION BY student_id) as total_exams_taken
FROM Exam e
LEFT JOIN scores sc 
  ON sc.exam_id = e.exam_id
)
, result AS 
(
SELECT student_id, total_exams_taken, COUNT(not_silent) as total_not_silent
FROM silent_flag
# WHERE silent IS NULL
GROUP BY student_id, total_exams_taken
HAVING COUNT(not_silent) = 0 
)

# | student_id | total_exams_taken | total_not_silent |
# | ---------- | ----------------- | ---------------- |
# | 2          | 2                 | 0                |

SELECT *
FROM Student
WHERE student_id IN (SELECT student_id FROM result)
```

### 1767. Find the Subtasks That Did Not Execute
https://leetcode.com/problems/find-the-subtasks-that-did-not-execute/

```sql
# Write your MySQL query statement below

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

### 1225. Report Contiguous Dates
https://leetcode.com/problems/report-contiguous-dates/

```sql
# Write your MySQL query statement below
WITH cte1 AS 
(
SELECT 'failed' as period_state, fail_date as event_date
FROM Failed
UNION
SELECT 'succeeded' as period_state, success_date as event_date
FROM Succeeded
ORDER BY event_date
)
,
cte2 AS 
(
SELECT *, 
    row_number() OVER(ORDER BY event_date) as event_id,
    dense_rank() OVER(PARTITION BY period_state ORDER BY event_date) as drnk
FROM cte1 
WHERE year(event_date) = 2019
)
,
cte3 AS 
(
SELECT *, event_id - drnk as grp
FROM cte2
)

SELECT 
    period_state, 
    min(event_date) as start_date, 
    max(event_date) as end_date 
FROM cte3
GROUP BY grp, period_state
ORDER BY start_date
```
