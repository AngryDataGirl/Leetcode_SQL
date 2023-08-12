# SQL - Hard

- [Recursive Queries](#recursive-queries) 
    - [571](#571)
    - [579](#579)
    - [1336](#1336)
    - [1384](#1384)
    - [1635](#1635)
    - [1651](#1651)
    - [1767](#1767)
    - [2474](#2474)

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

### 1384
1384. Total Sales Amount by Year
https://leetcode.com/problems/total-sales-amount-by-year/

- weird casting , no specification in the question, for me it was just the report year that needed to be cast into the proper CHAR type

```sql
# Write your MySQL query statement below

WITH recursive cte1 AS 
(
    #anchor
    SELECT 2018 as report_year
    UNION ALL
    #recursive 
    SELECT report_year + 1
    FROM cte1
    #condition
    WHERE report_year < (SELECT max(year(period_end)) FROM Sales)

)
,
cte2 AS (
SELECT *, 
    CASE 
        #when period start and end is same as report year
        WHEN year(period_start) = report_year AND year(period_end) = report_year 
            THEN DATEDIFF(period_end, period_start) + 1
        #when period start as same as report year but period end is not
        WHEN year(period_start) = report_year AND year(period_end) <> report_year 
            THEN DATEDIFF(DATE(CONCAT(year(period_start),"-12-31")), period_start) + 1
        #when period start and period end both not same as year
        WHEN year(period_start) <> report_year AND year(period_end) <> report_year
            THEN DATEDIFF(
                DATE(CONCAT(report_year,"-12-31")),
                DATE(CONCAT(report_year,"-01-01"))
                    ) + 1
        #when period end is same as report year 
        WHEN year(period_start) <> report_year AND year(period_end) = report_year
            THEN DATEDIFF(period_end, DATE(CONCAT(report_year,"-01-01"))) + 1 
        ELSE DATEDIFF(period_end, period_start)
        END AS sale_days_in_year
FROM Sales s, cte1
WHERE report_year >= year(period_start) AND report_year <= year(period_end)
ORDER BY product_id
)

SELECT 
    c.product_id, 
    p.product_name, 
    CAST(c.report_year AS CHAR(4)) as report_year, 
    sale_days_in_year * average_daily_sales as total_amount
FROM cte2 c
LEFT JOIN Product p ON p.product_id = c.product_id 
ORDER BY c.product_id, c.report_Year
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

### 569 
Median Employee Salary
https://leetcode.com/problems/median-employee-salary/

```sql
# Write your MySQL query statement below

WITH get_rank AS 
(
SELECT id, company, salary, RANK() OVER(PARTITION BY company ORDER BY salary ASC, id ASC) as rnk
FROM Employee
)
,
med_rank AS 
(
SELECT id, company, salary, floor(AVG(rnk)) as bottom, ceil(AVG(rnk)) as top
FROM get_rank
GROUP BY company
)
,
medians AS 
(
SELECT id, company, salary, bottom as median
FROM med_rank
UNION
SELECT id, company, salary, top as median
FROM med_rank
)

SELECT gr.id, gr.company, gr.salary
FROM get_rank gr
JOIN medians m
    ON m.company = gr.company 
    AND m.median = gr.rnk
```

### 615
Average Salary: Departments VS Company
https://leetcode.com/problems/average-salary-departments-vs-company/

```sql
#combine the tables
WITH cte1 AS 
(
SELECT e.employee_id, e.department_id, s.id as salary_id, s.amount, s.pay_date, DATE_FORMAT(pay_date, '%Y-%m') as pay_month  
FROM Employee e
JOIN Salary s ON s.employee_id = e.employee_id
)
#calculate company average salary by month
,
cte2 AS 
(
SELECT 
    pay_month, department_id, 
    AVG(amount) OVER(PARTITION BY pay_month) as company_avg, 
    AVG(amount) OVER(PARTITION BY pay_month, department_id) as dept_avg
FROM cte1
)

SELECT 
DISTINCT pay_month, department_id, 
    CASE WHEN dept_avg > company_avg THEN 'higher'
        WHEN dept_avg < company_avg THEN 'lower'
        ELSE 'same' END as comparison
FROM cte2
```
### 618
Students Report By Geography
https://leetcode.com/problems/students-report-by-geography/

```sql
WITH pivot AS 
(
SELECT
    CASE WHEN continent = 'America' THEN name END AS 'America',
    CASE WHEN continent = 'Asia' THEN name END AS 'Asia',
    CASE WHEN continent = 'Europe' THEN name END AS 'Europe',
    row_number() OVER(partition by continent ORDER BY name) as rn       
FROM Student
)

SELECT min(America) as America, min(Asia) as Asia, min(Europe) as Europe
FROM pivot
GROUP BY rn
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

### 1194
Tournament Winners
https://leetcode.com/problems/tournament-winners/

```sql
# Write your MySQL query statement below

# union 
WITH cte1 AS 
(
SELECT first_player as player_id, SUM(first_score) as total_points
FROM Matches
GROUP BY first_player
UNION ALL
SELECT second_player as player_id, SUM(second_score) as total_points
FROM Matches
GROUP BY second_player
)
,
#get total score
cte2 AS 
(
SELECT 
    player_id, SUM(total_points) as total_points
 FROM cte1 c
 GROUP BY player_id
)
,
#join group data & rank by criteria
cte3 AS 
(
SELECT c.*, p.group_id, rank() OVER(PARTITION BY group_id ORDER BY total_points DESC, player_id ASC) as rn
FROM cte2 c
LEFT JOIN Players p
    ON p.player_id = c.player_id
)

# SELECT group_id, player_id, total_points, rn
# FROM cte3
SELECT group_id, player_id 
FROM cte3
WHERE rn = 1
```

### 1369
1369. Get the Second Most Recent Activity
https://leetcode.com/problems/get-the-second-most-recent-activity/

```sql
# Write your MySQL query statement below
WITH cte1 AS (
SELECT DISTINCT 
    username, 
    activity, 
    startDate, 
    endDate, 
    row_number() OVER(PARTITION BY username ORDER BY startDate DESC) as rnk 
FROM UserActivity
)
, 
cte2 AS 
(
SELECT username, count(rnk)
FROM cte1 
GROUP BY username
HAVING count(rnk) = 1
)

SELECT username, activity, startDate, endDate
FROM cte1
WHERE rnk = 2 
OR username IN (SELECT username FROM cte2)
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

### 1479 
Sales by Day of the Week
https://leetcode.com/problems/sales-by-day-of-the-week/

```sql
SELECT 
    DISTINCT item_category AS Category,
    sum(case when dayofweek(order_date ) = 2 then quantity else 0 end) as Monday ,
    sum(case when dayofweek(order_date ) = 3 then quantity else 0 end) as Tuesday,
    sum(case when dayofweek(order_date ) = 4 then quantity else 0 end) as Wednesday,
    sum(case when dayofweek(order_date ) = 5 then quantity else 0 end) as Thursday,
    sum(case when dayofweek(order_date ) = 6 then quantity else 0 end) as Friday,
    sum(case when dayofweek(order_date ) = 7 then quantity else 0 end) as Saturday,
    sum(case when dayofweek(order_date ) = 1 then quantity else 0 end) as Sunday
FROM items i LEFT JOIN orders o ON o.item_id = i.item_id
GROUP BY Category
ORDER BY Category
```


### 1972
First and Last Call On the Same Day
https://leetcode.com/problems/first-and-last-call-on-the-same-day/

```sql
# rearrange table 
WITH cte1 AS 
(
SELECT caller_id, recipient_id, call_time 
FROM Calls
UNION 
SELECT recipient_id as caller_id, caller_id as recipient_id, call_time
FROM Calls
)
,
# get first call, rn to partition the call per day, but sort by timestamp to get the first / last 
cte2 AS 
(
SELECT 
    caller_id, 
    recipient_id, 
    DATE(call_time) as call_date, 
    row_number() OVER(PARTITION BY caller_id, DATE(call_time) ORDER BY call_time ASC) as rn
FROM cte1
)
,
first_call as 
(
SELECT * FROM cte2 
WHERE rn = 1
)
,
# get last call, rn to partition the call per day, but sort by timestamp to get the first / last 
cte3 as 
(
SELECT 
    caller_id, 
    recipient_id, 
    DATE(call_time) as call_date, 
    row_number() OVER(PARTITION BY caller_id, DATE(call_time) ORDER BY call_time DESC) as rn
FROM cte1
)
,
last_call AS (
SELECT * FROM cte3 
WHERE rn = 1
)

#first call and last call were to the same person on a given day, distinct to remove duplicate entries
SELECT DISTINCT fc.caller_id as user_id 
FROM first_call fc
JOIN last_call lc 
    ON fc.caller_id = lc.caller_id 
    AND fc.recipient_id = lc.recipient_id 
    AND fc.call_date = lc.call_date
```

### 2004 
The Number of Seniors and Juniors to Join the Company
https://leetcode.com/problems/the-number-of-seniors-and-juniors-to-join-the-company/

```sql
# Write your MySQL query statement below
WITH seniors AS 
(
SELECT 
    employee_id,
    experience, 
    salary, 
    SUM(salary) OVER(ORDER BY salary ASC, employee_id) as total_cost
FROM Candidates
WHERE experience = "Senior"
)
,
juniors AS 
(
    SELECT 
    employee_id,
    experience, 
    salary, 
    SUM(salary) OVER(ORDER BY salary ASC, employee_id) as total_cost
FROM Candidates
WHERE experience = "Junior"
)
,
accepted_seniors AS (
SELECT s.*, 70000 as budget
FROM seniors s
HAVING total_cost <= budget
)
,
leftover_monies AS (
SELECT IFNULL(budget-max(total_cost),70000) as remaining_budget
FROM accepted_seniors
)
,
accepted_juniors AS 
(
SELECT *
FROM juniors
JOIN leftover_monies
HAVING total_cost < remaining_budget
)
,
final_candidates AS 
(
SELECT * FROM accepted_seniors
UNION 
SELECT * FROM accepted_juniors
)

SELECT
    c.experience, 
    IFNULL(count(fc.employee_id),0) as accepted_candidates
FROM Candidates c
LEFT JOIN final_candidates fc ON c.employee_id = fc.employee_id
GROUP BY experience
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

### 2362 
2362. Generate the Invoice
https://leetcode.com/problems/generate-the-invoice/

```sql
# Write your MySQL query statement below

#get total cost on the invoice
WITH cte1 AS (
SELECT 
    p.invoice_id, 
    p.product_id, 
    p.quantity, 
    pr.price, 
    SUM(p.quantity * pr.price) as total_price 
FROM Purchases p
JOIN Products pr ON pr.product_id = p.product_id 
GROUP BY invoice_id
)
,

#rank the invoice total cost to get the max 
cte2 AS (
SELECT 
    invoice_id,
    dense_rank() OVER(ORDER BY total_price DESC, invoice_id ASC) as rnk
FROM cte1
)
,

#get the invoice with the highest price and the smallest ID 
cte3 AS (
SELECT invoice_id, rnk
FROM cte2
WHERE rnk = 1
)


#return final 
SELECT 
    pur.product_id, 
    pur.quantity, 
    prod.price * pur.quantity as price   
FROM Purchases pur 
LEFT JOIN products prod ON 
    prod.product_id = pur.product_id
WHERE pur.invoice_id IN (
    SELECT invoice_id 
    FROM cte3)
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
