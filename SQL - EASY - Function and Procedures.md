- [2205. The Number of Users That Are Eligible for Discount](#2205the-number-of-users-that-are-eligible-for-discount)
- [2230. The Users That Are Eligible for Discount](#2230the-users-that-are-eligible-for-discount)


### 2205. The Number of Users That Are Eligible for Discount
https://leetcode.com/problems/the-number-of-users-that-are-eligible-for-discount/

```sql
CREATE FUNCTION getUserIDs(startDate DATE, endDate DATE, minAmount INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below.
    SELECT 
        COUNT(DISTINCT user_id)
    FROM Purchases
    WHERE time_stamp BETWEEN startDate AND endDate
    AND amount > minAmount
    ORDER BY user_id
  );
END
```

### 2230. The Users That Are Eligible for Discount
https://leetcode.com/problems/the-users-that-are-eligible-for-discount/

```sql
CREATE PROCEDURE getUserIDs(startDate DATE, endDate DATE, minAmount INT)
BEGIN
	# Write your MySQL query statement below.
	SELECT DISTINCT
        user_id
    FROM Purchases
    WHERE time_stamp > startDate AND time_stamp < endDate
    AND amount > minAmount
    ORDER BY user_id
    ;
END
```