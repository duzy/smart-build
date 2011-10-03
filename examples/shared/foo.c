#include <stdio.h>
#include "foo.h"

void foo()
{
  printf("smart::build::example::module: %s", TEST);
}

void main() { foo(); }
