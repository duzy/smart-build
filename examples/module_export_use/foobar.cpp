#include <foobar/bar.h> // in foobar/bar
#include <foo.h> // in ../shared

int main(int argc, char**argv)
{
  foo(); // in ../shared

  bar(); // in foobar/bar
  
  return 0;
}
