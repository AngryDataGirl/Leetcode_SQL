- [185. Department Top Three Salaries](#185-department-top-three-salaries)
- [262. Trips and Users](#262-trips-and-users)
- [569. Median Employee Salary](#569-median-employee-salary)
- [601. Human Traffic of Stadium](#601-human-traffic-of-stadium)
- [615/ Average Salary: Departments VS Company](#615-average-salary-departments-vs-company)
- [618. Students Report By Geography](#618-students-report-by-geography)
- [1097. Game Play Analysis V](#1097-game-play-analysis-v)
- [1127. User Purchase Platform](#1127-user-purchase-platform)
- [1159. Market Analysis II](#1159-market-analysis-ii)
- [1194. Tournament Winners](#1194-tournament-winners)
- [1225. Report Contiguous Dates](#1225-report-contiguous-dates)
- [1336. Number of Transactions per Visit](#1336-number-of-transactions-per-visit)
- [1369. Get the Second Most Recent Activity](#1369-get-the-second-most-recent-activity)
- [1412. Find the Quiet Students in All Exams](#1412find-the-quiet-students-in-all-exams)
- [1479. Sales by Day of the Week](#1479-sales-by-day-of-the-week)
- [1892. Page Recommendations II](#1892-page-recommendations-ii)
- [1917. Leetcodify Friends Recommendations](#1917-leetcodify-friends-recommendations)
- [1919. Leetcodify Similar Friends](#1919-leetcodify-similar-friends)
- [1972. First and Last Call On the Same Day](#1972-first-and-last-call-on-the-same-day)
- [2004. The Number of Seniors and Juniors to Join the Company](#2004-the-number-of-seniors-and-juniors-to-join-the-company)
- [2010. The Number of Seniors and Juniors to Join the Company II](#2010-the-number-of-seniors-and-juniors-to-join-the-company-ii)
- [2362. Generate the Invoice](#2362generate-the-invoice)
- [2720. Popularity Percentage](#2720-popularity-percentage)
- [2793. Status of Flight Tickets](#2793-status-of-flight-tickets)
- [2991. Top Three Wineries](#2991-top-three-wineries)
- [2995. Viewers Turned Streamers](#2995-viewers-turned-streamers)

### 185. Department Top Three Salaries
https://leetcode.com/problems/department-top-three-salaries/

```sql
select 
    result.name as Employee,
    d.name as Department,
    result.salary as Salary
from
    (select 
        name, 
        departmentId,
        salary,
        dense_rank() over (
        partition by departmentId
        order by salary desc) as salaryRank
    from Employee e
    group by departmentId, name
    ) result
join Department d on d.id = result.departmentId 
where salaryRank <= 3
```

### 262. Trips and Users
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

### 569. Median Employee Salary
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

### 601. Human Traffic of Stadium
https://leetcode.com/problems/human-traffic-of-stadium/description/

```sql
SELECT
distinct s1.*

FROM
stadium s1, stadium s2, stadium s3

WHERE
s1.people >= 100 and
s2.people >= 100 and
s3.people >= 100

and
(
(s1.id - s2.id = 1 and s1.id - s3.id = 2 and s2.id - s3.id =1)  
    or
    (s2.id - s1.id = 1 and s2.id - s3.id = 2 and s1.id - s3.id =1) 
    or
    (s3.id - s2.id = 1 and s2.id - s1.id =1 and s3.id - s1.id = 2) 
)

order by s1.id
```

### 615/ Average Salary: Departments VS Company
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

### 618. Students Report By Geography
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

### 1097. Game Play Analysis V
https://leetcode.com/problems/game-play-analysis-v/

```sql
WITH activity1 AS 
(
SELECT 
  row_number() OVER(PARTITION BY player_id ORDER BY event_date) as rn,
  lead(event_date) OVER(PARTITION BY player_id ORDER BY event_date) as nxt_day,
  a.*
FROM Activity a 
)
,
installs AS 
(
SELECT 
  event_date as install_dt,
  count(player_id) as installs
FROM activity1
WHERE rn = 1
GROUP BY event_date
)
,
# SELECT * FROM installs
day1 AS 
(
SELECT 
  event_date, 
  count(player_id) as logged_in 
FROM Activity1
WHERE rn = 1 AND datediff(nxt_day,event_date) = 1
GROUP BY event_date
)

SELECT 
  i.install_dt,
  installs,
  round(ifnull(logged_in,0)/installs as Day1_retention 
FROM installs i
LEFT JOIN day1 d ON d.event_date = i.install_dt
```

### 1127. User Purchase Platform
https://leetcode.com/problems/user-purchase-platform/

```sql
select c.spend_date, c.platform, sum(coalesce(amount,0)) total_amount, sum(case when amount is null then 0 else 1 end) total_users 
    from
    
    (select distinct spend_date, 'desktop' platform from spending 
    union all
    select distinct spend_date, 'mobile' platform from spending 
    union all
    select distinct spend_date, 'both' platform from spending) c
    
    left join
    
    (select user_id, spend_date, case when count(*)=1 then platform else 'both' end platform, sum(amount) amount 
        from spending group by user_id, spend_date) v
    
    on c.spend_date=v.spend_date and c.platform=v.platform
    group by spend_date, platform;
```

### 1159. Market Analysis II
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

### 1194. Tournament Winners
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

### 1336. Number of Transactions per Visit
https://leetcode.com/problems/number-of-transactions-per-visit/

```sql
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

### 1369. Get the Second Most Recent Activity
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

### 1412. Find the Quiet Students in All Exams
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

### 1479. Sales by Day of the Week
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

### 1892. Page Recommendations II
https://leetcode.com/problems/page-recommendations-ii/

```sql
# Write your MySQL query statement below

# combine to get all friendships
WITH mod_friend AS 
(
SELECT 
  user1_id as user, user2_id as friend
FROM Friendship
UNION
SELECT
  user2_id as user, user1_id as friend
FROM Friendship
ORDER BY user
)
# need to get all the pages liked by a friend
,
friend_likes AS 
(
SELECT user as user_id, page_id, count(friend) as friends_likes
FROM mod_friend f
LEFT JOIN Likes l 
  ON l.user_id = f.friend
# filter clause 
GROUP BY user, page_id
)

SELECT 
  f.*
FROM friend_likes f
LEFT JOIN Likes l 
  ON l.user_id = f.user_id AND l.page_id = f.page_id 
WHERE l.user_id IS NULL
```

### 1917. Leetcodify Friends Recommendations
https://leetcode.com/problems/leetcodify-friends-recommendations/

Example output correct, expected output wrong, think it's a bug 

```sql
# Write your MySQL query statement below

WITH same_day_listens AS 
(
SELECT DISTINCT
  l1.user_id AS user1_id,
  l2.user_id AS user2_id
FROM Listens l1 
JOIN Listens l2 
  ON l1.song_id = l2.song_id 
  AND l1.day=l2.day 
  AND l1.user_id < l2.user_id
WHERE NOT EXISTS(
    SELECT * 
    FROM Friendship f 
    WHERE l1.user_id = f.user1_id 
    AND l2.user_id = f.user2_id)
GROUP BY 
  l1.user_id, 
  l2.user_id, 
  l1.day
HAVING 
  COUNT(DISTINCT l1.song_id) >= 3
) 

SELECT 
  user1_id AS user_id,
  user2_id AS recommended_id
FROM same_day_listens
UNION
SELECT 
  user2_id AS user_id,
  user1_id AS recommended_id
FROM same_day_listens
```

### 1919. Leetcodify Similar Friends
https://leetcode.com/problems/leetcodify-similar-friends/description/

```sql
WITH same_day_listens AS (
SELECT
  DISTINCT
  f.*,
  l.song_id,
  l.day
FROM Friendship f
LEFT JOIN Listens l ON 
  l.user_id = f.user1_id 
LEFT JOIN Listens l2 ON
  l2.user_id = f.user2_id AND l2.day = l.day 
WHERE l2.song_id = l.song_id
)
, cumulative AS (
SELECT 
  sd.*,
  dense_rank() OVER(PARTITION BY user1_id, user2_id, song_id, day) as rn
FROM same_day_listens sd
ORDER BY 1,2,3
)

  SELECT DISTINCT
    user1_id,
    user2_id
  FROM 
    cumulative
  GROUP BY user1_id, user2_id, day
  HAVING count(rn) >= 3
```

### 1972. First and Last Call On the Same Day
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

### 2004. The Number of Seniors and Juniors to Join the Company
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


### 2010. The Number of Seniors and Juniors to Join the Company II
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

### 2362. Generate the Invoice
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

### 2720. Popularity Percentage
https://leetcode.com/problems/popularity-percentage/

```sql
# total number of friends user has 
WITH total_friends AS 
(
(
SELECT 
  user1 as user,
  user2 as friend
FROM Friends 
)
UNION ALL
(
SELECT 
  user2 as user,
  user1 as friend
FROM Friends 
)
ORDER BY user ASC, friend ASC
)
,
distinct_friends AS 
(
  SELECT DISTINCT *
  FROM total_friends
)
,
# total users on platform 
total_users AS 
(
  SELECT 
    count(distinct user) as platform_total
  FROM total_friends 
)

#calculate popularity percentage as friends/total users * 100 rounded to 2 decimals
SELECT 
user as user1,
# count(friend),
# platform_total,
round((count(friend)/platform_total)*100,2) as percentage_popularity
FROM distinct_friends, total_users
GROUP BY user
```

### 2793. Status of Flight Tickets
https://leetcode.com/problems/status-of-flight-tickets/description/

```sql
WITH booking_order AS 
(
SELECT 
  p.*,
  f.capacity,
  row_number() OVER(PARTITION BY flight_id ORDER BY booking_time) as rn 
FROM Passengers p
LEFT JOIN Flights f ON f.flight_id = p.flight_id
)

SELECT 
  passenger_id,
  CASE WHEN rn <= capacity THEN 'Confirmed'
  ELSE 'Waitlist'
  END AS Status
FROM booking_order
ORDER BY passenger_id ASC
```

### 2991. Top Three Wineries

```sql
WITH RankedWineries AS (
    SELECT
        country,
        winery,
        SUM(points) as total_points,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(points) DESC, winery ASC) as winery_rank
    FROM Wineries
    GROUP BY country, winery
)
,
rw_clean AS (
    SELECT 
        country, 
        CONCAT(winery, ' (', total_points, ')') as winery,
        winery_rank
    FROM RankedWineries
)

SELECT
    country,
    CASE WHEN winery_rank = 1 THEN winery END as top_winery,
    COALESCE(MAX(CASE WHEN winery_rank = 2 THEN winery END), 'No second winery') as second_winery,
    COALESCE(MAX(CASE WHEN winery_rank = 3 THEN winery END), 'No third winery') as third_winery
FROM rw_clean
GROUP BY country
ORDER BY country;
```
### 2995. Viewers Turned Streamers
https://leetcode.com/problems/viewers-turned-streamers/ 

```python
# Write your MySQL query statement below

WITH viewer_first 
AS (

    SELECT * FROM 
    (    
    SELECT 
        s.*, 
        row_number() OVER(PARTITION BY user_id ORDER BY session_start ASC) as rn
    FROM Sessions s 
    ) t
    where rn = 1 
    and session_type = 'Viewer'
)

SELECT 
    s.user_id,
    COUNT(CASE WHEN session_type = 'Streamer' THEN 1 ELSE NULL END) AS sessions_count 
FROM Sessions s
WHERE s.user_id IN (SELECT user_id FROM viewer_first)
GROUP BY 1 
HAVING COUNT(CASE WHEN session_type = 'Streamer' THEN 1 ELSE NULL END) > 0
ORDER BY COUNT(CASE WHEN session_type = 'Streamer' THEN 1 ELSE NULL END) DESC, user_id DESC
```

### 3061. Calculate Trapping Rain Water
https://leetcode.com/problems/calculate-trapping-rain-water/

```sql
# Write your MySQL query statement below
with cte as (
    select id, height,
    max(height) over (order by id asc) as from_left_max,
    max(height) over (order by id desc) as from_right_max
    from heights
    order by id
)

SELECT sum(trapped_water) as total_trapped_water
FROM(
SELECT 
    cte.*, 
    least(from_left_max, from_right_max) as lowest_side, 
    least(from_left_max, from_right_max) - height as trapped_water
FROM cte
) t
```