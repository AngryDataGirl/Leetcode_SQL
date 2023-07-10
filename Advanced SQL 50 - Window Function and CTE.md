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
```
