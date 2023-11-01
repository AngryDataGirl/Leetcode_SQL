- [1978. Employees Whose Manager Left the Company](#1978-employees-whose-manager-left-the-company)
- [626. Exchange Seats](#626-exchange-seats)
- [1341. Movie Rating](#1341-movie-rating)
- [1321. Restaurant Growth](#1321-restaurant-growth)
- [602. Friend Requests II: Who Has the Most Friends](#602-friend-requests-ii-who-has-the-most-friends)
- [585. Investments in 2016](#585-investments-in-2016)
- [185. Department Top Three Salaries](#185-department-top-three-salaries)

### 1978. Employees Whose Manager Left the Company

```sql
WITH manager_left AS 
(
SELECT DISTINCT 
    manager_id 
FROM 
    Employees 
WHERE 
    manager_id NOT IN (
            SELECT DISTINCT employee_id 
            FROM Employees
            )
),

emp_salary_30 AS
(
SELECT 
    e1.employee_id, 
    e1.name, 
    e1.manager_id, 
    e1.salary
FROM 
    Employees e1
WHERE 
    e1.salary < 30000)

SELECT 
    employee_id 
FROM 
    emp_salary_30
WHERE 
    manager_id IN (
            SELECT * 
            FROM manager_left)
ORDER BY employee_id
```
simpler and more performant 
```sql
SELECT employee_id 
FROM Employees
WHERE salary < 30000
AND manager_id NOT IN (
    SELECT employee_id FROM Employees)
ORDER BY employee_id
```
### 626. Exchange Seats
https://leetcode.com/problems/exchange-seats/

```sql
SELECT
(CASE 
    WHEN id % 2 <> 0 AND counts <> id THEN id + 1
    WHEN id % 2 <> 0 AND counts = id THEN id
    ELSE id - 1
    END) as id,
    student
FROM Seat,
    (SELECT
        COUNT(*) as counts
    FROM seat) AS seat_counts
ORDER BY id ASC;
```

### 1341. Movie Rating
https://leetcode.com/problems/movie-rating/

```sql
WITH all_reviews AS (
SELECT 
    mr.movie_id,
    m.title, 
    mr.user_id, 
    u.name,
    mr.rating, 
    mr.created_at
FROM MovieRating mr 
JOIN Users u ON mr.user_id = u.user_id 
JOIN Movies m ON m.movie_id = mr.movie_id
)
,
max_reviews AS (
SELECT 
    name,
    count(user_id) as total_reviews
FROM all_reviews
GROUP BY name
ORDER BY total_reviews DESC, name ASC
),
avg_ratings AS (
    SELECT 
    title, 
    AVG(rating) as avg_rating
FROM all_reviews
WHERE MONTH(created_at) = 2 AND YEAR(created_at) = 2020
GROUP BY title 
ORDER BY avg_rating DESC, title ASC
)

(SELECT name as results FROM max_reviews LIMIT 1)
UNION ALL
(SELECT title as results FROM avg_ratings LIMIT 1)

```

### 1321. Restaurant Growth
https://leetcode.com/problems/restaurant-growth/

```sql
WITH customer_paid AS (
SELECT visited_on,
    SUM(amount) as total_amount
FROM Customer
GROUP BY visited_on
),
moving_avg AS (
SELECT 
    visited_on, 
    SUM(total_amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as amount, 
    ROUND(AVG(total_amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) as average_amount,
    RANK() OVER(ORDER BY visited_on ASC) as rn
FROM customer_paid 
GROUP BY visited_on
ORDER BY visited_on ASC
)

SELECT visited_on, amount, average_amount
FROM moving_avg
WHERE rn >= 7
```

### 602. Friend Requests II: Who Has the Most Friends
https://leetcode.com/problems/friend-requests-ii-who-has-the-most-friends/

```sql
# Write your MySQL query statement below
WITH requests AS 
(
SELECT requester_id,
COUNT(requester_id) as total_requests
FROM RequestAccepted 
GROUP BY requester_id
)
,
accepts AS
(
SELECT accepter_id,
COUNT(accepter_id) as total_accepts
FROM RequestAccepted 
GROUP BY accepter_id
)
,
totals AS
(
SELECT 
    DISTINCT ra.requester_id as id, 
    IFNULL(a.total_accepts,0) + IFNULL(r.total_requests,0) as num
FROM RequestAccepted ra 
LEFT JOIN accepts a ON a.accepter_id = ra.requester_id
LEFT JOIN requests r ON r.requester_id = ra.requester_id
)

SELECT id, num
FROM totals
ORDER BY num DESC
LIMIT 1
```

### 585. Investments in 2016
https://leetcode.com/problems/investments-in-2016/

```sql
WITH criteria_1A AS 
(
    SELECT tiv_2015, COUNT(tiv_2015) AS total_tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
),
criteria_1 AS 
(
SELECT tiv_2015
FROM criteria_1A
WHERE total_tiv_2015 > 1
),
criteria_2A AS
(
    SELECT lat, lon, COUNT(CONCAT(lat, lon)) as total_latlon_pairs
    FROM Insurance
    GROUP BY lat, lon
),
criteria_2 AS 
(
SELECT CONCAT(lat,lon) as pairs
FROM criteria_2A
WHERE total_latlon_pairs > 1
)

SELECT ROUND(SUM(tiv_2016),2) as tiv_2016
FROM Insurance
WHERE CONCAT(lat, lon) NOT IN (SELECT * FROM criteria_2)
AND tiv_2015 IN (SELECT * FROM criteria_1)
```

### 185. Department Top Three Salaries
https://leetcode.com/problems/department-top-three-salaries/

```sql
select 
    result.name as Employee,
    d.name as Department,
    result.salary as Salary
from
    (select 
        name, 
        departmentId,
        salary,
        dense_rank() over (
        partition by departmentId
        order by salary desc) as salaryRank
    from Employee e
    group by departmentId, name
    ) result
join Department d on d.id = result.departmentId 
where salaryRank <= 3
```
