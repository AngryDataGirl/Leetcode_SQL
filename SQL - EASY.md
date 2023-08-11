
# SQL - Easy

- [577. Employee Bonus](#577-employee-bonus)
- [597. Friend Requests I](#597-friend-requests-i)
- [1757. Recyclable and Low Fat Products](#1757-recyclable-and-low-fat-products)

### 577. Employee Bonus
https://leetcode.com/problems/employee-bonus/

```sql
SELECT e.name, b.bonus 
FROM Employee e
LEFT JOIN Bonus b ON b.empId = e.empId
WHERE b.bonus < 1000 or bonus IS NULL
```

### 597. Friend Requests I
https://leetcode.com/problems/friend-requests-i-overall-acceptance-rate/

Notes from question:
- count all total accepted requests (may not only be from the friend_request table)
  - first CTE adds a row number to the request accepted table so we can eliminate duplicated requests
  - second CTE counts the total accepts per unique pair
- request could be accepted more than once, duplicated requests or acceptances should only be counted once
  - third CTE adds row number so we can filter for the requests (but only count them once)
- if there are no requests at all, return 0.00 as the accept rate 
  - last CTE adds an IFNULL in order to return 0.00 as accept rate while counting total requests 
  - final SELECT calculates the accept_rate while rounding 

not super performant, will have to revisit 
```sql
WITH numbered_accepts AS (
    SELECT 
        requester_id, accepter_id, accept_date, 
        row_number() OVER(partition by requester_id, accepter_id) as rn
    FROM RequestAccepted ra
),
unique_accepts AS 
(
    SELECT count(accepter_id) as total_accepts
    FROM numbered_accepts
    WHERE rn = 1
),
numbered_requests AS (
    SELECT sender_id, send_to_id, request_date, 
    row_number() OVER(partition by sender_id, send_to_id order by sender_id) as rn
    FROM FriendRequest fr
),
unique_requests AS 
(
    SELECT IFNULL(count(sender_id),0) as total_requests
    FROM numbered_requests
    WHERE rn = 1
)

SELECT IFNULL(ROUND(total_accepts/total_requests, 2),0.00) AS accept_rate
FROM unique_accepts, unique_requests
```

### 1757. Recyclable and Low Fat Products
https://leetcode.com/problems/recyclable-and-low-fat-products/

- filtering data with a WHERE clause 
- multiple conditions in WHERE clause
- the data is in a single table
- the filters are columns in the table 
- therefore, we can just specify the conditions in a WHERE clause

```sql
select 
    product_id 
from 
    Products 
where 
    low_fats='Y' 
    and recyclable='Y';
```
