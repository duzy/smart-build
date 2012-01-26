#
#

this.dir := $(call sm-this-dir)

## Replace NDK's build scripts: 
# CLEAR_VARS                := $(BUILD_SYSTEM)/clear-vars.mk
# BUILD_HOST_EXECUTABLE     := $(this.dir)/fake-build-host-executable.mk
# BUILD_HOST_STATIC_LIBRARY := $(this.dir)/fake-build-host-static.mk
# BUILD_STATIC_LIBRARY      := $(this.dir)/fake-build-static.mk
# BUILD_SHARED_LIBRARY      := $(this.dir)/fake-build-shared.mk
# BUILD_EXECUTABLE          := $(this.dir)/fake-build-executable.mk
# PREBUILT_SHARED_LIBRARY   := $(this.dir)/fake-prebuilt-shared.mk
# PREBUILT_STATIC_LIBRARY   := $(this.dir)/fake-prebuilt-static.mk
CLEAR_VARS                := $(BUILD_SYSTEM)/clear-vars.mk
BUILD_HOST_EXECUTABLE     := $(BUILD_SYSTEM)/build-host-executable.mk
BUILD_HOST_STATIC_LIBRARY := $(BUILD_SYSTEM)/build-host-static-library.mk
BUILD_STATIC_LIBRARY      := $(BUILD_SYSTEM)/build-static-library.mk
BUILD_SHARED_LIBRARY      := $(BUILD_SYSTEM)/build-shared-library.mk
BUILD_EXECUTABLE          := $(BUILD_SYSTEM)/build-executable.mk
PREBUILT_SHARED_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-shared-library.mk
PREBUILT_STATIC_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-static-library.mk

## some NDK environment checks
$(call sm-check-defined, import-init)
$(call sm-check-defined, import-add-path)
$(call sm-check-defined, import-add-path-optional)

################################################## setup imports
## see setup-imports.mk for these:
NDK_MODULE_PATH := $(strip $(NDK_MODULE_PATH))
ifdef NDK_MODULE_PATH
  ifneq ($(words $(NDK_MODULE_PATH)),1)
    $(call __ndk_info,ERROR: You NDK_MODULE_PATH variable contains spaces)
    $(call __ndk_info,Please fix the error and start again.)
    $(call __ndk_error,Aborting)
  endif
endif

$(call import-init)
$(foreach sm.temp._path, $(subst $(HOST_DIRSEP),$(space),$(NDK_MODULE_PATH)),\
   $(call import-add-path,$(sm.temp._path))\
 )
$(call import-add-path-optional,$(NDK_ROOT)/sources)
$(call import-add-path-optional,$(NDK_ROOT)/../development/ndk/sources)
################################################## end setup imports

define android-ndk-import
$(import-module)\
$(eval \
  ifndef __ndk_modules
    $$(error smart: incompatible Android NDK, __ndk_modules is empty)
  endif #__ndk_modules
  sm.temp._ndk_m := $(lastword $(__ndk_modules))
 )\
$(eval \
  ifndef sm.temp._ndk_m
    $$(error smart: module is undefined)
  endif #sm.temp._ndk_m
  sm.temp._ndk_m := __ndk_modules.$(sm.temp._ndk_m)
 )\
$(eval \
  sm.temp._t_STATIC_LIBRARY := static
  sm.temp._t_SHARED_LIBRARY := shared
  sm._this := sm.module.$($(sm.temp._ndk_m).MODULE)
 )\
$(eval \
  $(sm._this).toolset := android-ndk
  $(sm._this).toolset.args := $(sm.temp._t_$($(sm.temp._ndk_m).MODULE_CLASS))
  $(sm._this).type := $(sm.temp._t_$($(sm.temp._ndk_m).MODULE_CLASS))
  $(sm._this).name := $($(sm.temp._ndk_m).MODULE)
  $(sm._this).suffix := $(suffix $($(sm.temp._ndk_m).MODULE_FILENAME))
  $(sm._this).prefix := #$($(sm.temp._ndk_m).PATH:$(sm.top)/%=%)
  $(sm._this).dir := $($(sm.temp._ndk_m).PATH)
  $(sm._this).dirs :=
  $(sm._this).makefile := $($(sm.temp._ndk_m).MAKEFILE)
  $(sm._this).gen_deps :=
  $(sm._this).includes := $(TARGET_C_INCLUDES)
  $(sm._this).compile.flags := $(sm.tool.android-ndk.flags.compile.variant.$(sm.config.variant))
  $(sm._this).compile.flags += -DANDROID $(TARGET_CFLAGS)
  $(sm._this).link.flags := $(sm.tool.android-ndk.flags.link.variant.$(sm.config.variant))
  $(sm._this).link.flags += $(TARGET_LD_FLAGS)
  $(sm._this).export.defines := $($(sm.temp._ndk_m).EXPORT_CPPFLAGS)
  $(sm._this).export.includes := $($(sm.temp._ndk_m).EXPORT_C_INCLUDES)
  $(sm._this).export.compile.flags := $($(sm.temp._ndk_m).EXPORT_CFLAGS)
  $(sm._this).export.link.flags :=
  $(sm._this).export.libs := $($(sm.temp._ndk_m).MODULE) $($(sm.temp._ndk_m).EXPORT_LDLIBS)
  $(sm._this).export.libdirs := $(sm.out.lib)
  $(sm._this).sources := $($(sm.temp._ndk_m).SRC_FILES)
  $(sm._this).verbose :=

  $$(call sm.tool.android-ndk.compile-pattern-rules, $$($(sm._this).name))
  include $(sm.dir.buildsys)/rules.mk

  sm.this.depends += goal-$($(sm.temp._ndk_m).MODULE)
  sm.goals += goal-$($(sm.temp._ndk_m).MODULE)
 )
endef #android-ndk-import
