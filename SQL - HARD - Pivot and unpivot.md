- [2252. Dynamic Pivoting of a Table](#2252-dynamic-pivoting-of-a-table)
- [2253. Dynamic Unpivoting of a Table](#2253-dynamic-unpivoting-of-a-table)

### 2252. Dynamic Pivoting of a Table
https://leetcode.com/problems/dynamic-pivoting-of-a-table/description/

```sql
CREATE PROCEDURE PivotProducts()
BEGIN
	# Write your MySQL query statement below.
    SET group_concat_max_len = 1000000; #This is tricky. There's a length limit on GROUP_CONCAT.
    SET @sql = NULL;

    SELECT
        GROUP_CONCAT(DISTINCT CONCAT('SUM(IF(store = "', store, '", price, null)) AS ', store) ORDER BY store ASC) INTO @sql
    FROM 
        Products;

    SET @sql = CONCAT('SELECT product_id, ', @sql, ' FROM Products GROUP BY product_id');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
```

### 2253. Dynamic Unpivoting of a Table
https://leetcode.com/problems/dynamic-unpivoting-of-a-table/solutions/2856713/mysql-dynamically-unpivot-table/

```sql
CREATE PROCEDURE UnpivotProducts()
BEGIN

# 1. Break the problem into individual queries

# SELECT product_id, "LC_Store" AS store, LC_Store AS price
# FROM Products
# WHERE LC_Store IS NOT NULL

# 2. Combine queries dynamically
# 3. An individual query can be constructed if we know the store's name - replace LC_Store with the variable
# 4. We can get the store names (the column names) from the table's meta information - these are the COLUMN_NAMEs from INFORMATION_SCHEMA.COLUMNS; make sure to ignore the "product_id" column
# 5. The individual query can be combined using GROUP_CONCAT and " UNION " as a separator
# 6. Increase the max length allowed for GROUP_CONCAT

    SET SESSION group_concat_max_len = 1000000;
    SET @case_stmt = NULL;

	SELECT GROUP_CONCAT(
            'SELECT product_id, "', COLUMN_NAME, '" AS store, ', COLUMN_NAME, ' AS price FROM Products WHERE ', COLUMN_NAME,' IS NOT NULL' SEPARATOR " UNION "
        )
    INTO @case_stmt
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME="Products" AND COLUMN_NAME != "product_id";

    SET @sql_query = @case_stmt;

    PREPARE final_sql_query FROM @sql_query;
    EXECUTE final_sql_query;
    DEALLOCATE PREPARE final_sql_query;

END
```
