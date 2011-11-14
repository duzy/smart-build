# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/test/toolchains/android-ndk/na.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_INTERS/test/toolchains/android-ndk/na.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $OUT_BIN/native-activity.so

out=`file $OUT_BIN/native-activity.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "ARM"
