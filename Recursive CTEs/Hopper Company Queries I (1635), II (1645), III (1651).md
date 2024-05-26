
### 1635. Hopper Company Queries I
https://leetcode.com/problems/hopper-company-queries-i/

```sql
#get months with recursive cte
WITH RECURSIVE list_months AS (
    SELECT 1 as m 
    UNION ALL
    SELECT m + 1
    FROM list_months
    WHERE m < 12
)
#get active drivers
,
active_drivers AS (
SELECT 
   month(join_date) as month, 
   count(driver_id) OVER (order by join_date) as active_drivers
 FROM drivers
 WHERE year(join_date) <= 2020
)
,
#get accepted rides 
accepted_rides AS (
    SELECT 
        month(requested_at) as month,
        count(ride_id) as accepted_rides_count
    FROM Rides ar 
where ride_id in (select ride_id from AcceptedRides) and year(requested_at) = 2020
    GROUP BY month
)

SELECT DISTINCT 
    m as month, 
    IFNULL(max(ad.active_drivers) over (order by lm.m),0) as active_drivers,
    IFNULL(ar.accepted_rides_count,0) as accepted_rides
FROM list_months lm
LEFT JOIN active_drivers ad ON ad.month = lm.m
LEFT JOIN accepted_rides ar ON ar.month = lm.m
```

### 1645. Hopper Company Queries II
https://leetcode.com/problems/hopper-company-queries-ii/

```sql
with recursive month (month) as
(
    select 1 as month
    union
    select month + 1
    from month
    where month < 12
),

total as
(
    select
        distinct m.month,
        count(distinct d.driver_id) as counter
    from month m, Drivers d
    where year(d.join_date) < 2020 or (year(d.join_date) = 2020 and month(d.join_date) <= m.month)
    group by 1
    order by 1
),

accept as
(
    select
        m.month,
        count(distinct b.driver_id) as counter2
    from month m
    left join (select
                    a.ride_id,
                    a.driver_id,
                    r.requested_at
    from AcceptedRides a left join Rides r on a.ride_id = r.ride_id
    where
        year(r.requested_at) = 2020) b on m.month = month(b.requested_at)
    group by 1
)

select
    m.month,
    ifnull(round(100*a.counter2/t.counter,2),0) as working_percentage
from total t
join accept a
    on t.month = a.month
right join month m
    on t.month = m.month
order by 1
```

### 1651. Hopper Company Queries III
https://leetcode.com/problems/hopper-company-queries-iii/

```sql
# Write your MySQL query statement below

#create anchor months
WITH RECURSIVE cte AS
(
    SELECT 1 as month 
    UNION ALL
    SELECT month + 1 
    FROM cte
    WHERE month < 12
)
# join with relevant data
,
cte1 AS (
SELECT c.month, IFNULL(SUM(t.ride_distance),0) as ride_distance, IFNULL(SUM(t.ride_duration),0) as ride_duration
FROM cte c 
LEFT JOIN 
    (
        SELECT 
            ar.ride_id, 
            ar.ride_distance,
            ar.ride_duration,
            r.requested_at, 
            month(requested_at) as month
        FROM AcceptedRides ar
        LEFT JOIN Rides r 
            ON r.ride_id = ar.ride_id
        WHERE year(requested_at) = 2020
    ) t
    ON c.month = t.month
    GROUP BY month
)
#calculate rolling averages
,
avgs AS (
SELECT 
    month,
    ROUND(AVG(ride_distance) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) as average_ride_distance,
    ROUND(AVG(ride_duration) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) as average_ride_duration
FROM cte1
)

SELECT * 
FROM avgs
WHERE month <= 10
ORDER BY month ASC
```
