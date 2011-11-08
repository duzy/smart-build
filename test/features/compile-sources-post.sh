# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/foobar.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/foo.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/bar.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-compile-sources$EXE
