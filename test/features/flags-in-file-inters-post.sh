# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-inters/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/feature-flags-in-file-inters/main.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-flags-in-file-inters/link.intermediates

out=`cat $OUT_TEMP/feature-flags-in-file-inters/link.intermediates`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "out/gcc/debug/intermediates/features/feature-flags-in-file-inters/main.c.o"
