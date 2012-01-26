# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-exe-in-cpp/toolsets/clang/main.cpp.o
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-exe-in-cpp/toolsets/clang/main.cpp.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/bin/toolset-clang-exe-in-cpp$EXE

out=`out/clang/debug/bin/toolset-clang-exe-in-cpp$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "clang: foo, 10"
