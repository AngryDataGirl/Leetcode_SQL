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
# Write your MySQL query statement below
SELECT 
  customer_id,
  COUNT(visit_id) as count_no_trans # calculates the total visits after filter has been applied
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
