# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-flags-in-file-compile/toolsets/gcc/features/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-flags-in-file-compile/toolsets/gcc/features/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/temp/feature-flags-in-file-compile/flags.compile.c.0

out=`test-readfile $OUT_TEMP/feature-flags-in-file-compile/flags.compile.c.0`
#test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"feature-flags-in-file-compile\\\""
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"feature-flags-in-file-compile\\\""
