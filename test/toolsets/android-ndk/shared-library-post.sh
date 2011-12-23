# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/intermediates/native-activity/toolsets/android-ndk/na.c.o
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/intermediates/native-activity/toolsets/android-ndk/na.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/bin/native-activity.so
test-check-file ${BASH_SOURCE}:${LINENO} $TOP/out/android-ndk/debug/lib/libandroid_native_app_glue.a

out=`file $TOP/out/android-ndk/debug/bin/native-activity.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "ARM"

make -f $TOP/main.mk ndk-libs && {
    test-check-file ${BASH_SOURCE}:${LINENO} $TOP/libs/armeabi/libnative-activity.so
} || {
    echo ${BASH_SOURCE}:${LINENO} "failed 'make ndk-libs'"
}
