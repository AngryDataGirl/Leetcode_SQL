# Advanced SQL 50

## Basic Joins

### 1890. The Latest Login in 2020
https://leetcode.com/problems/the-latest-login-in-2020/

```sql
select
  user_id,
  max(time_stamp) as last_stamp
from Logins 
group by user_id, year(time_stamp)
having year(last_stamp) = 2020
```

### 511. Game Play Analysis I
https://leetcode.com/problems/game-play-analysis-i/

```sql
SELECT player_id, 
MIN(event_date) as first_login
FROM Activity a
GROUP BY player_id
```

### 1571. Warehouse Manager
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


### 586. Customer Placing the Largest Number of Orders
https://leetcode.com/problems/customer-placing-the-largest-number-of-orders/

```sql
SELECT t1.customer_number
FROM (
  SELECT
    customer_number,
    COUNT(order_number) as num_orders
  FROM Orders o
  GROUP BY customer_number
  ORDER BY num_orders DESC Limit 1) t1
```

### 1741. Find Total Time Spent by Each Employee
https://leetcode.com/problems/find-total-time-spent-by-each-employee/

```sql
SELECT
  event_day as day,
  emp_id,
  sum(out_time-in_time) as total_time
FROM Employees
GROUP BY emp_id, event_day
```

### 1173. Immediate Food Delivery I
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

### 1445. Apples & Oranges
https://leetcode.com/problems/apples-oranges/

```sql
SELECT 
    a.sale_date, 
    a.sold_num - b.sold_num as diff
FROM Sales a
JOIN Sales b 
    ON b.sale_date = a.sale_date
WHERE 
    a.fruit = "apples" 
    AND a.fruit <> b.fruit
```

### 1699. Number of Calls Between Two Persons
https://leetcode.com/problems/number-of-calls-between-two-persons/

```sql
SELECT 
    CASE WHEN from_id < to_id THEN from_id ELSE to_id END as person1,
    CASE WHEN from_id > to_id THEN from_id ELSE to_id END as person2,
    COUNT(*) as call_count, 
    SUM(duration) as total_duration
FROM Calls  
GROUP BY person1, person2
```
