# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-flags-in-file-compile/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-flags-in-file-compile/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_TEMP/feature-flags-in-file-compile/compile.flags.0.c

out=`cat $OUT_TEMP/feature-flags-in-file-compile/compile.flags.0.c`
#test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"feature-flags-in-file-compile\\\""
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"feature-flags-in-file-compile\\\""
