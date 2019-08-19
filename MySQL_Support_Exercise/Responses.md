# Responses

1. "Citycodes" | 45 minutes
	1. The SELECT performs poorly because: 
		
		1. MySQL reads every one of the 32769 rows in the citycodes table in order to find the result. This can be seen in the output of EXPLAIN: type is "ALL", meaning all rows are read; and, rows is "32769". 
			1. MySQL reads every row because it does not use the existing index "idx_code" on the citycodes.code column. 
			1. It does not use the index "idx_code" because of a type mismatch: the query passes an integer (37040) as the value to be found in the citycodes.code column, while the type of the citycodes.code column is VARCHAR. 
	
	1. A possible solution is: Wrap 37040 in single quotes in the query, like `SELECT city FROM citycodes WHERE code = '37040'\G`. That way, 37040 would be passed as a string rather than as an integer, and MySQL would use the "idx_code" index to speed the query.
	
1. "Attendance" | 200 minutes 
	1. Changes that may bring performance improvements are:
		1. Add a composite index to the enrsec table so MySQL does not read all of its 268959744 rows. Put the columns of the composite index in the order in which they are JOINed by the query: `ALTER TABLE enrsec ADD INDEX(enrollment_id, course_no, section_no);`.
		1. Make FIND_IN_SET unnecessary and remove it from the SELECT so MySQL does not read all 262656 rows of the enrollment table:
			1. MySQL does not use an index when matching against a derived value e.g. the result of FIND_IN_SET. The WHERE clause of the given SELECT contains FIND_IN_SET('F', e.enrollment_flags); so, MySQL does not use an index when matching against it; so, make the following changes to make the FIND_IN_SET expression unneccessary and remove it from the SELECT:
				1. Add a table to store enrollment flags, named enrollment_flags. Let it have a column enrollment_id, and an index on that column:
				
					```sql
					CREATE TABLE enrollment_flags
					(
						enrollment_id INT NOT NULL,
						INDEX (enrollment_id)
					) ENGINE=MyISAM;
					```
					
				1. Move the flags from the enrollments table to the enrollment_flags table: 
					1. For each row in the enrollments table: 
						1. For each flag in the comma-separated list in the enrollment_flags column of the current row:
						    1. If there is no column named for the flag, in the enrollment_flags _table_; e.g. for a flag 'F', a column named F, in the enrollment_flags _table_:
								1. Create a column named for the flag, in the enrollments_flags _table_; e.g. for a flag 'F', create a column enrollment_flags.F.	
						1. Create a corresponding row in the enrollment_flags table.	
						1. Set enrollment_flags.enrollment_id of the corresponding row to the value of enrollment.enrollment_id of the current row.
						1. For each flag in the comma-separated list in the enrollment_flags column of the current row:
							1. Set the value of the respective (named for the flag) column in the corresponding row in the enrollment_flags table to TRUE; e.g. for 'F' set enrollment_flags.F to 1 in the corresponding row.
							1. Remove the flag from the comma-separated list.  
							1. If the flag is the last of the comma-separated values:
								1. Set the value of enrollment_flags of the current row to NULL.
				1. When the enrollment_flags column is NULL in every row of the enrollment table, remove the enrollment_flags column from the enrollment table.
				1. Make the following changes to the SELECT:
					1. Replace `e.enrollment_flags` with `ef.enrollment_flags`
					1. Append to the FROM: `INNER JOIN enrollment_flags ef ON e.enrollment_id = ef.enrollment_id`
					1. Delete from the WHERE: `AND FIND_IN_SET('F', e.enrollment_flags) != 0`
					1. Append to the WHERE: `AND ef.F = TRUE`

