# Advanced SQL50 

## Advanced Select and Joins

### 603. Consecutive Available Seats
https://leetcode.com/problems/consecutive-available-seats/

```sql
SELECT 
    DISTINCT c1.seat_id
FROM
  Cinema c1,
  Cinema c2
WHERE
  (c1.free = 1 AND c2.free = 1 AND c1.seat_id = c2.seat_id + 1)
  OR (c1.free = 1 AND c2.free = 1 AND c1.seat_id = c2.seat_id - 1)
ORDER BY c1.seat_id ASC, c2.seat_id ASC
```

### 1795. Rearrange Products Table
https://leetcode.com/problems/rearrange-products-table/

```sql
select 
    product_id, 
    'store1' as store, 
    store1 as price
from products 
where store1 is not null

union

select 
    product_id, 
    'store2' as store, 
    store2 as price
from products 
where store2 is not null

union 

select 
    product_id, 
    'store3' as store, 
    store3 as price
from products 
where store3 is not null
```

### 613. Shortest Distance in a Line
https://leetcode.com/problems/shortest-distance-in-a-line/

```sql
WITH dist_betw_pts AS
(
SELECT p1.x as x1, p2.x as x2, ABS(p1.x - p2.x) as distance
FROM Point p1, Point p2
)

SELECT min(distance) as shortest
FROM dist_betw_pts
WHERE x1 != x2
```

### 1965. Employees With Missing Information
https://leetcode.com/problems/employees-with-missing-information/

```sql
SELECT
  employee_id
FROM Employees
WHERE employee_id NOT IN (SELECT employee_id FROM Salaries)

UNION 

SELECT
  employee_id
FROM Salaries
WHERE employee_id NOT IN (SELECT employee_id FROM Employees)

ORDER BY 1 ASC
```

### 1264. Page Recommendations
https://leetcode.com/problems/page-recommendations/

```sql
SELECT DISTINCT page_id AS recommended_page
FROM 
    (SELECT 
        CASE WHEN user1_id=1 THEN user2_id
            WHEN user2_id=1 THEN user1_id
        END AS user_id
FROM Friendship) a
JOIN Likes
ON a.user_id=Likes.user_id
WHERE page_id NOT IN (SELECT page_id FROM Likes WHERE user_id=1)
```

### 608. Tree Node
https://leetcode.com/problems/tree-node/

```sql
SELECT DISTINCT t1.id, (
    CASE
    WHEN t1.p_id IS NULL  THEN 'Root'
    WHEN t1.p_id IS NOT NULL AND t2.id IS NOT NULL THEN 'Inner'
    WHEN t1.p_id IS NOT NULL AND t2.id IS NULL THEN 'Leaf'
    END
) AS Type 
FROM tree t1
LEFT JOIN tree t2
ON t1.id = t2.p_id
```

### 534. Game Play Analysis III
https://leetcode.com/problems/game-play-analysis-iii/

```sql
SELECT 
    player_id, 
    event_date, 
    sum(games_played) over (partition by player_id order by event_date) as games_played_so_far
from Activity;
```

### 1783. Grand Slam Titles
https://leetcode.com/problems/grand-slam-titles/

```sql
WITH reshaped AS (
SELECT "Wimbledon" as grand_slams, wimbledon as player_id, year FROM Championships 
UNION 
SELECT "Fr_open" as grand_slams, Fr_open as player_id, year FROM Championships 
UNION
SELECT "US_open" as grand_slams, US_open as player_id, year FROM Championships 
UNION
SELECT "Au_open" as grand_slams, Au_open as player_id, year FROM Championships 
)

SELECT p.player_id, p.player_name, count(r.player_id) as grand_slams_count
FROM Players p 
JOIN reshaped r ON r.player_id = p.player_id
GROUP BY p.player_id
```

### 1747. Leetflex Banned Accounts
https://leetcode.com/problems/leetflex-banned-accounts/

```
#group account id and remove duplicates
WITH distinct_log_info AS
(
    SELECT DISTINCT account_id, ip_address, login, logout
    FROM LogInfo
)
,
compared AS
(
SELECT *, 
    LAG(login) OVER(PARTITION BY account_id ORDER BY login) as prev_login,
    LAG(logout) OVER(PARTITION BY account_id ORDER BY login) as prev_logout,
    LAG(ip_address) OVER(PARTITION BY account_id ORDER BY login) as prev_ip
FROM distinct_log_info 
)
, 
banned AS
(
SELECT 
    account_id, 
    ip_address,
    prev_ip,
    prev_login,
    prev_logout, 
    login, 
    logout,
    CASE WHEN login <= prev_logout THEN 1 ELSE 0 END AS ban
FROM compared
WHERE date(login) = date(prev_login)
AND ip_address <> prev_ip
)

SELECT DISTINCT account_id
FROM banned
WHERE ban = 1
```
