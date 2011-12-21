# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/foo.c
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/foo.go
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/foo.cpp
