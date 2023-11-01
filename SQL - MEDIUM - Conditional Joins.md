- [626. Exchange Seats](#626exchange-seats)
- [1988. Find Cutoff Score for Each School](#1988find-cutoff-score-for-each-school)



### 626. Exchange Seats
https://leetcode.com/problems/exchange-seats/

```sql
SELECT
    s1.id, COALESCE(s2.student, s1.student) AS student
FROM
    seat s1
        LEFT JOIN
    seat s2 ON ((s1.id + 1) ^ 1) - 1 = s2.id
ORDER BY s1.id;
```

### 1988. Find Cutoff Score for Each School
https://leetcode.com/problems/find-cutoff-score-for-each-school/

```sql
SELECT 
    school_id,
    IFNULL(MIN(score),-1) AS score
FROM Schools
LEFT JOIN Exam
    ON capacity >= student_count
    GROUP BY school_id
```