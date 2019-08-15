# Responses

1. "Citycodes" | 45 minutes
	1. The SELECT performs poorly because: 
		
		1. MySQL reads every one of the 32769 rows in the citycodes table in order to find the result. This can be seen in the output of EXPLAIN: type is "ALL", meaning all rows are read; and, rows is "32769". 
			1. MySQL reads every row because it does not use the existing index "idx_code" on the citycodes.code column. 
			1. It does not use the index "idx_code" because of a type mismatch: the query passes an integer (37040) as the value to be found in the citycodes.code column, while the type of the citycodes.code column is VARCHAR. 
	
	1. A possible solution is: Wrap 37040 in single quotes in the query, like `EXPLAIN SELECT city FROM citycodes WHERE code = '37040'\G`. That way, 37040 would be passed as a string rather than as an integer, and MySQL would use the "idx_code" index to speed the query.
	
1. "Attendance" | 180 minutes 
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
						1. Create a corresponding row in the enrollments_flag table. 
						1. Set enrollment_flags.enrollment_id of the corresponding row to the value of enrollment.enrollment_id of the current row.
						2. For each flag in the comma-separated list in the enrollment_flags column of the current row:
							1. Create a corresponding row in the enrollment_flags table, named for the flag.	
							1. Set the value of the respective (named for the flag) column in the corresponding row in the enrollment_flags table to TRUE.
							1. Remove the flag from the comma-separated list.  
							1. If the flag is the last of the comma-separated values:
								1. Set the value of enrollment_flags of the current row to NULL.
				1. When the enrollment_flags column is NULL in every row of the enrollment table, remove the enrollment_flags column from the enrollment table.
				1. Make the following changes to the SELECT:
					1. Replace e.enrollment_flags with ef.enrollment_flags
					1. Append to the FROM: `INNER JOIN enrollment_flags ef ON e.enrollment_id = ef.enrollment_id`
					1. Delete from the WHERE: `AND FIND_IN_SET('F', e.enrollment_flags) != 0`
					1. Append to the WHERE: `AND ef.F = TRUE`

