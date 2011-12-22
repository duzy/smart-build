#
#
NDK_ROOT := $(sm.tool.android-ndk.path)
NDK_ROOT := $(NDK_ROOT:%/=%)
ifeq ($(wildcard $(NDK_ROOT)/build/core/init.mk),)
  $(error invalid Android NDK path "$(NDK_ROOT)")
else
  include $(NDK_ROOT)/build/core/init.mk
endif

##
## References:
##	1. $(NDK_ROOT)/build/core/setup-app.mk
##	2. $(NDK_ROOT)/build/core/setup-abi.mk
##	3. $(NDK_ROOT)/build/core/setup-toolchain.mk
##	4. $(NDK_ROOT)/build/core/build-binary.mk
##
ifdef sm.tool.android-ndk.args
  TARGET_PLATFORM := $(filter PLATFORM=%,$(sm.tool.android-ndk.args))
  TARGET_PLATFORM := $(patsubst PLATFORM=%,%,$(TARGET_PLATFORM))
  ifndef TARGET_PLATFORM
    TARGET_PLATFORM := $(filter android-%,$(sm.tool.android-ndk.args))
    TARGET_PLATFORM := $(lastword $(TARGET_PLATFORM))
  endif #TARGET_PLATFORM

  TARGET_ARCH_ABI := $(filter ABI=%,$(sm.tool.android-ndk.args))
  TARGET_ARCH_ABI := $(patsubst ABI=%,%,$(TARGET_ARCH_ABI))
  ifndef TARGET_ARCH_ABI
    TARGET_ARCH_ABI := $(filter armeabi% x86,$(sm.tool.android-ndk.args))
    TARGET_ARCH_ABI := $(lastword $(TARGET_ARCH_ABI))
  endif #TARGET_ARCH_ABI
endif #sm.tool.android-ndk.args

ifndef TARGET_PLATFORM
  TARGET_PLATFORM := android-$(NDK_MAX_PLATFORM_LEVEL)
endif #TARGET_PLATFORM

ifndef TARGET_ARCH_ABI
  TARGET_ARCH_ABI := armeabi
endif #TARGET_ARCH_ABI

$(info smart: Android NDK: Build for $(TARGET_PLATFORM) using ABI "$(TARGET_ARCH_ABI)")

##
## See setup-abi.mk for these:
TARGET_ARCH_for_armeabi     := arm
TARGET_ARCH_for_armeabi-v7a := arm
TARGET_ARCH_for_x86         := x86
TARGET_ARCH := $(TARGET_ARCH_for_$(TARGET_ARCH_ABI))

##
## Choose TARGET_TOOLCHAIN, same algorithm as in setup-toolchain.mk
ifndef NDK_TOOLCHAIN
   TARGET_TOOLCHAIN_LIST := $(strip $(sort $(NDK_ABI.$(TARGET_ARCH_ABI).toolchains)))
    ifndef TARGET_TOOLCHAIN_LIST
        $(call __ndk_info,There is no toolchain that supports the $(TARGET_ARCH_ABI) ABI.)
        $(call __ndk_info,Please modify the APP_ABI definition in $(NDK_APP_APPLICATION_MK) to use)
        $(call __ndk_info,a set of the following values: $(NDK_ALL_ABIS))
        $(call __ndk_error,Aborting)
    endif
    # Select the last toolchain from the sorted list.
    # For now, this is enough to select armeabi-4.4.0 by default for ARM
    TARGET_TOOLCHAIN := $(lastword $(TARGET_TOOLCHAIN_LIST))
    $(call ndk_log,Using target toolchain '$(TARGET_TOOLCHAIN)' for '$(TARGET_ARCH_ABI)' ABI)
else # NDK_TOOLCHAIN is not empty
    TARGET_TOOLCHAIN_LIST := $(strip $(filter $(NDK_TOOLCHAIN),$(NDK_ABI.$(TARGET_ARCH_ABI).toolchains)))
    ifndef TARGET_TOOLCHAIN_LIST
        $(call __ndk_info,The selected toolchain ($(NDK_TOOLCHAIN)) does not support the $(TARGET_ARCH_ABI) ABI.)
        $(call __ndk_info,Please modify the APP_ABI definition in $(NDK_APP_APPLICATION_MK) to use)
        $(call __ndk_info,a set of the following values: $(NDK_TOOLCHAIN.$(NDK_TOOLCHAIN).abis))
        $(call __ndk_info,Or change your NDK_TOOLCHAIN definition.)
        $(call __ndk_error,Aborting)
    endif
    TARGET_TOOLCHAIN := $(NDK_TOOLCHAIN)
endif

TARGET_ABI := $(TARGET_PLATFORM)-$(TARGET_ARCH_ABI)

SYSROOT := $(NDK_PLATFORMS_ROOT)/$(TARGET_PLATFORM)/arch-$(TARGET_ARCH)
TARGET_CRTBEGIN_STATIC_O  := $(SYSROOT)/usr/lib/crtbegin_static.o
TARGET_CRTBEGIN_DYNAMIC_O := $(SYSROOT)/usr/lib/crtbegin_dynamic.o
TARGET_CRTEND_O           := $(SYSROOT)/usr/lib/crtend_android.o

# crtbegin_so.o and crtend_so.o are not available for all platforms
TARGET_CRTBEGIN_SO_O := $(strip $(wildcard $(SYSROOT)/usr/lib/crtbegin_so.o))
TARGET_CRTEND_SO_O   := $(strip $(wildcard $(SYSROOT)/usr/lib/crtend_so.o))

TARGET_PREBUILT_SHARED_LIBRARIES :=

TOOLCHAIN_NAME   := $(TARGET_TOOLCHAIN)
TOOLCHAIN_ROOT   := $(NDK_ROOT)/toolchains/$(TOOLCHAIN_NAME)
TOOLCHAIN_PREBUILT_ROOT := $(TOOLCHAIN_ROOT)/prebuilt/$(HOST_TAG)

TOOLCHAIN_PREFIX := $(call merge,-,$(call chop,$(call split,-,$(TOOLCHAIN_NAME))))-
TOOLCHAIN_PREFIX := $(TOOLCHAIN_PREBUILT_ROOT)/bin/$(TOOLCHAIN_PREFIX)

include $(BUILD_SYSTEM)/default-build-commands.mk
include $(NDK_TOOLCHAIN.$(TARGET_TOOLCHAIN).setup)
