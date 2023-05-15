# Problem
https://leetcode.com/problems/consecutive-available-seats/

# Intuition
There is only one table in this problem, so we probably need to use **self join** to get a cartesian product

# Solution

```sql
# Write your MySQL query statement below

-- SELF JOIN METHOD 1
SELECT c1.*, c2.*
FROM Cinema c1
	JOIN Cinema c2 
ORDER BY c1.seat_id ASC, c2.seat_id ASC

-- SELF JOIN METHOD 2
SELECT c1.*, c2.*
FROM Cinema c1, Cinema c2

-- SOLUTION
SELECT 
    DISTINCT c1.seat_id
    # c1.free,
    # c2.seat_id, 
    # c2.free
FROM Cinema c1, Cinema c2
WHERE (c1.free = 1 AND c2.free = 1 AND c1.seat_id = c2.seat_id + 1)
    OR (c1.free = 1 AND c2.free = 1 AND c1.seat_id = c2.seat_id - 1)
ORDER BY c1.seat_id ASC, c2.seat_id ASC
```
