# Advanced SQL 50

## Select

### 1821. Find Customers With Positive Revenue this Year
https://leetcode.com/problems/find-customers-with-positive-revenue-this-year/

```sql
SELECT customer_id
FROM Customers
WHERE revenue > 0 AND year = 2021
```
