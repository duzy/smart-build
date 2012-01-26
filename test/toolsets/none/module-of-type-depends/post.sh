# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/none/debug/module-of-type-depends-foo.txt

out=`test-readfile out/none/debug/module-of-type-depends-foo.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "foo"
