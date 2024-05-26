
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


### 
### 
### 
### 
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