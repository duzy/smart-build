# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.cpp.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.cpp.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.go.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/foo.go.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/main.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/features/mixture-sources/main.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/mixture-sources

