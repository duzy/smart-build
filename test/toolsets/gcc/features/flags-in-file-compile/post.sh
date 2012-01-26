# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-compile/_/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-compile/_/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-flags-in-file-compile/flags.compile.c.0

out=`test-readfile out/gcc/debug/temp/feature-flags-in-file-compile/flags.compile.c.0`
#test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"feature-flags-in-file-compile\\\""
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"feature-flags-in-file-compile\\\""
