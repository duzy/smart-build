#
#	Copyright(c) 2009, 2010, 2011, 2012 by Zhan Xin-ming <code@duzy.info>
#

##
##  sm.tool.android-sdk
##

$(call sm-check-origin, sm.tool.android-sdk, undefined)

ANDROID_SDK_PATH := $(wildcard ~/open/android-sdk-linux_x86)

sm.tool.android-sdk := true
sm.tool.android-sdk.path := $(ANDROID_SDK_PATH)

sm.tool.android-sdk.langs := java
sm.tool.android-sdk.suffix.java := .java
sm.tool.android-sdk.suffix.intermediate.java := .class
sm.tool.android-sdk.suffix.target.win32.apk = $(error untested for win32)
sm.tool.android-sdk.suffix.target.win32.dex = $(error untested for win32)
sm.tool.android-sdk.suffix.target.linux.apk := .apk
sm.tool.android-sdk.suffix.target.linux.dex := .dex

sm.tool.android-sdk.flags.compile.variant.debug :=
sm.tool.android-sdk.flags.compile.variant.release :=
sm.tool.android-sdk.flags.link.variant.debug :=
sm.tool.android-sdk.flags.link.variant.release :=

######################################################################

##
## Compile Commands
define sm.tool.android-sdk.command.compile.java
javac $(sm.var.flags) $$$$^ $(sm.var.argfiles)
endef #sm.tool.android-sdk.command.compile.java

##
##
define sm.tool.android-sdk.command.link.java
endef #sm.tool.android-sdk.command.link.java

##
##
define sm.tool.android-sdk.command.archive
$(sm.tool.android-sdk.archive)
endef #sm.tool.android-sdk.command.archive

######################################################################

##
##
define sm.tool.android-sdk.config-module
$(call sm-check-not-empty, \
    sm.os.name \
    sm.config.variant \
 )\
$(eval \
  sm.this.platform := $(filter PLATFORM=%,$(sm.this.toolset.args))
  sm.this.platform := $$(subst PLATFORM=,,$$(sm.this.platform))
 )\
$(eval \
   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.android-sdk.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.sources := $(call sm-find-files-in,$(sm.this.dir)/src,%.java)
   sm.this.sources := $$(sm.this.sources:$(sm.this.dir)/%=%)
   sm.this.classes.path := $(sm.out)/$(sm.this.name)/classes
   sm.this.compile.flags := -cp $(sm.tool.android-sdk.path)/platforms/$(sm.this.platform)/android.jar
   sm.this.compile.flags += -sourcepath $(sm.this.dir)/src
   sm.this.compile.flags += -d $$(sm.this.classes.path)
   sm.this.link.flags :=
 )
endef #sm.tool.android-sdk.config-module

define sm.tool.android-sdk.args.types
$(filter-out -% PLATFORM=%, $($(sm._this).toolset.args))
endef #sm.tool.android-sdk.args.types

sm.tool.android-sdk.transform.apk := apk

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.android-sdk.transform-single-source
$(foreach _, $(sm.tool.android-sdk.args.types), \
  $(call sm.tool.android-sdk.transform-source-$(sm.tool.android-sdk.transform.$_)))
endef #sm.tool.android-sdk.transform-single-source

##
##
define sm.tool.android-sdk.transform-source-apk
$(call sm-check-not-empty, \
    sm._this $(sm._this).name \
    sm.var.source \
    sm.var.source.computed \
    sm.var.source.lang \
    sm.var.source.suffix \
    sm.var.intermediate \
 , android-sdk: strange parameters for "$(sm.var.source)" of "$($(sm._this).name)")\
$(eval #
  $($(sm._this).classes.path).list: $(sm.var.source.computed)

  ifneq ($($(sm._this).intermediates),$($(sm._this).classes.path).list)
    $(sm._this).intermediates := $($(sm._this).classes.path).list
  endif
 )
endef #sm.tool.android-sdk.transform-source-apk

##
##
define sm.tool.android-sdk.transform-intermediates
$(foreach _, $(sm.tool.android-sdk.args.types), \
     $(call sm.tool.android-sdk.transform-intermediates-$(sm.tool.android-sdk.transform.$_)))
endef #sm.tool.android-sdk.transform-intermediates

##
##
define sm.tool.android-sdk.transform-intermediates-apk
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
  $(sm._this).intermediates \
 , android-sdk: unknown language)\
$(eval #
  sm.var.argfiles :=
  sm.var.flags :=
  sm.var.flags += $($(sm._this).used.compile.flags)
  sm.var.flags += $($(sm._this).used.compile.flags.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).compile.flags)
  sm.var.flags += $($(sm._this).compile.flags.$(sm.var.source.lang))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    $(sm.var.intermediate) : $$(sm.temp._flagsfile)
    sm.var.argfiles := @$$(sm.temp._flagsfile)
    sm.var.flags :=
  endif

  sm.var.flags += $(strip $($(sm._this).compile.flags-$(sm.var.source)))

  $$(call sm-remove-duplicates,sm.var.flags)

  sm.var.command := $$(sm.tool.android-sdk.command.compile.$(sm.var.source.lang))
 )\
$(eval #
  $($(sm._this).classes.path).list:
	@[[ -d $($(sm._this).classes.path) ]] || mkdir -p $($(sm._this).classes.path)
	$(call sm.fun.wrap-rule-commands, android-sdk:, $(sm.var.command))
	@find $($(sm._this).classes.path) -type f -name '*.class' > $$@
 )\
$(eval #
  sm.var.intermediates := $($(sm._this).intermediates)
  sm.var.target :=
  sm.var.flags :=
  ifeq ($($(sm._this).type),static)
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.lib))/lib$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.archive.flags)
    sm.var.flags += $($(sm._this).used.archive.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).archive.flags)
    sm.var.flags += $($(sm._this).archive.flags.$($(sm._this).lang))
  else
    sm.var.target := $(patsubst $(sm.top)/%,%,$(sm.out.bin))/$($(sm._this).name)$($(sm._this).suffix)
    sm.var.flags += $($(sm._this).used.link.flags)
    sm.var.flags += $($(sm._this).used.link.flags.$($(sm._this).lang))
    sm.var.flags += $($(sm._this).link.flags)
    sm.var.flags += $($(sm._this).link.flags.$($(sm._this).lang))
    ifeq ($($(sm._this).type),shared)
      sm.var.flags := -shared $$(filter-out -shared,$$(sm.var.flags))
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

  ifeq ($($(sm._this).type),static)
    sm.var.command := $(sm.tool.android-sdk.command.archive)
  else
    sm.var.command := $(sm.tool.android-sdk.command.link.$($(sm._this).lang))
  endif
 )\
$(eval #
  $(sm._this).targets += $$(sm.var.target)
  $(sm.var.target) : $(sm.var.intermediates.preq)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	$(call sm.fun.wrap-rule-commands, gcc, $(sm.var.command))
 )
endef #sm.tool.android-sdk.transform-intermediates-apk
