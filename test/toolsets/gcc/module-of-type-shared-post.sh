# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-shared/toolsets/gcc/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-shared/toolsets/gcc/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/module-of-type-shared.so
