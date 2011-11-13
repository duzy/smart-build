# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/cweave.w.tex
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/cweave.w.idx
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/toolsets/common/cweave.w.scn
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_DOC/cweave.w.pdf
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/toolset-common-cweave
