# MySQL Support Exercise

## The Exercise

1. Given a query, a table definition for a table of type MyISAM, and EXPLAIN output: Identify why the query performs poorly, and possible solutions.
1. Given a query, a table definitions for a tables of type MyISAM, and EXPLAIN output: identify changes that would result in performance improvements.
1. Given a query and the size of the table it queries: Explain why the query performs poorly, and demo solutions to the problem. 
1. Given a query that works against v4.0 but not v5.0: Identify the cause, and demonstrate solutions.
1. Given the output of SHOW GLOBAL VARIABLES and SHOW GLOBAL STATUS: Suggest changes to improve performance, stability, etc.
1. Given table definitions and a stored procedure: Identify errors in the stored procedure, and provide a corrected version.
1. Given a C program utilizing the MySQL C API: Identify the problems and appropriate solutions.
1. Given a snippet of code from a Java application that uses Connector/J: Identify possible problems and possible solutions.
1. Given that execution of a specified snippet of C code results in "MySQL client ran out of memory": Identify probable causes and solutions.
1. Given that a snippet of Java code using Connector/J, that would create a stored procedure on MySQL 5.0, does not execute successfully: Identify the cause and available solutions.
1. Identify possible causes of the appearance of "sort aborted" in the mysqld error log.
1. Given that `mysqladmin status` fails to connect to server at localhost and throws "Can't create a new thread...": Identify possible causes.
1. Troubleshoot replication failure. Identify:
    1. What happened on the master
    1. Why a particular slave reported an error
    1. Why another slave succeeded
    1. How to recover
1. Given a set of information about an incidence of replication failure: Identify why replication is not working, and what must be done to resume operation.
1. Given a set of information about another incidence of replication failure: Identify why replication is not working, and what must be done to resume operation.
1. Given a binary, a core file, and source code for a multi-threaded linux executable: Use gdb to answer the following questions. For each answer, include the gdb output used to arrive at the answer:
    1. On what line of which function did the program crash? 
    1. What are the values of particular variables in the crashed thread? 
    1. Which threads would have executed one of a set of functions, and which function would each of the threads have executed?
1. Given that the output of `check table %table%\G` includes "%table% is marked as crashed and should be repaired": Identify solutions.
1. Given that an application began reporting an error number, and during attempts to resolve the error the error number changed twice; and that upon a SELECT from a table the application throws an error indicating that the file for the table can't be found: Identify the problem and possible solutions. 
1. Given a table definition and messages in the error log about "InnoDB" and "checksum" and "corruption on disk": Explain the problem and identify possible solutions. 
1. Given a table definition and messages in the error log about "InnoDB" and "checksum" and "corruption of an index tree": Explain the problem and identify possible solutions. 

## Resources for Study and Reference

### Optimizing Queries

#### Generally

