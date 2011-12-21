# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/none/debug/module-of-type-depends-foo.txt

out=`test-readfile $TOP/out/none/debug/module-of-type-depends-foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
