
https://leetcode.com/problems/the-latest-login-in-2020/

```sql
select user_id, max(time_stamp) as last_stamp
from Logins 
group by user_id, year(time_stamp)
having year(last_stamp) = 2020
```
