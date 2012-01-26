# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/go/debug/intermediates/toolset-go-command/_go_.6
test-check-file ${BASH_SOURCE}:${LINENO} out/go/debug/bin/toolset-go-command$EXE

out=`out/go/debug/bin/toolset-go-command$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "Hello, Go!"
