#include <foobar/bar.h> // in foobar/bar
#include <foobar.h> // in ../shared

int main(int argc, char**argv)
{
  foobar(); // in ../shared

  bar(); // in foobar/bar
  
  return 0;
}
