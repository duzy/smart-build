extern int bar(int n) __asm__("go.main.Foo");

int foo(int n) 
{
  return bar(n) * bar(n) / 2 / 2;
}