1. "Population" | 90 minutes 
	1. The query performs poorly in MySQL 5.0 because: [the MySQL 5.0 optimizer incorrectly identifies the subquery as a dependent subquery because the subquery is using "IN"](https://bugs.mysql.com/bug.php?id=32665), so the subquery is run once per row of the containing query. The execution time thus is on the order of O(rows-of-inner*rows-of-outer) rather than O(rows-of-inner+rows-of-outer). 
	1. Some solutions are:
		1. Replace "IN" with "=". Also, remove CountryCode from the subquery because the left and right sides of "=" must be single values. CountryCode can safely be removed from the subquery: it is redundant there because CountryCode is selected in the containing query. Here is the query with "IN" replaced by "=", and CountryCode removed from the subquery:
		
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
			1. [JOIN has a higher precedence than the comma operator in MySQL 5](https://dev.mysql.com/doc/refman/5.5/en/join.html); hence, the join expression "student, enrollment, inprog LEFT JOIN clsenr" is interpreted by MySQL 5 as (student, enrollment (inprog JOIN clsenr ON clsenr.enr_id= enrollment.enr_id)). 
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
			AND inprog.sch$_id= 1473;
		```
  
1. "Global Variables & Status" | **rough draft** | 240 minutes 
	1. Suggestions I feel are called for in order to improve performance, stability, et cetera; are: 
		1. Slow_queries is 12761. A high value indicates that many queries are not executed optimally. Use the slow query log to identify and target these slow queries for optimization.
		1. Select_full_join is 1867. This is a count of joins that do not use indexes. Select_scan is 25643. This is a count of the number of joins that did a full scan of the first table. Ensure indexes of tables exist that the optimizer can use to speed the joins, and that the joins are adjusted to take best advantage of the indexes.
		1. Handler_read_rnd_next/Handler_read_key is 23675456/78665646 i.e. about 1/2. The former indicates queries that require MySQL to scan entire tables, while the latter indicates proper indexing. Handler_read_first is 3794. This is the number of times MySQL accessed the first row of a table index, which suggests that it is performing a sequential scan of the entire index. This indicates that the corresponding table is not properly indexed. Adjust indexes and queries to work together optimally.
		1. Created_tmp_disk_tables/Created_tmp_tables is 123349/256798 i.e. about 1/2: ~50% of temp tables were created on disk. The actual limit of memory available for temporary tables is the smaller of the values of tmp_table_size (134217728) and max_heap_table_size (16777216). max_heap_table_size could be increased, to equal to or greater than the value of tmp_table_size; however, this might only enable inefficient queries to consume still more RAM, and might no longer be necessary once indexes and queries have been improved.
		1. Key_reads/Key_reads_requests (the cache miss rate) is 1327838/6786353 = 0.20, while per [the manual](https://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html), states "[it] should normally be less than 0.01". Consider improving (reduce) this ratio by increasing key_buffer_size which is set to the default 8388600. Use the following process (https://scalegrid.io/blog/calculating-innodb-buffer-pool-size-for-your-mysql-server/) to determine a larger value to assign to key_buffer_size:
			
			1. Start with total RAM available.
			1. Subtract suitable amount for the OS needs.
			1. Subtract an amount according to the needs of other processes running on the system.
			1. Subtract suitable amount for all MySQL needs (like various MySQL buffers, temporary tables, connection pools, and replication related buffers).
			1. Divide the result by 105%, which is an approximation of the overhead required to manage the key buffer itself.
		
		1. SSL is not in use. Enable and configure SSL if MySQL is accepting connections from other than localhost.
		1. Table_locks_waited/Table_locks_immediate is 542987/1272139 i.e almost 1/2: nearly half of all locks wait. Consider upgrading to MySQL 5.6+ and converting some or all tables to InnoDB to avoid table-level locking.
		1. Innodb_buffer_pool_wait_free is 2342. If this variable is high, it suggests that innodb_buffer_pool_size is incorrectly sized for the number of writes the server performed. Innodb_buffer_pool_reads is 630232. If this variable is high, it suggests that innodb_buffer_pool_size is incorrectly sized for the number of reads the system performed. innodb_buffer_pool_size is set to 8388608 bytes, which is the default . Set it to a larger value, as near as possible to the actual size of the InnoDB tables i.e.
			
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

			...plus 20%, leaving enough memory for other processes on the server to run without excessive paging (http://www.speedemy.com/mysql/17-key-mysql-config-file-settings/default_storage_engine/). Use the following process (https://scalegrid.io/blog/calculating-innodb-buffer-pool-size-for-your-mysql-server/) to determine what value to assign to innodb_buffer_pool_size:
			
			1. Start with total RAM available.
			1. Subtract suitable amount for the OS needs.
			1. Subtract an amount according to the needs of other processes running on the system.
			1. Subtract suitable amount for all MySQL needs (like various MySQL buffers, temporary tables, connection pools, and replication related buffers).
			1. Divide the result by 105%, which is an approximation of the overhead required to manage the buffer pool itself.

		1. query_cache_type is set to ON, and query_cache_size to 104857600 i.e 100 megabytes. Meanwhile, MySQL has made a write for every six reads ( 78293 (Com_insert) +23923 (Com_update) + 378232 (Com_delete) / 2783289 (Com_select) ) . Each write of a table invalidates the query cache for ALL queries cached for that table; so, a frequently updated table doesn't benefit from the query cache. Query cache costs around 10% to 15% in overhead, and the query cache hit rate percentage ((Qcache_hits / (Qcache_hits + Qcache_inserts + Qcache_not_cached)) * 100) is 0.0004%; thus,  use of query cache is a net loss. Consider setting both query_cache_type and query_cache_size to 0 (requires a restart of mysqld) until/unless Qcache_lowmem_prunes grows large. Also, Connections/Uptime is 6734354/405423 i.e. sixteen connections per second; so, if there were many processor cores, there would be potential for contention for the query cache which if extant would make the query cache a bottleneck. That is almost certainly not true for the system under observation: version_compile_machine is powerpc, and version_compile_os is apple-darwin8.6.0; so, the system is likely an Apple Power Mac with two or fewer cores; and hence, there can be no such contention; however, if the system were ported to a machine with many cores, the potential for contention for the query cache would be a consideration.
		1. Sort_merge_passes is 38291. Consider increasing the value of sort_buffer_size, which is 65536 as compared to the default 2097144. Else, sorting rows can be slower than expected because data is from disk rather than memory.

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
	
