- [Advanced SQL 50](#advanced-sql-50)
  - [Subqueries](#subqueries)
    - [1350. Students With Invalid Departments](#1350-students-with-invalid-departments)
    - [1303. Find the Team Size](#1303-find-the-team-size)
    - [512. Game Play Analysis II](#512-game-play-analysis-ii)
    - [184. Department Highest Salary](#184-department-highest-salary)
    - [1549. The Most Recent Orders for Each Product](#1549-the-most-recent-orders-for-each-product)
    - [1532. The Most Recent Three Orders](#1532-the-most-recent-three-orders)
    - [1831. Maximum Transaction Each Day](#1831-maximum-transaction-each-day)

# Advanced SQL 50

## Subqueries

### 1350. Students With Invalid Departments
https://leetcode.com/problems/students-with-invalid-departments/

```sql
SELECT 
    s.id, 
    s.name
FROM Students s
LEFT JOIN Departments d ON d.id = s.department_id
WHERE d.name IS NULL
```

### 1303. Find the Team Size
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
### 512. Game Play Analysis II
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

### 184. Department Highest Salary
https://leetcode.com/problems/department-highest-salary/

```sql
# Write your MySQL query statement below
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

### 1549. The Most Recent Orders for Each Product
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

### 1532. The Most Recent Three Orders
https://leetcode.com/problems/the-most-recent-three-orders/

```sql
# Write your MySQL query statement below
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

### 1831. Maximum Transaction Each Day
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
