#
#	Copyright(c) 2009-2011, by Zhan Xin-ming <code@duzy.info>
#

##
##  sm.tool.android-ndk
##

$(call sm-check-origin, sm.tool.android-ndk, undefined)

this.dir := $(call sm-this-dir)

ANDROID_NDK_PATH := $(wildcard ~/open/android-ndk-r6)

sm.tool.android-ndk := true
sm.tool.android-ndk.path := $(ANDROID_NDK_PATH)

################################################## Android NDK setup
## The variable "sm.tool.android-ndk.path" must be defined first!!
define sm.tool.android-ndk._setup
$(eval \
  this.dir.saved := $(this.dir)
  include $(this.dir)/android-ndk/init.mk
  include $(this.dir)/android-ndk/imports.mk
 )\
$(eval this.dir := $(this.dir.saved))
endef #sm.tool.android-ndk._setup

$(sm.tool.android-ndk._setup)
################################################## end Android NDK setup

sm.tool.android-ndk.langs := c++ c asm

sm.tool.android-ndk.cmd.c := $(TOOLCHAIN_PREFIX)gcc
sm.tool.android-ndk.cmd.c++ := $(TOOLCHAIN_PREFIX)g++
sm.tool.android-ndk.cmd.asm := $(TOOLCHAIN_PREFIX)gcc
sm.tool.android-ndk.cmd.ar := $(TOOLCHAIN_PREFIX)ar

sm.tool.android-ndk.suffix.c := .c
sm.tool.android-ndk.suffix.c++ := .cpp .c++ .cc .CC .C
sm.tool.android-ndk.suffix.asm := .s .S

sm.tool.android-ndk.suffix.intermediate.c := .o
sm.tool.android-ndk.suffix.intermediate.c++ := .o
sm.tool.android-ndk.suffix.intermediate.asm := .o

sm.tool.android-ndk.suffix.target.static.win32 = $(error untested for win32)
sm.tool.android-ndk.suffix.target.shared.win32 = $(error untested for win32)
sm.tool.android-ndk.suffix.target.exe.win32 = $(error untested for win32)
sm.tool.android-ndk.suffix.target.t.win32 = $(error untested for win32)
sm.tool.android-ndk.suffix.target.depends.win32 = $(error untested for win32)
sm.tool.android-ndk.suffix.target.static.linux := .a
sm.tool.android-ndk.suffix.target.shared.linux := .so
sm.tool.android-ndk.suffix.target.exe.linux :=
sm.tool.android-ndk.suffix.target.t.linux := .test
sm.tool.android-ndk.suffix.target.depends.linux :=

######################################################################

# define sm.tool.android-ndk.compile.c
# define sm.tool.android-ndk.compile.c++
# define sm.tool.android-ndk.compile.asm

# define sm.tool.android-ndk.dependency.c
# define sm.tool.android-ndk.dependency.c++
# define sm.tool.android-ndk.dependency.asm

##
define sm.tool.android-ndk.link
$(eval \
  PRIVATE_OBJECTS := $(sm.args.sources)
  PRIVATE_WHOLE_STATIC_LIBRARIES :=
  PRIVATE_STATIC_LIBRARIES :=
  PRIVATE_SHARED_LIBRARIES :=
  PRIVATE_LDFLAGS := $(sm.args.flags.0)
  PRIVATE_LDLIBS := $(sm.args.flags.1)
  @ := $(sm.args.target)
  ^ := $(sm.args.sources)
  < := $(firstword $(sm.args.sources))

  sm.temp._class := executable
  ifneq ($(filter -shared,$(sm.args.flags.0)),)
    sm.temp._class := shared-library
    PRIVATE_LDFLAGS += -Wl,-no-undefined
  endif # is shared library
 )$(cmd-build-$(sm.temp._class))
endef #sm.tool.android-ndk.link
sm.tool.android-ndk.link.c   = $(sm.tool.android-ndk.link)
sm.tool.android-ndk.link.c++ = $(sm.tool.android-ndk.link)
sm.tool.android-ndk.link.asm = $(sm.tool.android-ndk.link)

define sm.tool.android-ndk.archive
$(eval \
  PRIVATE_OBJECTS := $(sm.args.sources)
  @ := $(sm.args.target)
  ^ := $(sm.args.sources)
  < := $(firstword $(sm.args.sources))
 )$(cmd-build-static-library)
endef #sm.tool.android-ndk.archive
sm.tool.android-ndk.archive.c   = $(sm.tool.android-ndk.archive)
sm.tool.android-ndk.archive.c++ = $(sm.tool.android-ndk.archive)
sm.tool.android-ndk.archive.asm = $(sm.tool.android-ndk.archive)

######################################################################
# Options
sm.tool.android-ndk.includes := $(TARGET_C_INCLUDES)
sm.tool.android-ndk.compile.flags := -DANDROID $(TARGET_CFLAGS)
sm.tool.android-ndk.link.flags := $(TARGET_LD_FLAGS)
sm.tool.android-ndk.libdirs := 
sm.tool.android-ndk.libs :=
