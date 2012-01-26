# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.0
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.1
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.2
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/foobar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/foobar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/bar.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/feature-compile-sources-flags-in-file/_/bar.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/feature-compile-sources-flags-in-file$EXE

out=`out/gcc/debug/bin/feature-compile-sources-flags-in-file$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "smart.test.foo: foo;smart.test.bar: bar;"

out=`test-readfile out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.0`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"foobar\\\""

out=`test-readfile out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.1`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"foo\\\""

out=`test-readfile out/gcc/debug/temp/feature-compile-sources-flags-in-file/flags.compile.c.2`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-DTEST=\\\"bar\\\""
