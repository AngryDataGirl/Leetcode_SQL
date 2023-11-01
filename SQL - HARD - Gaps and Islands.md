- [Gaps and Islands (consecutive groups)](#gaps-and-islands-consecutive-groups)
    - [1225. Report Contiguous Dates](#1225-report-contiguous-dates)
    - [2173. Longest Winning Streak](#2173longest-winning-streak)
    - [2701. Consecutive Transactions with Increasing Amounts](#2701-consecutive-transactions-with-increasing-amounts)
    - [2752. Customers with Maximum Number of Transactions on Consecutive Days](#2752-customers-with-maximum-number-of-transactions-on-consecutive-days)

# Gaps and Islands (consecutive groups)

This kind of question occurs periodically in the HARD SQL questions on LeetCode.

The "gaps and islands" 
- "islands" = groups of continuous data 
- "gaps" = groups where the data is missing across a particular sequence

Thus:
- "key" - the main sequence, can be created using a window function over the core sequence 
- "values" - the partitioned values on the sequence which help us create the islands
- subtracting values from key will create the islands
- *how do you know when to use row number, dense rank? or rank?*

**Useful links**:
- https://stackoverflow.com/questions/36927685/count-number-of-consecutive-occurrence-of-values-in-table
- https://mattboegner.com/improve-your-sql-skills-master-the-gaps-islands-problem/

### 1225. Report Contiguous Dates
https://leetcode.com/problems/report-contiguous-dates/

- key: event date
- values: event date partitioned by period_state

```sql
WITH cte1 AS 
(
SELECT 'failed' as period_state, fail_date as event_date
FROM Failed
UNION
SELECT 'succeeded' as period_state, success_date as event_date
FROM Succeeded
ORDER BY event_date
)
,
cte2 AS 
(
SELECT *, 
    row_number() OVER(ORDER BY event_date) as event_id,
    dense_rank() OVER(PARTITION BY period_state ORDER BY event_date) as drnk
FROM cte1 
WHERE year(event_date) = 2019
)
,
cte3 AS 
(
SELECT *, event_id - drnk as grp
FROM cte2
)

SELECT 
    period_state, 
    min(event_date) as start_date, 
    max(event_date) as end_date 
FROM cte3
GROUP BY grp, period_state
ORDER BY start_date
```

### 2173. Longest Winning Streak
https://leetcode.com/problems/longest-winning-streak/

- since we are trying to find the winning streaks
    - key : match day
    - values: match day where result = win

```sql
#add row number
WITH cte AS 
(
SELECT 
    player_id,
    match_day, 
    result, 
    row_number() OVER(PARTITION BY player_id ORDER BY match_day) as rn
FROM Matches
)
#separate the wins records
,
cte2 AS 
(
SELECT 
    player_id,
    # this creates the group id 
    rn - ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_day) AS group_id
FROM cte
WHERE result = 'Win'
)
#count the win streaks
,
win_streaks AS 
(
SELECT 
    player_id, 
    count(group_id) as win_streak
FROM cte2 
# WHERE player_id = 429        
GROUP BY player_id, group_id
)

SELECT DISTINCT 
    m.player_id, IFNULL(longest_streak,0) as longest_streak
FROM Matches m
LEFT JOIN (
    SELECT player_id, 
        MAX(win_streak) as longest_streak
    FROM win_streaks
    GROUP BY player_id
) t 
ON t.player_id = m.player_id
```

### 2701. Consecutive Transactions with Increasing Amounts
https://leetcode.com/problems/consecutive-transactions-with-increasing-amounts/

- the main trick with this problem is that there are two groups we need to keep track of 
- first, the consecutive date streaks per customer
    - the id / key is the transaction dates (since this is the contiguous set we are trying to find)
    - the values is the transaction date partitioned by the customer id 
- second, the date streaks where the amount was increasing 
- note that you have to turn the dates into integer values, else it will fail the last case with customer 29 
- note that you also have to use row_number(), dense rank will also fail a case 

```sql
WITH cte1 AS -- this CTE keeps the rows of the original tables, while creating the first grouping based on consecutive dates
(
 SELECT
    t.*,
    -- ranking of the dates - ranking of the dates by customer to create groups
    TO_DAYS(T.transaction_date) - row_number() OVER(PARTITION BY t.customer_id ORDER BY t.transaction_date) AS consec_dts_group 
  FROM
    Transactions t
)
,
cte2 AS -- this CTE gives customer_id & the consecutive dates group 
(
SELECT 
    customer_id,
    -- we subtract one from the other to great the islands 
    consec_dts_group 
FROM cte1 c1
-- because a customer can have multiple consecutive grps, we need to group it by customer and grp
GROUP BY customer_id, consec_dts_group 
HAVING count(consec_dts_group) >= 3
)
# | customer_id | grp      |
# | ----------- | -------- |
# | 101         | 20230500 |
# | 105         | 20230500 |
# | 105         | 20230507 |
,
cte3a AS -- create lagged variable to see where amount is increasing
( 
 SELECT
    c1.*,
    LAG(c1.amount, 1, c1.amount) -- note that we lag it by 1 interval, the third arg puts the same amount if it is null
    OVER(PARTITION BY c1.customer_id, c1.consec_dts_group ORDER BY c1.transaction_date) as lag_amount
FROM cte1 c1
)
# | transaction_id | customer_id | transaction_date | amount | consecutive_dates_group | lag_amount |
# | -------------- | ----------- | ---------------- | ------ | ----------------------- | ---------- |
# | 1              | 101         | 2023-05-01       | 100    | 20230500                | 100        |
# | 2              | 101         | 2023-05-02       | 150    | 20230500                | 100        |
# | 3              | 101         | 2023-05-03       | 200    | 20230500                | 150        |
# | 4              | 102         | 2023-05-01       | 50     | 20230500                | 50         |
# | 5              | 102         | 2023-05-03       | 100    | 20230501                | 100        |
# | 6              | 102         | 2023-05-04       | 200    | 20230501                | 100        |
# | 7              | 105         | 2023-05-01       | 100    | 20230500                | 100        |
# | 8              | 105         | 2023-05-02       | 150    | 20230500                | 100        |
,
cte3b AS -- this creates the flag for when the new subgroup starts 
(
SELECT 
  c3a.*,
  (CASE WHEN c3a.amount - c3a.lag_amount <= 0 THEN 1 ELSE 0 END) AS inc_amt_subgroup 
FROM cte3a c3a
)
# | transaction_id | customer_id | transaction_date | amount | consec_dts_group | lag_amount | inc_amt_subgroup |
# | -------------- | ----------- | ---------------- | ------ | ---------------- | ---------- | ---------------- |
# | 1              | 101         | 2023-05-01       | 100    | 20230500         | 100        | 1                |
# | 2              | 101         | 2023-05-02       | 150    | 20230500         | 100        | 0                |
# | 3              | 101         | 2023-05-03       | 200    | 20230500         | 150        | 0                |
# | 4              | 102         | 2023-05-01       | 50     | 20230500         | 50         | 1                |
# | 5              | 102         | 2023-05-03       | 100    | 20230501         | 100        | 1                |
# | 6              | 102         | 2023-05-04       | 200    | 20230501         | 100        | 0                |
# | 7              | 105         | 2023-05-01       | 100    | 20230500         | 100        | 1       
,
cte4 AS -- cte2 with the consecutive dates, is joined to cte3b where we created the increasing amount subgroup
-- this creates a table with both subgroups together
(
SELECT 
  c3b.*
FROM cte3b c3b
INNER JOIN cte2 c2 
  ON c3b.customer_id = c2.customer_id
  AND c3b.consec_dts_group = c2.consec_dts_group
)
# | transaction_id | customer_id | transaction_date | amount | consec_dts_group | lag_amount | inc_amt_subgroup |
# | -------------- | ----------- | ---------------- | ------ | ---------------- | ---------- | ---------------- |
# | 7              | 105         | 2023-05-01       | 100    | 20230500         | 100        | 1                |
# | 8              | 105         | 2023-05-02       | 150    | 20230500         | 100        | 0                |
# | 9              | 105         | 2023-05-03       | 200    | 20230500         | 150        | 0                |
# | 10             | 105         | 2023-05-04       | 300    | 20230500         | 200        | 0                |
# | 11             | 105         | 2023-05-12       | 250    | 20230507         | 250        | 1                |
# | 12             | 105         | 2023-05-13       | 260    | 20230507         | 250        | 0                |
# | 13             | 105         | 2023-05-14       | 270    | 20230507         | 260        | 0   
,
cte5 AS -- this CTE creates the final grouping 
(
SELECT 
 c4.*,
 SUM(c4.inc_amt_subgroup) OVER(PARTITION BY c4.customer_id ORDER BY c4.transaction_date) as final_grp
FROM cte4 c4
)
# | transaction_id | customer_id | transaction_date | amount | consec_dts_group | lag_amount | inc_amt_subgroup | grp |
# | -------------- | ----------- | ---------------- | ------ | ---------------- | ---------- | ---------------- | --- |
# | 7              | 105         | 2023-05-01       | 100    | 20230500         | 100        | 1                | 1   |
# | 8              | 105         | 2023-05-02       | 150    | 20230500         | 100        | 0                | 1   |
# | 9              | 105         | 2023-05-03       | 200    | 20230500         | 150        | 0                | 1   |
# | 10             | 105         | 2023-05-04       | 300    | 20230500         | 200        | 0                | 1   |
# | 11             | 105         | 2023-05-12       | 250    | 20230507         | 250        | 1                | 2   |
# | 12             | 105         | 2023-05-13       | 260    | 20230507         | 250        | 0                | 2   |
# | 13             | 105         | 2023-05-14       | 270    | 202...

SELECT 
  customer_id,
  MIN(transaction_date) as consecutive_start,
  MAX(transaction_date) as consecutive_end
FROM cte5 
GROUP BY customer_id, final_grp
HAVING count(final_grp) >= 3
ORDER BY customer_id
-- final output 
# +-------------+-------------------+-----------------+
# | customer_id | consecutive_start | consecutive_end | 
# +-------------+-------------------+-----------------+
# | 101         |  2023-05-01       | 2023-05-03      | 
# | 105         |  2023-05-01       | 2023-05-04      |
# | 105         |  2023-05-12       | 2023-05-14      | 
# +-------------+-------------------+-----------------+ -->
```

### 2752. Customers with Maximum Number of Transactions on Consecutive Days
https://leetcode.com/problems/customers-with-maximum-number-of-transactions-on-consecutive-days/

```sql
#find consecutive transactions
WITH grps AS 
(
select 
    customer_id, 
    TO_DAYS(transaction_date) - rank() over (partition by customer_id order by transaction_date) as grp
from Transactions  t
)
,
#get max count of consecutive transactions 
total_transactions AS 
(
SELECT customer_id, count(grp) as total_consecutive_trans
FROM grps
GROUP BY customer_id, grp
)

SELECT customer_id 
FROM total_transactions
WHERE total_consecutive_trans = (SELECT max(total_consecutive_trans) FROM total_transactions)
ORDER BY 1

```
