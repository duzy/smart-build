# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-exe-in-c/toolsets/clang/exe-in-c/_/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-exe-in-c/toolsets/clang/exe-in-c/_/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/bin/toolset-clang-exe-in-c$EXE

out=`out/clang/debug/bin/toolset-clang-exe-in-c$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "clang: foo, 10"
