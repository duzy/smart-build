# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-static/toolsets/clang/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-static/toolsets/clang/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-static/toolsets/clang/foo.cpp.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/intermediates/toolset-clang-static/toolsets/clang/foo.cpp.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/clang/debug/lib/libtoolset-clang-static.a

