//#include "runtime.h"
//#include "type.h"
//#include "/home/duzy/open/go/src/pkg/runtime/type.h"

void toolset_go_package·Foo2(void* v, int n) {
  struct {
    void *type;
    void *ptr;
  } *a = v;
  runtime·printf("toolset_go_package·Foo2(%p, %d)\n", a, n);
}
