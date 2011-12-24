#
#	Copyright(c) 2009, 2010, 2011, 2012 by Zhan Xin-ming <code@duzy.info>
#

##
##  sm.tool.android-sdk
##

$(call sm-check-origin, sm.tool.android-sdk, undefined)

ANDROID_SDK_PATH := \
 $(or \
   $(wildcard ~/open/android-sdk-linux_x86),\
   $(wildcard ~/open/android-sdk-linux_86),\
   $(wildcard ~/open/android-sdk),\
  )

sm.tool.android-sdk := true
sm.tool.android-sdk.path := $(ANDROID_SDK_PATH)
sm.tool.android-sdk.aapt := $(sm.tool.android-sdk.path)/platform-tools/aapt
sm.tool.android-sdk.dx := $(sm.tool.android-sdk.path)/platform-tools/dx
sm.tool.android-sdk.zipalign := $(sm.tool.android-sdk.path)/tools/zipalign
sm.tool.android-sdk.android_jar = $(sm.tool.android-sdk.path)/platforms/$($(sm._this).platform)/android.jar

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
javac $(sm.var.flags) $(sm.var.source.R) $$$$^ $(sm.var.argfiles)
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
  ifndef sm.tool.android-sdk.path
    $$(error Android SDK not found)
  endif

   sm.this.gen_deps := true
   sm.this.type := $(firstword $(sm.this.toolset.args))
   sm.this.suffix := $$(sm.tool.android-sdk.suffix.target.$(sm.os.name).$$(sm.this.type))
   sm.this.sources := $(call sm-find-files-in,$(sm.this.dir)/src,%.java)
   sm.this.sources := $$(sm.this.sources:$(sm.this.dir)/%=%)
   sm.this.path.classes := $(sm.out)/$(sm.this.name)/classes
   sm.this.path.res := $(sm.out)/$(sm.this.name)/res
   sm.this.compile.flags := -cp $(sm.tool.android-sdk.path)/platforms/$(sm.this.platform)/android.jar
   sm.this.compile.flags += -sourcepath $(sm.this.dir)/src
   sm.this.compile.flags += -d $$(sm.this.path.classes)
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
  $($(sm._this).path.classes).list: $(sm.var.source.computed)

  ifneq ($($(sm._this).intermediates),$($(sm._this).path.classes).list)
    $(sm._this).intermediates := $($(sm._this).path.classes).list
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
## see: android/build: package.mk, definitions.mk
##	$(add-assets-to-package)
##	$(add-jni-shared-libs-to-package)
##	$(sign-package)
##	$(align-package)
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

  sm.var.source.R := `find $($(sm._this).path.res) -type f -name R.java`
  sm.var.command := $$(sm.tool.android-sdk.command.compile.$(sm.var.source.lang))
 )\
$(eval #see definitions.mk(add-assets-to-package) for this
  $($(sm._this).path.classes).list:
	@[[ -d $($(sm._this).path.classes) ]] || mkdir -p $($(sm._this).path.classes)
	@[[ -d $($(sm._this).path.res)     ]] || mkdir -p $($(sm._this).path.res)
	$(sm.tool.android-sdk.aapt) package -m \
	  -J $($(sm._this).path.res)\
	  -M $($(sm._this).dir)/AndroidManifest.xml\
	  -S $($(sm._this).dir)/res\
	  -A $($(sm._this).dir)/res\
	  -I $(sm.tool.android-sdk.android_jar)\
	  ;
	$(call sm.fun.wrap-rule-commands, android-sdk:, $(sm.var.command))
	@find $($(sm._this).path.classes) -type f -name '*.class' > $$@

  sm.var.target := $($(sm._this).path.classes).dex
 )\
$(eval #
  $(sm.var.target) : $($(sm._this).path.classes).list
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	cd $($(sm._this).path.classes) > /dev/null &&\
	$(sm.tool.android-sdk.dx) \
	    $(if $(findstring windows,$(sm.os.name)),,-JXms16M -JXmx1536M)\
	    --dex --output=_.dex `cat ../classes.list | sed 's|^$($(sm._this).path.classes)/||'` &&\
	cd - > /dev/null && mv $($(sm._this).path.classes)/_.dex $$@

  sm.var.target.dex := $(sm.var.target)
  sm.var.target := $(dir $(sm.var.target))unsigned.apk
 )\
$(eval #
  $(sm.var.target) : $(sm.var.target.dex)
	( cd $(dir $(sm.var.target)) &&\
	  jar cf $(notdir $(sm.var.target)) $(notdir $(sm.var.target.dex)) &&\
	  cd - ) > /dev/null && \
	$(sm.tool.android-sdk.aapt) package -u \
	    -F $(sm.var.target)\
	    -M $($(sm._this).dir)/AndroidManifest.xml\
	    -S $($(sm._this).dir)/res\
	    -A $($(sm._this).dir)/res\
	    -I $(sm.tool.android-sdk.android_jar)\
	    --version-code 7\
	    --version-name 10-1\
	    --rename-manifest-package $(rename_manifest)\
	    --rename-instrumentation-target-package $(rename_instrumentation) \
	$(add-jni-shared-libs-to-package)\

  sm.var.target.unsigned := $(sm.var.target)
  sm.var.target := $(sm.var.target:%unsigned.apk=%signed.apk)
  sm.var.keystore := $(wildcard $($(sm._this).keystore))
  ifndef sm.var.keystore
    sm.var.keystore := $(wildcard $($(sm._this).dir))/sign.keystore
  endif
 )\
$(eval #
  ifdef sm.var.keystore
    $(sm._this).targets += $(sm.var.target)
  else
    $(sm._this).targets += $(sm.var.target.unsigned)
    android-sign-apk: $(sm.var.target)
  endif
  $(sm.var.target) : $(sm.var.target.unsigned)
	$(sign-package)\
	$(sm.tool.android-sdk.zipalign) 4 $(sm.var.target.unsigned) $(sm.var.target)
 )
endef #sm.tool.android-sdk.transform-intermediates-apk
