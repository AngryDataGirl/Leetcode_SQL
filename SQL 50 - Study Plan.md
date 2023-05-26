# SQL 50

## Select

### 1757. Recyclable and Low Fat Products
https://leetcode.com/problems/recyclable-and-low-fat-products/

```sql
SELECT 
    product_id 
FROM 
    Products 
WHERE 
    low_fats='Y' 
    and recyclable='Y';
```
### 584. Find Customer Referee
https://leetcode.com/problems/find-customer-referee/

```sql
SELECT 
  name
FROM 
  customer
WHERE 
  referee_id <> 2 
  or referee_id is null
```

### 595. Big Countries
https://leetcode.com/problems/big-countries/

```sql
SELECT 
  name, 
  population, 
  area 
FROM 
  world w
WHERE 
  population >= 25000000
INNER JOIN (
    SELECT 
      name, 
      area
    FROM 
      world w2
    WHERE 
      area >= 3000000) w2
      ON w.name = w2.name
```

### 1148. Article Views I
https://leetcode.com/problems/article-views-i/

```sql
SELECT DISTINCT author_id as "id"
FROM Views v
WHERE viewer_id = author_id
ORDER BY author_id ASC
```

### 1683. Invalid Tweets
https://leetcode.com/problems/invalid-tweets/

```sql
SELECT 
    tweet_id
FROM Tweets
WHERE LENGTH(content) > 15
```

## Basic Joins

### 1378. Replace Employee ID With The Unique Identifier
https://leetcode.com/problems/replace-employee-id-with-the-unique-identifier/

```sql
SELECT 
    u.unique_id AS unique_id,
    e.name
FROM Employees e
LEFT JOIN EmployeeUNI u ON u.id = e.id
```

### 1068. Product Sales Analysis I
https://leetcode.com/problems/product-sales-analysis-i/

```sql
SELECT p.product_name, s.year, s.price
FROM Sales s
JOIN Product p ON p.product_id = s.product_id
```

### 1581. Customer Who Visited but Did Not Make Any Transactions
https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/

```sql
SELECT 
  customer_id,
# calculates the total visits after filter has been applied
  COUNT(visit_id) as count_no_trans 
FROM 
  Visits v
WHERE 
  visit_id 
  NOT IN
# subquery serves as filter, we are trying to find customers who did not have transactions
( 
  SELECT 
    visit_id
  FROM 
    transactions t
  ) 
GROUP BY customer_id # groups results by customer id 

```

### 197. Rising Temperature
https://leetcode.com/problems/rising-temperature/

```sql
SELECT 
    w1.id
FROM 
# create the cross join / cartesian product
    Weather w1, Weather w2
WHERE 
# we are trying to find where the temp was higher 
    w1.temperature > w2.temperature 
AND 
# than previous day
    datediff(w1.recordDate, w2.recordDate) = 1
```

### 1661. Average Time of Process per Machine
https://leetcode.com/problems/average-time-of-process-per-machine/

```sql
# get the start times only
WITH start AS
(
SELECT 
    machine_id, process_id, timestamp as start_timestamp
FROM 
    Activity
WHERE activity_type = 
    'start'
)
,
# get the end times only
end AS
(
SELECT 
    machine_id, process_id, timestamp as end_timestamp
FROM 
    Activity
WHERE activity_type = 
    'end'
)

# the join will create the final table where we can subtract one column from the other
SELECT 
    s.machine_id, 
# need to find average and round to 3 decimal places
    ROUND(AVG(e.end_timestamp - s.start_timestamp),3) as processing_time
FROM start s
JOIN end e
# ensure the join is correct as the machine and process both have ids
    ON e.machine_id = s.machine_id
    AND e.process_id = s.process_id
# we group by machine id, since the proceses should be avged
GROUP BY s.machine_id
```

### 577. Employee Bonus
https://leetcode.com/problems/employee-bonus/

```sql
# Write your MySQL query statement below
SELECT 
    name, 
    bonus
FROM Employee e
LEFT JOIN Bonus b 
    ON e.empId = b.empId
WHERE bonus < 1000
    OR bonus IS NULL
```

# 1280. Students and Examinations
https://leetcode.com/problems/students-and-examinations/

```sql
# Write your MySQL query statement below
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

# 570. Managers with at Least 5 Direct Reports
https://leetcode.com/problems/managers-with-at-least-5-direct-reports/

```sql
# group and count the direct reports
WITH grouped AS 
(
SELECT managerId, COUNT(id) as direct_reports
FROM Employee
GROUP BY managerId
)

#filter for those that have at least 5 direct reports
SELECT e.name
FROM grouped g
JOIN Employee e ON e.id = g.managerId
WHERE direct_reports >= 5
```

# 1934. Confirmation Rate
https://leetcode.com/problems/confirmation-rate/

```sql
# Write your MySQL query statement below

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

alternative solution using a CASE WHEN / COUNT statement as opposed to separate CTEs
```sql
WITH totals AS 
(
SELECT 
    user_id,
    COUNT(CASE WHEN action = "confirmed" then 1 ELSE NULL END) as total_confirms,
    COUNT(action) as total_requested
FROM Confirmations
GROUP BY user_id
)

SELECT 
    s.user_id,
    IFNULL(ROUND(t.total_confirms/t.total_requested, 2),0) as confirmation_rate
FROM Signups s
LEFT JOIN totals t
    ON s.user_id = t.user_id
```
