# Advanced SQL 50

## Sorting and Grouping

### 1587. Bank Account Summary II
https://leetcode.com/problems/bank-account-summary-ii/

```sql
SELECT
  name,
  SUM(t.amount) as balance
FROM Transactions t
JOIN Users u ON u.account = t.account
GROUP BY t.account
HAVING balance > 10000
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

OR

```sql
SELECT DISTINCT email
FROM (SELECT *,COUNT(id) OVER(PARTITION BY email) as RN
      FROM Person) t1 
      WHERE RN > 1
```

### 1050. Actors and Directors Who Cooperated At Least Three Times
https://leetcode.com/problems/actors-and-directors-who-cooperated-at-least-three-times/

```sql

SELECT actor_id, director_id
FROM
(
SELECT 
  actor_id, 
  director_id, 
  count(timestamp) as total_collab
FROM ActorDirector
GROUP BY actor_id, director_id
) t
WHERE total_collab >= 3
```

or 

```sql
SELECT
  a1.actor_id,
  a1.director_id
FROM ActorDirector a1
GROUP BY a1.actor_id, a1.director_id
HAVING COUNT(timestamp) >= 3
```

### 1511. Customer Order Frequency
https://leetcode.com/problems/customer-order-frequency/

```sql
WITH jj_orders AS
(
(SELECT 
    o.customer_id, 
    c.name,
    o.order_date,
    MONTH(order_date) AS order_month,
    o.quantity*p.price AS total_cost
FROM Orders o
JOIN Product p ON p.product_id = o.product_id
JOIN Customers c ON c.customer_id = o.customer_id
WHERE (MONTH(order_date) = 6 OR MONTH(order_date) = 7)
AND YEAR(order_date) = 2020
GROUP BY o.customer_id, order_month, order_date)
),
sum_jj_orders AS
(
SELECT 
    customer_id, 
    name, 
    order_month, 
    sum(total_cost) AS total_cost
FROM jj_orders
GROUP BY customer_id, order_month
),
june AS
(
SELECT name FROM sum_jj_orders WHERE order_month = 6 AND total_cost >= 100
),
july AS
(
SELECT name FROM sum_jj_orders WHERE order_month = 7 AND total_cost >= 100
)

SELECT customer_id, name
FROM Customers 
WHERE name IN (SELECT name FROM june)
AND name IN (SELECT name FROM july)
```

### 1693. Daily Leads and Partners
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

### 1495. Friendly Movies Streamed Last Month
https://leetcode.com/problems/friendly-movies-streamed-last-month/

```sql
SELECT DISTINCT c.title
FROM Content c
JOIN TVProgram t ON t.content_id = c.content_id
WHERE 
    kids_content = 'Y' 
AND 
    content_type = 'Movies'
AND
    MONTH(program_date) = 6 AND YEAR(program_date) = 2020
```
or

```sql
WITH kids_movies AS
(
    SELECT title, content_id
    FROM Content
    WHERE kids_content = 'Y'
    AND content_type = 'Movies'

)

SELECT DISTINCT title 
FROM kids_movies km 
JOIN TVProgram t ON t.content_id = km.content_id
AND
    MONTH(program_date) = 6 AND YEAR(program_date) = 2020
```

### 1501. Countries You Can Safely Invest In
https://leetcode.com/problems/countries-you-can-safely-invest-in/

```sql
SELECT
  co.name as country
FROM Person p
JOIN Country co
  ON LEFT(p.phone_number, 3) = co.country_code
JOIN calls
  ca ON p.id IN (ca.caller_id, ca.callee_id)
GROUP BY co.name
HAVING AVG(duration) >
  (SELECT AVG(duration) FROM Calls)
```
