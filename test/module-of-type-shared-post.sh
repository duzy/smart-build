# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/module-of-type-shared/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/module-of-type-shared/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/module-of-type-shared.so
