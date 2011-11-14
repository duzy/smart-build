#
#
$(call test-check-undefined,NDK_ROOT)
$(call test-check-undefined,TOOLCHAIN_PREFIX)
#$(call sm-new-module, native-activity, shared, android-ndk:armeabi:android-9)
#$(call sm-new-module, native-activity, shared, android-ndk armeabi android-9)
$(call sm-new-module, native-activity, shared, android-ndk ABI=armeabi PLATFORM=android-9)

## TODO: get rid of the usage of android-ndk-import-module

$(call test-check-undefined,sm.module.android_native_app_glue.dir)
$(call test-check-undefined,sm.module.android_native_app_glue.name)
$(call test-check-undefined,sm.module.android_native_app_glue.type)
$(call test-check-flavor,android-ndk-import-module,recursive)
$(call android-ndk-import-module, android/native_app_glue)
$(call test-check-value-pat-of,sm.module.android_native_app_glue.dir,%/sources/android/native_app_glue)
$(call test-check-value-of,sm.module.android_native_app_glue.type,static)
$(call test-check-value-of,sm.module.android_native_app_glue.name,android_native_app_glue)
$(call test-check-value-pat-of,sm.module.android_native_app_glue.export.includes,%/sources/android/native_app_glue)
$(call test-check-value,$(filter android_native_app_glue,$(sm.module.android_native_app_glue.export.libs)),android_native_app_glue)

$(call sm-use, android_native_app_glue)
$(call test-check-value,$(sm.module.native-activity.using_list),android_native_app_glue)

sm.this.verbose :=
sm.this.sources := na.c
sm.this.libs := log android EGL GLESv1_CM

$(sm-build-this)
$(call test-check-defined,NDK_ROOT)
$(call test-check-defined,TOOLCHAIN_PREFIX)

# define dump
# $(info $(strip $1): $($(strip $1)))
# endef #dump
# $(call dump, TOOLCHAIN_PREFIX)
# $(call dump, NDK_ROOT)
# $(call dump, NDK_PLATFORMS_ROOT)
# $(call dump, NDK_TOOLCHAIN)
# $(call dump, NDK_TOOLCHAIN_PREFIX)
# $(call dump, NDK_ALL_PLATFORMS)
# $(call dump, NDK_ALL_PLATFORM_LEVELS)
# $(call dump, NDK_MAX_PLATFORM_LEVEL)
# $(call dump, NDK_ALL_ABIS)
# $(foreach abi, $(NDK_ALL_ABIS), $(call dump,NDK_ABI.$(abi).toolchains))
# $(call dump, NDK_ALL_TOOLCHAINS)
# $(foreach tc, $(NDK_ALL_TOOLCHAINS), $(call dump,NDK_TOOLCHAIN.$(tc).abis))
# $(foreach tc, $(NDK_ALL_TOOLCHAINS), $(call dump,NDK_TOOLCHAIN.$(tc).setup))
# $(info using_list: $(sm.module.native-activity.using_list))
# $(info used.includes: $(sm.module.native-activity.used.includes))
# $(info used.libs: $(sm.module.native-activity.used.libs))
