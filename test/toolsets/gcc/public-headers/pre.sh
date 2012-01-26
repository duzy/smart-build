# -*- bash -*-
test-check-file $TOP/${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../features/foo.h
test-check-file $TOP/${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../features/bar.h
