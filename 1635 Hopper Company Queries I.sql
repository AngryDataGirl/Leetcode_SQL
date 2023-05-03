1635. Hopper Company Queries I
# https://leetcode.com/problems/hopper-company-queries-i/

# Write your MySQL query statement below

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
