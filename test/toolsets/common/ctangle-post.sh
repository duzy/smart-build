# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/ctangle.w.tex
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/ctangle.w.idx
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/ctangle.w.scn
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/common.w.tex
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/common.w.idx
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/common.w.scn
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_DOC/ctangle.w.pdf
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_DOC/common.w.pdf
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_DOC/cwebman.pdf
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/toolset-common-ctangle
