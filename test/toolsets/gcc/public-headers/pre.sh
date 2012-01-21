# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../features/foo.h
test-check-file ${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../features/bar.h
