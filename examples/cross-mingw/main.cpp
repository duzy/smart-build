#include <windows.h>

int main(int argc, char**argv)
{
  MessageBox(NULL,
             LPCTSTR("MinGW32 cross built under Linux"),
             LPCTSTR("Cross Build"),
             0);
  return 0;
}
