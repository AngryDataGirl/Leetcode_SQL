# SQL - HARD - Recursive Queries

## Table of Contents
- [571](#571)
- [579](#579)
- [1336](#1336)
- [1384](#1384)
- [1635](#1635)
- [1645](#1645)
- [1651](#1651)
- [1767](#1767)
- [2153](#2153)
- [2474](#2474)
- [2494](#2494)

---

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

### 1645
1645. Hopper Company Queries II
https://leetcode.com/problems/hopper-company-queries-ii/

```sql
with recursive month (month) as
(
    select 1 as month
    union
    select month + 1
    from month
    where month < 12
),

total as
(
    select
        distinct m.month,
        count(distinct d.driver_id) as counter
    from month m, Drivers d
    where year(d.join_date) < 2020 or (year(d.join_date) = 2020 and month(d.join_date) <= m.month)
    group by 1
    order by 1
),

accept as
(
    select
        m.month,
        count(distinct b.driver_id) as counter2
    from month m
    left join (select
                    a.ride_id,
                    a.driver_id,
                    r.requested_at
    from AcceptedRides a left join Rides r on a.ride_id = r.ride_id
    where
        year(r.requested_at) = 2020) b on m.month = month(b.requested_at)
    group by 1
)

select
    m.month,
    ifnull(round(100*a.counter2/t.counter,2),0) as working_percentage
from total t
join accept a
    on t.month = a.month
right join month m
    on t.month = m.month
order by 1
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
### 2153
The Number of Passengers in Each Bus II
https://leetcode.com/problems/the-number-of-passengers-in-each-bus-ii/

```sql
WITH RECURSIVE A AS(
    SELECT bus_id,
    LAG(arrival_time, 1, -1) OVER( ORDER BY arrival_time) AS last_arrival_time,
    arrival_time,  capacity FROM Buses 
),
B AS(
    SELECT A.bus_id, A.arrival_time,  A.capacity, COUNT(P.passenger_id) AS passager_count FROM A LEFT JOIN Passengers P 
    ON A.last_arrival_time < P.arrival_time AND P.arrival_time<= A.arrival_time GROUP BY 1
),
C AS(
    SELECT bus_id, 
    capacity,
    passager_count AS total_passenger,
    ROW_NUMBER() OVER(ORDER BY arrival_time) AS id
    FROM B
),
D AS(
    SELECT bus_id,capacity , total_passenger,id,
    IF(capacity>total_passenger, total_passenger, capacity) AS passager_taken,
    IF(capacity<total_passenger, total_passenger - capacity, 0) AS passager_overleft
    FROM C WHERE id = 1
    UNION
    SELECT C.bus_id,C.capacity , C.total_passenger, C.id,
    IF(C.capacity>C.total_passenger+D.passager_overleft, C.total_passenger+D.passager_overleft, C.capacity) AS passager_taken,
    IF(C.capacity<C.total_passenger+D.passager_overleft, C.total_passenger+D.passager_overleft - C.capacity, 0) AS passager_overleft
    FROM C 
    INNER JOIN D ON D.id+1 = C.id
)
SELECT bus_id, passager_taken AS passengers_cnt FROM D ORDER BY 1
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

### 2494
Merge Overlapping Events in the Same Hall
https://leetcode.com/problems/merge-overlapping-events-in-the-same-hall/

```sql
# Write your MySQL query statement below

WITH RECURSIVE c1 AS (
    SELECT  ROW_NUMBER() OVER (ORDER BY hall_id, start_day) AS event_id,
            hall_id,
            start_day,
            end_day
    FROM HallEvents
), c2 AS (
    SELECT  event_id,
            hall_id,
            start_day,
            end_day
    FROM c1
    WHERE event_id = 1

    UNION ALL

    SELECT  c1.event_id,
            c1.hall_id,
            # for the same hall if there is overlap, change the start day and end day
            (CASE WHEN c1.hall_id = c2.hall_id 
              AND DATEDIFF(c2.end_day,c1.start_day)>=0 
              THEN c2.start_day 
              ELSE c1.start_day END) AS start_day,
            (CASE WHEN c1.hall_id = c2.hall_id 
              AND DATEDIFF(c2.end_day,c1.start_day)>=0 
              THEN GREATEST(c2.end_day,c1.end_day) 
              ELSE c1.end_day END) AS end_day
    FROM c2 JOIN c1 ON c2.event_id + 1 = c1.event_id
)

SELECT  hall_id,
        start_day,
        MAX(end_day) AS end_day
FROM c2
GROUP BY hall_id, start_day
```

