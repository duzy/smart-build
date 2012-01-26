# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/module-of-type-exe-use-static/_/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/intermediates/module-of-type-exe-use-static/_/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/gcc/debug/bin/module-of-type-exe-use-static$EXE

out=`out/gcc/debug/bin/module-of-type-exe-use-static$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo(5) = 25"
