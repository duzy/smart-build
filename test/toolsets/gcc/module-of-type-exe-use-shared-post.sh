# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-exe-use-shared/toolsets/gcc/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-exe-use-shared/toolsets/gcc/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/module-of-type-exe-use-shared$EXE

out=`$TOP/out/gcc/debug/bin/module-of-type-exe-use-shared$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(10) = 100"

out=`ldd $TOP/out/gcc/debug/bin/module-of-type-exe-use-shared$EXE | grep out/gcc/debug/bin/module-of-type-shared.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "out/gcc/debug/bin/module-of-type-shared.so"
