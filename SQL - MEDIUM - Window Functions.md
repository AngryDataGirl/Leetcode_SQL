- [177. Nth Highest Salary](#177-nth-highest-salary)
- [184. Department Highest Salary](#184-department-highest-salary)
- [1077. Project Employees III](#1077project-employees-iii)
- [1107. New Users Daily Count](#1107new-users-daily-count)
- [1112. Highest Grade For Each Student](#1112highest-grade-for-each-student)
- [1126. Active Businesses](#1126active-businesses)
- [1164. Product Price at a Given Date](#1164product-price-at-a-given-date)
- [1174. Immediate Food Delivery II](#1174immediate-food-delivery-ii)
- [1204. Last Person to Fit in the Bus](#1204last-person-to-fit-in-the-bus)
- [1308. Running Total for Different Genders](#1308-running-total-for-different-genders)
- [1532. The Most Recent Three Orders](#1532the-most-recent-three-orders)
- [1454. Active Users](#1454active-users)
- [1549. The Most Recent Orders for Each Product](#1549the-most-recent-orders-for-each-product)
- [1596. The Most Frequently Ordered Products for Each Customer](#1596the-most-frequently-ordered-products-for-each-customer)
- [1709. Biggest Window Between Visits](#1709biggest-window-between-visits)
- [1747. Leetflex Banned Accounts](#1747leetflex-banned-accounts)
- [1831. Maximum Transaction Each Day](#1831maximum-transaction-each-day)
- [1875. Group Employees of the Same Salary](#1875group-employees-of-the-same-salary)
- [2066. Account Balance](#2066-account-balance)
- [2112. The Airport With the Most Traffic](#2112the-airport-with-the-most-traffic)
- [2159. Order Two Columns Independently](#2159-order-two-columns-independently)
- [2228. Users With Two Purchases Within Seven Days](#2228users-with-two-purchases-within-seven-days)
- [2314. The First Day of the Maximum Recorded Degree in Each City](#2314the-first-day-of-the-maximum-recorded-degree-in-each-city)
- [2324. Product Sales Analysis IV](#2324product-sales-analysis-iv)
- [2346. Compute the Rank as a Percentage](#2346-compute-the-rank-as-a-percentage)
- [2820. Election Results](#2820-election-results)

### 177. Nth Highest Salary
https://leetcode.com/problems/nth-highest-salary/

```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below.
       SELECT 
            CASE WHEN SALARY IS NULL THEN NULL
            ELSE SALARY END AS getNthHighestSalary 
        FROM (
            SELECT SALARY,ROW_NUMBER() OVER(ORDER BY SALARY DESC)RN
            FROM
                (
                    SELECT DISTINCT SALARY FROM EMPLOYEE
                )E
              )T
        WHERE RN=N
  );
END
```

### 184. Department Highest Salary
https://leetcode.com/problems/department-highest-salary/

```sql
WITH cte1 AS 
(
SELECT 
    e.name as employee_name, 
    e.salary, 
    d.name as dept_name, 
    rank() OVER(PARTITION BY departmentId ORDER BY salary DESC) as rnk
FROM Employee e 
LEFT JOIN Department d ON d.id = e.departmentId
)

SELECT dept_name as Department, employee_name as Employee, Salary 
FROM cte1 
WHERE rnk = 1
```

### 1077. Project Employees III
https://leetcode.com/problems/project-employees-iii/

```sql
WITH ranked AS (
SELECT p.project_id, e.employee_id, rank() OVER (PARTITION BY project_id ORDER BY e.experience_years DESC) as p_rank
FROM Project p 
JOIN Employee e ON e.employee_id = p.employee_id
)

SELECT project_id, employee_id
FROM ranked 
WHERE p_rank = 1
```

### 1107. New Users Daily Count
https://leetcode.com/problems/new-users-daily-count/

```sql
WITH fl AS 
(
    SELECT *, row_number() OVER(PARTITION BY user_id ORDER BY activity_date) as act_num
    FROM Traffic
    WHERE activity = 'login'
)
 
SELECT activity_date as login_date, COUNT(user_id) as user_count 
FROM fl
WHERE act_num = 1
AND activity_date BETWEEN DATE_SUB('2019-06-30', INTERVAL 90 DAY) AND '2019-06-30'
GROUP BY 1
```

### 1112. Highest Grade For Each Student
https://leetcode.com/problems/highest-grade-for-each-student/

```sql
WITH max_grades AS 
(
SELECT 
    student_id, course_id, grade,
    ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC, course_id ASC) as grade_rn
FROM Enrollments
)

SELECT student_id, course_id, grade
FROM max_grades
WHERE grade_rn = 1
```

### 1126. Active Businesses
https://leetcode.com/problems/active-businesses/

```sql
WITH avg_activity AS
(
SELECT
    *, 
    AVG(occurences) OVER(PARTITION BY event_type) as avg_of_event_type
FROM Events
)
,
greater_than_avg AS
(
SELECT *
FROM avg_activity
GROUP BY business_id, event_type
HAVING occurences > avg_of_event_type
)

SELECT business_id
FROM greater_than_avg
GROUP BY business_id
HAVING count(business_id) > 1
```

### 1164. Product Price at a Given Date
https://leetcode.com/problems/product-price-at-a-given-date/

```sql
WITH new_prices AS (
SELECT DISTINCT product_id,
    FIRST_VALUE(new_price) OVER (PARTITION BY product_id
    ORDER BY change_date DESC) as price
FROM products
WHERE change_date <= '2019-08-16'
)
,
distinct_products AS
(
SELECT DISTINCT product_id
FROM Products
)

SELECT dp.product_id, IFNULL(np.price,10) as price 
FROM distinct_products dp
LEFT JOIN new_prices np ON np.product_id = dp.product_id
```

### 1174. Immediate Food Delivery II
https://leetcode.com/problems/immediate-food-delivery-ii/

is there a faster way to calculate percentages?

```sql
# Write your MySQL query statement below
WITH crit1 AS 
(
SELECT delivery_id, customer_id, 
    CASE WHEN order_date = customer_pref_delivery_date THEN 'immediate' ELSE 'scheduled' END AS order_type, 
    rank() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_number
FROM Delivery
)
,
immediate_count AS
(
SELECT count(delivery_id) as immediate_total
FROM crit1
WHERE order_number = 1 AND order_type = 'immediate'
)
,
total_first AS 
(
    SELECT count(delivery_id) as total_first_order
    FROM crit1
    WHERE order_number = 1
)

SELECT ROUND((immediate_total/total_first_order)*100,2) as immediate_percentage 
FROM immediate_count, total_first
```

### 1204. Last Person to Fit in the Bus
https://leetcode.com/problems/last-person-to-fit-in-the-bus/

cumulative sum problem 

```sql
WITH total_weight AS (
SELECT 
    person_id, 
    person_name, 
    SUM(weight) OVER (ORDER BY turn) as cumulative_weight
FROM Queue
ORDER BY turn DESC
)

SELECT person_name
FROM total_weight
WHERE cumulative_weight <= 1000
LIMIT 1
```

### 1308. Running Total for Different Genders
https://leetcode.com/problems/running-total-for-different-genders/

```sql
SELECT 
    gender, 
    day,
    SUM(score_points) OVER(PARTITION BY gender ORDER BY day) as total
FROM Scores
```

### 1532. The Most Recent Three Orders
https://leetcode.com/problems/the-most-recent-three-orders/

```sql
WITH all_orders AS 
(
SELECT o.*, c.name,
    row_number() OVER(PARTITION BY c.customer_id ORDER BY order_date DESC) as rn
FROM Orders o
JOIN Customers c 
    ON c.customer_id = o.customer_id
)

SELECT name as customer_name, customer_id, order_id, order_date
FROM all_orders
WHERE rn <= 3
ORDER BY customer_name ASC, customer_id ASC, order_date DESC
```

### 1454. Active Users
https://leetcode.com/problems/active-users/
* continuous range question

```sql
\WITH distinct_days AS
(
SELECT DISTINCT login_date
FROM Logins
),

ranges AS 
(
SELECT l.id, a.name, l.login_date, 
    LEAD(l.login_date,4) OVER(PARTITION BY l.id ORDER BY l.login_date) as next_login
FROM Logins l 
JOIN Accounts a ON a.id = l.id
GROUP BY l.id, a.name, l.login_date
),

diffs AS
(
SELECT DISTINCT id, name, datediff(next_login, login_date) as diff
FROM ranges
HAVING diff = 4
)

SELECT id, name
FROM diffs
```

### 1549. The Most Recent Orders for Each Product
https://leetcode.com/problems/the-most-recent-orders-for-each-product/

```sql
WITH recent_orders AS (
SELECT o.product_id, o.order_id, o.order_date,
    dense_rank() OVER(PARTITION BY product_id ORDER BY order_date DESC) as rn
FROM Orders o
)

SELECT p.product_name, ro.product_id, ro.order_id, ro.order_date
FROM recent_orders ro
JOIN Products p ON p.product_id = ro.product_id
WHERE rn = 1
ORDER BY product_name ASC, product_id ASC, order_id ASC
```

### 1596. The Most Frequently Ordered Products for Each Customer
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

### 1709. Biggest Window Between Visits
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

### 1747. Leetflex Banned Accounts
https://leetcode.com/problems/leetflex-banned-accounts/

```sql
WITH distinct_log_info AS
(
    SELECT DISTINCT account_id, ip_address, login, logout
    FROM LogInfo
)
,
compared AS
(
SELECT *, 
    LAG(login) OVER(PARTITION BY account_id ORDER BY login) as prev_login,
    LAG(logout) OVER(PARTITION BY account_id ORDER BY login) as prev_logout,
    LAG(ip_address) OVER(PARTITION BY account_id ORDER BY login) as prev_ip
FROM distinct_log_info 
)
, 
banned AS
(
SELECT 
    account_id, 
    ip_address,
    prev_ip,
    prev_login,
    prev_logout, 
    login, 
    logout,
    CASE WHEN login <= prev_logout THEN 1 ELSE 0 END AS ban
FROM compared
WHERE date(login) = date(prev_login)
AND ip_address <> prev_ip
)

SELECT DISTINCT account_id
FROM banned
WHERE ban = 1
```


### 1831. Maximum Transaction Each Day
https://leetcode.com/problems/maximum-transaction-each-day/

```sql
WITH cte1 AS (
SELECT 
    transaction_id, 
    day, 
    amount,
    rank() OVER(PARTITION BY DATE(day) ORDER BY amount DESC) as rnk
FROM Transactions t
)

SELECT transaction_id FROM cte1
WHERE rnk = 1
ORDER BY transaction_id ASC
```

### 1875. Group Employees of the Same Salary
https://leetcode.com/problems/group-employees-of-the-same-salary/

```sql
WITH filter AS
(
    SELECT salary, count(salary) as single
    FROM Employees
    GROUP BY salary
    HAVING single = 1
)

SELECT 
    e.*, 
    dense_rank() OVER(ORDER BY salary ASC) as team_id
FROM Employees e
WHERE salary NOT IN (SELECT salary FROM filter)
```

### 2066. Account Balance
https://leetcode.com/problems/account-balance/

```sql
WITH types AS 
(
    SELECT 
        account_id, day, type, amount, 
        CASE WHEN type = 'Deposit' THEN amount 
            WHEN type = 'Withdraw' THEN amount*(-1) 
            ELSE 0 END as balance 
    FROM Transactions
)

SELECT 
    account_id, 
    day, 
    SUM(balance) OVER(partition by account_id ORDER BY day) as balance
FROM types
```


### 2112. The Airport With the Most Traffic
https://leetcode.com/problems/the-airport-with-the-most-traffic/

```sql
WITH cte1 AS (
SELECT arrival_airport as airport_id, flights_count
FROM Flights
UNION ALL
SELECT departure_airport as airport_id, flights_count
FROM Flights
)
,
cte2 AS (
SELECT airport_id, SUM(flights_count) as total_flights
FROM cte1
GROUP BY airport_id
)
,
cte3 AS (
SELECT *, dense_rank() OVER(ORDER BY total_flights DESC) as rnk
FROM cte2
)

SELECT airport_id FROM cte3 
WHERE rnk = 1
```


### 2159. Order Two Columns Independently
https://leetcode.com/problems/order-two-columns-independently/

1. create row number alias?
2. join on rn after sorting

```sql
WITH data1 AS 
(
SELECT DISTINCT first_col, 
    row_number() OVER(ORDER BY first_col ASC) as RN FROM Data 
), 
data2 AS
(
SELECT DISTINCT second_col,
    row_number() OVER(ORDER BY second_col DESC) as RN FROM Data
)

SELECT first_col, second_col
FROM data1 
JOIN data2 ON data1.RN = data2.RN
```

### 2228. Users With Two Purchases Within Seven Days
https://leetcode.com/problems/users-with-two-purchases-within-seven-days/

```sql
WITH cte1 AS (
SELECT *, 
    rank() OVER(PARTITION BY user_id ORDER BY purchase_date) as rnk,
    LEAD(purchase_date,1) OVER(PARTITION BY user_id ORDER BY purchase_date) as within_period
FROM Purchases
)
,
cte2 AS 
(
SELECT user_id, ABS(datediff(purchase_date, within_period)) as diff
FROM cte1 
)

SELECT DISTINCT user_id
FROM cte2
WHERE diff <= 7
ORDER BY user_id
```

### 2314. The First Day of the Maximum Recorded Degree in Each City
https://leetcode.com/problems/the-first-day-of-the-maximum-recorded-degree-in-each-city/

```sql
WITH ranked_weather AS (
SELECT city_id, day, degree, 
    rank() OVER(PARTITION BY city_id ORDER BY degree DESC, day ASC) as rn
FROM Weather
)

SELECT city_id, day, degree
FROM ranked_weather
WHERE rn = 1
```

### 2324. Product Sales Analysis IV
https://leetcode.com/problems/product-sales-analysis-iv/

```sql
WITH cte1 AS (
SELECT s.sale_id, s.product_id, s.user_id, s.quantity, p.price,
SUM(s.quantity * p.price) as total_spend
FROM Sales s
JOIN Product p ON p.product_id = s.product_id
GROUP BY product_id, user_id
)
,
cte2 AS (
SELECT 
product_id, user_id, quantity, price, total_spend,
dense_rank() OVER(PARTITION BY user_id ORDER BY total_spend DESC) as rn
FROM cte1
)

select user_id, product_id FROM cte2
WHERE rn = 1
```

### 2346. Compute the Rank as a Percentage
https://leetcode.com/problems/compute-the-rank-as-a-percentage/

```sql
WITH cte1 AS 
(
SELECT *, rank() OVER(PARTITION BY department_id ORDER BY mark DESC) as rnk
FROM Students s
)
,
cte2 AS 
(
SELECT department_id, count(student_id) as total_students
FROM Students 
GROUP BY department_id
)

SELECT 
    c1.student_id, 
    c1.department_id, 
    IFNULL(ROUND(((rnk - 1) * 100) / (total_students - 1),2),0) as percentage
FROM cte1 c1
JOIN cte2 c2 ON c2.department_id = c1.department_id
```

### 2820. Election Results
https://leetcode.com/problems/election-results/description/

```sql
WITH votes AS 
(
SELECT 
candidate, 
sum(vote_value) as total
FROM
(
  SELECT 
    voter, 
    candidate, 
    1/(count(voter) OVER(PARTITION BY voter)) as vote_value
  FROM Votes
) t
GROUP BY candidate
)

SELECT candidate
FROM votes v
WHERE total IN (SELECT max(total) FROM votes)
ORDER BY candidate ASC
```
