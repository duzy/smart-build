#include <stdio.h>
extern int foo(int n);
void main() { int n = TEST_NUM; printf("%s(%d) = %d\n", TEST_STR, n, foo(n)); }
