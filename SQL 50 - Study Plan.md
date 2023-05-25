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
