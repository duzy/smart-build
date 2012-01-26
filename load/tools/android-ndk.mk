#
#	Copyright(c) 2009, 2010, 2011, 2012 by Zhan Xin-ming <code@duzy.info>
#

##
##  sm.tool.android-ndk
##

$(call sm-check-origin, sm.tool.android-ndk, undefined)

$(call sm.fun.new-toolset, android-ndk,\
    c++: .o: .cpp .c++ .cc .CC .C\
    c:   .o: .c\
    asm: .o: .s .S\
 )

android.tool.dir := $(call sm-this-dir)

#ANDROID_NDK_PATH := $(wildcard ~/open/android-ndk-r6)
#ANDROID_NDK_PATH := $(wildcard ~/open/android-ndk-r6b)
ANDROID_NDK_PATH := $(wildcard ~/open/android-ndk-r7)

sm.tool.android-ndk := true
sm.tool.android-ndk.path := $(ANDROID_NDK_PATH)

################################################## Android NDK setup
## The variable "sm.tool.android-ndk.path" must be defined first!!
sm.tool.android-ndk.args :=
#include $(android.tool.dir)/android-ndk/init.mk
#include $(android.tool.dir)/android-ndk/imports.mk
################################################## Android NDK setup finished

sm.tool.android-ndk.suffix.target.win32.static = $(error untested for win32)
sm.tool.android-ndk.suffix.target.win32.shared = $(error untested for win32)
sm.tool.android-ndk.suffix.target.win32.exe = $(error untested for win32)
sm.tool.android-ndk.suffix.target.win32.t = $(error untested for win32)
sm.tool.android-ndk.suffix.target.linux.static := .a
sm.tool.android-ndk.suffix.target.linux.shared := .so
sm.tool.android-ndk.suffix.target.linux.exe :=
sm.tool.android-ndk.suffix.target.linux.t := .test

sm.tool.android-ndk.flags.compile.variant.debug := -g -ggdb
sm.tool.android-ndk.flags.compile.variant.release := -O3
sm.tool.android-ndk.flags.link.variant.debug := -g -ggdb
sm.tool.android-ndk.flags.link.variant.release := -O3

######################################################################

##
## Compile Commands
define sm.tool.android-ndk.command.compile.c
$(TOOLCHAIN_PREFIX)gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.android-ndk.command.compile.c

define sm.tool.android-ndk.command.compile.c.d
$(TOOLCHAIN_PREFIX)gcc -MM -MT $@ $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.android-ndk.command.compile.c.d

define sm.tool.android-ndk.command.compile.c++
$(TOOLCHAIN_PREFIX)g++ $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.android-ndk.command.compile.c++

define sm.tool.android-ndk.command.compile.c++.d
$(TOOLCHAIN_PREFIX)g++ -MM -MT $@ $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.android-ndk.command.compile.c++.d

define sm.tool.android-ndk.command.compile.go
$(TOOLCHAIN_PREFIX)gccgo $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.android-ndk.command.compile.go

define sm.tool.android-ndk.command.compile.go.d
$(TOOLCHAIN_PREFIX)gccgo -MM -MT $@ $(sm.var.flags) $(sm.var.source) > $@
endef #sm.tool.android-ndk.command.compile.go.d

define sm.tool.android-ndk.command.compile.asm
$(TOOLCHAIN_PREFIX)gcc $(sm.var.flags) -o $@ -c $(sm.var.source)
endef #sm.tool.android-ndk.command.compile.asm

define sm.tool.android-ndk.compile
$(eval #
  ifndef sm.tool.android-ndk.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
  ifndef sm.tool.android-ndk.command.compile.$(sm.tool.android-ndk.lang.$(suffix $*))
    $$(error smart: "sm.tool.android-ndk.command.compile.$(sm.tool.gcc.lang.$(suffix $*))" undefined)
  endif
 )$(sm.tool.android-ndk.command.compile.$(sm.tool.android-ndk.lang.$(suffix $*)))
endef #sm.tool.android-ndk.compile

define sm.tool.android-ndk.compile.d
$(eval #
  ifndef sm.tool.android-ndk.lang.$(suffix $*)
    $$(error smart: "smart: gcc2: unknown source: $(suffix $*)")
  endif
 )$(sm.tool.android-ndk.command.compile.$(sm.tool.android-ndk.lang.$(suffix $*)).d)
endef #sm.tool.android-ndk.compile.d

######################################################################

