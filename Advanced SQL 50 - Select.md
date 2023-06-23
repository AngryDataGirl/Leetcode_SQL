# Advanced SQL 50

## Select

### 1821. Find Customers With Positive Revenue this Year
https://leetcode.com/problems/find-customers-with-positive-revenue-this-year/

```sql
SELECT customer_id
FROM Customers
WHERE revenue > 0 AND year = 2021
```

### 183. Customers Who Never Order
https://leetcode.com/problems/customers-who-never-order/

```sql

select c.name as Customers
from customers c
where c.id NOT IN
    (select o.customerId 
    from orders o)
```

### 1873. Calculate Special Bonus
https://leetcode.com/problems/calculate-special-bonus/

```sql
select employee_id, if(
    (employee_id % 2 <> 0) and name not like 'M%', 
    salary,
    0) as bonus
from employees
order by employee_id asc
```

### 1398. Customers Who Bought Products A and B but Not C
https://leetcode.com/problems/customers-who-bought-products-a-and-b-but-not-c/

```sql
# Write your MySQL query statement below
WITH customersA AS (
    SELECT customer_id FROM Orders WHERE product_name = 'A'
),
 customersB AS (
    SELECT customer_id FROM Orders WHERE product_name = 'B'
),
 customersC AS (
    SELECT customer_id FROM Orders WHERE product_name = 'C'
)

SELECT DISTINCT o.customer_id, c.customer_name FROM Orders o
JOIN Customers c ON c.customer_id = o.customer_id
WHERE o.customer_id IN (SELECT * FROM CustomersA)
AND o.customer_id IN (SELECT * FROM CustomersB)
AND o.customer_id NOT IN (SELECT * FROM CustomersC)
```

### 1112. Highest Grade For Each Student
https://leetcode.com/problems/highest-grade-for-each-student/

```sql
WITH max_grades AS 
(
SELECT 
    student_id, course_id, grade,
    ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC, course_id ASC) as grade_rn
FROM Enrollments
)

SELECT student_id, course_id, grade
FROM max_grades
WHERE grade_rn = 1
```
