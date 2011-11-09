# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/debug/temp/features-interpolate.txt

out=`cat $TOP/out/debug/temp/features-interpolate.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-- { foo } == { bar } --"
