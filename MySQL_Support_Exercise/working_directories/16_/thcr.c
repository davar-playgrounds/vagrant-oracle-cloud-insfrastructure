/* thcr.c - random thread failure */

#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <assert.h>

/* 1 of 3 possible failure points */
void pf3()
{
  void *m;
  m= malloc(8192);
  free(m);
  free(m);
  free(0);
}

/* 1 of 3 possible failure points */
void pf2()
{
  int x= 1/0;
  free((void *)x);
}

/* 1 of 3 possible failure points */
void pf1()
{
  int a= 0;
  assert(a=1);
  assert(a==0);
}

/* arguments passed to each thread */
struct targ
{
  int tc; /* thread count (number) */
  int cr; /* whether thread should crash */
  int pf; /* failure point to use */
};

void* handler( void* arg )
{
  struct targ *ta;
  ta= (struct targ*)arg;
  if (ta->cr == 1)
  {
    switch (ta->pf)
    {
    case 0:
      pf1();
      break;
    case 1:
      pf2();
      break;
    case 2:
      pf3();
      break;
    }
  }
  pthread_exit(0);
}

int main()
{
  pthread_t tp[10];
  struct targ ta[10];
  int ctr;

  srandom(time(0));
  for (ctr= 0; ctr< 10; ctr++)
  {
    ta[ctr].tc= ctr;
    ta[ctr].cr= random()%2;
    ta[ctr].pf= random()%3;
  }
  for (ctr= 0; ctr< 10; ctr++)
  {
    pthread_create(&tp[ctr], NULL, handler, (void*)&ta[ctr]);
  }
  for (ctr= 0; ctr< 10; ctr++)
  {
    pthread_join(tp[ctr],0);
  }
  return 0;
}
