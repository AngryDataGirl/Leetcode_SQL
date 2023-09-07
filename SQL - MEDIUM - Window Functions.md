# SQL - Medium - Window Functions

## Table of Contents

- [177](#177)
- [184](#184)
- [1308](#1308)
- [2159](#2159)
- [2066](#2066)
- [2346](#2346)
- [2820](#2820)

---

## Solutions

### 177
Nth Highest Salary
https://leetcode.com/problems/nth-highest-salary/

```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below.
       SELECT 
            CASE WHEN SALARY IS NULL THEN NULL
            ELSE SALARY END AS getNthHighestSalary 
        FROM (
            SELECT SALARY,ROW_NUMBER() OVER(ORDER BY SALARY DESC)RN
            FROM
                (
                    SELECT DISTINCT SALARY FROM EMPLOYEE
                )E
              )T
        WHERE RN=N
  );
END
```

### 184
Department Highest Salary
https://leetcode.com/problems/department-highest-salary/

```sql
WITH cte1 AS 
(
SELECT 
    e.name as employee_name, 
    e.salary, 
    d.name as dept_name, 
    rank() OVER(PARTITION BY departmentId ORDER BY salary DESC) as rnk
FROM Employee e 
LEFT JOIN Department d ON d.id = e.departmentId
)

SELECT dept_name as Department, employee_name as Employee, Salary 
FROM cte1 
WHERE rnk = 1
```

### 1308
Running Total for Different Genders
https://leetcode.com/problems/running-total-for-different-genders/

```sql
SELECT 
    gender, 
    day,
    SUM(score_points) OVER(PARTITION BY gender ORDER BY day) as total
FROM Scores
```

### 2066
Account Balance
https://leetcode.com/problems/account-balance/

```sql
WITH types AS 
(
    SELECT 
        account_id, day, type, amount, 
        CASE WHEN type = 'Deposit' THEN amount 
            WHEN type = 'Withdraw' THEN amount*(-1) 
            ELSE 0 END as balance 
    FROM Transactions
)

SELECT 
    account_id, 
    day, 
    SUM(balance) OVER(partition by account_id ORDER BY day) as balance
FROM types
```

### 2159
Order Two Columns Independently
https://leetcode.com/problems/order-two-columns-independently/

1. create row number alias?
2. join on rn after sorting

```sql
WITH data1 AS 
(
SELECT DISTINCT first_col, 
    row_number() OVER(ORDER BY first_col ASC) as RN FROM Data 
), 
data2 AS
(
SELECT DISTINCT second_col,
    row_number() OVER(ORDER BY second_col DESC) as RN FROM Data
)

SELECT first_col, second_col
FROM data1 
JOIN data2 ON data1.RN = data2.RN
```

### 2346
Compute the Rank as a Percentage
https://leetcode.com/problems/compute-the-rank-as-a-percentage/

```sql
WITH cte1 AS 
(
SELECT *, rank() OVER(PARTITION BY department_id ORDER BY mark DESC) as rnk
FROM Students s
)
,
cte2 AS 
(
SELECT department_id, count(student_id) as total_students
FROM Students 
GROUP BY department_id
)

SELECT 
    c1.student_id, 
    c1.department_id, 
    IFNULL(ROUND(((rnk - 1) * 100) / (total_students - 1),2),0) as percentage
FROM cte1 c1
JOIN cte2 c2 ON c2.department_id = c1.department_id
```

### 2820
Election Results
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