1. [5 Tips to Optimize Your SQL Queries](https://www.vertabelo.com/blog/technical-articles/5-tips-to-optimize-your-sql-queries)
1. [Practical MySQL Performance Tuning - query optimization.pdf](https://learn.percona.com/ebook-practical-mysql-performance-optimization-section-2)
1. [MySQL Server and SQL Performance Tuning](https://www.oracle.com/technetwork/community/developer-day/mysql-performance-tuning-403029.pdf)
1. [Exclusive MySQL Performance Tuning Tips For Better Database Optimization](https://www.cloudways.com/blog/mysql-performance-tuning/#optimize)
1. [MySQL Troubleshooting :: Basics :: Slow Queries](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch01.html#basics_performance)
1. [MySQL Stored Procedure Programming :: Tuning Stored Programs and Their SQL](https://learning.oreilly.com/library/view/mysql-stored-procedure/0596100892/ch19.html)
1. [MySQL Stored Procudure Programming :: Basic SQL Tuning](https://learning.oreilly.com/library/view/mysql-stored-procedure/0596100892/ch20.html)
1. [MySQL Stored Procudure Programming :: Advanced SQL Tuning](https://learning.oreilly.com/library/view/mysql-stored-procedure/0596100892/ch20.html)
1. [High Performance MySQL :: Query Performance Optimization](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch06.html)
1. [How to Optimize MySQL Queries for Speed and Performance - DZone Database](https://dzone.com/articles/how-to-optimize-mysql-queries-for-speed-and-perfor)
1. [MySQL 5 Certification Study Guide (PDF)](https://www.scribd.com/document/62417803/MySQL-5-Certification-Study-Guide) - Download and search for "Basic Optimizations" 

#### By Adding Indexes

1. [An Introduction to MySQL Indexes](https://www.vertabelo.com/blog/technical-articles/an-introduction-to-mysql-indexes)
1. [MySQL Troubleshooting :: Basics :: Table Tuning and Indexes](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch01.html#id374995) 
1. [High Performance MySQL :: Indexing for High Performance](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch05.html)
1. [An in-depth look at Database Indexing](https://www.freecodecamp.org/news/database-indexing-at-a-glance-bb50809d48bd/)
1. [MySQL: Building the best INDEX for a given SELECT](http://mysql.rjweb.org/doc.php/index_cookbook_mysql)
1. [MySQL Index - Ultimate Guide to Indexes in MySQL By Practical Examples](http://www.mysqltutorial.org/mysql-index/)
1. [Making slow queries fast with composite indexes in MySQL](https://blog.nodeswat.com/making-slow-queries-fast-with-composite-indexes-in-mysql-eb452a8d6e46)
1. [Use the Index, Luke](https://use-the-index-luke.com)
1. [SQL Performance Explained](https://sql-performance-explained.com/?utm_source=use-the-index-luke.com&utm_campaign=front&utm_medium=web)

#### By using the EXPLAIN statement

1. [HowTo: MySQL Query Optimization using EXPLAIN and Indexing - YouTube](https://www.youtube.com/watch?v=9K26Wb84f50)
1. [SQL Explain statement - YouTube](https://www.youtube.com/watch?v=5y8G72q-IpE&list=PLpPXw4zFa0uIjh_Jv_j7OVsqBPsjdP9CT&index=5)
1. [Using EXPLAIN to Write Better MySQL Queries — SitePoint](https://www.sitepoint.com/using-explain-to-write-better-mysql-queries/)
1. [MySQL Performance Boosting with Indexes and Explain — SitePoint](https://www.sitepoint.com/mysql-performance-indexes-explain/)
1. [MySQL :: MySQL Workbench Manual :: 7.5 Tutorial: Using Explain to Improve Query Performance](https://dev.mysql.com/doc/workbench/en/wb-tutorial-visual-explain-dbt3.html)
1. [MySQL Troubleshooting :: Tuning a Query with Information from EXPLAIN](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch01.html#explain)
1. [MariaDB Explain Analyzer](https://mariadb.org/explain_analyzer/analyze/)
1. [MySQL 5 Certification Study Guide (PDF)](https://www.scribd.com/document/62417803/MySQL-5-Certification-Study-Guide) - Download and search for "Using EXPLAIN to Analyze Queries"
1. [High Performance MySQL :: Using EXPLAIN](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/apd.html) 
1. [MySQL :: MySQL 5.7 Reference Manual :: 8.8.2 EXPLAIN Output Format](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html)


### Improving MySQL Server Performance and Stability

1. [MySQL 5 Certification Study Guide (PDF)](https://www.scribd.com/document/62417803/MySQL-5-Certification-Study-Guide) - Download and search for "Optimizing the Server" 
1. [MySQL Troubleshooting :: Effects of Server Options](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch03.html)  
1. [High Performance MySQL :: Optimizing Server Settings](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch08.html)  
1. [Tuning MySQL System Variables for High Performance](https://geekflare.com/mysql-performance-tuning/)
1. [MySQL performance & variables tweaking - Stack Overflow](https://stackoverflow.com/questions/9195139/mysql-performance-variables-tweaking)
1. [10 MySQL variables that you should monitor](https://www.techrepublic.com/blog/linux-and-open-source/10-mysql-variables-that-you-should-monitor/)
1. [MySQL 5.7 Performance Tuning After Installation - Percona Database Performance Blog](https://www.percona.com/blog/2016/10/12/mysql-5-7-performance-tuning-immediately-after-installation/)
1. [17 Key MySQL Config File Settings (MySQL 5.7 proof) - Speedemy](https://www.speedemy.com/17-key-mysql-config-file-settings-mysql-5-7-proof/)
1. [MySQL Configuration Tuning Handbook by Speedemy](http://speedemy.com/files/ebook1/Speedemy-MySQL-Configuration-Tuning-Handbook.pdf)
1. [MySQL Performance Cheat Sheet | Severalnines](https://severalnines.com/blog/mysql-performance-cheat-sheet)
1. [MySQL Server and SQL Performance Tuning](https://www.oracle.com/technetwork/community/developer-day/mysql-performance-tuning-403029.pdf)
1. [Exclusive MySQL Performance Tuning Tips For Better Database Optimization](https://www.cloudways.com/blog/mysql-performance-tuning/#optimize)

### Understanding Stored Procedures

1. [MySQL Stored Procedures 101 - Peter Lafferty - Medium](https://medium.com/@peter.lafferty/mysql-stored-procedures-101-6b4fe230967)
1. [Intermediate MySQL Stored Procedures - Peter Lafferty - Medium](https://medium.com/@peter.lafferty/intermediate-mysql-stored-procedures-24394d3cab03)
1. [Advanced Stored Procedures In MySQL - Peter Lafferty - Medium](https://medium.com/@peter.lafferty/advanced-stored-procedures-in-mysql-9673d396a220)
1. [MySQL Stored Procedure Programming](https://learning.oreilly.com/library/view/mysql-stored-procedure/0596100892/)
1. [High Performance MySQL :: Advanced MySQL Features :: Storing Code Inside MySQL :: Stored Procedures and Functions](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch07.html#stored_procedures_and_functions)
1. [MySQL 5 Certification Study Guide (PDF)](https://www.scribd.com/document/62417803/MySQL-5-Certification-Study-Guide) - Download and search for "Stored Procedures and Functions" 
1. [MySQL Stored Procedure Tutorial](http://www.mysqltutorial.org/mysql-stored-procedure-tutorial.aspx)

### Debugging Linux executables, with gdb

1. [Debugging With GDB - YouTube](https://www.youtube.com/watch?v=OpVMB7DNlmY)
1. [gdb Text User Interface (tui)](https://doc.ecoscentric.com/gnutools/doc/gdb/TUI.html#TUI)
1. [Tips on Using GDB to Track Down and Stamp Out Software Bugs](https://www-numi.fnal.gov/offline_software/srt_public_context/WebDocs/Companion/intro_talks/gdb/gdb.html)
1. [GNU Debugger Tutorial](https://www.tutorialspoint.com/gnu_debugger/index.htm)
1. [Debugging Under Unix: gdb Tutorial](https://www.cs.cmu.edu/~gilpin/tutorial/)
1. [How to Use gdb](http://heather.cs.ucdavis.edu/%7Ematloff/UnixAndC/CLanguage/Debug.html#tth_sEc4)
1. [gdb tutorial by Krueger at toronto.edu](http://www.cs.toronto.edu/~krueger/csc209h/tut/gdb_tutorial.html)
1. [Debugging with GDB - Running Programs Under GDB](http://web.mit.edu/gnu/doc/html/gdb_6.html)
1. [GNU Debugger (gdb) on RHEL 7](https://access.redhat.com/documentation/en-us/red_hat_developer_toolset/7/html/user_guide/chap-gdb)
1. [gdb Debugging Full Example (Tutorial): ncurses](http://www.brendangregg.com/blog/2016-08-09/gdb-example-ncurses.html)

### Troubleshooting Replication

1. [MySQL 5 Certification Study Guide (PDF)](https://www.scribd.com/document/62417803/MySQL-5-Certification-Study-Guide) - Download and search for "Replication Troubleshooting"
1. [MySQL Troubleshooting :: You Are Not Alone: Concurrency Issues :: Replication and Concurrency](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch02.html#concurrency_replication)
1. [High Performance MySQL :: Replication :: Replication Problems and Solutions ](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch10.html)

### Troubleshooting InnoDB Corruption

1. [High Performance MySQL :: Backup and Recovery :: Recovery from a Backup: InnoDB Crash Recovery :: Causes of InnoDB Corruption](https://learning.oreilly.com/library/view/high-performance-mysql/9781449332471/ch15.html)
1. [MySQL Troubleshooting :: Basics :: Issues with Solutions Specific to Storage Engines :: InnoDB Corruption](https://learning.oreilly.com/library/view/mysql-troubleshooting/9781449317836/ch01.html)