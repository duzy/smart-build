# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/exe-use-shared/_/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/exe-use-shared/_/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/foo.go.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-shared/_/foo.go.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/gcc-shared.so
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/lib/libgcc-shared.so
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/exe-use-shared$EXE

out=`out/gcc/debug/bin/exe-use-shared$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(10) = 100"

out=`ldd out/gcc/debug/bin/exe-use-shared$EXE | grep out/gcc/debug/bin/gcc-shared.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "out/gcc/debug/bin/gcc-shared.so"
