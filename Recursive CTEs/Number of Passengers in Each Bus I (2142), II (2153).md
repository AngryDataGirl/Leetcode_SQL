
### 2142. The Number of Passengers in Each Bus I
https://leetcode.com/problems/the-number-of-passengers-in-each-bus-i/

```sql
# Write your MySQL query statement below
WITH RECURSIVE cte AS (
    SELECT 1 as arrival_time
    UNION ALL
    SELECT arrival_time + 1 
    FROM cte
    WHERE arrival_time < (SELECT max(arrival_time) FROM Buses)
)
,
sched AS (
SELECT c.arrival_time, b.bus_id, p.passenger_id
FROM cte c
LEFT JOIN Buses b ON b.arrival_time = c.arrival_time
LEFT JOIN Passengers p ON p.arrival_time = c.arrival_time
)
,
#fill values
cte1 AS (
SELECT *, row_number() OVER() as rn
FROM sched
)
,
cte2 AS (
    SELECT arrival_time, bus_id, passenger_id, rn, COUNT(bus_id) OVER(ORDER BY rn DESC) as cnt
    FROM cte1 
)
,
cte3 AS (
SELECT arrival_time, bus_id, passenger_id, first_value(bus_id) OVER(PARTITION BY cnt) as bus_id2
FROM cte2
)

#get bus
SELECT bus_id2 as bus_id, COUNT(passenger_id) as passengers_cnt
FROM cte3
GROUP BY bus_id2
ORDER BY bus_id2 ASC
```


### 2153. The Number of Passengers in Each Bus II
https://leetcode.com/problems/the-number-of-passengers-in-each-bus-ii/

```sql
WITH RECURSIVE A AS(
    SELECT bus_id,
    LAG(arrival_time, 1, -1) OVER( ORDER BY arrival_time) AS last_arrival_time,
    arrival_time,  capacity FROM Buses 
),
B AS(
    SELECT A.bus_id, A.arrival_time,  A.capacity, COUNT(P.passenger_id) AS passager_count FROM A LEFT JOIN Passengers P 
    ON A.last_arrival_time < P.arrival_time AND P.arrival_time<= A.arrival_time GROUP BY 1
),
C AS(
    SELECT bus_id, 
    capacity,
    passager_count AS total_passenger,
    ROW_NUMBER() OVER(ORDER BY arrival_time) AS id
    FROM B
),
D AS(
    SELECT bus_id,capacity , total_passenger,id,
    IF(capacity>total_passenger, total_passenger, capacity) AS passager_taken,
    IF(capacity<total_passenger, total_passenger - capacity, 0) AS passager_overleft
    FROM C WHERE id = 1
    UNION
    SELECT C.bus_id,C.capacity , C.total_passenger, C.id,
    IF(C.capacity>C.total_passenger+D.passager_overleft, C.total_passenger+D.passager_overleft, C.capacity) AS passager_taken,
    IF(C.capacity<C.total_passenger+D.passager_overleft, C.total_passenger+D.passager_overleft - C.capacity, 0) AS passager_overleft
    FROM C 
    INNER JOIN D ON D.id+1 = C.id
)
SELECT bus_id, passager_taken AS passengers_cnt FROM D ORDER BY 1
```
