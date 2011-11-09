# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/module-of-type-exe-use-shared$EXE

out=`$OUT_BIN/module-of-type-exe-use-shared$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(10) = 100"

out=`ldd $OUT_BIN/module-of-type-exe-use-shared$EXE | grep $OUT_BIN/module-of-type-shared.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "$OUT_BIN/module-of-type-shared.so"
