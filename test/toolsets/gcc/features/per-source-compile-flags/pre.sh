# -*- bash -*-
test-check-file $TOP/${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../foobar.c
test-check-file $TOP/${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../foo.c
test-check-file $TOP/${BASH_SOURCE}:${LINENO} `dirname $BASH_SOURCE`/../bar.c
