
https://leetcode.com/problems/game-play-analysis-ii/

```sql
# get first login 
WITH first_login AS
(
    SELECT 
        player_id, 
        min(event_date) as event_date 
    FROM Activity 
    GROUP by player_id
)

# get result columns joining to first login
SELECT 
    a.player_id, 
    a.device_id
FROM Activity a
INNER JOIN first_login f1
ON f1.player_id = a.player_id
AND f1.event_date = a.event_date
```
