# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/debug/module-of-type-depends-foo.txt

out=`cat $TOP/out/debug/module-of-type-depends-foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
