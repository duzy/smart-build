# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-external-sources/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-external-sources/main.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/feature-external-sources$EXE

out=`$OUT_BIN/feature-external-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test: test"
