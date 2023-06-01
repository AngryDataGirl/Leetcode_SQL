# SQL 50

## Advanced Select and Joins

### 1731. The Number of Employees Which Report to Each Employee
https://leetcode.com/problems/the-number-of-employees-which-report-to-each-employee/

```sql
SELECT DISTINCT
    e2.employee_id,
    e2.name, 
    COUNT(e1.employee_id) AS reports_count, 
    ROUND(AVG(e1.age),0) AS average_age
FROM Employees e1
JOIN Employees e2 
  ON e1.reports_to = e2.employee_id
GROUP BY e2.employee_id, e2.name
ORDER BY employee_id
```

### 1789. Primary Department for Each Employee
https://leetcode.com/problems/primary-department-for-each-employee/

```sql
WITH rownum AS 
(
SELECT 
    row_number() OVER(partition by employee_id ORDER BY primary_flag) as rn,
    employee_id,
    department_id, 
    primary_flag
FROM Employee
)

SELECT employee_id, department_id
FROM rownum
WHERE rn = 1
```

### 610. Triangle Judgement
https://leetcode.com/problems/triangle-judgement/

```sql
SELECT t.*, 
    CASE WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
    ELSE 'No'
    END AS triangle
FROM Triangle t
```

### 180. Consecutive Numbers
https://leetcode.com/problems/consecutive-numbers/description/

```sql
SELECT 
distinct l1.num as "ConsecutiveNums"

FROM
Logs l1, 
Logs l2,
logs l3

WHERE
l1.id = l2.id-1
and 
l2.id = l3.id-1
and 
(l1.num = l2.num) and (l2.num = l3.num)

ORDER BY

l1.Id, l2.Id, l3.Id
```
- alternate solution using window functions LAG and LEAD
- personally I find this more readable

```sql
WITH lagged AS (

SELECT 
lag(num) OVER(ORDER BY id) as last_num,
num, 
lead(num) OVER(ORDER BY id) as next_num
FROM Logs

)

SELECT DISTINCT num as ConsecutiveNums
FROM lagged
WHERE last_num = num AND next_num = num
```

### 1164. Product Price at a Given Date
https://leetcode.com/problems/product-price-at-a-given-date/

```sql
WITH new_prices AS 
(
    SELECT DISTINCT 
        product_id,
        FIRST_VALUE(new_price) OVER (PARTITION BY product_id ORDER BY change_date DESC) as price
    FROM 
        products
    WHERE 
        change_date <= '2019-08-16'
)
,
distinct_products AS
(
    SELECT DISTINCT 
        product_id
    FROM 
        Products
)

SELECT 
    dp.product_id, 
    IFNULL(np.price,10) as price 
FROM 
    distinct_products dp
LEFT JOIN new_prices np 
    ON np.product_id = dp.product_id
```

### 1204. Last Person to Fit in the Bus
https://leetcode.com/problems/last-person-to-fit-in-the-bus/

- this kind of cumulative sum or count question shows up here and there in other medium / hard questions 

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

### 1907. Count Salary Categories
https://leetcode.com/problems/count-salary-categories/

```sql
WITH categories AS 
(
SELECT "Low Salary" as category FROM dual
UNION
SELECT "Average Salary" as category FROM dual
UNION 
SELECT "High Salary" as category FROM dual
)
,
sorted AS 
(
SELECT
    account_id,
    CASE 
        WHEN income < 20000 THEN "Low Salary"
        WHEN income BETWEEN 20000 AND 50000 THEN "Average Salary"
        ELSE "High Salary"
    END as category
FROM Accounts
)

SELECT c.category, IFNULL(accounts_count,0) as accounts_count
FROM categories c
LEFT JOIN (
    SELECT category, COUNT(account_id) as accounts_count
    FROM sorted
    GROUP BY category) s 
ON s.category = c.category
```
