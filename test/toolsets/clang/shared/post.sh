# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-shared/toolsets/clang/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-shared/toolsets/clang/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-shared/toolsets/clang/foo.cpp.o
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/intermediates/toolset-clang-shared/toolsets/clang/foo.cpp.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/bin/toolset-clang-shared.so
test-check-file ${BASH_SOURCE}:${LINENO} out/clang/debug/lib/libtoolset-clang-shared.so

#out=`ldd out/clang/debug/bin/toolset-clang-shared.so`

