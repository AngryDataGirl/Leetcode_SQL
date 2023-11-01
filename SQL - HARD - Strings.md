- [2118. Build the Equation](#2118-build-the-equation)
- [2199. Finding the Topic of Each Post](#2199-finding-the-topic-of-each-post)


### 2118. Build the Equation
https://leetcode.com/problems/build-the-equation/

```sql
# Write your MySQL query statement below
WITH a AS (
SELECT 
    CASE WHEN factor > 0 THEN '+' ELSE '' END as sign, 
    factor, 
    CASE WHEN power = 1 THEN 'X' 
        WHEN power = 0 THEN '' ELSE CONCAT('X^', power) END as x
    ,
    power
FROM Terms 
)

SELECT 
    CONCAT(
        GROUP_CONCAT(sign, factor, x ORDER BY power DESC SEPARATOR ''),
        '=0'
    ) AS equation
FROM a
```

### 2199. Finding the Topic of Each Post
https://leetcode.com/problems/finding-the-topic-of-each-post/

```sql
WITH cte1 AS 
(
SELECT DISTINCT
    p.post_id, p.content, k.topic_id, k.word
FROM Posts p
LEFT JOIN Keywords k
ON concat(' ', lower(p.content), ' ') like concat('% ', lower(k.word), ' %')
) 

SELECT 
    post_id, 
    COALESCE(GROUP_CONCAT(distinct topic_id order by topic_id),'Ambiguous!') as topic
FROM cte1
GROUP BY post_id
```
