# Regex

### 2738. Count Occurrences in Text
https://leetcode.com/problems/count-occurrences-in-text/

- poor description
- standalone word means that the word must not be the first or last word in the text, e.g. bull is not a bear, doesn't contain bull or bear.

```sql
WITH bull AS 
(
SELECT 
  'bull' as word,
  SUM(REGEXP_LIKE(content,"[^a-z]bull[^a-z]")) AS count
FROM Files 
)
,
bear AS
(
SELECT 
  'bear' as word,
  SUM(REGEXP_LIKE(content,"[^a-z]bear[^a-z]")) AS count
FROM Files 
)

SELECT * FROM bull
UNION
SELECT * FROM bear
```
