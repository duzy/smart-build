int foo(int n)
{
  extern int go_foo(int n) __asm__("go.foo.Foo");
  return go_foo(n) * go_foo(n) / 2 / 2;
}
