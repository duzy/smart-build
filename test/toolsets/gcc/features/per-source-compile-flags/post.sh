# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-per-source-compile-flags/_/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/feature-per-source-compile-flags$EXE

out=`out/gcc/debug/bin/feature-per-source-compile-flags$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
