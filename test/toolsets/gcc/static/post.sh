# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-static/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/gcc-static/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/lib/libgcc-static.a
