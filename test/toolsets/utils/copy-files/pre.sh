# -*- bash -*-
test-check-file $TOP/${BASH_SOURCE}:${LINENO} $(dirname $BASH_SOURCE)/foo.txt
test-check-file $TOP/${BASH_SOURCE}:${LINENO} $(dirname $BASH_SOURCE)/foo.in

