# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-exe-in-cpp/toolsets/clang/main.cpp.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-exe-in-cpp/toolsets/clang/main.cpp.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/bin/toolset-clang-exe-in-cpp$EXE

out=`$TOP/out/clang/debug/bin/toolset-clang-exe-in-cpp$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "clang: foo, 10"
