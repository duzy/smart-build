# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/module-of-type-static/foo.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/module-of-type-static/foo.c.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_LIB/libmodule-of-type-static.a
