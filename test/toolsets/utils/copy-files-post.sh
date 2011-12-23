# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/foo.txt
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/foo.in

out=`test-readfile $TOP/out/foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
