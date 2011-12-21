# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/foobar.c
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/foo.c
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/bar.c