##
##
define sm.tool.android-ndk.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 )\
$(eval \
   sm.tool.android-ndk.args := $(sm.this.toolset.args)
   include $(android.tool.dir)/android-ndk/init.mk
   include $(android.tool.dir)/android-ndk/imports.mk
 )\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.android-ndk.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.includes := $(TARGET_C_INCLUDES)
   sm.this.compile.flags := $(sm.tool.android-ndk.flags.compile.variant.$(sm.config.variant))
   sm.this.compile.flags += -DANDROID $(TARGET_CFLAGS)
   sm.this.link.flags := $(sm.tool.android-ndk.flags.link.variant.$(sm.config.variant))
   sm.this.link.flags += $(TARGET_LD_FLAGS)
   sm.this.libdirs :=
   sm.this.libs :=
 )$(call sm.tool.android-ndk.compile-pattern-rules,$(sm.this.name))
endef #sm.tool.android-ndk.config-module

define sm.tool.android-ndk.compile-pattern-rules
$(eval #
  sm.temp._name := $(strip $1)
 )\
$(eval #
  $(sm.out.inter)/$(sm.temp._name)/%.o:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$$(or $$(sm.tool.android-ndk.compile),echo "error:0: No command for \"$$@\"" && false)

  $(sm.out.inter)/$(sm.temp._name)/%.o.d:
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	@[[ -f $$(sm.var.source) ]] || (echo "smart:0: no source \"$$(sm.var.source)\"" && false)
	$$(or $$(sm.tool.android-ndk.compile.d),echo "smart:0:info: no command for \"$$@\"")\
	|| (echo "$(sm.this.makefile):0: \"$$(sm.var.source)\" absent" && rm -f $$@ && false)
 )
endef #sm.tool.android-ndk.compile-pattern-rules

define sm.tool.android-ndk.args.types
$(filter-out ABI=% PLATFORM=%, $($(sm._this).toolset.args))
endef #sm.tool.android-ndk.args.types

sm.tool.android-ndk.transform.headers := h
sm.tool.android-ndk.transform.static  := bin
sm.tool.android-ndk.transform.shared  := bin
sm.tool.android-ndk.transform.exe     := bin

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.android-ndk.transform-single-source
$(foreach _, $(sm.tool.android-ndk.args.types), \
  $(call sm.tool.android-ndk.transform-source-$(sm.tool.android-ndk.transform.$_)))
endef #sm.tool.android-ndk.transform-single-source

##
##
define sm.tool.android-ndk.transform-source-h
$(info TODO: android-ndk: header: $(sm.var.source.computed))
endef #sm.tool.android-ndk.transform-source-h

##
##
define sm.tool.android-ndk.transform-source-bin
$(call sm-check-not-empty, \
    sm._this $(sm._this).name \
    sm.var.source \
    sm.var.source.lang \
    sm.var.source.suffix \
 , android-ndk: strange parameters for "$(sm.var.source)" of "$($(sm._this).name)")\
$(eval #
  sm.var.flags :=
  sm.var.flags += $($(sm._this).used.defines)
  sm.var.flags += $($(sm._this).used.defines.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).used.compile.flags)
  sm.var.flags += $($(sm._this).used.compile.flags.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).defines)
  sm.var.flags += $($(sm._this).defines.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).compile.flags)
  sm.var.flags += $($(sm._this).compile.flags.$(sm.var.source.lang))

  $$(call sm.fun.append-items-with-fix, sm.var.flags, \
         $($(sm._this).includes)\
         $($(sm._this).used.includes)\
         $($(sm.var.tool).includes)\
        , -I, , -%)

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)
 )\
$(eval #
  $(sm._this).intermediates += $(sm.var.intermediate)

  $(sm.var.intermediate): sm.var.flags := $(sm.var.flags)
  $(sm.var.intermediate): sm.var.source := $(sm.var.source.computed)
  $(sm.var.intermediate): $(sm.temp._flagsfile) $(sm.var.source.computed)

  ifeq ($(call sm-true,$($(sm._this).gen_deps)),true)
    -include $(sm.var.intermediate).d
    $(sm.var.intermediate).d: sm.var.flags := $(sm.var.flags)
    $(sm.var.intermediate).d: sm.var.source := $(sm.var.source.computed)
    $(sm.var.intermediate).d: $(sm.temp._flagsfile) $(sm.var.source.computed)
  endif
 )
endef #sm.tool.android-ndk.transform-source-bin

##
##
define sm.tool.android-ndk.transform-intermediates
$(foreach _, $(sm.tool.android-ndk.args.types), \
     $(call sm.tool.android-ndk.transform-intermediates-$(sm.tool.android-ndk.transform.$_)))
