# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/foo.txt
test-check-file ${BASH_SOURCE}:${LINENO} out/foo.in

out=`test-readfile out/foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
