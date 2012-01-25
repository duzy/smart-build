# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/toolset-gcc-gccgo/toolsets/gcc/foo.go.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/toolset-gcc-gccgo/toolsets/gcc/foo.go.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/toolset-gcc-gccgo/toolsets/gcc/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/toolset-gcc-gccgo/toolsets/gcc/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/toolset-gcc-gccgo$EXE

out=`$OUT_BIN/toolset-gcc-gccgo$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo.go: foo(10) = 100"