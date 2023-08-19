# SQL - Medium - Window Functions

## Table of Contents

- [2820](#2820)

---

## Solutions
### 2820. Election Results
https://leetcode.com/problems/election-results/description/

```sql
WITH votes AS 
(
SELECT 
candidate, 
sum(vote_value) as total
FROM
(
  SELECT 
    voter, 
    candidate, 
    1/(count(voter) OVER(PARTITION BY voter)) as vote_value
  FROM Votes
) t
GROUP BY candidate
)

SELECT candidate
FROM votes v
WHERE total IN (SELECT max(total) FROM votes)
ORDER BY candidate ASC
```
