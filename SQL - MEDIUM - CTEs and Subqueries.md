
- [570. Managers with at Least 5 Direct Reports](#570managers-with-at-least-5-direct-reports)
- [578. Get Highest Answer Rate Question](#578get-highest-answer-rate-question)
- [580. Count Student Number in Departments](#580count-student-number-in-departments)
- [614. Second Degree Follower](#614second-degree-follower)
- [1264. Page Recommendations](#1264-page-recommendations)
- [1270. All People Report to the Given Manager](#1270all-people-report-to-the-given-manager)
- [1355. Activity Participants](#1355activity-participants)
- [1364. Number of Trusted Contacts of a Customer](#1364number-of-trusted-contacts-of-a-customer)
- [1555. Bank Account Summary](#1555bank-account-summary)
- [1811. Find Interview Candidates](#1811-find-interview-candidates)
- [1843. Suspicious Bank Accounts](#1843suspicious-bank-accounts)
- [1867. Orders With Maximum Quantity Above Average](#1867-orders-with-maximum-quantity-above-average)
- [1907. Count Salary Categories](#1907count-salary-categories)
- [1934. Confirmation Rate](#1934confirmation-rate)
- [1949. Strong Friendship](#1949-strong-friendship)
- [1951. All the Pairs With the Maximum Number of Common Followers](#1951all-the-pairs-with-the-maximum-number-of-common-followers)
- [1990. Count the Number of Experiments](#1990count-the-number-of-experiments)
- [2020. Number of Accounts That Did Not Stream](#2020number-of-accounts-that-did-not-stream)
- [2041. Accepted Candidates From the Interviews](#2041accepted-candidates-from-the-interviews)
- [2051. The Category of Each Member in the Store](#2051the-category-of-each-member-in-the-store)
- [2084. Drop Type 1 Orders for Customers With Type 0 Orders](#2084drop-type-1-orders-for-customers-with-type-0-orders)
- [2175. The Change in Global Rankings](#2175the-change-in-global-rankings)
- [2238. Number of Times a Driver Was a Passenger](#2238number-of-times-a-driver-was-a-passenger)
- [2292. Products With Three or More Orders in Two Consecutive Years](#2292products-with-three-or-more-orders-in-two-consecutive-years)
- [2388. Change Null Values in a Table to the Previous Value](#2388change-null-values-in-a-table-to-the-previous-value)
- [2394. Employees With Deductions](#2394employees-with-deductions)
- [3050. Pizza Toppings Cost Analysis](#3050-pizza-toppings-cost-analysis)
- [3052. Maximize Items](#3052-maximize-items)

### 570. Managers with at Least 5 Direct Reports
https://leetcode.com/problems/managers-with-at-least-5-direct-reports/

```sql
WITH grouped AS 
(
SELECT managerId, COUNT(id) as direct_reports
FROM Employee
GROUP BY managerId
)

SELECT e.name
FROM grouped g
JOIN Employee e ON e.id = g.managerId
WHERE direct_reports >= 5
```

### 578. Get Highest Answer Rate Question
https://leetcode.com/problems/get-highest-answer-rate-question/

```sql
WITH answers AS
(
SELECT id, question_id, COUNT(question_id) as answer
FROM SurveyLog 
WHERE action = 'answer'
GROUP BY id, question_id
)
,
shown AS
(
SELECT id, question_id, COUNT(question_id) as shown
FROM SurveyLog 
WHERE action = 'show'
GROUP BY id, question_id
)
,
tallies AS 
(
SELECT  
    s.id, 
    s.question_id, 
    IFNULL(a.answer,0) as total_answered, 
    IFNULL(q.shown,0) as total_shown
FROM SurveyLog s
LEFT JOIN answers a ON
    a.id = s.id AND a.question_id = s.question_id
LEFT JOIN shown q ON
    q.id = s.id AND q.question_id = s.question_id
GROUP BY id, question_id
)
,
answer_rates_per_q AS 
(
SELECT id, question_id, total_answered/total_shown as answer_rate
FROM tallies
)
,
max_ar AS
(
SELECT question_id, answer_rate
FROM answer_rates_per_q
ORDER BY answer_rate DESC, question_id ASC
)

SELECT question_id as 'survey_log'
FROM max_ar
LIMIT 1
```

### 580. Count Student Number in Departments
https://leetcode.com/problems/count-student-number-in-departments/

```sql
WITH total_students AS
(
SELECT dept_id, COUNT(student_id) as student_number
FROM Student 
GROUP BY dept_id
)

SELECT d.dept_name, IFNULL(s.student_number, 0) as student_number
FROM Department d
LEFT JOIN total_students s ON s.dept_id = d.dept_id
ORDER BY s.student_number DESC, d.dept_name ASC
```

### 614. Second Degree Follower
https://leetcode.com/problems/second-degree-follower/

```sql
WITH crit1 AS
(
SELECT followee
FROM Follow
GROUP BY followee
HAVING COUNT(follower) >= 1
)
,
crit2 AS
(
SELECT follower
FROM Follow
GROUP BY follower
HAVING COUNT(followee) >= 1
)
,
second_degree AS 
(
SELECT * FROM crit1 c1
WHERE followee IN (SELECT * FROM crit2)
)

SELECT followee as follower, COUNT(follower) as num
FROM Follow
WHERE followee IN (SELECT * FROM second_degree)
GROUP BY followee
ORDER BY followee ASC
```

### 1264. Page Recommendations
https://leetcode.com/problems/page-recommendations/

```sql
SELECT DISTINCT page_id AS recommended_page
FROM 
    (SELECT 
        CASE WHEN user1_id=1 THEN user2_id
            WHEN user2_id=1 THEN user1_id
        END AS user_id
FROM Friendship) a
JOIN Likes
ON a.user_id=Likes.user_id
WHERE page_id NOT IN (SELECT page_id FROM Likes WHERE user_id=1)
```

### 1270. All People Report to the Given Manager
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

### 1355. Activity Participants
https://leetcode.com/problems/activity-participants/

```sql
WITH activity_participants AS
(
SELECT 
    a.id as activity_id,
    COUNT(f.id) as total_participants
FROM Friends f
LEFT JOIN Activities a ON a.name = f.activity
GROUP BY activity_id
)

SELECT name as activity 
FROM activity_participants ap 
	JOIN Activities a ON a.id = ap.activity_id
WHERE total_participants NOT IN (
			SELECT max(total_participants) as participants FROM activity_participants 
			UNION 
			SELECT min(total_participants) as participants FROM activity_participants 
)
```

### 1364. Number of Trusted Contacts of a Customer
https://leetcode.com/problems/number-of-trusted-contacts-of-a-customer/

```sql
WITH customers_with_contacts AS (
    SELECT cus.customer_id, cus.customer_name, cus.email, con.contact_name
    FROM Customers cus
    LEFT JOIN Contacts con ON con.user_id = cus.customer_id 
)
,
contacts_cnt AS (
    SELECT customer_id, customer_name, COUNT(contact_name) as contacts_cnt
    FROM customers_with_contacts 
    GROUP BY customer_id
)
,
trusted_contacts AS (
    SELECT customer_id, customer_name, COUNT(contact_name) as trusted_contact_cnt
    FROM customers_with_contacts
    WHERE contact_name IN (SELECT customer_name FROM Customers)
    GROUP BY customer_id
)

SELECT 
    i.invoice_id,
    c.customer_name,
    i.price, 
    IFNULL(cc.contacts_cnt,0) as contacts_cnt,
    IFNULL(tc.trusted_contact_cnt,0) as trusted_contacts_cnt
FROM Invoices i
LEFT JOIN Customers c ON c.customer_id = i.user_id 
LEFT JOIN contacts_cnt cc ON cc.customer_id = c.customer_id
LEFT JOIN trusted_contacts tc ON tc.customer_id = c.customer_id
ORDER BY 1 ASC
```

### 1555. Bank Account Summary
https://leetcode.com/problems/bank-account-summary/

```sql
#make tall
WITH Transactions_tall AS (
#outflow
SELECT 
    trans_id, 
    paid_by AS user_id, 
    0 - amount  as amount
FROM Transactions t1 
UNION
#inflow
SELECT 
    trans_id,
    paid_to AS user_id, 
    amount as amount
FROM Transactions t2
)
,
running_bal AS (
SELECT 
    u.user_id, 
    u.user_name, 
    u.credit, 
    IFNULL(SUM(tt.amount),0) as cash_flow
FROM Users u 
LEFT JOIN Transactions_tall tt ON u.user_id = tt.user_id
GROUP BY user_id, user_name, credit
)

SELECT 
    user_id, 
    user_name,
    IFNULL(credit + cash_flow,0) as credit,
    CASE WHEN IFNULL(credit + cash_flow,0) < 0 THEN 'Yes' ELSE 'No' END AS credit_limit_breached
FROM running_bal
GROUP BY user_id, user_name
```

### 1811. Find Interview Candidates 
https://leetcode.com/problems/find-interview-candidates/

```sql
#make tall
WITH cte1 AS 
(
SELECT contest_id, gold_medal as user_id, "gold_medal" as medal
FROM Contests
UNION 
SELECT contest_id, silver_medal as user_id, "silver_medal" as medal
FROM Contests
UNION 
SELECT contest_id, bronze_medal as user_id, "bronze_medal" as medal
FROM Contests
)

#join
SELECT DISTINCT u.name, u.mail
FROM Users u
JOIN
(SELECT gold_medal as user_id
FROM Contests
GROUP BY gold_medal
HAVING COUNT(gold_medal) >= 3

UNION ALL

SELECT a.user_id
FROM cte1 a
JOIN cte1 b ON b.contest_id = a.contest_id +1 AND b.user_id = a.user_id
JOIN cte1 c ON c.contest_id = a.contest_id +2 AND c.user_id = a.user_id) t ON t.user_id = u.user_id
```

### 1843. Suspicious Bank Accounts
https://leetcode.com/problems/suspicious-bank-accounts/
* consecutive 

```sql
with monthly_income as 
(
    SELECT 
        t.account_id,
        DATE_FORMAT(t.day,"%y%m") AS month,a.max_income
    FROM Accounts as a 
    JOIN Transactions as t
    ON a.account_id=t.account_id
    GROUP BY 1, 2
    HAVING SUM((type='Creditor')*amount)>a.max_income
)

SELECT DISTINCT a.account_id
FROM monthly_income as a JOIN monthly_income as b
ON a.account_id=b.account_id AND PERIOD_DIFF(a.month,b.month)=1
ORDER BY account_id;
```

### 1867. Orders With Maximum Quantity Above Average
https://leetcode.com/problems/orders-with-maximum-quantity-above-average/

```sql
with

  cte_user_agg as (
    select
      order_id,
      sum(quantity) / count(product_id) as avg_quantity,
      max(quantity) as max_quantity
    from OrdersDetails
    group by 1
  ),
  
  cte_filter as (
    select
      order_id
    from cte_user_agg
    where max_quantity > (
      select max(avg_quantity) from cte_user_agg 
    )
  )
  
select * from cte_filter
```

### 1907. Count Salary Categories
https://leetcode.com/problems/count-salary-categories/

```sql
#create categories 
WITH categories AS 
(
SELECT "Low Salary" as category FROM dual
UNION
SELECT "Average Salary" as category FROM dual
UNION 
SELECT "High Salary" as category FROM dual
)
,
sorted AS 
(
SELECT
    account_id,
    CASE 
        WHEN income < 20000 THEN "Low Salary"
        WHEN income BETWEEN 20000 AND 50000 THEN "Average Salary"
        ELSE "High Salary"
    END as category
FROM Accounts
)

SELECT c.category, IFNULL(accounts_count,0) as accounts_count
FROM categories c
LEFT JOIN (
    SELECT category, COUNT(account_id) as accounts_count
    FROM sorted
    GROUP BY category) s 
ON s.category = c.category
```

### 1934. Confirmation Rate
https://leetcode.com/problems/confirmation-rate/

```sql
WITH tr AS 
(
SELECT *, count(action) as total_requests
FROM Confirmations
GROUP BY user_id
)
,
cr AS 
(
SELECT *, count(action) as confirmed_requests
FROM Confirmations
WHERE action = 'confirmed' 
GROUP BY user_id
)

SELECT 
    s.user_id, 
    ROUND(IFNULL(IFNULL(cr.confirmed_requests,0)/IFNULL(tr.total_requests,0),0),2) as confirmation_rate
FROM Signups s
LEFT JOIN tr ON tr.user_id = s.user_id
LEFT JOIN cr ON cr.user_id = s.user_id
```

### 1949. Strong Friendship
https://leetcode.com/problems/strong-friendship/

```sql
WITH cte AS 
(
    SELECT user1_id, user2_id 
    FROM friendship
    UNION 
    SELECT user2_id, user1_id 
    FROM friendship
)

SELECT c1.user1_id, 
    c2.user1_id as user2_id,
    count(*) as common_friend
FROM cte c1
JOIN cte c2 
    ON c1.user1_id < c2.user1_id 
    AND c1.user2_id = c2.user2_id 
WHERE (c1.user1_id, c2.user1_id) IN (SELECT * FROM friendship)
GROUP BY 1, 2
HAVING count(*) >= 3
```

### 1951. All the Pairs With the Maximum Number of Common Followers
https://leetcode.com/problems/all-the-pairs-with-the-maximum-number-of-common-followers/

```sql
#get all pairs
WITH total_followers AS 
(
SELECT 
r1.user_id as user1_id, 
r2.user_id as user2_id, 
count(*) as total_followers
FROM relations r1
JOIN relations r2 ON r1.follower_id = r2.follower_id 
WHERE r1.user_id < r2.user_id
GROUP BY 1, 2
),
max_followers AS 
(SELECT max(total_followers) as max_follow
FROM total_followers
)

SELECT user1_id, user2_id
FROM total_followers tf
JOIN max_followers mf 
WHERE tf.total_followers >= mf.max_follow
```

### 1990. Count the Number of Experiments
https://leetcode.com/problems/count-the-number-of-experiments/

```sql
WITH Platforms1 AS (
SELECT "Android" AS platform FROM dual
UNION
SELECT "IOS" AS platform FROM dual
UNION
SELECT "Web" AS platform FROM dual
)
,
Experiments1 AS (
SELECT "Reading" AS experiment_name  FROM dual
UNION
SELECT "Sports" AS experiment_name  FROM dual
UNION
SELECT "Programming" AS experiment_name  FROM dual
)
,
output AS (
SELECT DISTINCT platform, experiment_name
FROM Platforms1, Experiments1 
ORDER BY platform ASC, experiment_name ASC
)
,
totals AS (
SELECT platform, experiment_name, COUNT(experiment_id) as num_experiments
FROM Experiments
GROUP BY platform, experiment_name
)

SELECT o.platform, o.experiment_name, IFNULL(num_experiments,0) as num_experiments
FROM output o
LEFT JOIN totals t ON t.platform = o.platform AND t.experiment_name = o.experiment_name
```

### 2020. Number of Accounts That Did Not Stream
https://leetcode.com/problems/number-of-accounts-that-did-not-stream/

```sql
WITH active2021 AS 
(
SELECT *
FROM Subscriptions
WHERE end_date BETWEEN DATE('2021-01-01') AND DATE('2021-12-31')
)

SELECT COUNT(account_id) as accounts_count
FROM Streams
WHERE account_id IN (SELECT account_id FROM active2021)
AND YEAR(stream_date) <> 2021
```

### 2041. Accepted Candidates From the Interviews
https://leetcode.com/problems/accepted-candidates-from-the-interviews/

```sql
WITH scores AS 
(
    SELECT interview_id, sum(score) as total_score
    FROM Rounds 
    GROUP BY interview_id
    HAVING total_score > 15
)
,
exp AS 
(
    SELECT interview_id, years_of_exp
    FROM Candidates
    WHERE years_of_exp >= 2
)

SELECT c.candidate_id FROM scores s
JOIN exp ON exp.interview_id = s.interview_id
JOIN Candidates c ON c.interview_id = s.interview_id
```

### 2051. The Category of Each Member in the Store
https://leetcode.com/problems/the-category-of-each-member-in-the-store/

```sql
WITH cte1 AS 
(
SELECT m.member_id, m.name, count(v.visit_id) as num_visits, count(p.charged_amount) as num_purchases 
FROM Members m 
LEFT JOIN Visits v ON m.member_id = v.member_id
LEFT JOIN Purchases p ON p.visit_id = v.visit_id
GROUP BY m.member_id, m.name
)
,
cte2 AS 
(
SELECT member_id, name, ROUND((100*num_purchases)/num_visits,2) as conv_rate
FROM cte1 
)

# conversion rate = (100 * total number of purchases for the member) / total number of visits for the member.
SELECT member_id, name, 
    CASE WHEN conv_rate >= 80 THEN 'Diamond'
        WHEN conv_rate >= 50 AND conv_rate < 80 THEN 'Gold'
        WHEN conv_rate < 50 THEN 'Silver'
        ELSE 'Bronze'
    END AS category
FROM cte2
```

### 2084. Drop Type 1 Orders for Customers With Type 0 Orders
https://leetcode.com/problems/drop-type-1-orders-for-customers-with-type-0-orders/

```sql
# Write your MySQL query statement below

#get all type_0 orders
WITH cte1 AS (
SELECT * 
FROM Orders
WHERE order_type = 0
)
#those with at least 1 type_0
,
cte2 AS (
SELECT order_id, customer_id, COUNT(order_type) as total_type0
FROM cte1
GROUP BY customer_id
)

#combine cte 1 with orders filtered by cte2
SELECT order_id, customer_id, order_type FROM cte1
UNION
SELECT order_id, customer_id, order_type FROM Orders 
    WHERE order_type = 1 
    AND customer_id NOT IN (SELECT customer_id FROM cte2)
```

### 2175. The Change in Global Rankings
https://leetcode.com/problems/the-change-in-global-rankings/

```sql
#update the points
WITH updated_points AS (
SELECT 
    tp.team_id, 
    tp.name, 
    tp.points,
    pc.points_change, 
    tp.points + pc.points_change as updated_points
FROM TeamPoints tp 
JOIN PointsChange pc ON pc.team_id = tp.team_id
)
,
#get original ranking and updated ranking
rankings AS (
SELECT 
    team_id, name, points, points_change, updated_points, 
    rank() OVER(ORDER BY updated_points DESC, name ASC) as new_rank,
    rank() OVER(ORDER BY points DESC, name ASC) as old_rank
FROM updated_points
)

#calculate rank difference
SELECT team_id, name, 
    CASE 
        WHEN new_rank < old_rank THEN 0 - (CAST(new_rank AS SIGNED) - CAST(old_rank AS SIGNED))
        WHEN new_rank > old_rank THEN (CAST(old_rank AS SIGNED) - CAST(new_rank AS SIGNED))
        ELSE 0 END 
        AS rank_diff 
FROM rankings
ORDER BY points DESC, name ASC
```

### 2238. Number of Times a Driver Was a Passenger
https://leetcode.com/problems/number-of-times-a-driver-was-a-passenger/

```sql
#get drivers who were passengers
WITH cte1 AS
(
    SELECT DISTINCT passenger_id
    FROM Rides 
    WHERE passenger_id IN (SELECT driver_id FROM Rides)
) 
#create table for left join
,
cte2 AS 
(
    SELECT DISTINCT driver_id
    FROM Rides)

#count drivers
,
cte3 AS
(
    SELECT passenger_id, count(passenger_id) as cnt
    FROM Rides
    WHERE passenger_id IN (SELECT passenger_id FROM cte1)
    GROUP BY passenger_id
)

SELECT driver_id, IFNULL(cnt,0) as cnt FROM cte2
LEFT JOIN cte3 ON cte3.passenger_id = cte2.driver_id
```

### 2292. Products With Three or More Orders in Two Consecutive Years
https://leetcode.com/problems/products-with-three-or-more-orders-in-two-consecutive-years/

```sql
# Write your MySQL query statement below

#group and count the orders
WITH cte1 AS (
SELECT 
    product_id, 
    COUNT(order_id) as num_orders, 
    YEAR(purchase_date) as current_year 
FROM Orders o 
GROUP BY YEAR(purchase_date), product_id
HAVING num_orders >= 3
)
,
#lead on years so we can filter for consecutive years
cte2 AS (
SELECT 
    product_id, num_orders, current_year, 
    LEAD(current_year) OVER(PARTITION BY product_id ORDER BY current_year) AS next_year
FROM cte1
)

SELECT DISTINCT product_id FROM cte2
WHERE next_year = current_year + 1
```

### 2388. Change Null Values in a Table to the Previous Value
https://leetcode.com/problems/change-null-values-in-a-table-to-the-previous-value/

```sql
WITH cte1 AS (
SELECT id, drink, ROW_NUMBER() OVER () as rn
FROM CoffeeShop
)
, 
cte2 AS (
SELECT id, drink, rn, COUNT(drink) OVER(ORDER BY rn) as cnt 
FROM cte1
)

SELECT id, first_value(drink) OVER(PARTITION BY cnt) as drink FROM cte2
```

### 2394. Employees With Deductions
https://leetcode.com/problems/employees-with-deductions/

```sql
WITH cte1 AS 
(
SELECT *, 
timestampdiff(SECOND, in_time, out_time) as total_sec,
ROUND((timestampdiff(SECOND, in_time, out_time))/60,0) as total_min,
ROUND((timestampdiff(SECOND, in_time, out_time))/60/60,2) as total_hour
FROM Logs 
)
,
cte2 AS
(
SELECT employee_id, sum(total_hour) as total_hour FROM cte1
GROUP BY employee_id
)
,
cte3 AS 
(
SELECT e.employee_id, e.needed_hours, IFNULL(c.total_hour,0) as total_hour
FROM Employees e
LEFT JOIN cte2 c ON c.employee_id = e.employee_id
HAVING total_hour < needed_hours
)

SELECT employee_id
FROM cte3
```

### 3050. Pizza Toppings Cost Analysis
https://leetcode.com/problems/pizza-toppings-cost-analysis/

```sql
WITH pizzas AS 
(
SELECT 
    t1.topping_name t1, 
    t2.topping_name t2,  
    t3.topping_name t3,     
    ROUND((t1.cost + t2.cost + t3.cost),2) as total_cost
FROM Toppings t1, Toppings t2, Toppings t3
WHERE 
    t1.topping_name < t2.topping_name AND t2.topping_name < t3.topping_name
)

SELECT DISTINCT
CONCAT(t1,',',t2,',',t3) as pizza, total_cost
FROM pizzas
GROUP BY 1
ORDER BY 2 DESC, 1 ASC
```

### 3052. Maximize Items
https://leetcode.com/problems/maximize-items/

```sql
WITH prime AS 
(
SELECT 
    i.item_type,
    sum(square_footage) as sqft,
    count(item_id) as items
FROM Inventory i
WHERE item_type = "prime_eligible"
)
,
not_prime AS 
(
SELECT 
    i.item_type,
    sum(square_footage) as sqft,
    count(item_id) as items
FROM Inventory i
WHERE item_type = "not_prime"
)

SELECT 
    "prime_eligible" as item_type,
    floor(500000/prime.sqft) * prime.items as item_count
FROM prime
UNION
SELECT 
    "not_prime" as item_type,
    floor((500000- (floor(500000/prime.sqft) * prime.sqft)) / not_prime.sqft) * not_prime.items
FROM prime, not_prime
```