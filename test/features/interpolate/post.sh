# -*- bash -*-
test-check-file $TOP/${BASH_SOURCE}:${LINENO} out/none/debug/temp/features-interpolate.txt

out=`test-readfile out/none/debug/temp/features-interpolate.txt`
test-check-value $TOP/${BASH_SOURCE}:${LINENO} "$out" "-- { foo } == { bar } --"
