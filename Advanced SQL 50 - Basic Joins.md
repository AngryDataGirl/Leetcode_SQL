# Advanced SQL 50

## Basic Joins

### 175. Combine Two Tables
https://leetcode.com/problems/combine-two-tables/

```sql
select firstName, lastName, city, state
from person p 
left join address a on p.personId=a.personId
```

### 1607. Sellers With No Sales
https://leetcode.com/problems/sellers-with-no-sales/

```sql
SELECT 
    seller_name
FROM Seller s 
WHERE seller_id NOT IN (
    SELECT seller_id
    FROM Orders o 
    WHERE YEAR(sale_date) = 2020)
ORDER BY seller_name ASC
```

###
