# SQL 50

## Sorting and Grouping

### 2356. Number of Unique Subjects Taught by Each Teacher
https://leetcode.com/problems/number-of-unique-subjects-taught-by-each-teacher/

```sql
SELECT 
    teacher_id, 
    COUNT(DISTINCT subject_id) as 'cnt'
FROM Teacher
GROUP BY teacher_id
```
