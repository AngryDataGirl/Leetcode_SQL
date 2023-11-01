- [1193. Monthly Transactions I](#1193monthly-transactions-i)
- [1205. Monthly Transactions II](#1205monthly-transactions-ii)
- [1098. Unpopular Books](#1098unpopular-books)
- [1393. Capital Gain/Loss](#1393-capital-gainloss)
- [2072. The Winner University](#2072the-winner-university)


### 1193. Monthly Transactions I
https://leetcode.com/problems/monthly-transactions-i/

```sql
SELECT  
    DATE_FORMAT(trans_date, '%Y-%m') as month, 
    country,
    COUNT(id) as trans_count,
    COUNT(CASE 
            WHEN state = 'approved' THEN state 
            WHEN state = 'declined' THEN NULL
            END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) as approved_total_amount
FROM Transactions
GROUP BY 1, 2
```

### 1205. Monthly Transactions II
https://leetcode.com/problems/monthly-transactions-ii/

```sql
# Write your MySQL query statement below
WITH combined AS
(
SELECT 
    c.trans_id as id,
    t.country as country, 
    'chargeback' as state, 
    t.amount as amount, 
    DATE_FORMAT(c.trans_date,'%Y-%m') as month 
FROM Chargebacks c
JOIN Transactions t ON c.trans_id = t.id
UNION
SELECT 
    t1.id, 
    t1.country, 
    t1.state, 
    t1.amount, 
    DATE_FORMAT(t1.trans_date,'%Y-%m') as month 
FROM Transactions t1
)
,
total as (
SELECT 
    month, 
    country, 
    SUM(IF(state = 'approved',1,0)) as approved_count,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) as approved_amount,
    SUM(IF(state = 'chargeback',1,0)) as chargeback_count,
    SUM(CASE WHEN state = 'chargeback' THEN amount ELSE 0 END) as chargeback_amount
FROM combined
GROUP BY 1, 2
ORDER BY 1
)

SELECT *
FROM total
WHERE (approved_count != 0 
OR approved_amount != 0 
OR chargeback_count != 0 
OR chargeback_amount != 0)
```

or second solution

```sql
select left(trans_date,7) as month, country,  
sum(case when state = 'approved' then 1 else 0 end) as approved_count,
sum(case when state = 'approved' then amount else 0 end) as approved_amount,
sum(case when state = 'chargeback' then 1 else 0 end) as chargeback_count,
sum(case when state = 'chargeback' then amount else 0 end) as chargeback_amount
from 
    (select trans_id as id, country, 'chargeback' as state, amount, Chargebacks.trans_date  as trans_date 
    from Chargebacks 
    join Transactions on Transactions.id = Chargebacks.trans_id
    union
    select id, country, state, amount, trans_date 
    from Transactions) as tmp1
group by month,country
having (approved_count+approved_amount+chargeback_count+chargeback_amount) > 0;
```


### 1098. Unpopular Books
https://leetcode.com/problems/unpopular-books/

```sql
SELECT 
    b.book_id, 
    b.name
FROM books b
LEFT JOIN orders o ON o.book_id = b.book_id
WHERE datediff('2019-06-23', available_from)>30
GROUP BY b.book_id, b.name
HAVING
    SUM(CASE 
            WHEN datediff('2019-06-23',dispatch_date)>365 
            THEN quantity=0 
            ELSE quantity 
            END)
        <10 
OR SUM(QUANTITY) IS NULL
```

### 1393. Capital Gain/Loss
https://leetcode.com/problems/capital-gainloss/

```SQL
select
    stock_name, 
sum(
    case when operation = 'Buy' 
    then price*-1 
    else price 
end) as capital_gain_loss
from Stocks
group by stock_name
```

### 2072. The Winner University
https://leetcode.com/problems/the-winner-university/

```sql
WITH NYwin AS 
(
SELECT COUNT(student_id) as win
FROM NewYork 
WHERE score >= 90
),
CALIwin AS
(
SELECT COUNT(student_id) as win
FROM California 
WHERE score >= 90
)

SELECT 
    CASE WHEN ny.win > ca.win THEN 'New York University' 
        WHEN ca.win > ny.win THEN 'California University' 
        ELSE 'No Winner' END AS winner
FROM NYwin ny, CALIwin ca
```