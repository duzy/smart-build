# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/foobar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-compile-sources/bar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-compile-sources$EXE

out=`$OUT_BIN/feature-compile-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
