# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/main.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/module-of-type-exe-use-static$EXE

out=`$OUT_BIN/module-of-type-exe-use-static$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(10) = 100"
