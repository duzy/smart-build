# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-exe-use-static/toolsets/gcc/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/intermediates/module-of-type-exe-use-static/toolsets/gcc/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/gcc/debug/bin/module-of-type-exe-use-static$EXE

out=`$TOP/out/gcc/debug/bin/module-of-type-exe-use-static$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(5) = 25"
