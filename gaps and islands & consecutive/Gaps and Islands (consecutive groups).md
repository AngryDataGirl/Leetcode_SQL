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

