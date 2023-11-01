- [620. Not Boring Movies](#620-not-boring-movies)
- [1251. Average Selling Price](#1251-average-selling-price)
- [1075. Project Employees I](#1075-project-employees-i)
- [1633. Percentage of Users Attended a Contest](#1633-percentage-of-users-attended-a-contest)
- [1211. Queries Quality and Percentage](#1211-queries-quality-and-percentage)
- [1193. Monthly Transactions I](#1193-monthly-transactions-i)
- [1174. Immediate Food Delivery II](#1174-immediate-food-delivery-ii)
- [550. Game Play Analysis IV](#550-game-play-analysis-iv)

### 620. Not Boring Movies
https://leetcode.com/problems/not-boring-movies/

```sql
SELECT  
    id, 
    movie, 
    description, 
    rating
FROM 
    Cinema
WHERE 
    # filter out the results where description is "boring" since we want the non-boring movies
    description <> 'boring' 
AND 
    # the question asked for odd numbered IDs so we use a MOD 
    id % 2 = 1
# question specified order to results
ORDER BY rating desc
```

### 1251. Average Selling Price
https://leetcode.com/problems/average-selling-price/

```sql
# Write your MySQL query statement below
WITH combined_table AS 
(
SELECT 
    us.product_id, 
    us.purchase_date, 
    us.units, 
    # we join the prices table to get price column
    p.price
FROM UnitsSold us 
LEFT JOIN Prices p
    ON p.product_id = us.product_id
    # filter for the right price during the correct start and end period
WHERE purchase_date BETWEEN p.start_date AND p.end_date
)

SELECT 
    product_id, 
    # the average price is explained as Total Price of Product / Number products sold 
    ROUND(SUM(units * price) / SUM(units),2) as average_price
FROM combined_table
GROUP BY product_id
```

### 1075. Project Employees I
https://leetcode.com/problems/project-employees-i/

```sql
SELECT 
    project_id, 
    ROUND(AVG(experience_years),2) as average_years
FROM Employee e
JOIN Project p 
    ON p.employee_id = e.employee_id
GROUP BY project_id
```

### 1633. Percentage of Users Attended a Contest
https://leetcode.com/problems/percentage-of-users-attended-a-contest/

```sql
# Write your MySQL query statement below

# get total users that could potentially register for a contest
WITH total_users AS
(
    SELECT 
        COUNT(DISTINCT user_id) as total_users
    FROM 
        Users u
)

# find percentage of users registered in each contest 
SELECT 
    r.contest_id, 
    # we divide the number of distinct users by total users, 
    # ie if all users registered in a contest, the percentage would be 100% 
    ROUND((COUNT(distinct r.user_id)/total_users)*100,2) as percentage
FROM 
    Register r 
JOIN 
    total_users tu ON user_id = r.user_id
GROUP BY 
    r.contest_id
ORDER BY 
    percentage DESC, 
    contest_id ASC
```

### 1211. Queries Quality and Percentage
https://leetcode.com/problems/queries-quality-and-percentage/

```sql
SELECT 
    query_name, 
    ROUND(AVG(rating / position),2) as quality, 
    ROUND(
        AVG(
            CASE WHEN rating < 3 THEN 1 ELSE 0 END
            ) * 100, 
        2) as poor_query_percentage
FROM Queries q
GROUP BY query_name
```

### 1193. Monthly Transactions I
https://leetcode.com/problems/monthly-transactions-i/

```sql
SELECT  
    # creates the date in the month_approved format required for output
    DATE_FORMAT(trans_date, '%Y-%m') as month, 
    country,
    # total transactions count is simple, we just count the id
    COUNT(id) as trans_count,
    # this counts only those with state approved 
    COUNT(CASE 
            WHEN state = 'approved' THEN state 
            WHEN state = 'declined' THEN NULL
            END) AS approved_count,
    # total amount 
    SUM(amount) AS trans_total_amount,
    # sums the total amounts only if the state was "approved" 
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) as approved_total_amount
FROM Transactions
# group by to appropriately group the aggregate calculations
GROUP BY 1, 2

```

### 1174. Immediate Food Delivery II
https://leetcode.com/problems/immediate-food-delivery-ii/

```sql
# Write your MySQL query statement below
WITH crit1 AS 
(
SELECT 
    delivery_id, 
    customer_id, 
    CASE WHEN order_date = customer_pref_delivery_date 
        THEN 'immediate' 
        ELSE 'scheduled' 
        END AS order_type, 
    rank() OVER (
        PARTITION BY customer_id 
        ORDER BY order_date) AS order_number
FROM 
    Delivery
)
,
immediate_count AS
(
SELECT 
    count(delivery_id) as immediate_total
FROM 
    crit1
WHERE 
    order_number = 1 
    AND order_type = 'immediate'
)
,
total_first AS 
(
    SELECT 
        count(delivery_id) as total_first_order
    FROM 
        crit1
    WHERE 
        order_number = 1
)

SELECT 
    ROUND((immediate_total/total_first_order)*100,2) as immediate_percentage 
FROM 
    immediate_count, 
    total_first

```

### 550. Game Play Analysis IV
https://leetcode.com/problems/game-play-analysis-iv/

```sql
# get the first login and next_login date
WITH logins AS 
(
SELECT 
    dense_rank() OVER(PARTITION BY player_id ORDER BY event_date) as rnk,
    lead(event_date) OVER(PARTITION BY player_id ORDER BY event_date) as next_login,
    player_id, 
    device_id, 
    event_date, 
    games_played
FROM 
    Activity a
)

SELECT 
    # round the final fraction
    ROUND(
        (
        # count only of the next login is same as subsequent day
        COUNT(
            CASE WHEN rnk = 1 AND next_login = event_date + 1 
            THEN 1 ELSE NULL END
            ) 
        # divide by total unique players
        / COUNT(DISTINCT player_id)),2) as fraction
FROM logins
```
alternate solution using CTEs to break out the calculations

```sql
WITH first_login AS 
(
    SELECT player_id, min(a.event_date)
    FROM Activity a
    GROUP BY a.player_id
),
day_after_login as 
(
    SELECT player_id, DATE(min(a.event_date)+1) as event_date
    FROM Activity a
    GROUP BY a.player_id
),
user_who_logged_in AS
(
SELECT a.player_id, a.event_date
FROM Activity a
JOIN day_after_login dl ON dl.player_id = a.player_id
    AND dl.event_date = a.event_date
GROUP BY player_id
)

SELECT 
  ROUND(COUNT(DISTINCT ui.player_id)/COUNT(DISTINCT a.player_id),2) as fraction
FROM Activity a, user_who_logged_in ui
```
