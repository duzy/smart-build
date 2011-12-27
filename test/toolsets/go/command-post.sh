# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/go/debug/intermediates/toolset-go-command/_go_.6
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/go/debug/bin/toolset-go-command$EXE

out=`$TOP/out/go/debug/bin/toolset-go-command$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "Hello, Go!"
