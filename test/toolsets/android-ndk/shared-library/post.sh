# -*- bash -*-
test-check-file ${BASH_SOURCE}:${LINENO} out/android-ndk/debug/intermediates/android_native_app_glue/__android/android_native_app_glue.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/android-ndk/debug/intermediates/native-activity/na.c.o
test-check-file ${BASH_SOURCE}:${LINENO} out/android-ndk/debug/intermediates/native-activity/na.c.o.d
test-check-file ${BASH_SOURCE}:${LINENO} out/android-ndk/debug/lib/libandroid_native_app_glue.a
test-check-file ${BASH_SOURCE}:${LINENO} out/android-ndk/debug/bin/native-activity.so

out=`file out/android-ndk/debug/bin/native-activity.so`
test-check-value-contains ${BASH_SOURCE}:${LINENO} "$out" "ARM"

#smart -C $TOP ndk-libs && {
smart ndk-libs && {
    test-check-file ${BASH_SOURCE}:${LINENO} libs/armeabi/libnative-activity.so
} || {
    echo ${BASH_SOURCE}:${LINENO} "failed 'make ndk-libs'"
}
