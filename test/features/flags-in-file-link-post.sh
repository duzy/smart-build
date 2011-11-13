# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-link/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-link/main.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-flags-in-file-link/link.flags

out=`cat $OUT_TEMP/feature-flags-in-file-link/link.flags`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-O2"
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-Wl,--no-undefined -O2"

