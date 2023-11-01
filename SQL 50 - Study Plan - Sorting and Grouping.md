- [2356. Number of Unique Subjects Taught by Each Teacher](#2356-number-of-unique-subjects-taught-by-each-teacher)
- [1141. User Activity for the Past 30 Days I](#1141-user-activity-for-the-past-30-days-i)
- [1070. Product Sales Analysis III](#1070-product-sales-analysis-iii)
- [596. Classes More Than 5 Students](#596-classes-more-than-5-students)
- [1729. Find Followers Count](#1729-find-followers-count)
- [619. Biggest Single Number](#619-biggest-single-number)
- [1045. Customers Who Bought All Products](#1045-customers-who-bought-all-products)

### 2356. Number of Unique Subjects Taught by Each Teacher
https://leetcode.com/problems/number-of-unique-subjects-taught-by-each-teacher/

```sql
SELECT 
    teacher_id, 
    COUNT(DISTINCT subject_id) as 'cnt'
FROM Teacher
GROUP BY teacher_id
```

### 1141. User Activity for the Past 30 Days I
https://leetcode.com/problems/user-activity-for-the-past-30-days-i/

```sql
SELECT 
    activity_date as day, 
    count(distinct user_id) as active_users
FROM
    Activity
WHERE 
    activity_date between DATE('2019-06-28') and DATE('2019-07-27')
GROUP BY day
```

### 1070. Product Sales Analysis III
https://leetcode.com/problems/product-sales-analysis-iii/

```sql

WITH ranked_year AS
(
SELECT 
    s.product_id, 
    s.year, 
    s.quantity, 
    s.price, 
    dense_rank() OVER(PARTITION BY s.product_id ORDER BY s.year ASC) as rn
FROM Sales s
)

SELECT 
    product_id, 
    year as first_year, 
    quantity, 
    price
FROM ranked_year
WHERE rn = 1
```

### 596. Classes More Than 5 Students
https://leetcode.com/problems/classes-more-than-5-students/

```sql
SELECT 
    class
FROM Courses
GROUP BY class
HAVING count(student) >= 5
```

### 1729. Find Followers Count
https://leetcode.com/problems/find-followers-count/

```sql
SELECT 
    f1.user_id, 
    COUNT(DISTINCT f1.follower_id) as followers_count
FROM Followers f1
GROUP BY f1.user_id
```

### 619. Biggest Single Number
https://leetcode.com/problems/biggest-single-number/

```sql
WITH duplicates AS
(
    SELECT 
        num, 
        row_number() OVER(partition by num order by num) as rn
    FROM MyNumbers
), 

not_single AS
(
SELECT 
    num
FROM duplicates 
WHERE rn = 2
)

SELECT 
    IFNULL(max(num),NULL) as num
FROM 
    MyNumbers 
WHERE 
    num NOT IN (SELECT * FROM not_single)
```

### 1045. Customers Who Bought All Products
https://leetcode.com/problems/customers-who-bought-all-products/

```sql
SELECT 
    customer_id
FROM 
    Customer
GROUP BY 
    customer_id
HAVING
  COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product);
```
