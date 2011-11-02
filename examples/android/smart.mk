#
#
$(call sm-new-module, native-activity, shared, android-ndk)
#$(call sm-use, android_native_app_glue)

sm.this.verbose := true
sm.this.sources := na.c
sm.this.libs := log android EGL GLESv1_CM

$(sm-build-this)
