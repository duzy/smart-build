# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/foobar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-per-source-compile-flags/bar.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-per-source-compile-flags$EXE

out=`$OUT_BIN/feature-per-source-compile-flags$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