1. "Population" | 90 minutes 
	1. The query performs poorly in MySQL 5.0 because: [the MySQL 5.0 optimizer incorrectly identifies the subquery as a dependent subquery because the subquery is using "IN"](https://bugs.mysql.com/bug.php?id=32665), so the subquery is run once per row of the containing query. The execution time thus is on the order of O(rows-of-inner*rows-of-outer) rather than O(rows-of-inner+rows-of-outer). 
	1. Some solutions are:
		1. Replace "IN" with "=", and remove CountryCode from the subquery because the left and right sides of "=" must be single values. CountryCode can safely be removed from the subquery: it is redundant there because CountryCode is selected in the containing query. Here is the query with "IN" replaced by "=", and CountryCode removed from the subquery:
		
			```sql
			SELECT
				ID,
				CountryCode,
				Name,
				District,
				Population
			FROM
				City
			WHERE
				Population = (
					SELECT
						MAX(Population)
					FROM City
			);
			```
			
		1. SELECT the desired columns from a JOIN of City (as c) and an alias of City (as m) ON c.Population = MAX(m.Population):

			```sql
			SELECT
				ID,
				CountryCode,
				Name,
				District,
				Population
			FROM 
				City c
			INNER JOIN
				City m ON c.Population = MAX(m.Population);
			```
  			  		
	 	1. Upgrade to MySQL 6+.	

1. "Enrollment" | 75 minutes 
	1. The cause of the failure of the query is: 
		1. There are INNER JOINs expressed by the comma operator (aka "comma joins") mixed with another join type i.e. LEFT JOINs: 
			1. [The precedence of the comma operator is less than of... LEFT JOIN](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/sql-syntax.html); hence, the join expression "student, enrollment, inprog LEFT JOIN clsenr" is interpreted by MySQL 5 as (student, enrollment (inprog JOIN clsenr ON clsenr.enr_id= enrollment.enr_id)). 
			1. The operands of the ON clause thus are only inprog and clsenr, i.e. do not include enrollment; so, the enrollment.enr_id column is unknown to the ON clause.
	1. A solution is: Avoid the use of the comma operator. Use JOIN instead:

		```sql
		SELECT
			student.nfirst,
			student.nlast,
			inprog.syear,
			enrollment.pin,
			section.title,
			section.course
		FROM
			student 
		INNER JOIN enrollment ON
			enrollment.std_id = student.std_id
		INNER JOIN inprog ON
			enrollment.inprog_id = inprog.inprog_id
		LEFT JOIN clsenr ON
			clsenr.enr_id= enrollment.enr_id
		LEFT JOIN section ON
			section.sec_id= clsenr.sec_id
		WHERE
			inprog.syear= 2007
		AND inprog.sch_id= 1473;
		```
  
1. "Global Variables & Status" | 360 minutes 
	1. Suggestions I feel are called for in order to improve performance, stability, et cetera; are: 
		1. Optimize queries.
			1. Suggestions: 
				1. [Optimize](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#statement-optimization) queries. Use [the slow query log](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#slow-query-log) to identify queries to optimize first.
			1. Rationale: 
				1. [Slow_queries](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Slow_queries) is 12761. This is a count of SQL statements that took more than [long_query_time](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_long_query_time) seconds to execute.
				1. [Select_full_join](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Select_full_join) is 1867. This is a count of joins that perform table scans because they do not use indexes. If this value is not 0, you should carefully check the indexes of your tables.
				1. [Handler_read_rnd_next](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Handler_read_rnd_next) is 23675456. This value is high if you are doing a lot of table scans. Generally this suggests that your tables are not properly indexed or that your queries are not written to take advantage of the indexes you have. The ratio of Handler_read_rnd_next to [Questions](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Questions) (the total number of statements sent to the server by clients) is 23675456:23167761 i.e. ~1:1; so, [Handler_read_rnd_next](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Handler_read_rnd_next) can be considered high. 
				1. [Select_scan](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Select_scan) is 25643. This is a count of the number of joins that did a full scan of the first table. 
				1. [Created_temp_tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Created_tmp_tables) is 256798. This is a count of internal temporary tables created by the server while executing statements. 
					1. There is a significant negative impact on performance when temporary tables are created on disk.
					1.  Nearly half of all temporary tables were created on disk: [Created_tmp_disk_tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Created_tmp_disk_tables) is 123349. This has a significant negative impact on performance. 
					1. Creation of temporary tables can be avoided by optimizing queries. For more information:
						1. [7.8.4. How MySQL Uses Internal Temporary Tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#internal-temporary-tables) describes the conditions under which temporary tables are created
						1. [7.3.1.12. GROUP BY Optimization](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#group-by-optimization) describes how MySQL is able to avoid creation of temporary tables by using index access when queries are optimized.
		1. Increase key_buffer_size.
			1. Suggestion:	Assign a larger value to [key_buffer_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_key_buffer_size) to get better index handling for all reads and multiple writes.
			1. Rationale:	
				1. Key_reads/Key_reads_requests (the cache miss rate) is 1327838/6786353 = 0.20, while "[[it] should normally be less than 0.01](https://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html)".
			1. How to determine the optimal value for key_buffer_size: 
				1. Start with total RAM available.
				1. Subtract a suitable amount for the OS needs.
				1. Subtract a suitable amount for all MySQL needs such as buffers e.g. key_buffer_size and replication-related buffers, temporary tables, and connection pools.
				1. Subtract an amount according to the needs of other processes running on the system.
				1. Divide the result by 105%, which is an approximation of the overhead required to manage the key buffer itself.
	 	1. Increase innodb_buffer_pool_size.
			1. Suggestion: Assign a larger value to [innodb_buffer_pool_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/storage-engines.html#sysvar_innodb_buffer_pool_size) so less disk I/O is needed to access data in tables.
			1. Rationale: 
				1. [Innodb_buffer_pool_reads](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Innodb_buffer_pool_reads) is 630232. This is the number of logical reads that InnoDB could not satisfy from the buffer pool, and had to read directly from the disk. If the buffer pool size has been set properly, this value should be small. 
				1. [Innodb_buffer_pool_wait_free](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Innodb_buffer_pool_wait_free) is 2342. If the buffer pool size has been set properly, this value should be small. 
				1. How to determine the _optimal_ value for innodb_buffer_pool_size:
					1. Determine the actual size of the InnoDB tables by running the query in the code block below.
				
						```
						SELECT engine,
							count(*) as TABLES,
							concat(round(sum(table_rows)/1000000,2),'M') rows,
							concat(round(sum(data_length)/(1024*1024*1024),2),'G') DATA,
							concat(round(sum(index_length)/(1024*1024*1024),2),'G') idx,
							concat(round(sum(data_length+index_length)/(1024*1024*1024), 2),'G') total_size,
							round(sum(index_length)/sum(data_length),2) idxfrac
						FROM information_schema.TABLES
						WHERE table_schema not in ('mysql', 'performance_schema', 'information_schema')
						GROUP BY engine
						ORDER BY sum(data_length+index_length) DESC LIMIT 10;
						```

					1. Add 20%. 
				1. How to determine the _actual_ value to assign to innodb_buffer_pool_size:
					1. Start with total RAM available.
					1. Subtract a suitable amount for the OS needs.
					1. Subtract a suitable amount for all MySQL needs such as buffers e.g. key_buffer_size and replication-related buffers, temporary tables, and connection pools.
					1. Subtract an amount according to the needs of other processes running on the system.
					1. Divide the result by 105%, which is an approximation of the overhead required to manage the buffer pool itself.

		1. Use SSL. 
			1. Suggestion: [Use SSL](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#secure-basics) for Secure Connections for clients outside the trusted network. 
			1. Rationale: 
				1. Unencrypted data sent over the network is accessible to everyone who has the time and ability to intercept it.
			1. Side effects: 
				1. Increased CPU usage. Encrypting data is a CPU-intensive operation that requires the computer to do additional work and can delay other MySQL tasks. 
		1. Turn off the query cache.
			1. Suggestion: Turn off [the query cache](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#query-cache) by setting both [query_cache_type](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_query_cache_type) and [query_cache_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_query_cache_size) to 0.
			1. Rationale: 
				1. The query cache hit rate is very low: 0.0004% ((Qcache_hits / (Qcache_hits + Qcache_inserts + Qcache_not_cached)) * 100).
				1. There is overhead for having the query cache active.	
		1. Increase the value of sort_buffer_size.
			1. Suggestion: Assign a higher value to [sort_buffer_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_sort_buffer_size). 
			1. Rationale: 
				1. Sort_merge_passes is 38291. If this is high, data is read from disk when sorting rows.
				1. sort_buffer_size is 65536, which is only ~3% of the default value 2097144.

1. "User Data (identifier), or Cities or People or Vehicles" | 225 minutes 
	1. The errors are:
		1. No DELIMITER 
			1. No DELIMITER is declared to delimit statements that affect the procedure at the scope at which the procudure is created, e.g. to delimit the final END statement of the creation of the procedure. Such a delimiter is necessary in order that MySQL can distinguish statements that are at the level/scope of the exterior of the procedure from those that are within the procedure, which are delimited by the semicolon. 
			2. There is no such delimiter delimiting the terminus of the final END statement of the declaration of the procedure.
		2. The first parameter of the procedure, user_group, has the same name as a field/column to which it is compared in the WHERE clause of the SELECT of the CURSOR declaration. As a result, the query completes successfully but the comparison isn't made; so, the SELECT returns multiple rows when only one row would otherwise be returned. A solution is to change the name of the parameter.
		3. The declaration of mdata is unnecessary and overwrites the value of the parameter mdata with NULL. It can be omitted.
		4. The SELECT of the declaration of the CURSOR is missing the FROM clause i.e. has no "...FROM musers...".
		5. The CONTINUE HANDLER sets the variable named "done" to 0 (FALSE) rather than 1 (TRUE). This results in an infinite loop.
		5. The presence of a BEGIN/END wrapping the IF statement that follows the declaration of the CONTINUE HANDLER results in a fatal error. It is unnecessary.
		6. The variable "psql" is set like "SET psql=...", without "@" prefixing, when it is SET with a value that is a statement to be executed. The "@" is required syntax, like: "SET @psql=...".
		7. The SELECT in the statement on the right side of the declaration of psql for the case that mdata is equal to the empty string does not "retrieve muser_data from musers for all users that belong to the specified muser_group", but rather returns the results for the mu_ table with the suffix matching the value of the mdata parameter of the procedure.
		8. The END IF that closes the "IF NOT done..." and the one that closes the "IF mdata <>...'' statement are both missing the semicolon as delimiter at the end of the line.
		9. The "CLOSE cr;" statement is outside the ELSE of the "IF mdata <>..." statement, and belongs inside it.
		
	1. The corrected procedure is:
		
		```sql
		
		-- mu_fetch( in_muser_group INT, mdata VARCHAR(30) )
		-- If mdata is provided, return results for the mu_ table with that suffix
		-- Otherwise, retrieve muser_data from musers for all users that
		-- belong to the specified muser_group.
		
		DELIMITER $$
		DROP PROCEDURE IF EXISTS mu_fetch$$
		CREATE PROCEDURE mu_fetch( in_muser_group INT, mdata VARCHAR(30) )
		BEGIN
			DECLARE done INT DEFAULT 0;
			DECLARE psql VARCHAR(200);
			DECLARE cr CURSOR FOR 
				SELECT muser_data FROM musers 
					WHERE muser_group = in_muser_group;
			DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
			IF mdata <> '' THEN
				SET @psql= CONCAT('SELECT * FROM mu_', mdata);
				PREPARE stmt FROM @psql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
			ELSE
				OPEN cr;
				REPEAT
					FETCH cr INTO mdata;
					IF NOT done THEN
					SET @psql= CONCAT('SELECT muser_data FROM musers WHERE muser_group = ', mdata);
						PREPARE stmt FROM @psql;
						EXECUTE stmt;
					DEALLOCATE PREPARE stmt;
					END IF;
				UNTIL done
				END REPEAT;
				CLOSE cr;
			END IF;
		END$$
		```
1. "Users at Host with C Lang" | 280 minutes
	1. The problems with the C program, and the respective solutions, are:
		1. The MySQL API header is not included; so, the API is not available.
			1. Problem: mysql.h is not among the headers included.
			1. Solution: Append 
			
				```c
				#include <mysql.h>
				```

				to

				```c
				#include <stdio.h>
				#include <stdlib.h>
				#include <string.h>
				```

				like

				```c
				#include <stdio.h>
				#include <stdlib.h>
				#include <string.h>
				#include <mysql.h>
				```

		1. The MySQL API is not initialized.
			1. Problem: mysql_real_connect() is called with m as a parameter before the pointer m has been initialized to a database connection handler by the mysql_init() function.
			1. Solution: Initialize m, by preceding 
			
				```c
				mysql_real_connect(m,"localhost","root","","test",0,NULL,0);
				``` 
				
				with	

				```c
				m = mysql_init(m);
				```

				like

				```c
				m = mysql_init(m);
				mysql_real_connect(m,"localhost","root","","test",0,NULL,0);
				```

		1. The "password" parameter is empty.	
	    	1. Problem: The "password" parameter is set to the empty string, in the call of mysql_real_connect(); so, the connection attempt fails.
			1. Solution: Insert the password for the MySQL root user into the double quotes in the password parameter in the call of mysql_real_connect(), thereby changing 

				```c
				mysql_real_connect(m,"localhost","root","","test",0,NULL,0);
				```

				to like

				```c
				mysql_real_connect(m,"localhost","root","password-of-mysql-root-user","test",0,NULL,0);
				```

		1. The "database" parameter is set to a database that does not exist.
			1. Problem: The "database" parameter is set to "test", a database that does not exist, in the call of mysql_real_connect(); so, the connection attempt fails.
			1. Solution: Replace "test" with NULL in the call of mysql_real_connect(), thereby changing 

				```c
				mysql_real_connect(m,"localhost","root","password-of-mysql-root-user","test",0,NULL,0);
				```

				to like

				```c
				mysql_real_connect(m,"localhost","root","password-of-mysql-root-user",NULL,0,NULL,0);
				```

	 	1. The while loop doesn't fetch the rows that result from the regular execution of sql1
			1. Problem: The call of mysql_fetch_row() in the condition of the while loop that would print the values from the results of the regular execution of the query in sql1 is missing the "MYSQL_RES *result" parameter.
			1. Solution: Insert the parameter by replacing 

				```c
				while (w= mysql_fetch_row)
				```

				with

				```c
				while ((w = mysql_fetch_row(r)))
				```

		1. The statement "s" is not initialized before it is prepared.
			1. Problem: mysql_stmt_prepare() is called with s as a parameter before the pointer s has been initialized to a prepared statement handler by the mysql_stmt_init() function.
			1. Solution: Initialize s, by preceding 
			
				```c
				mysql_stmt_prepare(s, sql2, strlen(sql2));	
				``` 
				
				with	

				```cc
				s = mysql_stmt_init(m);
				```

				like

				```c
				s = mysql_stmt_init(m);
				mysql_stmt_prepare(s, sql2, strlen(sql2));	
				```
				
		1. The buffer of the parameter is set to a char rather than a pointer. 
			1. Problem: The buffer of the parameter bound to the prepared statement s, par[0].buffer, is set to the char value of sd[0] rather than to a reference to the location ("address") of sd[0] in memory (aka a pointer); so, when '%localhost%' is later copied into the address of sd[0], the value of par[0].buffer does not change accordingly i.e. does not become '%localhost%.
			1. Solution: Replace

				```c
				par[0].buffer= sd[0]
				```

				with

				```c
				par[0].buffer= &sd[0] //pointer to sd[0]
				```

		1. The buffer of the first result is set to a char rather than a pointer.
			1. Problem: res[0].buffer is set to the char value of sd[1] rather than a pointer to sd[1]; so, when a result is later copied into the address of sd[1], the value of res[0].buffer does not change accordingly i.e. does not get the result.
			1. Solution: Replace

				```c
				res[0].buffer= sd[1]
				```

				with

				```c
				res[0].buffer= &sd[1] //pointer to sd[1]
				```

		1. The buffer of the second result is set to a char rather than a pointer.	
			1. Problem: res[1].buffer is set to the char value of sd[2] rather than a pointer to sd[2]; so, when a result is later copied into the address of sd[2], the value of res[1].buffer does not change accordingly i.e. does not get the result.
			1. Solution: Replace

				```c
				res[1].buffer= sd[2]
				```

				with

				```c
				res[1].buffer= &sd[2] //pointer to sd[2]
				```

	 	1. The while loop doesn't fetch the results of the execution of the prepared statement for sql2
			1. Problem: The condition of the while loop that would print the values from the results of the execution of the prepared statement for sql2 does not fetch values from the results bound to the statement.
			1. Solution: Replace

				```c
				while(w= mysql_fetch_row(r))
				```

				with

				```c
				while (!mysql_stmt_fetch(s))
				```

1. "Reservations" | 90 minutes
	1. Problems and possible solutions are:
		1. Problem: getInteger() is called on the instance of ResultSet, rs, while there is no getInteger() method in [the ResultSet interface](https://docs.oracle.com/javase/7/docs/api/java/sql/ResultSet.html).
		1. Solution: Replace each instance of

			```
			rs.getInteger
			```

			with

			```
			rs.getInt
			```

			which _is_ a method in [the ResultSet interface](https://docs.oracle.com/javase/7/docs/api/java/sql/ResultSet.html).
1. "Absences" | 150 minutes
	1. Probable cause: [The MYSQL_RES structure allocated for the client by mysql_store_result()](https://dev.mysql.com/doc/refman/5.7/en/mysql-store-result.html) grew until it consumed the available memory.
	1. Possible solutions: 
		1. Select only columns needed, rather than "SELECT *", if not all columns are needed. 
			1. Fewer columns selected would result in a smaller result set that might not exceed limits.	
		1. Make multiple queries. 
			1. Let each query [select a limited number of rows beginning at an offset](https://dev.mysql.com/doc/refman/5.7/en/select.html).
			1. Let each query, after the first, increase the offset by the value of the limit.
			1. Call [mysql_free_result()](https://dev.mysql.com/doc/refman/5.7/en/mysql-free-result.html) after each query. 
			1. Adjust the limit and offset to keep the size of the MYSQL_RES structure below the threshold of available memory.
		1. There is a third possible solution _if the output isn't sent to a screen on which the user may type a ^S (stop scroll) e.g. a Linux terminal_: call [mysql_use_result()](https://dev.mysql.com/doc/refman/5.7/en/mysql-use-result.html) rather than mysql_store_result(). _This is not an option if the output is sent to a screen on which the user may type a ^S (stop scroll) e.g. a Linux terminal, because [^S would tie up the server and prevent other threads from updating any tables from which the data were being fetched](https://dev.mysql.com/doc/refman/5.7/en/mysql-use-result.html)_. 