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
		1. Make FIND_IN_SET unnecessary and remove it from the SELECT so MySQL does not read all 262656 rows of the enrollment table.
			1. MySQL does not use an index when matching against a derived value e.g. the value of FIND_IN_SET('F', e.enrollment_flags) != 0); so, make FIND_IN_SET unneccessary to the query, and remove it from the SELECT.
				1. Add a table named enrollment_flags to store (you guessed it!) enrollment flags. Let it have a column enrollment_id, and an index on that column.
				
					```sql
					CREATE TABLE enrollment_flags
					(
						enrollment_id INT NOT NULL,
						INDEX (enrollment_id)
					) ENGINE=MyISAM;
					```
					
				1. Move the flags from the enrollments table to the enrollment_flags table.
					1. For each row in the enrollments table:
						1. Create a row in the enrollment_flags table.	
						1. Set enrollment_flags.enrollment_id to the value of enrollment.enrollment_id.
						1. For each flag in the comma-separated list in enrollment.enrollment_flags, e.g. for a flag 'F':
						    1. If in the enrollment_flags table there is no column named for the flag e.g. if there is no column enrollment_flags.F.
								1. Create in the enrollments_flags table a column named for the flag e.g. create a column enrollment_flags.F.	
							1. Set the value of the column named for the flag to 1 (aka TRUE) e.g. set enrollment_flags.F to 1.
							1. Remove the flag from the comma-separated list in enrollment.enrollment_flags e.g. remove 'F' from the list.
							1. If the flag is the last of the comma-separated values in enrollment.enrollment_flags e.g. if 'F' is the last flag in the list:
								1. Set the value of enrollment_flags to NULL.
				1. When the enrollment.enrollment_flags column is NULL in every row, remove the enrollment_flags column from the enrollment table.
				1. Make the following changes to the SELECT.
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
  
