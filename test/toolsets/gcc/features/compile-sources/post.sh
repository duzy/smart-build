# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources/_/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/feature-compile-sources$EXE

out=`out/gcc/debug/bin/feature-compile-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
