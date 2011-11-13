#include <stdio.h>

extern int foo(int n);

int main(int argc, char**argv)
{
  printf("foo(10) = %d\n", foo(10));
  
  return 0;
}
