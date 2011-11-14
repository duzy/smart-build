# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-libs/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-libs/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-flags-in-file-libs/link.libs

out=`cat $OUT_TEMP/feature-flags-in-file-libs/link.libs`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-Ltest"
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-lm"
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-Ltest -lm"
