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

