# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/foo.txt

out=`cat $TOP/out/foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
