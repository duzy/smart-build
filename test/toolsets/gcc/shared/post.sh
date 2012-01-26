# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-shared/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-shared/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/module-of-type-shared.so
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/lib/libmodule-of-type-shared.so
