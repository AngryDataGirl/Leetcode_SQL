- [175. Combine Two Tables](#175-combine-two-tables)
- [176. Second Highest Salary](#176second-highest-salary)
- [180. Consecutive Numbers](#180-consecutive-numbers)
- [181. Employees Earning More than their Managers](#181-employees-earning-more-than-their-managers)
- [182. Duplicate Emails](#182-duplicate-emails)
- [183. Customers Who Never Order](#183customers-who-never-order)
- [196. Delete Duplicate Emails](#196delete-duplicate-emails)
- [511. Game Play Analysis I](#511game-play-analysis-i)
- [512. Game Play Analysis II](#512game-play-analysis-ii)
- [574. Winning Candidate](#574winning-candidate)
- [577. Employee Bonus](#577-employee-bonus)
- [584. Find Customer Referee](#584find-customer-referee)
- [595. Big Countries](#595-big-countries)
- [597. Friend Requests I](#597-friend-requests-i)
- [607. Sales Person](#607sales-person)
- [608. Tree Node](#608tree-node)
- [613. Shortest Distance in a Line](#613shortest-distance-in-a-line)
- [627. Swap Salary](#627swap-salary)
- [1050. Actors and Directors Who Cooperated At Least Three Times](#1050-actors-and-directors-who-cooperated-at-least-three-times)
- [1068. Product Sales Analysis I](#1068product-sales-analysis-i)
- [1069. Product Sales Analysis II](#1069product-sales-analysis-ii)
- [1075. Project Employees I](#1075project-employees-i)
- [1076. Project Employees II](#1076project-employees-ii)
- [1082. Sales Analysis I](#1082sales-analysis-i)
- [1084. Sales Analysis III](#1084sales-analysis-iii)
- [1113. Reported Posts](#1113reported-posts)
- [1142. User Activity for the Past 30 Days II](#1142user-activity-for-the-past-30-days-ii)
- [1173. Immediate Food Delivery I](#1173immediate-food-delivery-i)
- [1211. Queries Quality and Percentage](#1211queries-quality-and-percentage)
- [1241. Number of Comments per Post](#1241number-of-comments-per-post)
- [1251. Average Selling Price](#1251average-selling-price)
- [1280. Students and Examinations](#1280students-and-examinations)
- [1294. Weather Type in Each Country](#1294weather-type-in-each-country)
- [1303. Find the Team Size](#1303find-the-team-size)
- [1322. Ads Performance](#1322ads-performance)
- [1378. Replace Employee ID With The Unique Identifier](#1378replace-employee-id-with-the-unique-identifier)
- [1393. Capital Gain/Loss](#1393capital-gainloss)
- [1421. NPV Queries](#1421npv-queries)
- [1407. Top Travellers](#1407top-travellers)
- [1435. Create a Session Bar Chart](#1435create-a-session-bar-chart)
- [1484. Group Sold Products By The Date](#1484group-sold-products-by-the-date)
- [1527. Patients With a Condition](#1527patients-with-a-condition)
- [1543. Fix Product Name Format](#1543fix-product-name-format)
- [1565. Unique Orders and Customers Per Month](#1565unique-orders-and-customers-per-month)
- [1571. Warehouse Manager](#1571warehouse-manager)
- [1581. Customer Who Visited but Did Not Make Any Transactions](#1581customer-who-visited-but-did-not-make-any-transactions)
- [1623. All Valid Triplets That Can Represent a Country](#1623all-valid-triplets-that-can-represent-a-country)
- [1633. Percentage of Users Attended a Contest](#1633percentage-of-users-attended-a-contest)
- [1661. Average Time of Process per Machine](#1661average-time-of-process-per-machine)
- [1667. Fix Names in a Table](#1667fix-names-in-a-table)
- [1677. Product's Worth Over Invoices](#1677products-worth-over-invoices)
- [1693. Daily Leads and Partners](#1693daily-leads-and-partners)
- [1683. Invalid Tweets](#1683invalid-tweets)
- [1731. The Number of Employees Which Report to Each Employee](#1731the-number-of-employees-which-report-to-each-employee)
- [1757. Recyclable and Low Fat Products](#1757-recyclable-and-low-fat-products)
- [1777. Product's Price for Each Store](#1777products-price-for-each-store)
- [1789. Primary Department for Each Employee](#1789primary-department-for-each-employee)
- [1795. Rearrange Products Table](#1795rearrange-products-table)
- [1809. Ad-Free Sessions](#1809ad-free-sessions)
- [1821. Find Customers With Positive Revenue this Year](#1821-find-customers-with-positive-revenue-this-year)
- [1853. Convert Date Format](#1853convert-date-format)
- [1873. Calculate Special Bonus](#1873calculate-special-bonus)
- [1890. The Latest Login in 2020](#1890the-latest-login-in-2020)
- [1939. Users That Actively Request Confirmation Messages](#1939users-that-actively-request-confirmation-messages)
- [1965. Employees With Missing Information](#1965employees-with-missing-information)
- [2026. Low-Quality Problems](#2026low-quality-problems)
- [2082. The Number of Rich Customers](#2082the-number-of-rich-customers)
- [2377. Sort the Olympic Table](#2377sort-the-olympic-table)
- [2339. All the Matches of the League](#2339all-the-matches-of-the-league)
- [2504. Concatenate the Name and the Profession](#2504concatenate-the-name-and-the-profession)
- [2329. Product Sales Analysis V](#2329product-sales-analysis-v)
- [2480. Form a Chemical Bond](#2480form-a-chemical-bond)
- [2985. Calculate Compressed Mean](#2985-calculate-compressed-mean)
- [2987. Find Expensive Cities](#2987-find-expensive-cities)

### 175. Combine Two Tables
https://leetcode.com/problems/combine-two-tables/

```sql
SELECT 
  p.firstName, 
  p.lastName, 
  a.city, 
  a.state
FROM Person p
LEFT JOIN Address a ON a.personId = p.personId
```

### 176. Second Highest Salary
https://leetcode.com/problems/second-highest-salary/

```sql
select max(salary) as SecondHighestSalary
from employee
where salary <(
  select max(salary)
  from  employee)
```

### 180. Consecutive Numbers
https://leetcode.com/problems/consecutive-numbers/description/

```sql
WITH lagged AS (
SELECT 
  lag(num) OVER(ORDER BY id) as last_num,
  num, 
  lead(num) OVER(ORDER BY id) as next_num
FROM Logs
)

SELECT 
  DISTINCT num as ConsecutiveNums
FROM lagged
WHERE last_num = num AND next_num = num
```

### 181. Employees Earning More than their Managers
https://leetcode.com/problems/employees-earning-more-than-their-managers/

get cartesian product of employee / employee in database and compare employee 1 to employee 2 and take those where employee 1 salary > employee 2 salary

```sql
select e1.name as Employee
from employee e1 
join employee e2 on e1.managerId = e2.id 
and e1.salary > e2.salary
```

### 182. Duplicate Emails
https://leetcode.com/problems/duplicate-emails/

```sql
SELECT email
FROM (
    Select email, count(email) as num
    from person
    group by email
)
as statistic
where num > 1
```

### 183. Customers Who Never Order
https://leetcode.com/problems/customers-who-never-order/

```sql
SELECT Name AS Customers
FROM CUSTOMERS
LEFT JOIN ORDERS
ON ORDERS.CustomerID = Customers.Id
WHERE Orders.CustomerID IS NULL
```

### 196. Delete Duplicate Emails
https://leetcode.com/problems/delete-duplicate-emails/

```sql
DELETE FROM Person
WHERE Id NOT IN (SELECT t.Id FROM (SELECT MIN(Id) AS Id FROM Person GROUP BY Email) t)
```

### 511. Game Play Analysis I
https://leetcode.com/problems/game-play-analysis-i/

```sql
SELECT player_id, 
MIN(event_date) as first_login
FROM Activity a
GROUP BY player_id
```

### 512. Game Play Analysis II
https://leetcode.com/problems/game-play-analysis-ii/

```sql
# get first login 
WITH first_login AS
(
    SELECT 
        player_id, 
        min(event_date) as event_date 
    FROM Activity 
    GROUP by player_id
)

# get result columns joining to first login
SELECT 
    a.player_id, 
    a.device_id
FROM Activity a
INNER JOIN first_login f1
ON f1.player_id = a.player_id
AND f1.event_date = a.event_date
```


### 574. Winning Candidate
https://leetcode.com/problems/winning-candidate/

```sql
WITH winner AS
(
    SELECT id, candidateId
    FROM Vote
    GROUP BY candidateId
    ORDER BY COUNT(*)
    DESC LIMIT 1
)

SELECT name
FROM Candidate c
JOIN winner w ON w.candidateId = c.Id
```

### 577. Employee Bonus
https://leetcode.com/problems/employee-bonus/

```sql
SELECT e.name, b.bonus 
FROM Employee e
LEFT JOIN Bonus b ON b.empId = e.empId
WHERE b.bonus < 1000 or bonus IS NULL
```

### 584. Find Customer Referee
https://leetcode.com/problems/find-customer-referee/

```sql
SELECT
    name
FROM
    Customer
	
# SOLUTION 1  - MOST EFFICIENT 
WHERE 
    IFNULL(referee_id,0) <> 2;
    
#SOLUTOIN 2    
WHERE
    referee_id != 2 OR referee_id is NULL

#SOLUTION 3   
WHERE
    COALESCE(referee_id, 0) <> 2

#===========================================
    
#SOLUTION 4  nested query 
SELECT  
    name
FROM 
    Customer
WHERE 
    id NOT IN
        (
        SELECT id
        FROM Customer
        WHERE referee_id = 2
        )
```

### 595. Big Countries
https://leetcode.com/problems/big-countries/

```sql
SELECT name, population, area
FROM world
WHERE population >= 25000000

UNION

SELECT name, population, area
FROM world
WHERE area >= 3000000
;
```

### 597. Friend Requests I
https://leetcode.com/problems/friend-requests-i-overall-acceptance-rate/

Notes from question:
- count all total accepted requests (may not only be from the friend_request table)
  - first CTE adds a row number to the request accepted table so we can eliminate duplicated requests
  - second CTE counts the total accepts per unique pair
- request could be accepted more than once, duplicated requests or acceptances should only be counted once
  - third CTE adds row number so we can filter for the requests (but only count them once)
- if there are no requests at all, return 0.00 as the accept rate 
  - last CTE adds an IFNULL in order to return 0.00 as accept rate while counting total requests 
  - final SELECT calculates the accept_rate while rounding 

not super performant, will have to revisit 
```sql
WITH numbered_accepts AS (
    SELECT 
        requester_id, accepter_id, accept_date, 
        row_number() OVER(partition by requester_id, accepter_id) as rn
    FROM RequestAccepted ra
),
unique_accepts AS 
(
    SELECT count(accepter_id) as total_accepts
    FROM numbered_accepts
    WHERE rn = 1
),
numbered_requests AS (
    SELECT sender_id, send_to_id, request_date, 
    row_number() OVER(partition by sender_id, send_to_id order by sender_id) as rn
    FROM FriendRequest fr
),
unique_requests AS 
(
    SELECT IFNULL(count(sender_id),0) as total_requests
    FROM numbered_requests
    WHERE rn = 1
)

SELECT IFNULL(ROUND(total_accepts/total_requests, 2),0.00) AS accept_rate
FROM unique_accepts, unique_requests
```

### 607. Sales Person
https://leetcode.com/problems/sales-person/

```sql
SELECT name
FROM SalesPerson 
WHERE name NOT IN (
    SELECT s.name
    FROM Orders o 
    JOIN Company c ON c.com_id = o.com_id
    JOIN SalesPerson s ON s.sales_id = o.sales_id
    WHERE c.name = "RED")
```

### 608. Tree Node
https://leetcode.com/problems/tree-node/

```sql
SELECT DISTINCT t1.id, (
    CASE
    WHEN t1.p_id IS NULL  THEN 'Root'
    WHEN t1.p_id IS NOT NULL AND t2.id IS NOT NULL THEN 'Inner'
    WHEN t1.p_id IS NOT NULL AND t2.id IS NULL THEN 'Leaf'
    END
) AS Type 
FROM tree t1
LEFT JOIN tree t2
ON t1.id = t2.p_id
```

### 613. Shortest Distance in a Line
https://leetcode.com/problems/shortest-distance-in-a-line/

```sql
WITH dist_betw_pts AS
(
SELECT p1.x as x1, p2.x as x2, ABS(p1.x - p2.x) as distance
FROM Point p1, Point p2
)

SELECT min(distance) as shortest
FROM dist_betw_pts
WHERE x1 != x2
```

### 627. Swap Salary
https://leetcode.com/problems/swap-salary/

```sql
UPDATE Salary
SET sex = CASE sex
WHEN 'm' THEN 'f'
WHEN 'f' THEN 'm'
ELSE NULL
END
```

### 1050. Actors and Directors Who Cooperated At Least Three Times
https://leetcode.com/problems/actors-and-directors-who-cooperated-at-least-three-times/

- the table is already shaped in a way where we can aggregate the actor/director pair
- the question is simply looking for a group by / having count 
- you could use a WHERE clause, but you would have to perform the aggregation and count in a subquery / CTE 

Solution using HAVING
```sql
SELECT 
  a1.actor_id, 
  a1.director_id
FROM 
  ActorDirector a1
GROUP BY 
  a1.actor_id, 
  a1.director_id
HAVING 
  COUNT(timestamp) >= 3
```

Solution using WHERE
```sql

SELECT actor_id, director_id
FROM
(
SELECT 
  actor_id, 
  director_id, 
  count(timestamp) as total_collab
FROM 
  ActorDirector
GROUP BY 
  actor_id, 
  director_id
) t
WHERE 
  total_collab >= 3
```

### 1068. Product Sales Analysis I
https://leetcode.com/problems/product-sales-analysis-i/

```sql
SELECT p.product_name, s.year, s.price
FROM Sales s
JOIN Product p ON p.product_id = s.product_id
```

### 1069. Product Sales Analysis II
https://leetcode.com/problems/product-sales-analysis-ii/

```sql
SELECT 
  product_id, 
  SUM(quantity) as total_quantity
FROM Sales s
GROUP By product_id
```

### 1075. Project Employees I
https://leetcode.com/problems/project-employees-i/

```SQL
SELECT project_id, ROUND(AVG(experience_years),2) as average_years
FROM Employee e
JOIN Project p ON p.employee_id = e.employee_id
GROUP BY project_id
```

### 1076. Project Employees II
https://leetcode.com/problems/project-employees-ii/

```sql
WITH total_employees AS
(
SELECT p.project_id, COUNT(e.employee_id) as total_emp_per_project
FROM Project p 
JOIN Employee e ON e.employee_id = p.project_id 
GROUP BY p.project_id
ORDER BY total_emp_per_project DESC
), 
max_emp AS
(
    SELECT MAX(total_emp_per_project)
    FROM total_employees
)

SELECT project_id
FROM total_employees
WHERE total_emp_per_project = (SELECT * FROM max_emp)
```

### 1082. Sales Analysis I
https://leetcode.com/problems/sales-analysis-i/

```sql
WITH total_sales AS 
(
SELECT 
    s.seller_id,
    p.product_id,
    p.product_name, 
    SUM(s.quantity) as total_quantity, 
    SUM(s.price) as total_price
FROM Sales s 
JOIN Product p ON s.product_id = p.product_id
GROUP BY s.seller_id
),
best_seller AS
(
SELECT max(total_price) as seller_max
FROM total_sales
)

SELECT seller_id 
FROM total_sales
WHERE total_price IN (SELECT seller_max FROM best_seller)
```

### 1084. Sales Analysis III
https://leetcode.com/problems/sales-analysis-iii/

```sql
select p.product_id, p.product_name
from Product p
join
(select s.product_id
from Sales s
group by s.product_id
having min(s.sale_date) >= DATE("2019-01-01") and
max(s.sale_date) <= DATE("2019-03-31")) as s1

on s1.product_id = p.product_id
```

### 1113. Reported Posts
https://leetcode.com/problems/reported-posts/

```sql
# AND action_date = DATE('2019-07-05') - 1

WITH post_actions_count AS
(
    SELECT 
        row_number() OVER(PARTITION BY post_id, action_date, action, extra 
                          ORDER BY post_id, action_date) as rn, 
        post_id, 
        action_date, 
        action, 
        extra    
    FROM Actions
    WHERE extra IS NOT NULL AND action = 'report'
    AND action_date = DATE('2019-07-05') -1
)

SELECT 
    extra as report_reason, 
    count(extra) as report_count
FROM post_actions_count
WHERE rn = 1
GROUP by extra
```

### 1142. User Activity for the Past 30 Days II
https://leetcode.com/problems/user-activity-for-the-past-30-days-ii/

```sql
WITH date_range AS
(
SELECT activity_date
FROM Activity 
WHERE activity_date < DATE('2019-07-27') 
    AND activity_date > DATE_SUB('2019-07-27', INTERVAL 30 DAY)
),
total_sessions_per_user AS
(
SELECT 
    user_id,  
    COUNT(DISTINCT session_id) as total_sessions
FROM Activity
WHERE activity_date IN (SELECT activity_date FROM date_range)
GROUP BY user_id
)

SELECT IFNULL(ROUND(AVG(total_sessions),2),0.00) as average_sessions_per_user
FROM total_sessions_per_user
```

### 1173. Immediate Food Delivery I
https://leetcode.com/problems/immediate-food-delivery-i/

```sql
SELECT
    ROUND(
        AVG(
            CASE WHEN order_date = customer_pref_delivery_date  
            THEN 1 ELSE 0 END
            ) * 100, 
        2) as immediate_percentage
    FROM Delivery
```

### 1211. Queries Quality and Percentage
https://leetcode.com/problems/queries-quality-and-percentage/

```sql
SELECT 
    query_name, 
    ROUND(AVG(rating / position),2) as quality,
    ROUND(SUM(CASE WHEN rating < 3 THEN 1 ELSE 0 END)/COUNT(rating)*100,2) as poor_query_percentage
FROM Queries
GROUP BY query_name
```

or

```sql
SELECT 
    query_name, 
    ROUND(AVG(rating / position),2) as quality, 
    ROUND(
        AVG(
            CASE WHEN rating < 3 THEN 1 ELSE 0 END
            ) * 100, 
        2) as poor_query_percentage
FROM Queries q
GROUP BY query_name
```

### 1241. Number of Comments per Post
https://leetcode.com/problems/number-of-comments-per-post/

```sql
WITH parents AS 
(
    SELECT DISTINCT sub_id as parent_id
    FROM Submissions
    Where parent_id IS NULL
), 
comments AS
(
    SELECT DISTINCT
        parent_id as post_id, 
        sub_id as comment_id
    FROM Submissions
    WHERE parent_id IS NOT NULL
)

SELECT p.parent_id as post_id, COUNT(comment_id) as number_of_comments
FROM parents p
LEFT JOIN comments c ON c.post_id = p.parent_id
GROUP BY p.parent_id
ORDER BY post_id ASC
```

### 1251. Average Selling Price
https://leetcode.com/problems/average-selling-price/

```sql
WITH updated_prices AS 
(
SELECT DISTINCT
    p.product_id, 
    p.start_date, 
    p.end_date,
    p.price, 
    us.purchase_date, 
    us.units
FROM Prices p, UnitsSold us
WHERE p.product_id = us.product_id
AND us.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id, us.purchase_date, p.price
),
total_units AS
(
    SELECT product_id, sum(units) as number_of_products
    FROM updated_prices
    GROUP BY product_id
),
total_price AS 
(
    SELECT product_id, purchase_date, SUM(units*price) AS total_price_of_product
    FROM updated_prices
    GROUP BY product_id
)

SELECT p.product_id, ROUND(total_price_of_product/number_of_products,2) as average_price
FROM total_price p JOIN total_units u ON p.product_id = u.product_id
```


### 1280. Students and Examinations
https://leetcode.com/problems/students-and-examinations/

```sql
WITH attendance_list AS 
(
SELECT s.student_id, s.student_name, sub.subject_name
FROM Students s, Subjects sub
)

SELECT a.*, COUNT(e.subject_name) AS attended_exams
FROM attendance_list a 
LEFT JOIN Examinations e ON e.subject_name = a.subject_name AND e.student_id = a.student_id
GROUP BY a.student_id, a.student_name, a.subject_name
ORDER BY a.student_id
```

### 1294. Weather Type in Each Country
https://leetcode.com/problems/weather-type-in-each-country/

```sql
SELECT DISTINCT c.country_name, w.weather_type
FROM Countries c 
JOIN
(
    SELECT 
        country_id, 
        CASE 
            WHEN AVG(weather_state) <= 15 THEN 'Cold'
            WHEN AVG(weather_state) >= 25 THEN 'Hot'
        ELSE 'Warm'
        END AS weather_type
    FROM Weather
    WHERE MONTH(day) = 11
    GROUP BY country_id
) w ON w.country_id = c.country_id
```

### 1303. Find the Team Size
https://leetcode.com/problems/find-the-team-size/

```sql
WITH team_size AS
(
    SELECT team_id, COUNT(employee_id) as team_size
    FROM Employee 
    GROUP BY team_id
)

SELECT employee_id, team_size
FROM Employee e JOIN team_size t ON t.team_id = e.team_id
```

### 1322. Ads Performance
https://leetcode.com/problems/ads-performance/

```sql
WITH totals AS
(
SELECT 
    ad_id, 
    COUNT(CASE WHEN action = 'Clicked' THEN 1 END) AS total_clicks,
    COUNT(CASE WHEN action = 'Viewed' THEN 1 END) AS total_views
FROM Ads a
GROUP BY a.ad_id
)

SELECT 
    ad_id, 
    IFNULL(ROUND(((total_clicks / (total_clicks+total_views)) * 100),2), 0.00) as ctr
FROM totals
ORDER BY ctr DESC, ad_id ASC
```

### 1378. Replace Employee ID With The Unique Identifier
https://leetcode.com/problems/replace-employee-id-with-the-unique-identifier/

```sql
SELECT 
    u.unique_id AS unique_id,
    e.name
FROM Employees e
LEFT JOIN EmployeeUNI u ON u.id = e.id
```

### 1393. Capital Gain/Loss
https://leetcode.com/problems/capital-gainloss/

```sql
SELECT stock_name, (bs.total_sell-bs.total_buy) as capital_gain_loss
FROM
(SELECT 
    stock_name,
    SUM(CASE WHEN operation = 'Buy' THEN price ELSE 0 END) as total_buy,
    SUM(CASE WHEN operation = 'Sell' THEN price ELSE 0 END) as total_sell
FROM Stocks
GROUP BY stock_name
) bs
```

### 1421. NPV Queries
https://leetcode.com/problems/npv-queries/

```sql
SELECT q.id, q.year,IFNULL(n.npv,0) AS npv
FROM Queries q
LEFT JOIN NPV n ON n.id = q.id AND n.year = q.year
```

### 1407. Top Travellers
https://leetcode.com/problems/top-travellers/

```sql
SELECT 
  distinct(u.name) as name, 
  ifnull(sum(r.distance),0) as travelled_distance
from users u
left join rides r on r.user_id = u.id
group by u.id
order by  travelled_distance desc, name asc
```

### 1435. Create a Session Bar Chart
https://leetcode.com/problems/create-a-session-bar-chart/

```sql
WITH session_in_minutes AS (
SELECT session_id, duration/60 as minutes
FROM Sessions 
)
,

bins AS
(
    SELECT '[0-5>' as bin
    UNION 
    SELECT '[5-10>' as bin
    UNION
    SELECT '[10-15>' as bin
    UNION
    SELECT '15 or more' as bin
),
transform AS 
(
    SELECT 
        session_id, 
        CASE 
            WHEN minutes >=0 and minutes <5 THEN '[0-5>'
            WHEN minutes >=5 and minutes <10 THEN '[5-10>'
            WHEN minutes >=10 and minutes <15 THEN '[10-15>'
            WHEN minutes >=15 THEN '15 or more'
            ELSE NULL END AS bin
    FROM session_in_minutes
)

SELECT b.bin, count(session_id) as total
FROM bins b LEFT JOIN transform t ON t.bin = b.bin
GROUP BY b.bin
```

### 1484. Group Sold Products By The Date
https://leetcode.com/problems/group-sold-products-by-the-date/

```sql
SELECT 
  sell_date, 
  COUNT(DISTINCT product) as num_sold, 
  GROUP_CONCAT(DISTINCT product) as "products"
FROM Activities
GROUP BY sell_date
```

### 1527. Patients With a Condition
https://leetcode.com/problems/patients-with-a-condition/

```sql
select patient_id, patient_name, conditions
from patients
where conditions like '% DIAB1%' or conditions like 'DIAB1%'

-- or 

SELECT * FROM patients WHERE conditions REGEXP '\\bDIAB1'
```

### 1543. Fix Product Name Format
https://leetcode.com/problems/fix-product-name-format/

```sql
# Write your MySQL query statement below
WITH format AS
(
SELECT 
sale_id,
TRIM(LOWER(product_name)) as product_name, 
DATE_FORMAT(sale_date, '%Y-%m') as sale_date
FROM Sales s
)

SELECT product_name, sale_date, COUNT(sale_id) AS total
FROM format
GROUP BY product_name, sale_date
ORDER BY product_name ASC, sale_date ASC
```

### 1565. Unique Orders and Customers Per Month
https://leetcode.com/problems/unique-orders-and-customers-per-month/

```sql
select 
    distinct left(order_date, 7) as month, 
    count(distinct order_id) as order_count, 
    count(distinct customer_id) as customer_count
from Orders
where invoice > '20'
group by month;
```

second solution, different syntax

```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(distinct order_id) as order_count, 
    COUNT(distinct customer_id) as customer_count
FROM Orders o 
WHERE invoice > 20
GROUP BY month
```

### 1571. Warehouse Manager
https://leetcode.com/problems/warehouse-manager/

```sql
WITH volume AS 
(SELECT 
    w.product_id, 
    w.name,
    p.Width * p.Length * p.Height * w.units as volume
FROM Warehouse w 
JOIN Products p ON p.product_id = w.product_id
)

SELECT 
    name as warehouse_name, 
    sum(volume) as volume
FROM volume
GROUP BY name
```

### 1581. Customer Who Visited but Did Not Make Any Transactions
https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/

```sql
SELECT v.customer_id, COUNT(v.visit_id) as "count_no_trans"
FROM Visits v
LEFT JOIN Transactions t on t.visit_id = v.visit_id
WHERE t.amount IS NULL
GROUP BY customer_id
```

### 1623. All Valid Triplets That Can Represent a Country
https://leetcode.com/problems/all-valid-triplets-that-can-represent-a-country/

```sql
SELECT 
    scA.student_name as member_A, 
    scB.student_name as member_B, 
    scC.student_name as member_C
FROM SchoolA scA, SchoolB scB, SchoolC scC
WHERE scA.student_id <> scB.student_id
AND scB.student_id <> scC.student_id
AND scA.Student_id <> scC.student_id
AND scA.student_name <> scB.student_name
AND scB.student_name <> scC.student_name
AND scA.student_name <> scC.student_name
```

### 1633. Percentage of Users Attended a Contest
https://leetcode.com/problems/percentage-of-users-attended-a-contest/

```sql
WITH total_users AS
(
    SELECT COUNT(DISTINCT user_id) as total_users
    FROM Users u
)

SELECT 
    r.contest_id, 
    ROUND((COUNT(distinct r.user_id)/total_users)*100,2) as percentage
FROM Register r 
JOIN total_users tu ON user_id = r.user_id
GROUP BY r.contest_id
ORDER BY percentage DESC, contest_id ASC
```

### 1661. Average Time of Process per Machine
https://leetcode.com/problems/average-time-of-process-per-machine/

```sql
WITH process AS (
SELECT 
    a1.machine_id, 
    a2.timestamp - a1.timestamp AS processing_time
FROM Activity a1, Activity a2
WHERE 
    a1.machine_id = a2.machine_id 
    AND a1.process_id = a2.process_id
    AND a1.timestamp < a2.timestamp 
GROUP BY a1.machine_id, a1.process_id
)

SELECT machine_id, 
    ROUND(AVG(processing_time),3) AS processing_time
FROM process
GROUP BY machine_id
```

### 1667. Fix Names in a Table
https://leetcode.com/problems/fix-names-in-a-table/

```sql
Select user_id, CONCAT(UPPER(SUBSTRING(name,1,1)),LOWER(SUBSTRING(name,2))) AS Name 
from users
order by user_id
```

### 1677. Product's Worth Over Invoices
https://leetcode.com/problems/products-worth-over-invoices/

coalesce()

```sql
SELECT 
    p.name, 
    COALESCE(SUM(i.rest),0) as rest,
    COALESCE(SUM(i.paid),0) as paid,
    COALESCE(SUM(i.canceled),0) as canceled,
    COALESCE(SUM(i.refunded),0) as refunded
FROM Product p
LEFT JOIN Invoice i ON i.product_id = p.product_id
GROUP BY p.name
ORDER BY p.name
```

### 1693. Daily Leads and Partners
https://leetcode.com/problems/daily-leads-and-partners/

```sql
SELECT
  date_id, 
  make_name,
  COUNT(DISTINCT lead_id) as unique_leads,
  COUNT(DISTINCT partner_id) as unique_partners
FROM DailySales
GROUP BY date_id, make_name
```

### 1683. Invalid Tweets
https://leetcode.com/problems/invalid-tweets/

```sql
SELECT 
    tweet_id
FROM Tweets
WHERE LENGTH(content) > 15
```

### 1731. The Number of Employees Which Report to Each Employee
https://leetcode.com/problems/the-number-of-employees-which-report-to-each-employee/

```sql
SELECT DISTINCT
    e2.employee_id,
    e2.name, 
    COUNT(e1.employee_id) AS reports_count, 
    ROUND(AVG(e1.age),0) AS average_age
FROM Employees e1
JOIN Employees e2 ON e1.reports_to = e2.employee_id
GROUP BY e2.employee_id, e2.name
ORDER BY employee_id
```

### 1757. Recyclable and Low Fat Products
https://leetcode.com/problems/recyclable-and-low-fat-products/

- filtering data with a WHERE clause 
- multiple conditions in WHERE clause
- the data is in a single table
- the filters are columns in the table 
- therefore, we can just specify the conditions in a WHERE clause

```sql
select 
    product_id 
from 
    Products 
where 
    low_fats='Y' 
    and recyclable='Y';
```

### 1777. Product's Price for Each Store
https://leetcode.com/problems/products-price-for-each-store/

```sql
WITH stores AS 
(
SELECT 
    product_id, 
    price,
    CASE WHEN store = 'store1' THEN price ELSE NULL END as 'store1',
    CASE WHEN store = 'store2' THEN price ELSE NULL END as 'store2',
    CASE WHEN store = 'store3' THEN price ELSE NULL END as 'store3'
FROM Products p
)

SELECT product_id, 
    sum(store1) as store1,
    sum(store2) as store2, 
    sum(store3) as store3
FROM stores
GROUP BY product_id
```

### 1789. Primary Department for Each Employee
https://leetcode.com/problems/primary-department-for-each-employee/

```sql
WITH rownum AS 
(
SELECT 
    row_number() OVER(partition by employee_id ORDER BY primary_flag) as rn,
    employee_id,
    department_id, 
    primary_flag
FROM Employee
)

SELECT employee_id, department_id
FROM rownum
WHERE rn = 1
```

### 1795. Rearrange Products Table
https://leetcode.com/problems/rearrange-products-table/

```sql
select 
    product_id, 
    'store1' as store, 
    store1 as price
from products 
where store1 is not null

union

select 
    product_id, 
    'store2' as store, 
    store2 as price
from products 
where store2 is not null

union 

select 
    product_id, 
    'store3' as store, 
    store3 as price
from products 
where store3 is not null
```

### 1809. Ad-Free Sessions
https://leetcode.com/problems/ad-free-sessions/

```sql
WITH sessions_shown_ads AS 
(
SELECT 
    p.session_id
FROM Playback p
JOIN Ads a ON a.customer_id = p.customer_id
WHERE a.timestamp >= p.start_time AND a.timestamp <= p.end_time
GROUP BY p.customer_id, p.session_id
)

SELECT p.session_id
FROM Playback p
WHERE p.session_id NOT IN (SELECT * FROM sessions_shown_ads)
```

### 1821. Find Customers With Positive Revenue this Year
https://leetcode.com/problems/find-customers-with-positive-revenue-this-year/

```SQL
SELECT customer_id
FROM Customers
WHERE revenue > 0 AND year = 2021
```

### 1853. Convert Date Format
https://leetcode.com/problems/convert-date-format/

```sql
SELECT DATE_FORMAT(day,'%W, %M %e, %Y') as day
FROM Days
```

### 1873. Calculate Special Bonus
https://leetcode.com/problems/calculate-special-bonus/

```sql
SELECT employee_id, if((employee_id % 2 <> 0)
                       and name not like 'M%',
                       salary,
                       0) as bonus
FROM Employees
ORDER BY employee_id

-- Method 1. Using CASE Expression https://www.w3schools.com/sql/sql_case.asp
SELECT employee_id, 
CASE WHEN employee_id % 2 = 1 and name not like 'M%' 
THEN salary 
ELSE 0 
END AS bonus 
FROM Employees 
ORDER BY employee_id;

-- Method 2. Using IF Function https://www.w3schools.com/sql/func_mysql_if.asp
SELECT employee_id, IF(employee_id % 2 = 1 and name not like 'M%', salary, 0) AS bonus 
FROM Employees 
ORDER BY employee_id;

-- Difference: The IF statement is useful if you're trying to evaluate something to a TRUE/FALSE condition. The CASE statement is used when you have multiple possible conditions.

-- Method 3. Without CASE and IF.
SELECT employee_id, salary * (employee_id % 2) * (name not like 'M%') as bonus 
FROM Employees 
ORDER BY employee_id;
-- The above one is simple, as the value of boolean is between 1, 0 so simply when the condition is not met the bonus become 0 else salary.
```

### 1890. The Latest Login in 2020
https://leetcode.com/problems/the-latest-login-in-2020/

```sql
select user_id, max(time_stamp) as last_stamp
from Logins 
group by user_id, year(time_stamp)
having year(last_stamp) = 2020
```

### 1939. Users That Actively Request Confirmation Messages
https://leetcode.com/problems/users-that-actively-request-confirmation-messages/

```sql
WITH diff AS 
(
SELECT
    c1.user_id,
    ABS(TIMESTAMPDIFF(SECOND,c1.time_stamp,c2.time_stamp)) as diff
FROM Confirmations c1
JOIN Confirmations c2 on C1.user_id = c2.user_id AND c1.time_stamp > c2.time_stamp
)

SELECT DISTINCT user_id
FROM diff
WHERE diff <= (60*60*24)
```

### 1965. Employees With Missing Information
https://leetcode.com/problems/employees-with-missing-information/

```sql
SELECT t1.employee_id
FROM
(SELECT e.employee_id
FROM Employees e 
UNION
SELECT s.employee_id
FROM Salaries s) as t1
LEFT JOIN Employees e on t1.employee_id = e.employee_id
LEFT JOIN Salaries s on t1.employee_id = s.employee_id
WHERE name IS NULL or salary IS NULL
ORDER BY employee_id ASC

--or--

SELECT employee_id 
FROM Employees 
WHERE employee_id NOT IN (SELECT employee_id FROM Salaries)
UNION 
SELECT employee_id 
FROM Salaries 
WHERE employee_id NOT IN (SELECT employee_id FROM Employees)

ORDER BY 1 ASC

```

### 2026. Low-Quality Problems
https://leetcode.com/problems/low-quality-problems/

```sql
WITH percentages AS
(
SELECT 
    problem_id, 
    (SUM(likes) / (SUM(likes)+SUM(dislikes)))*100 as low_quality
FROM Problems p
GROUP BY problem_id
)

SELECT problem_id
FROM percentages 
WHERE low_quality < 60
ORDER BY problem_id ASC
```

### 2082. The Number of Rich Customers
https://leetcode.com/problems/the-number-of-rich-customers/

```sql
SELECT COUNT(DISTINCT customer_id) AS rich_count
FROM Store
WHERE amount > 500
```

### 2377. Sort the Olympic Table
https://leetcode.com/problems/sort-the-olympic-table/

```sql
SELECT *
FROM Olympic
ORDER by gold_medals DESC, silver_medals DESC, bronze_medals DESC, country ASC
```

### 2339. All the Matches of the League
https://leetcode.com/problems/all-the-matches-of-the-league/

```sql
SELECT t1.team_name as home_team, t2.team_name as away_team
FROM Teams t1, Teams t2
WHERE t1.team_name <> t2.team_name
```

### 2504. Concatenate the Name and the Profession
https://leetcode.com/problems/concatenate-the-name-and-the-profession/

```sql
SELECT person_id, CONCAT(name, '(', LEFT(profession, 1), ')') AS name
FROM Person
ORDER BY person_id desc
```

### 2329. Product Sales Analysis V
https://leetcode.com/problems/product-sales-analysis-v/

```sql
WITH total_spend AS 
(
SELECT 
    s.user_id,
    s.product_id,
    s.quantity*p.price AS spending
FROM Sales s
LEFT JOIN Product p ON p.product_id = s.product_id
)

SELECT user_id, sum(spending) as spending
FROM total_spend
GROUP BY user_id
ORDER BY spending DESC
```

### 2480. Form a Chemical Bond
https://leetcode.com/problems/form-a-chemical-bond/

```sql
WITH metal AS
(SELECT symbol
FROM elements
WHERE type = 'Metal'),

nonmetal AS
(SELECT symbol
FROM elements
WHERE type = 'Nonmetal')

SELECT m.symbol as metal, nm.symbol as nonmetal
FROM metal m, nonmetal nm
```

### 2985. Calculate Compressed Mean
https://leetcode.com/problems/calculate-compressed-mean/

```sql
SELECT 
    ROUND(SUM(item_count*order_occurrences)/SUM(order_occurrences),2) as average_items_per_order
FROM orders
```

### 2987. Find Expensive Cities
https://leetcode.com/problems/find-expensive-cities/

```sql

SELECT city
FROM 
(

    SELECT city, avg_price 
    FROM (
        SELECT 
            city, avg(price) as avg_price
        FROM
            Listings
        GROUP BY city
        ) t
    HAVING avg_price > (SELECT avg(price) as price FROM Listings)

) t2

ORDER BY city ASC


```