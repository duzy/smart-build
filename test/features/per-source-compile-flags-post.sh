# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-per-source-compile-flags$EXE

out=`$OUT_BIN/feature-per-source-compile-flags$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
