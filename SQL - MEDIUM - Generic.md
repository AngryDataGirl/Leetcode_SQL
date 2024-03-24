
- [612. Shortest Distance in a Plane](#612shortest-distance-in-a-plane)
- [1132. Reported Posts II](#1132reported-posts-ii)
- [1149. Article Views II](#1149article-views-ii)
- [1158. Market Analysis I](#1158market-analysis-i)
- [1212. Team Scores in Football Tournament](#1212team-scores-in-football-tournament)
- [1398. Customers Who Bought Products A and B but Not C](#1398customers-who-bought-products-a-and-b-but-not-c)
- [1440. Evaluate Boolean Expression](#1440evaluate-boolean-expression)
- [1445. Apples \& Oranges](#1445apples--oranges)
- [1459. Rectangles Area](#1459rectangles-area)
- [1468. Calculate Salaries](#1468calculate-salaries)
- [1699. Number of Calls Between Two Persons](#1699number-of-calls-between-two-persons)
- [1715. Count Apples and Oranges](#1715count-apples-and-oranges)
- [1783. Grand Slam Titles](#1783grand-slam-titles)
- [1841. League Statistics](#1841league-statistics)
- [2308. Arrange Table by Gender](#2308-arrange-table-by-gender)
- [2298. Tasks Count in the Weekend](#2298tasks-count-in-the-weekend)
- [2372. Calculate the Influence of Each Salesperson](#2372calculate-the-influence-of-each-salesperson)
- [2893. Calculate Orders Within Each Interval](#2893-calculate-orders-within-each-interval)
- [3087. Find Trending Hashtags](#3087-find-trending-hashtags)


### 612. Shortest Distance in a Plane
https://leetcode.com/problems/shortest-distance-in-a-plane/

```sql
WITH distances_CTE AS
(
SELECT 
    sqrt(
        power((p2.x - p1.x),2) + power((p2.y - p1.y),2)
        ) as distance 
FROM Point2D p1, Point2D p2 
WHERE CONCAT(p1.x, p1.y) <> CONCAT(p2.x, p2.y)
)

SELECT ROUND(min(distance),2) as shortest
FROM distances_CTE

```

### 1132. Reported Posts II
https://leetcode.com/problems/reported-posts-ii/
`There is no primary key for this table, it may have duplicate rows.` Usually means you have to add DISTINCT in the queries. Additionally, the average was weird, since it said “do not care about action or remove dates” so if you added 0 for all action dates it would give wrong average, also need to make remove / total spam (not the reverse).

```sql
WITH spam AS
(
    SELECT DISTINCT user_id, post_id, action_date, action, extra
    FROM Actions
    WHERE action = 'report' AND extra = 'spam'
),
spam_removes AS 
(
SELECT DISTINCT action_date, IFNULL(s.post_id,NULL) as spam_id, IFNULL(r.post_id,NULL) as remove_id
FROM spam s 
LEFT JOIN Removals r ON r.post_id = s.post_id
),
percentages_table AS 
(
SELECT action_date, COUNT(remove_id) as trem, COUNT(spam_id) as tspam, COUNT(remove_id)/COUNT(spam_id)*100 as percentage
FROM spam_removes
GROUP BY action_date
)

SELECT ROUND(avg(percentage),2) as average_daily_percent
FROM percentages_table
```

### 1149. Article Views II
https://leetcode.com/problems/article-views-ii/

```sql
SELECT DISTINCT viewer_id AS id
FROM Views
GROUP BY viewer_id, view_date
HAVING COUNT(DISTINCT article_id)>1
ORDER BY viewer_id ASC
```

### 1158. Market Analysis I
https://leetcode.com/problems/market-analysis-i/description/

```sql
SELECT user_id AS buyer_id, join_date, COUNT(o.order_id) AS orders_in_2019
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.buyer_id AND YEAR(order_date)='2019'
GROUP BY user_id
ORDER BY user_id
```

### 1212. Team Scores in Football Tournament
https://leetcode.com/problems/team-scores-in-football-tournament/

```sql
WITH host_points as 
(
SELECT 
    m.match_id,
    m.host_team as team_id, 
    SUM(CASE WHEN m.host_goals > m.guest_goals THEN 3 
            WHEN m.host_goals = m.guest_goals THEN 1 
            ELSE 0 END) as num_points
FROM Matches m 
GROUP BY m.match_id
),
guest_points AS
(
SELECT 
    m.match_id,
    m.guest_team as team_id,
    SUM(CASE WHEN m.guest_goals > m.host_goals THEN 3 
            WHEN m.guest_goals = m.host_goals THEN 1 
            ELSE 0 END) as num_points
FROM Matches m 
GROUP BY match_id
),
combined AS
(
    SELECT * FROM host_points
    UNION ALL
    SELECT * FROM guest_points
)

SELECT t.team_id, t.team_name, IFNULL(sum(num_points),0) as num_points
FROM Teams t
LEFT JOIN combined c ON c.team_id = t.team_id
GROUP BY team_id
ORDER BY num_points DESC, team_id ASC
```

second solution

```sql
SELECT team_id,team_name,
SUM(CASE WHEN team_id=host_team AND host_goals>guest_goals THEN 3
         WHEN team_id=guest_team AND guest_goals>host_goals THEN 3
         WHEN team_id=host_team AND host_goals=guest_goals THEN 1
         WHEN team_id=guest_team AND guest_goals=host_goals THEN 1 ELSE 0 END) as num_points
FROM Teams
LEFT JOIN Matches
ON team_id=host_team OR team_id=guest_team
GROUP BY team_id
ORDER BY num_points DESC, team_id ASC;
```

### 1398. Customers Who Bought Products A and B but Not C
https://leetcode.com/problems/customers-who-bought-products-a-and-b-but-not-c/

```sql
WITH customersA AS (
    SELECT customer_id FROM Orders WHERE product_name = 'A'
),
 customersB AS (
    SELECT customer_id FROM Orders WHERE product_name = 'B'
),
 customersC AS (
    SELECT customer_id FROM Orders WHERE product_name = 'C'
)

SELECT DISTINCT o.customer_id, c.customer_name FROM Orders o
JOIN Customers c ON c.customer_id = o.customer_id
WHERE o.customer_id IN (SELECT * FROM CustomersA)
AND o.customer_id IN (SELECT * FROM CustomersB)
AND o.customer_id NOT IN (SELECT * FROM CustomersC)
```

### 1440. Evaluate Boolean Expression
https://leetcode.com/problems/evaluate-boolean-expression/

```sql
SELECT 
    left_operand, operator, right_operand, 
    CASE WHEN operator = '>' THEN IF(v1.value > v2.value,"true","false") 
        WHEN operator = '=' THEN IF(v1.value = v2.value,"true","false") 
        WHEN operator = '<' THEN IF(v1.value < v2.value,"true","false")
    END AS value   
FROM Expressions e
JOIN Variables v1 ON v1.name = e.left_operand 
LEFT JOIN Variables v2 on v2.name = e.right_operand
```

### 1445. Apples & Oranges
https://leetcode.com/problems/apples-oranges/

```sql
SELECT 
a.sale_date, a.sold_num - b.sold_num as diff
FROM Sales a
JOIN Sales b ON b.sale_date = a.sale_date
WHERE a.fruit = "apples" AND a.fruit <> b.fruit
```

### 1459. Rectangles Area
https://leetcode.com/problems/rectangles-area/

```sql
#get areas
WITH areas AS (
SELECT DISTINCT 
    p1.id as P1, p2.id as P2,
    # p1.x_value, p2.x_value, p1.y_value, p2.y_value, 
    ABS(p1.x_value - p2.x_value) * ABS(p1.y_value - p2.y_value) as AREA
FROM Points p1, Points p2
WHERE p1.x_value <> p2.x_value
HAVING AREA > 0
)

SELECT DISTINCT 
    CASE WHEN P1 > P2 THEN P2 ELSE P1 END AS P1,
    CASE WHEN P1 > P2 THEN P1 ELSE P2 END AS P2,
    AREA 
FROM areas
ORDER BY AREA DESC, P1 ASC
```

### 1468. Calculate Salaries
https://leetcode.com/problems/calculate-salaries/

```sql
WITH company_tax_rate AS 
(
SELECT company_id,
    CASE WHEN max(salary) < 1000 THEN 0.00
         WHEN max(salary) >= 1000 AND max(salary) <= 10000 THEN 0.24
         ELSE 0.49 END
    AS tax_rate
FROM Salaries 
GROUP BY company_id
)

SELECT s.company_id, s.employee_id, s.employee_name, ROUND(s.salary-(s.salary*t.tax_rate),0) as salary
FROM Salaries s
JOIN company_tax_rate as t ON t.company_id = s.company_id
```

### 1699. Number of Calls Between Two Persons
https://leetcode.com/problems/number-of-calls-between-two-persons/

```sql
SELECT 
    CASE WHEN from_id < to_id THEN from_id ELSE to_id END as person1,
    CASE WHEN from_id > to_id THEN from_id ELSE to_id END as person2,
    COUNT(*) as call_count, 
    SUM(duration) as total_duration
FROM Calls  
GROUP BY person1, person2
```

### 1715. Count Apples and Oranges
https://leetcode.com/problems/count-apples-and-oranges/

```sql
#combine boxes and chests
SELECT
    IFNULL(sum(b.apple_count),0) + IFNULL(sum(c.apple_count),0) as apple_count,
    IFNULL(sum(b.orange_count),0) + IFNULL(sum(c.orange_count),0) as orange_count
FROM Boxes b
LEFT JOIN Chests c ON c.chest_id = b.chest_id
```

### 1783. Grand Slam Titles
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

### 1841. League Statistics
https://leetcode.com/problems/league-statistics/

```sql
WITH stats AS 
(SELECT 
    team_name, 
    COUNT(*) as matches_played, 
    SUM(CASE 
        WHEN team_id = home_team_id AND home_team_goals > away_team_goals THEN 3
        WHEN team_id = home_team_id AND home_team_goals = away_team_goals THEN 1
        WHEN team_id = away_team_id AND home_team_goals < away_team_goals THEN 3  
        WHEN team_id = away_team_id AND home_team_goals = away_team_goals THEN 1  
        ELSE 0 END) AS points,
    SUM(CASE 
        WHEN team_id = home_team_id THEN home_team_goals
        WHEN team_id = away_team_id THEN away_team_goals
        ELSE 0 END) AS goal_for,
    SUM(CASE 
        WHEN team_id = home_team_id THEN away_team_goals
        WHEN team_id = away_team_id THEN home_team_goals
        ELSE 0 END) AS goal_against,
    SUM(CASE 
        WHEN team_id = home_team_id THEN home_team_goals
        WHEN team_id = away_team_id THEN away_team_goals
        ELSE 0 END) - 
    SUM(CASE 
        WHEN team_id = home_team_id THEN away_team_goals
        WHEN team_id = away_team_id THEN home_team_goals
        ELSE 0 END) AS goal_diff    
FROM Teams t
JOIN Matches m ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
GROUP BY team_name)

SELECT * FROM stats
ORDER BY points DESC, goal_diff DESC, team_name ASC
```

### 2308. Arrange Table by Gender 
https://leetcode.com/problems/arrange-table-by-gender/

```sql
WITH cte1 AS(
SELECT 
user_id, 
gender, 
rank() OVER(PARTITION BY gender ORDER BY user_id) as rn, 
CASE gender WHEN 'female' THEN 1
    WHEN 'other' THEN 2
    ELSE 3 
    END AS gender_order
FROM Genders 
ORDER BY user_id
)

SELECT
    user_id,
    gender
FROM 
    cte1
ORDER BY rn ASC, gender_order ASC;
```

### 2298. Tasks Count in the Weekend
https://leetcode.com/problems/tasks-count-in-the-weekend/

```sql
SELECT 
    SUM(CASE WHEN DAYOFWEEK(submit_date) IN (1,7) THEN 1 ELSE 0 END) AS weekend_cnt,
    SUM(CASE WHEN DAYOFWEEK(submit_date) IN (2,3,4,5,6) THEN 1 ELSE 0 END) AS working_cnt
FROM Tasks
```

### 2372. Calculate the Influence of Each Salesperson
https://leetcode.com/problems/calculate-the-influence-of-each-salesperson/

```sql
SELECT 
	sp.salesperson_id, sp.name, 
	IFNULL(SUM(s.price),0) as total
FROM Salesperson sp 
LEFT JOIN Customer c ON c.salesperson_id = sp.salesperson_id
LEFT JOIN Sales s ON s.customer_id = c.customer_id
GROUP BY sp.salesperson_id
```
### 2893. Calculate Orders Within Each Interval
https://leetcode.com/problems/calculate-orders-within-each-interval/

```SQL
# Write your MySQL query statement below
SELECT 
    CEIL(minute/6) as interval_no,
    SUM(order_count) as total_orders  
FROM Orders
GROUP BY 1
ORDER BY 1 
```

### 3087. Find Trending Hashtags
https://leetcode.com/problems/find-trending-hashtags/

```SQL
SELECT 
    CONCAT('#',hashtag) as HASHTAG, 
    count(tweet_id) as HASHTAG_COUNT
FROM
    (
    SELECT 
        tweet_id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(tweet, '#', -1), ' ', 1) AS hashtag
    FROM Tweets
    ) t
GROUP BY hashtag
ORDER BY HASHTAG_COUNT DESC, HASHTAG DESC
LIMIT 3
```