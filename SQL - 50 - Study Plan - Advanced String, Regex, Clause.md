# SQL 50

## Advanced String Functions / Regex / Clause

### 1667. Fix Names in a Table
https://leetcode.com/problems/fix-names-in-a-table/

```sql
SELECT 
  user_id as user_id, 
  INITCAP(name) as name
FROM 
    Users
ORDER BY 
  user_id
```

### 1527. Patients With a Condition
https://leetcode.com/problems/patients-with-a-condition/

```sql
SELECT 
    * 
FROM 
    patients
WHERE 
    conditions REGEXP '\\bDIAB1'
```

### 196. Delete Duplicate Emails
https://leetcode.com/problems/delete-duplicate-emails/

```sql
DELETE 
  p1 
FROM 
  Person p1, Person p2
WHERE 
  p1.id > p2.id 
  AND p1.Email = p2.Email
```

### 176. Second Highest Salary
https://leetcode.com/problems/second-highest-salary/

```sql
SELECT 
  max(salary) as SecondHighestSalary
FROM 
  employee
WHERE  
  salary <(
  SELECT 
    max(salary)
  FROM  
    employee)
```

### 1484. Group Sold Products By The Date
https://leetcode.com/problems/group-sold-products-by-the-date/

```sql
SELECT 
  sell_date, 
  COUNT(DISTINCT product) as num_sold, 
  GROUP_CONCAT(DISTINCT product) as "products"
FROM 
  Activities
GROUP BY 
  sell_date
```

### 1327. List the Products Ordered in a Period
https://leetcode.com/problems/list-the-products-ordered-in-a-period/

```sql
WITH totals AS 
(
SELECT p.product_name, sum(o.unit) as total_unit
FROM Orders o
LEFT JOIN Products p ON p.product_id = o.product_id
WHERE MONTH(o.order_date) = 2 AND YEAR(o.order_date) = 2020
GROUP BY o.product_id
)

SELECT product_name, total_unit as unit
FROM totals
WHERE total_unit >= 100
```

### 1517. Find Users With Valid E-Mails
https://leetcode.com/problems/find-users-with-valid-e-mails/

```sql
SELECT
    user_id,
    name,
    mail
FROM 
    Users 
WHERE 
    REGEXP_LIKE(
      mail, 
      '^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode[.]com$'
  )
```
