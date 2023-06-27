# Advanced SQL 50

## Basic Joins

### 1890. The Latest Login in 2020
https://leetcode.com/problems/the-latest-login-in-2020/

```sql
select
  user_id,
  max(time_stamp) as last_stamp
from Logins 
group by user_id, year(time_stamp)
having year(last_stamp) = 2020
```

### 511. Game Play Analysis I
https://leetcode.com/problems/game-play-analysis-i/

```sql
SELECT player_id, 
MIN(event_date) as first_login
FROM Activity a
GROUP BY player_id
```

### 1571. Warehouse Manager
https://leetcode.com/problems/warehouse-manager/

```sql
WITH volume AS 
(SELECT 
    w.product_id, 
    w.name,
    p.Width * p.Length * p.Height * w.units as volume
FROM Warehouse w 
JOIN Products p ON p.product_id = w.product_id
)

SELECT 
    name as warehouse_name, 
    sum(volume) as volume
FROM volume
GROUP BY name
```
