# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/debug/temp/features-interpolate.txt

out=`test-readfile $TOP/out/debug/temp/features-interpolate.txt`
test-check-value ${BASH_SOURCE}:${LINENO} "$out" "-- { foo } == { bar } --"
