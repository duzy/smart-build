# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-libs/_/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-flags-in-file-libs/_/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-flags-in-file-libs/flags.libs.link.0

out=`test-readfile out/gcc/debug/temp/feature-flags-in-file-libs/flags.libs.link.0`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-Ltest"
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "-lm"
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-Ltest -lm"
