#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>

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

  m = mysql_init(m);
  mysql_real_connect(m,"localhost","root","password-of-mysql-root-user",NULL,0,NULL,0);

  puts("Regular Execution");
  mysql_real_query(m, sql1, strlen(sql1));

  r= mysql_store_result(m);
  while ((w = mysql_fetch_row(r)))
  {
    printf("%s@%s\n", w[0], w[1]);
  }

  puts("Prepared Statement");
  s = mysql_stmt_init(m);
  mysql_stmt_prepare(s, sql2, strlen(sql2));
  // parameter
  par[0].buffer_type= MYSQL_TYPE_STRING;
  par[0].buffer= &sd[0];
  par[0].is_null= 0;
  par[0].length= &sdl[0];
  mysql_stmt_bind_param(s,par);

  strncpy(sd[0],"%localhost%",60);
  sdl[0]= strlen(sd[0]);
  mysql_stmt_execute(s);
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
  mysql_stmt_bind_result(s,res);

  while (!mysql_stmt_fetch(s))
  {
    printf("%s@%s\n", sd[1], sd[2]);
  }

  mysql_stmt_free_result(s);
  mysql_stmt_close(s);
  mysql_close(m);
}
