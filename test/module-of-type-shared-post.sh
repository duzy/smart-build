# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/foo.c.o
#test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/foo.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/module-of-type-shared.so
