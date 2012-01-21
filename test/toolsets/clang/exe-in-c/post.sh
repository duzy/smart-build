# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-exe-in-c/toolsets/clang/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-exe-in-c/toolsets/clang/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/bin/toolset-clang-exe-in-c$EXE

out=`$TOP/out/clang/debug/bin/toolset-clang-exe-in-c$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "clang: foo, 10"
