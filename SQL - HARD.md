# SQL - Hard

- [Recursive Queries](#recursive-queries) 
    - [571](#571)
    - [579](#579)
    - [1336](#1336)
    - [1635](#1635)
    - [1651](#1651)
    - [1767](#1767)
    - [2474](#2474)

- [Window Functions](#window-functions)
    - [262](#262)
    - [1159](#1159)
    - [1412](#1412)
    - [2010](#2010)

- [Strings](#strings)  
    - [2199](#2199)
    - [2118](#2118)

---

## Recursive Queries 

### 571
Find Median Given Frequency of Numbers
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

### 579
Find Cumulative Salary of an Employee
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

### 1336
Number of Transactions per Visit
https://leetcode.com/problems/number-of-transactions-per-visit/

```sql
# Write your MySQL query statement below

#full table with count of transactions
WITH RECURSIVE cte1 AS 
(
SELECT 
    v.user_id,
    v.visit_date, 
    t.transaction_date, 
    IFNULL(t.amount,0) as amount,
    sum(case when transaction_date is NOT NULL then 1 else 0 end) as transactions_count 
FROM Visits v
LEFT JOIN Transactions t 
    ON t.user_id = v.user_id
    AND t.transaction_date = v.visit_date
GROUP BY v.visit_date, v.user_id
)
#create table of counts
,
cte2 AS (
    SELECT 0 as transactions_count
    UNION ALL
    SELECT transactions_count + 1
    FROM cte2
    WHERE transactions_count < (SELECT MAX(transactions_count) FROM cte1) 
    )
#count the visits
,
visits AS 
(
SELECT transactions_count, COUNT(transactions_count) as visits_count
FROM cte1
GROUP BY transactions_count
)

SELECT c.transactions_count, IFNULL(v.visits_count,0) as visits_count
FROM cte2 c
LEFT JOIN visits v 
    ON c.transactions_count = v.transactions_count
```

### 1635
Hopper Company Queries I
https://leetcode.com/problems/hopper-company-queries-i/

```sql
#get months with recursive cte
WITH RECURSIVE list_months AS (
    SELECT 1 as m 
    UNION ALL
    SELECT m + 1
    FROM list_months
    WHERE m < 12
)
#get active drivers
,
active_drivers AS (
SELECT 
   month(join_date) as month, 
   count(driver_id) OVER (order by join_date) as active_drivers
 FROM drivers
 WHERE year(join_date) <= 2020
)
,
#get accepted rides 
accepted_rides AS (
    SELECT 
        month(requested_at) as month,
        count(ride_id) as accepted_rides_count
    FROM Rides ar 
where ride_id in (select ride_id from AcceptedRides) and year(requested_at) = 2020
    GROUP BY month
)

SELECT DISTINCT 
    m as month, 
    IFNULL(max(ad.active_drivers) over (order by lm.m),0) as active_drivers,
    IFNULL(ar.accepted_rides_count,0) as accepted_rides
FROM list_months lm
LEFT JOIN active_drivers ad ON ad.month = lm.m
LEFT JOIN accepted_rides ar ON ar.month = lm.m
```

### 1651
Hopper Company Queries III
https://leetcode.com/problems/hopper-company-queries-iii/

```sql
# Write your MySQL query statement below

#create anchor months
WITH RECURSIVE cte AS
(
    SELECT 1 as month 
    UNION ALL
    SELECT month + 1 
    FROM cte
    WHERE month < 12
)
# join with relevant data
,
cte1 AS (
SELECT c.month, IFNULL(SUM(t.ride_distance),0) as ride_distance, IFNULL(SUM(t.ride_duration),0) as ride_duration
FROM cte c 
LEFT JOIN 
    (
        SELECT 
            ar.ride_id, 
            ar.ride_distance,
            ar.ride_duration,
            r.requested_at, 
            month(requested_at) as month
        FROM AcceptedRides ar
        LEFT JOIN Rides r 
            ON r.ride_id = ar.ride_id
        WHERE year(requested_at) = 2020
    ) t
    ON c.month = t.month
    GROUP BY month
)
#calculate rolling averages
,
avgs AS (
SELECT 
    month,
    ROUND(AVG(ride_distance) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) as average_ride_distance,
    ROUND(AVG(ride_duration) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) as average_ride_duration
FROM cte1
)

SELECT * 
FROM avgs
WHERE month <= 10
ORDER BY month ASC
```

### 1767
Find the Subtasks That Did Not Execute
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

### 2474
Customers With Strictly Increasing Purchases
https://leetcode.com/problems/customers-with-strictly-increasing-purchases/

```sql
#set up recursive cte
WITH RECURSIVE cte1 AS 
# get total purchases for each customer by year
(
SELECT 
    customer_id, 
    YEAR(order_date) as order_year, 
    sum(price) as total_annual_purchase
FROM 
    Orders 
GROUP BY 1, 2 
)
,
#get the min and max year for everyone
cte2 AS
(
    SELECT 
        customer_id, 
        min(YEAR(order_date)) as min_year, 
        max(YEAR(order_date)) as max_year 
    FROM Orders
    GROUP BY customer_id
)
,
#get the years using prev to set up recursive cte
cte3 AS 
(
SELECT customer_id, min_year as n FROM cte2
UNION ALL
SELECT customer_id, n + 1 FROM cte3
WHERE n < (SELECT max_year FROM cte2 WHERE cte2.customer_id = cte3.customer_id)
)
,
all_years as
( 
SELECT * 
FROM cte3
ORDER BY customer_id, n
)
,
joined AS 
(
SELECT ay.customer_id, n, IFNULL(total, 0) as total
FROM all_years ay
LEFT JOIN 
(
    SELECT customer_id, YEAR(order_date) as order_year, SUM(price) as total 
    FROM Orders
    GROUP BY customer_id, YEAR(order_date)
) t1 ON t1.customer_id = ay.customer_id AND t1.order_year = ay.n
ORDER BY ay.customer_id, ay.n
)
,
#filter for those that have break in increase of purchase 
breaks as 
(
SELECT a.customer_id
FROM joined as a, joined as b
WHERE a.customer_id = b.customer_id
AND a.n+1 = b.n
AND a.total >= b.total
)

#grab ids that do not have breaks 
SELECT DISTINCT customer_id FROM Orders
WHERE customer_id NOT IN (SELECT customer_id FROM breaks)
```

## Window Functions

### 262
262. Trips and Users
https://leetcode.com/problems/trips-and-users/

```sql

#banned users CTE
with cte as (
    select * 
    from trips t
    where client_id in (select users_id from users where banned = "No")
    and driver_id in (select users_id from users where banned = "No")
),

#get sum of cancelled trips
cte2 as(
    select 
    request_at, 
    count(*) as Total, 
    sum(case when status <> "completed" then 1 else 0 end) as cancelled
    from cte
    group by request_at
)

select 
    request_at as 'Day', 
    round(cancelled/Total,2) as "Cancellation Rate"
    from cte2
    group by request_at
    having request_at between "2013-10-01" AND "2013-10-03";
```

### 1159
Market Analysis II
https://leetcode.com/problems/market-analysis-ii/

```sql
#join orders with items 
WITH cte1 AS 
(
SELECT o.*, i.item_brand as sold_brand, u.favorite_brand as sellers_fav_brand, 
rank() OVER(PARTITION BY o.seller_id ORDER BY o.order_date) as rnk
FROM Orders o 
LEFT JOIN Items i ON i.item_id = o.item_id
LEFT JOIN Users u ON u.user_id = o.seller_id 
)
,
seller_fav AS 
(
SELECT seller_id, "yes" as fav_brand FROM cte1
WHERE rnk = 2 AND sold_brand = sellers_fav_brand
)

SELECT user_id as seller_id, CASE WHEN fav_brand IS NULL THEN 'no' ELSE fav_brand END as 2nd_item_fav_brand 
FROM Users u
LEFT JOIN seller_fav sf ON sf.seller_id = u.user_id
```
### 1412
1412. Find the Quiet Students in All Exams
https://leetcode.com/problems/find-the-quiet-students-in-all-exams/

```sql
WITH atleast1 AS 
(
SELECT student_id, count(exam_id) as total_exams
FROM Exam e 
GROUP BY student_id
HAVING total_exams >= 1
)
,
scores AS 
(
SELECT e.*, 
    max(score) OVER(PARTITION BY exam_id) as max_score,
    min(score) OVER(PARTITION BY exam_id) as min_score
FROM Exam e 
WHERE student_id IN (SELECT student_id FROM atleast1)
)
,
hs AS 
(
SELECT student_id FROM scores
WHERE score = max_score
)
,
ls AS 
(
SELECT student_id FROM scores
WHERE score = min_score
)

SELECT DISTINCT s.student_id, s.student_name FROM scores
JOIN Student s ON s.student_id = scores.student_id
WHERE 
    scores.student_id NOT IN (SELECT student_id FROM hs)
AND 
    scores.student_id NOT IN (SELECT student_id FROM ls)
```

### 2010
The Number of Seniors and Juniors to Join the Company II
https://leetcode.com/problems/the-number-of-seniors-and-juniors-to-join-the-company-ii/

```sql
# Write your MySQL query statement below

#total table
WITH cte1 AS 
(
SELECT 
    employee_id, 
    experience, 
    salary,
    70000 as budget
FROM Candidates
)

#total cost of seniors
,
total_seniors AS 
(
SELECT 
    c.*,
    SUM(salary) OVER(ORDER BY salary ASC) as total_cost
FROM cte1 c
WHERE experience = 'Senior'
)

#number of seniors to hire
,
hired_seniors AS 
(
SELECT *
FROM total_seniors
HAVING total_cost < budget
)
#leftover money
,
leftover_money AS
(
SELECT IFNULL(budget - max(total_cost),70000) as budget
FROM hired_seniors
)
#total juniors
,
total_juniors AS 
(
SELECT 
    c.employee_id,
    c.experience,
    c.salary,
    SUM(salary) OVER(ORDER BY salary ASC) as total_cost,
    lm.budget
FROM cte1 c, leftover_money lm
WHERE experience = 'Junior'
)
#number of juniors to hire
,
hired_juniors AS 
(
SELECT *
FROM total_juniors
HAVING total_cost < budget
)

SELECT employee_id FROM hired_seniors
UNION
SELECT employee_id FROM hired_juniors
```

## Strings

### 2118
Build the Equation
https://leetcode.com/problems/build-the-equation/

```sql
# Write your MySQL query statement below
WITH a AS (
SELECT 
    CASE WHEN factor > 0 THEN '+' ELSE '' END as sign, 
    factor, 
    CASE WHEN power = 1 THEN 'X' 
        WHEN power = 0 THEN '' ELSE CONCAT('X^', power) END as x
    ,
    power
FROM Terms 
)

SELECT 
    CONCAT(
        GROUP_CONCAT(sign, factor, x ORDER BY power DESC SEPARATOR ''),
        '=0'
    ) AS equation
FROM a
```

### 2199
Finding the Topic of Each Post
https://leetcode.com/problems/finding-the-topic-of-each-post/

```sql
WITH cte1 AS 
(
SELECT DISTINCT
    p.post_id, p.content, k.topic_id, k.word
FROM Posts p
LEFT JOIN Keywords k
ON concat(' ', lower(p.content), ' ') like concat('% ', lower(k.word), ' %')
) 

SELECT 
    post_id, 
    COALESCE(GROUP_CONCAT(distinct topic_id order by topic_id),'Ambiguous!') as topic
FROM cte1
GROUP BY post_id
```