endef #sm.tool.android-ndk.transform-intermediates

##
##
define sm.tool.android-ndk.transform-intermediates-h
$(info TODO: android-ndk: header: $(sm.var.source.computed))
endef #sm.tool.android-ndk.transform-intermediates-h

##
##
define sm.tool.android-ndk.transform-intermediates-bin
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 , android-ndk: unknown language)\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.flags :=
  sm.temp._class :=
  ifeq ($($(sm._this).type),static)
    sm.temp._class := static-library
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.archive.flags)
    sm.var.flags += $($(sm._this).used.archive.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).archive.flags)
    sm.var.flags += $($(sm._this).archive.flags.$($(sm._this).lang))
  else
    sm.temp._class := executable
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.link.flags)
    sm.var.flags += $($(sm._this).used.link.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).link.flags)
    sm.var.flags += $($(sm._this).link.flags.$($(sm._this).lang))
    ifeq ($($(sm._this).type),shared)
      sm.temp._class := shared-library
      sm.var.flags := -shared $$(filter-out -shared,$$(sm.var.flags))
      sm.var.flags += -Wl,-no-undefined
    endif
  endif
  sm.var.loadlibs :=
 )\
$(call sm.fun.append-items-with-fix, sm.var.loadlibs, \
      $($(sm._this).libdirs) \
      $($(sm._this).used.libdirs)\
      $($(sm.var.tool).libdirs)\
     , -L, , -% -Wl%)\
$(call sm.fun.append-items-with-fix, sm.var.loadlibs, \
      $($(sm._this).libs) \
      $($(sm._this).used.libs)\
      $($(sm.var.tool).libs)\
     , -l, , -% -Wl% %.a %.so %.lib %.dll)\
$(call sm-remove-duplicates,sm.var.flags)\
$(call sm-remove-duplicates,sm.var.loadlibs)\
$(eval #
  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, link, $($(sm._this).link.flags.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.flags := @$$(sm.temp._flagsfile)
  endif

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.intermediates, intermediates.link, $($(sm._this).link.intermediates.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.intermediates.preq := $(sm.var.intermediates)
    sm.var.intermediates := @$$(sm.temp._flagsfile)
  else
    sm.var.intermediates.preq = $(sm.var.intermediates)
  endif

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.loadlibs, libs.link, $($(sm._this).libs.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.loadlibs := @$$(sm.temp._flagsfile)
  endif
 )\
$(eval #
  ifndef cmd-build-$$(sm.temp._class)
    $$(error android-ndk: "cmd-build-$$(sm.temp._class)" is undefined)
  endif
  $(sm._this).targets += $(sm.var.target)
  ifeq ($$(sm.temp._class),static-library)
    $(sm.var.target): PRIVATE_AR := $(TARGET_AR) $(TARGET_ARFLAGS)
    $(sm.var.target): PRIVATE_OBJECTS := $(sm.var.intermediates)
  else
    $(sm.var.target): PRIVATE_LD := $(TARGET_LD)
    $(sm.var.target): PRIVATE_LDFLAGS := $(TARGET_LDFLAGS) $(LOCAL_LDFLAGS)
    $(sm.var.target): PRIVATE_LDLIBS  := $(LOCAL_LDLIBS) $(TARGET_LDLIBS)
    $(sm.var.target): PRIVATE_LIBGCC := $(TARGET_LIBGCC)
    $(sm.var.target): PRIVATE_CXX := $(TARGET_CXX)
    $(sm.var.target): PRIVATE_CC := $(TARGET_CC)
    $(sm.var.target): PRIVATE_SYSROOT := $(SYSROOT)
    $(sm.var.target): PRIVATE_NAME := $(notdir $(sm.var.target))
    $(sm.var.target): PRIVATE_OBJECTS := $(sm.var.intermediates)
    $(sm.var.target): PRIVATE_WHOLE_STATIC_LIBRARIES :=
    $(sm.var.target): PRIVATE_STATIC_LIBRARIES :=
    $(sm.var.target): PRIVATE_SHARED_LIBRARIES :=
    $(sm.var.target): PRIVATE_LDFLAGS := $(sm.var.flags)
    $(sm.var.target): PRIVATE_LDLIBS := $(sm.var.loadlibs)
  endif
  $(sm.var.target): $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$$(cmd-build-$(sm.temp._class))
 )
endef #sm.tool.android-ndk.transform-intermediates-bin
