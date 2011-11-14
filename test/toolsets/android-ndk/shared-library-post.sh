# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/intermediates/toolsets/android-ndk/native-activity/na.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/intermediates/toolsets/android-ndk/native-activity/na.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/bin/native-activity.so

out=`file $TOP/out/android-ndk/debug/bin/native-activity.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "ARM"
