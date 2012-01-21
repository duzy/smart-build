# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-compile-sources/toolsets/gcc/features/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/feature-compile-sources$EXE

out=`$TOP/out/gcc/debug/bin/feature-compile-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
