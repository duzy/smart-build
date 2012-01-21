# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/feature-per-source-compile-flags/toolsets/gcc/features/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/feature-per-source-compile-flags$EXE

out=`$TOP/out/gcc/debug/bin/feature-per-source-compile-flags$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"
