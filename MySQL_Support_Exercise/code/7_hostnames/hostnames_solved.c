// gcc -I/usr/include/mysql hostnames.c -o hostnames `mysql_config --cflags --libs`

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h> // see the -I option of the gcc command in a comment above, for use on Oracle Linux
                   // with the following packages installed: mysql mysql-devel mysql-lib

int main()
{
  MYSQL *m;
  MYSQL_RES *r;
  MYSQL_ROW w;
  MYSQL_STMT *s;
  MYSQL_BIND par[2];
  MYSQL_BIND res[2];
  char sd[4][60];
  unsigned long sdl[4];
  my_bool nl[4];
  char sql1[]= "SELECT user, host FROM mysql.user WHERE host LIKE '%localhost%'";
  char sql2[]= "SELECT user, host FROM mysql.user WHERE host LIKE ?";
  int param_count;

  m = mysql_init(m);
  if (!m) {
    puts("Init failed, out of memory?");
    return EXIT_FAILURE;
  }
  if (!mysql_real_connect(m,"localhost","root","JNOhdkbe3j,U",NULL,0,NULL,0))
  {
	  fprintf(stderr, " Failed to connect to database: Error: %s\n", mysql_error(m));
  }

  puts("Regular Execution");
  mysql_real_query(m, sql1, strlen(sql1));

  r= mysql_store_result(m);
  while ((w = mysql_fetch_row(r)))
  {
  	printf(" %s@%s\n", w[0], w[1]);
  }

  puts("Prepared Statement");
  s = mysql_stmt_init(m);
  if (!s)
  {
	  fprintf(stderr, " mysql_stmt_init(), out of memory\n");
	  exit(0);
  }
  if (mysql_stmt_prepare(s, sql2, strlen(sql2)))
  {
	  fprintf(stderr, " mysql_stmt_prepare(), sql2 failed\n");
	  fprintf(stderr, " %s\n", mysql_stmt_error(s));
	  exit(0);
  }
  // fprintf(stdout, " Prepare, INSERT successful\n");

  /*param_count= mysql_stmt_param_count(s);
  fprintf(stdout,  " Total parameters in sql2: %d\n", param_count);*/

  par[0].buffer_type= MYSQL_TYPE_STRING;
  par[0].buffer= &sd[0];
  par[0].is_null= 0;
  par[0].length= &sdl[0];

  if (mysql_stmt_bind_param(s,par))
  {
	  fprintf(stderr, " mysql_stmt_bind_param() failed\n");
	  fprintf(stderr, " %s\n", mysql_stmt_error(s));
	  exit(0);
  }
  // fprintf(stdout, " Bind of parameters successful\n");

  strncpy(sd[0],"%localhost%",60);
  // printf(" %s\n", sd[0]);

  sdl[0]= strlen(sd[0]);
  // printf(" %lu\n", sdl[0]);

  if (mysql_stmt_execute(s))
  {
	  fprintf(stderr, " mysql_stmt_execute(), 1 failed\n");
	  fprintf(stderr, " %s\n", mysql_stmt_error(s));
	  exit(0);
  }
  // fprintf(stdout, " Execution of statement successful\n");

  res[0].buffer_type= MYSQL_TYPE_STRING;
  res[0].buffer= &sd[1];
  res[0].buffer_length= 60;
  res[0].is_null= &nl[1];
  res[0].length= &sdl[1];
  res[1].buffer_type= MYSQL_TYPE_STRING;
  res[1].buffer= &sd[2];
  res[1].buffer_length= 60;
  res[1].is_null= &nl[2];
  res[1].length= &sdl[2];

  if (mysql_stmt_bind_result(s, res))
  {
	  fprintf(stderr, " mysql_stmt_bind_result() failed\n");
	  fprintf(stderr, " %s\n", mysql_stmt_error(s));
	  exit(0);
  }
  // fprintf(stdout, " Bind of results successful\n");

  while (!mysql_stmt_fetch(s))
  {
    printf("%s@%s\n", sd[1], sd[2]);
  }

  mysql_stmt_free_result(s);
  mysql_stmt_close(s);
  mysql_close(m);
}
