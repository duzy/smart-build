# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-external-sources/toolsets/gcc/features/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-external-sources/toolsets/gcc/features/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/feature-external-sources$EXE

out=`out/gcc/debug/bin/feature-external-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test: test"
