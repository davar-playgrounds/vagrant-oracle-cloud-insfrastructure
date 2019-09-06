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