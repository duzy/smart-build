# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-flags-in-file-compile/compile.flags.0.c
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/main.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/foo.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/bar.o
