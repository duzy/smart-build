# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/go/debug/intermediates/toolset-go-command2/_go_.6
test-check-file ${BASH_SOURCE}:${LINENO} out/go/debug/bin/toolset-go-command2$EXE

out=`out/go/debug/bin/toolset-go-command2$EXE`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "Hello, Go! (29)"
