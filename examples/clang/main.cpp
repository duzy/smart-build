#include <iostream>

int foo();
extern "C" int bar();

int main(int argc, char**argv)
{
  std::cout
    <<"Hi, clang ! - "
    <<_LIBCPP_VERSION<<", "
    <<_LIBCPP_ABI_VERSION<<", "
    <<foo()+bar()
    <<std::endl
    ;
  return 0;
}