1. "Global Variables & Status" | 390 minutes 
	1. Suggestions I feel are called for in order to improve performance, stability, et cetera; are: 
		1. [Optimize](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#statement-optimization) queries. Use [the slow query log](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#slow-query-log) to identify queries to optimize first.
			1. Rationale: 
				1. [Slow_queries](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Slow_queries) is 12761. This is a count of SQL statements that took more than [long_query_time](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_long_query_time) seconds to execute.
				1. [Select_full_join](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Select_full_join) is 1867. This is a count of joins that perform table scans because they do not use indexes. If this value is not 0, carefully check the indexes of your tables.
				1. [Handler_read_rnd_next](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Handler_read_rnd_next) is 23675456. This value is high if you are doing a lot of table scans. Generally this suggests that your tables are not properly indexed or that your queries are not written to take advantage of the indexes you have. The ratio of Handler_read_rnd_next to [Questions](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Questions) (the total number of statements sent to the server by clients) is 23675456:23167761 i.e. ~1:1; so, I think [Handler_read_rnd_next](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Handler_read_rnd_next) can be considered high. 
				1. [Created_temp_tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Created_tmp_tables) is 256798. This is a count of internal temporary tables created by the server while executing statements. 
					1.  Nearly half of all temporary tables were created on disk (a performance cost): [Created_tmp_disk_tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Created_tmp_disk_tables) is 123349 while [Created_temp_tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#statvar_Created_tmp_tables) is 256798. 
					1. Creation of temporary tables can be avoided by optimizing queries:
						1. [7.8.4. How MySQL Uses Internal Temporary Tables](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#internal-temporary-tables) describes the conditions under which temporary tables are created
						1. [7.3.1.12. GROUP BY Optimization](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#group-by-optimization) describes how MySQL is able to avoid creation of temporary tables by using index access when queries are optimized.
		1. Increase [key_buffer_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_key_buffer_size) to get better index handling for all reads and multiple writes.
			1. Rationale: Key_reads/Key_read_requests (the cache miss rate) is 1327838/6786353 = 0.20, while "[[it] should normally be less than 0.01](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html)".
			1. Execution: 
			    1. [Observe free memory](https://www.linuxjournal.com/article/8178) for the whole of the system.
				1. Increase key_buffer_size by an amount corresponding to some fraction of the observed free memory.	
				1. If the increased key_buffer_size leads to [memory swapping out and reduced performance aka "thrashing"](https://www.linuxjournal.com/article/8178), then reduce the value of key_buffer_size until performance is within tolerance. 
				1. Else, continue to incrementally increase the value of key_buffer_size until thrashing is observed, and then back it off until performance returns to within tolerance. 
		1. Turn off [the query cache](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/optimization.html#query-cache) .
			1. Rationale: Only 0.0004 percent of queries access the cache: the "queue cache hit rate" i.e. Qcache_hits / (Qcache_hits + Qcache_inserts + Qcache_not_cached)*100 is 0.0004. The cost of the overhead of running the query cache likely exceeds the benefit while the hit rate is that low.
			1. Execution: 
				1. Set [query_cache_type](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_query_cache_type) to 0. 
				1. Set [query_cache_size](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/server-administration.html#sysvar_query_cache_size) to 0.
1. "User Data (identifier), or Cities or People or Vehicles" | 225 minutes 
	1. The errors are:
		1. No DELIMITER 
			1. No DELIMITER is declared to delimit statements that affect the procedure at the scope at which the procudure is created. Such a delimiter is necessary in order that MySQL can distinguish statements that are at the level/scope of the exterior of the procedure from those that are within the procedure, which are delimited by the semicolon. 
			2. Correspondingly, there is no such delimiter delimiting the END statement that closes the CREATE PROCEDURE.
		2. The first parameter of the procedure, muser_group, has the same name as a field/column to which it is compared in the WHERE clause of the SELECT of the CURSOR declaration. As a result, the query completes successfully but the comparison isn't made; so, the SELECT returns multiple rows when only one row would otherwise be returned. A solution is to change the name of the parameter.
		3. The declaration of mdata is unnecessary and overwrites the value of the parameter mdata with NULL. The declaration can be omitted.
		4. The SELECT of the declaration of the CURSOR is missing the FROM clause i.e. has no "...FROM musers...".
		5. The CONTINUE HANDLER sets the variable named "done" to 0 (FALSE) rather than 1 (TRUE). This results in an infinite loop.
		6. psql is not a [User-Defined Variable](https://dev.mysql.com/doc/refman/5.7/en/user-variables.html) while it is the object of the FROM clause of a PREPARE statement. MySQL considers this a syntactical error.
		7. The SELECT in the statement on the right side of the declaration of psql for the case that mdata is equal to the empty string does not "retrieve muser_data from musers for all users that belong to the specified muser_group", but rather returns the results for the mu_ table with the suffix matching the value of the mdata parameter of the procedure.
		8. The END IF that closes the "IF mdata <>...", the END IF that closes the "IF NOT done...", and the END of the BEGIN that immediately follows the variable declarations are all missing the semicolon as delimiter at the end of the line.
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

			```java
			rs.getInteger
			```

			with

			```java
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
1. "Connector/j CREATE PROCEDURE" | 90 minutes
	1. The cause is: java.sql.Statement.execute() considers 'DELIMITER //', 'DELIMITER', and '//' to be invalid SQL syntax.
	1. An available solution is: DELIMITER is unnecessary to the Connector/J client; so, remove DELIMITER and associated substrings from the query.
		1. Remove the following substrings from the query:

			```java
			DELIMITER //\n
			```

			and

			```java
			\n//\nDELIMITER
			```

			leaving

			```java
			"CREATE PROCEDURE abdt (std INT)\nBEGIN\nSELECT att_begin, att_end FROM abdt WHERE student_id = std;\n\nEND; ;"
			```

		1. There is no need for any delimiter following the final END in the statement; so, remove the two semicolons, leaving:

			```java
			"CREATE PROCEDURE abdt (std INT)\nBEGIN\nSELECT att_begin, att_end FROM abdt WHERE student_id = std;\n\nEND"
			```

1. "Sort aborted" | 120 minutes
	1. Possible causes are:
		1. The temporary file for use by [filesort](https://dev.mysql.com/doc/refman/5.7/en/order-by-optimization.html#order-by-filesort) could not be opened due to a lack of disk space on the filesystem containing the directory to which [tmpdir](https://dev.mysql.com/doc/refman/5.7/en/temporary-files.html) points.
			1. The dearth of disk space could be due to scanning of, or the return of a very large data set from,  a very large table or join of tables. Use of [the slow query log](https://dev.mysql.com/doc/refman/5.7/en/slow-query-log.html) and [EXPLAIN to optimize queries and indexes](https://dev.mysql.com/doc/refman/5.7/en/using-explain.html) could help resolve the issue in that case.  
		1. A service managing multiple connections to mysqld e.g. a webserver, stopped, dropping the connections, while sorts were in progress.
		1. Users (persons or bots) [killed queries](https://dev.mysql.com/doc/refman/5.7/en/kill.html ) while sorts were in progress.
		1. Transactions were rolled back due to [deadlock detection](https://dev.mysql.com/doc/refman/5.7/en/innodb-deadlock-detection.html) or [lock wait timeout](https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_lock_wait_timeout), while sorts were in progress.
		1. An error occurred e.g. table corruption.
	1. How to discover possible causes: 
		1. Versions of MySQL newer than 5.5.10: Set [log_warnings](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_log_warnings) to 2. 
			1. Messages showing the client host, user, thread, and query will be written to the error log.
		1. All versions: Enable the general query log, and then match timestamps therein with timestamps in the error log.
1. "Can't create a new thread" | 240 minutes
	1. Possible causes:
		1. The operating system ("system") user that mysqld is running as (often "mysql") has reached the limit of processes or file descriptors afforded to the user by the system.
			1. The value of [max_connections](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_max_connections) may be greater than the limit of processes afforded to the user that mysqld runs as (a user-level limit). 
			1. The value of [open_files_limit](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_open_files_limit) may be greater than the limit of file descriptors afforded to the user that mysqld runs as (a user-level limit).
			1. The value of [max_connections](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_max_connections) or [open_files_limit](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_open_files_limit) may be greater than the respective system-level limit.
			1. The way to view and set limits varies across operating systems. On Oracle Linux:
				1. Limits for a user, for example a user named "mysql", can be seen by running [su mysql](https://www.unix.com/man-page/centos/7/su) (may require [sudo](https://www.unix.com/man-page/centos/7/sudo)), followed by [ulimit](https://www.unix.com/man-page/centos/7/ulimit); like: 
				
					```
					sudo su mysql
					ulimit -u #show number of processes, aka noproc, afforded the user
					ulimit -n #show number of file descriptors, aka nofile, afforded the user
					```
					
				1. Per-user limits e.g. [noproc (maximum number of processes) and nofile (maximum number of open files)](http://linux-pam.org/Linux-PAM-html/sag-pam_limits.html) are set in [/etc/security/limits.conf and /etc/security/limits.d/*.conf](https://www.unix.com/man-page/centos/7/limits.conf/), and enforced by [PAM](https://www.unix.com/man-page/centos/5/pam/).
				1. Corresponding system-level limits can be seen by running [sysctl](https://www.unix.com/man-page/centos/7/sysctl/), and are set in [/etc/sysctl.conf](https://www.unix.com/man-page/centos/5/sysctl.conf/).		
				1. Changes to /etc/security/limits.conf, /etc/security/limits.d/*.conf, and /etc/sysctl.conf require a reboot to take effect. Log out and back in before rebooting so the shell will have the new limits when the reboot operation is initiated.
				1. __Important!__: Services that are started by Systemd do not use PAM for login, so the limits in /etc/security/limits.conf and /etc/security/limits.d/\*.conf are ignored in that case! 
					1. Hence, to modify a user-level limit for mysql running as a Systemd service, define the limit in the Systemd service definition file for mysqld, /usr/lib/systemd/system/mysqld.service, _in addition to setting it in /etc/security/limits.d/*.conf_.	
						1. Add line(s) for the limit(s) to the [Service] section, e.g.

						
							```
							...
							[Service]
							...
							LimitNOFILE=55000
							LimitNPROC=55000
							```

					1. Reload the Systemd configuration by running `systemctl daemon-reload` (may require sudo).

		1. mysqld consumed all available system memory i.e., roughly, the size in memory of "buffers shared by all threads + per-thread buffers * max_connections" exceeded the free memory of the system.
1. "Different Errors on Master and Slave" | 180 minutes
	1. Identify
		1. What happened on the master: The query was killed. The statement was put into the binlog, along with error 1317.
		1. Why the NY slave reported an error: [If a statement produces different errors on the master and the slave, the slave SQL thread terminates. This includes the case that a statement produces an error on the master or the slave, but not both](https://dev.mysql.com/doc/refman/5.7/en/replication-features-slaveerrors.html). The statement generated 1317 on the master but not on the NY slave; so, the NY slave stopped with an error.
		1. Why the TX slave succeeded: [replicate_do_db](https://dev.mysql.com/doc/refman/5.7/en/replication-options-slave.html#option_mysqld_replicate-do-db) was set to 'asms' on the TX slave, while the default database was 'test' when the query executed there; so, the slave did not replicate the statement.
		1. How to recover: On the NY slave, run 
		
			```sql
			-- Skip the error
			SET GLOBAL SLAVE_SKIP_COUNTER=1; /* https://dev.mysql.com/doc/refman/5.7/en/start-slave.html */
			-- Continue replication
			START SLAVE; /* https://dev.mysql.com/doc/refman/5.7/en/start-slave.html */
			```

1. "Binlog" | 360 minutes
	1. Replication is not working because:
		1. The slave IO thread is not running. It exited due to a fatal error while reading the contents of the binlog file hfisk-desktop-bin.000009 in an update sent by the Binlog Dump thread of the master. A run of [mysqlbinlog](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/programs.html#mysqlbinlog) i.e. `mysqlbinlog hfisk-desktop-bin.000009`, sent "ERROR: Could not read entry at offset 466: Error in log format or read error" to stderr, which indicates corruption of hfisk-desktop-bin.000009. Due to the corruption of the binlog, there may be statements committed on the master but not on the slave. Corruption of the binlog is likely due to OS or hardware issues on the master, or packet corruption i.e a network issue. 
	1. To resume operation: Re-create the slave server from a master server backup.	
		1. On the master:
			1. Take backups of your databases and logs.
			1. [Obtain the Replication Master Binary Log Coordinates](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/replication.html#replication-howto-masterstatus).
				1. Flush all tables and block write statements by executing the FLUSH TABLES WITH READ LOCK statement.

					```sql
					mysql> FLUSH TABLES WITH READ LOCK;
					```

				1. _In a different mysql client session_ (e.g. open another terminal window or tab and run `mysql` there), use the SHOW MASTER STATUS statement to determine the current binary log file name and position.

					```sql
					mysql> SHOW MASTER STATUS;
					```
				
					The File column shows the name of the log file and Position shows the position within the file. Record these values. You'll need them later when you are setting up the slave. They represent the replication coordinates at which the slave should begin processing new updates from the master.

					If the master has been running previously without binary logging enabled, the log file name and position values displayed by SHOW MASTER STATUS will be empty. In that case, the values that you need to use later when specifying the slave's log file and position are the empty string ('') and 4.

					You now have the information you need to enable the slave to start reading from the binary log in the correct place to start replication.
			1. [Create a data snapshot using mysqldump](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/replication.html#replication-howto-mysqldump), and copy the dumpfile to the slave.
				1. In _yet another session_ (e.g. open another terminal window to get a new shell), use mysqldump to create a dump either of all the databases you want to replicate, or of selected individual databases, and compress it into an archive, e.g.

					```sh
					shell> mysqldump --all-databases --lock-all-tables | gzip - > dbdump.sql.gz
					```
				
				1. In the session/client where you acquired the read lock (above), release the lock.

					```sql
					mysql> UNLOCK TABLES;
					```
			
			1. Copy the archive to the slave e.g. use rsync.

				
				```sh
				shell> rsync -azvP dbdump.sql.gz [username]@[hostname]:[path]

				```

		1. IMPORTANT: Ensure no clients will access the slave while it is being recreated.	
		1. On the slave
			1. Take backups of your logs.
			1. Stop the slave.

				```sql
				mysql> STOP SLAVE;
				```

			1. Delete the databases. 
				1. Show the databases.

					```sh
					shell> mysql -e "SHOW DATABASES" | grep -v Database | grep -v mysql| grep -v information_schema
					```

				1. Drop the databases.
				
					```sql 
					mysql> DROP DATABASE a_replicated_database;
					mysql> DROP DATABASE another_replicated_database;
					mysql> /* drop the remaining databases, like as above */
					```
			
			1. Import the dump file; e.g. use zcat to unpack the archive, and pipe the resultant SQL to a mysql client.

				```sh
				shell> zcat dbdump.sql.gz | mysql
				```
			
			1. Delete the dump file if the import succeeded.

				```sh
				shell> rm dbdump.sql.gz
				```
			
			1. [Configure the slave with the replication coordinates from the master](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/replication.html#replication-howto-slaveinit), using the coordinates obtained and recorded earlier.

				```sql
				mysql> CHANGE MASTER TO
					->     MASTER_LOG_FILE='recorded_log_file_name',
					->     MASTER_LOG_POS=recorded_log_position;
				```

			1. Start the slave threads.

				```sql
				mysql> START SLAVE;
				```

1. "Relay log" | 180 minutes
	1. Replication is not working because: The slave SQL thread is not running. It aborted when it was unable to parse a relay log entry in ubuntu3-relay-bin.000003. A run of [mysqlbinlog](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/programs.html#mysqlbinlog) i.e. `mysqlbinlog ubuntu3-relay-bin.000003`, sent "ERROR: Could not read entry at offset 466: Error in log format or read error" to stderr, which indicates corruption of ubuntu3-relay-bin.000003.
	1. To resume operation:
	 	1. Consider that the current [Relay_Master_Log_File](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/sql-syntax.html#show-slave-status), hfisk-desktop-bin.000007, is intact. This is indicated by the absense of errors upon a run of `mysqlbinlog hfisk-desktop-bin.000007`. Good! Because the current Relay_Master_Log_File is intact, we can with confidence stop the slave, set the binlog coordinates to Relay_Master_Log_File:Exec_Master_Log_Pos, and start the slave anew. This will purge existing relay logs and re-fetch all events which have not yet been executed.
		1. Note the value of Relay_Master_Log_File and Exec_Master_Log_Pos in the output of `SHOW SLAVE STATUS` in slave_tee.txt.		
			1. Relay_Master_Log_File is hfisk-desktop-bin.000007.
			1. Exec_Master_Log_Pos is 583.
		1. On the slave:	
			1. Stop the slave.

				```
				mysql> STOP SLAVE;
				```

			1. Change MASTER_LOG_FILE to hfisk-desktop-bin.000007 and MASTER_LOG_POS to 583.

				```
				mysql> CHANGE MASTER TO MASTER_LOG_FILE='hfisk-desktop-bin.000007', MASTER_LOG_POS=583;
				```
			
			1. Start the slave.

				```
				mysql> START SLAVE;
				```
			
			1. Run [SHOW SLAVE STATUS](https://docs.oracle.com/cd/E19078-01/mysql/mysql-refman-5.0/sql-syntax.html#show-slave-status) a few times to observe whether Exec_Master_Log_Pos is increasing and Seconds_Behind_Master decreasing. If so, then, bravo, Bob's your uncle!
1. "thcr" | 180 minutes
	1. On what line of which function did the program crash? The program crashed on the first line of the function pf2() (line 21 of thcr.c).

		```sh
		shell> gdb thcr core
		...
		Program terminated with signal 8, Arithmetic exception.
		#0  0x08048617 in pf2 () at thcr.c:21
		...
		```
 	
	1. What are the values for tc, cr and pf in the thread which crashed?
	 	1. tc: 0
		1. cr: 1
		1. pf: 1

			```sh
			(gdb) info threads
			  Id   Target Id         Frame
			  11   LWP 20523         0xffffe410 in __kernel_vsyscall ()
			  10   LWP 20525         0x40067800 in ?? ()
			  9    LWP 20526         0x400aa09f in ?? ()
			  8    LWP 20527         0x08048617 in pf2 () at thcr.c:21
			  7    LWP 20528         0x40132b30 in ?? ()
			  6    LWP 20529         0x40067800 in ?? ()
			  5    LWP 20530         0x08048617 in pf2 () at thcr.c:21
			  4    LWP 20531         0x40132b30 in ?? ()
			  3    LWP 20532         0x40132b30 in ?? ()
			  2    LWP 20533         0x40067800 in ?? ()
			* 1    LWP 20524         0x08048617 in pf2 () at thcr.c:21
			(gdb) up
			#1  0x080486a4 in handler (arg=0xbfffdfb0) at thcr.c:53
			53	      pf2();
			(gdb) print ta.tc
			$1 = 0
			(gdb) print ta.cr
			$2 = 1
			(gdb) print ta.pf
			$3 = 1
			```

 	1. Which threads would have executed one of the pf() functions, and which function would each of these threads have executed? 
	 	1. The threads that would have executed a pf() function are those threads for which 1 were the value of the cr member of the targ struct passed to the handler() function upon the creation of the respective thread. The value of cr would be the remainder of the division by 2 of a randomly generated integer i.e. random()%2.
			1. Each of these threads would have executed the pf() function indicated by the case of the switch statement of the handler() function, the case for the value of the pf member of the targ struct passed to the handler() function upon the creation of the respective thread. The value of pf would be the remainder of the division by 3 of a randomly generated integer i.e. random()%3.
1. "City is crashed" | 240 minutes
	1. The problem is: The table City is corrupted. City is likely using the MyISAM engine, because: for tables using the InnoDB engine, [in most situations... the recovery process happens automatically](https://docs.oracle.com/cd/E17952_01/mysql-5.0-en/innodb-recovery.html). And, also: [if CHECK TABLE finds a problem for an InnoDB table, the server shuts down to prevent error propagation. Details of the error will be written to the error log](https://docs.oracle.com/cd/E17952_01/mysql-5.0-en/check-table.html); so, if the error log contains no messages indicating that mysqld shut down upon the run of `check table`, then MyISAM is indicated.
		1. First, discover which engine is used by City (most likely MyISAM).

			```sql
			mysql> SELECT TABLE_NAME, ENGINE
				-> FROM information_schema.TABLES
				-> WHERE TABLE_SCHEMA LIKE 'world' AND TABLE_NAME = 'City' AND ENGINE IS NOT NULL;
			```
	
		1. Then, possible solutions are:
			1. For the most likely case that City uses MyISAM:
				1. Locate the "datadir" i.e. the location of database files, e.g..

					```sql
					mysql> SELECT @@datadir;
					+-----------------+
					| @@datadir       |
					+-----------------+
					| /var/lib/mysql/ |
					+-----------------+
					```

				1. Ensure the database directory and table files are readable and writable by you and by the user mysqld runs as (often username "mysql").
				1. Stage One: Try an easy safe repair.	
					1. Stop mysqld e.g.

						```
						shell> sudo systemctl stop mysqld
						```

					1. Make a backup of the data file, City.MYD, e.g.

						```sh
						shell> cp /var/lib/mysql/World/City.MYD ~/
						```

					1. Use "[myisamchk](https://docs.oracle.com/cd/E17952_01/mysql-5.0-en/myisamchk.html) -r tbl_name" (-r means “recovery mode”). This removes incorrect rows and deleted rows from the data file and reconstructs the index file. For example:

						```sh
						shell> sudo myisamchk -r /var/lib/mysql/World/City
						```

					1. If the preceding step fails, use "myisamchk --safe-recover tbl_name". Safe recovery mode uses an old recovery method that handles a few cases that regular recovery mode does not (but is slower). For example:

						```sh
						shell> sudo myisamchk --safe-recover /var/lib/mysql/World/City
						```

					> __Note__
					> To make a repair operation to go much faster, set the values of the sort_buffer_size and key_buffer_size variables each to about 25% of your available memory when running myisamchk.
					1. If you get unexpected errors when repairing (such as out of memory errors), or if myisamchk crashes, continue to Stage Two, below.
				1. Stage Two: Difficult repair
					1. You'll reach this stage only if the first 16KB block in the index file is destroyed or contains incorrect information, or if the index file is missing. In this case, it is necessary to create a new index file. Do so as follows:
						1. Move the data file to a safe place, e.g.

							```sh
							shell> mkdir ~/safe && mv /var/lib/mysql/World/City.MYD ~/safe/
							```
						
						1. If you are using replication, stop it.
						1. Start mysqld if it's not already running.	

							```
							shell> sudo systemctl stop mysqld
							```
						
						1. Use the table description file to create new (empty) data and index files, e.g.

							```sh
							shell> mysql -uroot -p World # Run the mysql client and use the World database
							```

							```sql
							mysql> SET autocommit=1; -- Set autocommit to TRUE
							mysql> TRUNCATE TABLE City; -- Create the new files
							mysql> quit
							```

						1. Copy the old data file back onto the newly created data file (Do not just move the old file back onto the new file. Retain a copy in case something goes wrong.), e.g.

							```sh
							shell> cp -i ~/safe/City.MYD /var/lib/mysql/World/
							```

						1. Go back to Stage One. `myisamchk -r -q /var/lib/mysql/World/City` will likely work this time.
				1. Stage Three: Very difficult repair
					1. You'll reach this stage only if the .frm description file has also crashed. That is not expected to happen, because the description file is not changed after the table is created.
						1. Restore the .frm description file from a backup and go back to Stage Two. You can also restore the .MYI index file and go back to Stage One. In the latter case, start with `myisamchk -r /var/lib/mysql/World/City`.
						1. If you do not have a backup but know exactly how the table was created, create a copy of the table in another database. Remove the new data file, and then move the .frm description and .MYI index files from the other database to your crashed database. This gives you new description and index files, but leaves the .MYD data file alone. Go back to Stage One and attempt to reconstruct the index file.
			1. For the very unlikely case that City uses InnoDB:
				1. If you experience corruption with the InnoDB storage engine, something is seriously wrong. Investigate it right away. InnoDB simply shouldn’t corrupt. Its design makes it very resilient to corruption. Corruption is evidence of either a hardware problem such as bad memory or disks (likely), an administrator error such as manipulating the database files externally to MySQL (likely), or an InnoDB bug (unlikely). If you experience data corruption with InnoDB:
					1. Try to determine why it’s occurring; don’t simply repair the data, or the corruption could return. 
					1. You can repair the data by putting InnoDB into forced recovery mode with the innodb_force_recovery parameter; see [the MySQL manual for details](https://docs.oracle.com/cd/E17952_01/mysql-5.0-en/forcing-innodb-recovery.html).
1. "Missing index file" | 240 minutes
	1. The problem is: The index file, City.MYI, was corrupted and then removed during efforts to repair the table. 
	1. Possible solutions are:
	 	1. Stage One: Easy repair	
			1. Create a new index file by taking the following steps.
				1. If you are using replication, stop it.
				1. Locate the "datadir" i.e. the location of database files, e.g.

					```sql
					mysql> SELECT @@datadir;
					+-----------------+
					| @@datadir       |
					+-----------------+
					| /var/lib/mysql/ |
					+-----------------+
					```
				
				1. Ensure the database directory and table files are readable and writable by you and by the user mysqld runs as, e.g.

					```sh
					shell> MY_USER=`whoami` && \
					sudo chown $MY_USER:mysql /var/lib/mysql/World /var/lib/mysql/World/* && \
					sudo chmod 0775 /var/lib/mysql/World && \
					sudo chmod 0660 /var/lib/mysql/World/*
					```

				1. Move the data file to a safe place, e.g. 

					```sh
					shell> mkdir ~/safe && mv /var/lib/mysql/World/City.MYD ~/safe/
					```
				
				1. Use the table description file to create new (empty) data and index files, e.g.

					```sh
					shell> mysql World # Run the mysql client and use the World database
					```

					```sql
					mysql> SET autocommit=1; -- Set autocommit to TRUE
					mysql> TRUNCATE TABLE City; -- Create the new files
					mysql> quit
					```
					
					1. Copy the old data file back onto the newly created data file (Do not just move the old file back onto the new file. Retain a copy in case something goes wrong.), e.g.

						```sh
						shell> sudo cp -i ~/safe/City.MYD /var/lib/mysql/World/
						```
						
					1. Ensure the data file and index file are readable and writable by you and by the user mysqld runs as, e.g.

						```sh
						shell> sudo chown -R vagrant:mysql /var/lib/mysql/World/ && sudo chmod 0664 /var/lib/mysql/World/* 
						```
				
				1. Make a backup of the data file, City.MYD, e.g.

					```sh
					shell> cp /var/lib/mysql/World/City.MYD ~/
					```

				1. Stop mysqld.

					```
					shell> sudo systemctl stop mysqld
					```
				
				1. Use "[myisamchk](https://docs.oracle.com/cd/E17952_01/mysql-5.0-en/myisamchk.html) -r tbl_name" (-r means “recovery mode”). This removes incorrect rows and deleted rows from the data file and reconstructs the index file. For example:

					```sh
					shell> sudo myisamchk -r /var/lib/mysql/World/City
					```

				1. If the preceding step fails, use "myisamchk --safe-recover tbl_name". Safe recovery mode uses an old recovery method that handles a few cases that regular recovery mode does not (but is slower). For example:

					```sh
					shell> sudo myisamchk --safe-recover /var/lib/mysql/World/City
					```

				> __Note__
				> To make a repair operation to go much faster, set the values of the sort_buffer_size and key_buffer_size variables each to about 25% of your available memory when running myisamchk.
				1. If you get unexpected errors when repairing (such as out of memory errors), or if myisamchk crashes, continue to Stage Two, below.
		1. Stage Two: Difficult repair
			1. You'll reach this stage only if the .frm description file has also crashed. That is not expected to happen, because the description file is not changed after the table is created.
				1. Restore the .frm description and .MYI index file from a backup, and go back to Stage One.
				1. If you do not have a backup but know exactly how the table was created, create a copy of the table in another database. Remove the new data file, and then move the .frm description and .MYI index files from the other database to your crashed database. This gives you new description and index files, but leaves the .MYD data file alone. Go back to Stage One and attempt to reconstruct the index file.