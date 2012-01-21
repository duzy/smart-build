# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/go/debug/intermediates/toolset-go-command2/_go_.6
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/go/debug/bin/toolset-go-command2$EXE

out=`$TOP/out/go/debug/bin/toolset-go-command2$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "Hello, Go! (16)"
