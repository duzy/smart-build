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

define android-ndk-import-module
$(import-module)\
$(eval \
  ifndef __ndk_modules
    $$(error smart: incompatible Android NDK, __ndk_modules is empty)
  endif #__ndk_modules
  sm.temp._m := $(lastword $(__ndk_modules))
 )\
$(eval \
  ifndef sm.temp._m
    $$(error smart: module is undefined)
  endif #sm.temp._m
  sm.temp._m := __ndk_modules.$(sm.temp._m)
 )\
$(eval \
  sm.temp._sm := sm.module.$($(sm.temp._m).MODULE)
  sm.temp._t_STATIC_LIBRARY := static
  sm.temp._t_SHARED_LIBRARY := shared
 )\
$(eval \
  sm.global.modules += $($(sm.temp._m).MODULE)
  sm.global.goals += goal-$($(sm.temp._m).MODULE)

  $(sm.temp._sm).toolset := android-ndk
  $(sm.temp._sm).type := $(sm.temp._t_$($(sm.temp._m).MODULE_CLASS))
  $(sm.temp._sm).name := $($(sm.temp._m).MODULE)
  $(sm.temp._sm).suffix := $(suffix $($(sm.temp._m).MODULE_FILENAME))
  $(sm.temp._sm).dir := $($(sm.temp._m).PATH)
  $(sm.temp._sm).dirs :=
  $(sm.temp._sm).makefile := $($(sm.temp._m).MAKEFILE)
  $(sm.temp._sm).gen_deps :=
  $(sm.temp._sm).export.defines := $($(sm.temp._m).EXPORT_CPPFLAGS)
  $(sm.temp._sm).export.includes := $($(sm.temp._m).EXPORT_C_INCLUDES)
  $(sm.temp._sm).export.compile.flags := $($(sm.temp._m).EXPORT_CFLAGS)
  $(sm.temp._sm).export.link.flags :=
  $(sm.temp._sm).export.libs := $($(sm.temp._m).MODULE) $($(sm.temp._m).EXPORT_LDLIBS)
  $(sm.temp._sm).export.libdirs := $(sm.out.lib)
  $(sm.temp._sm).sources := $($(sm.temp._m).SRC_FILES)
  $(sm.temp._sm).verbose :=

  sm._this := sm.module.$($(sm.temp._m).MODULE)
  include $(sm.dir.buildsys)/rules.mk

  sm.this.depends += goal-$($(sm.temp._m).MODULE)
 )
endef #android-ndk-import-module

# $(eval \
#   $(foreach _l,$(modules-LOCALS),$$(info $(_l): $$($(sm.temp._m).$(_l))))
#   $$(info vars: $$(filter $(sm.temp._m).%, $$(.VARIABLES)))
#  )\
