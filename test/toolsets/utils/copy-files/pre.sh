# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $(dirname $BASH_SOURCE)/foo.txt
test-check-file ${BASH_SOURCE}:${LINENO} $(dirname $BASH_SOURCE)/foo.in

