# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/gcc/toolset-gcc-gccgo/foo.go.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/gcc/toolset-gcc-gccgo/foo.go.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/gcc/toolset-gcc-gccgo/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/gcc/toolset-gcc-gccgo/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/toolset-gcc-gccgo$EXE

out=`$OUT_BIN/toolset-gcc-gccgo$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo.go: foo(10) = 100"
