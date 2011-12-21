# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.0.c
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.1.c
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.2.c
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/features/feature-compile-sources-flags-in-file/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/feature-compile-sources-flags-in-file$EXE

out=`$TOP/out/gcc/debug/bin/feature-compile-sources$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"

out=`cat $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.0.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"foobar\\\""

out=`cat $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.1.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"foo\\\""

out=`cat $TOP/out/gcc/debug/temp/feature-compile-sources-flags-in-file/compile.flags.2.c`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-g -ggdb -DTEST=\\\"bar\\\""
