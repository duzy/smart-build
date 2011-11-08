# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/main.t.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/module-of-type-t.test$EXE

out=`$OUT_BIN/module-of-type-t.test$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test"
