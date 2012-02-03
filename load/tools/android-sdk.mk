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
sm.tool.android-sdk.android_jar = "$(sm.tool.android-sdk.path)/platforms/$(or $(sm.this.platform),$($(sm._this).platform))/android.jar"

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

ifneq ($(shell which keytool),)
android-genkey:
#	@[[ -f .keystore ]] && echo "keystore already existed" && false
	keytool -genkey -keystore .keystore -alias cert \
	  -keyalg RSA -keysize 2048 -validity 10000
else
ifneq ($(shell which openssl),)
android-genkey:
	openssl genrsa -out $(sm.out)/key.pem 1024
	openssl req -new -key $(sm.out)/key.pem -out $(sm.out)/request.pem
	openssl x509 -req -days 10000 -signkey $(sm.out)/key.pem \
	  -in $(sm.out)/request.pem -out $(sm.out)/certificate.pem
	openssl pkcs8 -topk8 -nocrypt \
	  -inform PEM -in $(sm.out)/key.pem \
	  -outform DER -out $(sm.out)/key.pk8
endif
endif

######################################################################

##
## Compile Commands
define sm.tool.android-sdk.command.compile.sources
$(filter %,javac $(sm.var.flags) $(sm.var.source.R) $(sm.var.sources.java) $(sm.var.argfiles))
endef #sm.tool.android-sdk.command.compile.sources

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
   sm.this.out.classes := $(sm.out)/$(sm.this.name)/classes
   sm.this.out.res := $(sm.out)/$(sm.this.name)/res
   sm.this.out.apk := $(sm.out)/$(sm.this.name)
   sm.this.out.jar := $(sm.out)/$(sm.this.name)
   sm.this.classpath := $(sm.tool.android-sdk.path)/platforms/$(sm.this.platform)/android.jar
   sm.this.compile.flags :=
   sm.this.compile.flags += -sourcepath $(sm.this.dir)/src
   sm.this.compile.flags += -d $$(sm.this.out.classes)
   sm.this.link.flags :=
 )\
$(eval #
  sm.this.keystore.found := $(strip $(or \
    $(wildcard $(sm.this.keystore)),\
    ))
  sm.var.storepass := $(strip $(or \
    $(wildcard $(sm.this.storepass)),\
    ))
  sm.var.keypass := $(strip $(or \
    $(wildcard $(sm.this.keypass)),\
    ))

  ifeq ($(sm.config.variant),debug)
    ifndef sm.this.keystore.found
      sm.this.keystore.found := $(wildcard $(sm.dir.buildsys)/tools/android-sdk/keystore)
    endif
    ifndef sm.var.storepass
      sm.var.storepass := $(wildcard $(sm.dir.buildsys)/tools/android-sdk/storepass)
    endif
    ifndef sm.var.keypass
      sm.var.keypass := $(wildcard $(sm.dir.buildsys)/tools/android-sdk/keypass)
    endif
  endif

  ifndef sm.this.keystore.found
    sm.this.keystore.found := $(wildcard $(sm.this.dir)/.keystore)
  endif
  ifndef sm.var.storepass
    sm.var.storepass := $(wildcard $(sm.this.dir)/.storepass)
  endif
  ifndef sm.var.keypass
    sm.var.keypass := $(wildcard $(sm.this.dir)/.keypass)
  endif
 )\
$(eval #
  ifdef sm.var.storepass
    $(sm.this.out.apk)/signed.apk: sm.var.storepass := "$$(shell cat $(sm.var.storepass))"
  endif
  ifdef sm.var.keypass
    $(sm.this.out.apk)/signed.apk: sm.var.keypass := "$$(shell cat $(sm.var.keypass))"
  endif
  ifdef sm.this.keystore.found
    $(sm.this.out.apk)/signed.apk: sm.var.keystore := $(sm.this.keystore.found)
  endif
  $(sm.this.out.apk)/signed.apk: $(sm.this.out.apk)/unsigned.apk
	@echo "android-sdk: signing '$$@'.." && test -f $$(sm.var.keystore) &&\
	cp $$< $$@ && jarsigner -keystore $$(sm.var.keystore)\
	    $$(addprefix -storepass ,$$(sm.var.storepass))\
	    $$(addprefix -keypass ,$$(sm.var.keypass))\
	    $$@ cert
	$(sm.tool.android-sdk.zipalign) 4 $$@ $$@.aligned &&\
	rm -f $$@ && mv $$@.aligned $$@ || ( rm -f $$@.aligned $$@ ; false )
  $(sm.this.out.apk)/unsigned.apk: $(sm.this.out.classes).dex
	@# create empty package
	( cd $$(@D) && touch dummy && jar cf $$(@F) dummy && zip -qd $$(@F) dummy &&\
	  rm -f dummy && cd - ) > /dev/null
	@# add assets and resources to the package
	$(sm.tool.android-sdk.aapt) package -u \
	    $(addprefix -F ,$$@)\
	    $(addprefix -c ,$(TODO-product_aapt_config))\
	    $(addprefix --preferred-configurations ,$(TODO-product_aapt_pref_config))\
	    $(addprefix -M ,$(sm.this.dir)/AndroidManifest.xml)\
	    $(addprefix -S ,$(wildcard $(sm.this.dir)/res))\
	    $(addprefix -A ,$(wildcard $(sm.this.dir)/assets))\
	    $(addprefix -I ,$(sm.tool.android-sdk.android_jar))\
	    $(addprefix --min-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --target-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --product ,$(TODO-aapt_characteristics))\
	    $(addprefix --version-code ,$(TODO-platform_sdk_version))\
	    $(addprefix --version-name ,$(TODO-platform_version)$(TODO-build_number))\
	    $(addprefix --rename-manifest-package , $(TODO-manifest_package_name))\
	    $(addprefix --rename-instrumentation-target-package , $(TODO-manifest_instrumentation_for))
	@# add DEX to package
	$(sm.tool.android-sdk.aapt) add -k $$@ $$<
	@# add JNI shared libs to package
	@# TODO: JNI libraries
	test -f $$@
#  $(sm.this.out.jar)/library.jar: $(sm.this.out.classes).dex
#	@echo TODO: $$@
  $(sm.this.out.jar)/library.jar: sm.var.manifest :=
  $(sm.this.out.jar)/library.jar: $(sm.this.out.classes).list | $(sm.tool.android-sdk.aapt)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	@# create empty package
	( cd $$(@D) && touch dummy && jar cf $$(@F) dummy && zip -qd $$(@F) dummy &&\
	  rm -f dummy && cd - ) > /dev/null
	@# add assets and resources to the package
	$(sm.tool.android-sdk.aapt) package -u \
	    $(addprefix -F ,$$@)\
	    $(addprefix -c ,$(TODO-product_aapt_config))\
	    $(addprefix --preferred-configurations ,$(TODO-product_aapt_pref_config))\
	    $(addprefix -M ,$(sm.this.dir)/AndroidManifest.xml)\
	    $(addprefix -S ,$(wildcard $(sm.this.dir)/res))\
	    $(addprefix -A ,$(wildcard $(sm.this.dir)/assets))\
	    $(addprefix -I ,$(sm.tool.android-sdk.android_jar))\
	    $(addprefix --min-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --target-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --product ,$(TODO-aapt_characteristics))\
	    $(addprefix --version-code ,$(TODO-platform_sdk_version))\
	    $(addprefix --version-name ,$(TODO-platform_version)$(TODO-build_number))\
	    $(addprefix --rename-manifest-package , $(TODO-manifest_package_name))\
	    $(addprefix --rename-instrumentation-target-package , $(TODO-manifest_instrumentation_for))
	@# add classes into the package(static package)
	jar $$(if $$(strip $$(sm.var.manifest)),-ufm,-uf) $$@ $$(sm.var.manifest) -C $(sm.this.out.classes) .
	@# add JNI shared libs to package
	@# TODO: JNI libraries
	test -f $$@
  $(sm.this.out.classes).dex: $(sm.this.out.classes).list | $(sm.tool.android-sdk.dx)
	@[[ -d $$(@D) ]] || mkdir -p $$(@D)
	cd $(sm.this.out.classes) > /dev/null &&\
	$(sm.tool.android-sdk.dx) \
	    $(if $(findstring windows,$(sm.os.name)),,-JXms16M -JXmx1536M)\
	    --dex --output=_.dex `cat ../classes.list | sed 's|^$(sm.this.out.classes)/||'` &&\
	cd - > /dev/null && mv $(sm.this.out.classes)/_.dex $$@
  $(sm.this.out.classes).list: sm.var.source.R := `find $(sm.this.out.res) -type f -name R.java`
  $(sm.this.out.classes).list: sm.var.sources.java :=
  $(sm.this.out.classes).list: sm.var.flags :=
  $(sm.this.out.classes).list: $(sm.this.out.res).list
	@rm -rf $(sm.this.out.classes) && mkdir -p $(sm.this.out.classes)
	$$(sm.tool.android-sdk.command.compile.sources)
	@find $(sm.this.out.classes) -type f -name '*.class' > $$@
  $(sm.this.out.res).list: $(sm.this.dir)/AndroidManifest.xml | $(sm.tool.android-sdk.aapt)
	@[[ -d $(sm.this.out.res) ]] || mkdir -p $(sm.this.out.res)
	$(filter %,$(sm.tool.android-sdk.aapt) package -m \
	    $(addprefix -J ,$(sm.this.out.res))\
	    $(addprefix -M ,$(sm.this.dir)/AndroidManifest.xml)\
	    $(addprefix -P ,$(TODO-resource_publics_output))\
	    $(addprefix -S ,$(wildcard $(sm.this.dir)/res))\
	    $(addprefix -A ,$(wildcard $(sm.this.dir)/assets))\
	    $(addprefix -I ,$(sm.tool.android-sdk.android_jar))\
	    $(addprefix -G ,$(wildcard $(sm.this.dir)/proguard.cfg))\
	    $(addprefix --min-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --target-sdk-version ,$(TODO-default_app_target_sdk))\
	    $(addprefix --version-code ,$(TODO-platform_sdk_version))\
	    $(addprefix --version-name ,$(TODO-platform_version)$(TODO-build_number))\
	    $(addprefix --rename-manifest-package , $(TODO-manifest_package_name))\
	    $(addprefix --rename-instrumentation-target-package , $(TODO-manifest_instrumentation_for))\
	)
 )
endef #sm.tool.android-sdk.config-module

define sm.tool.android-sdk.args.types
$(filter-out -% PLATFORM=%, $($(sm._this).toolset.args))
endef #sm.tool.android-sdk.args.types

sm.tool.android-sdk.transform.apk := apk
sm.tool.android-sdk.transform.jar := jar

## sm.var.source
## sm.var.source.computed
## sm.var.source.lang
## sm.var.source.suffix
## sm.var.intermediate (source -> intermediate)
define sm.tool.android-sdk.transform-single-source
$(foreach _, $(sm.tool.android-sdk.args.types),\
  $(eval #
    ifndef sm.tool.android-sdk.transform.$_
      $$(info $($(sm._this).makefile):1: unsupported module type "$_")
      $$(error unsupported module type "$_" defined by $($(sm._this).name))
    endif
   )\
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
  sm.var.argfiles :=
  sm.var.flags := -cp "$$(subst $$(sm.char.space),:,$(filter %,$($(sm._this).classpath) $($(sm._this).used.classpath)))"
  sm.var.flags += $($(sm._this).used.compile.flags)
  sm.var.flags += $($(sm._this).used.compile.flags.$(sm.var.source.lang))
  sm.var.flags += $($(sm._this).compile.flags)
  sm.var.flags += $($(sm._this).compile.flags.$(sm.var.source.lang))

  #$$(call sm-remove-duplicates,sm.var.flags)

  sm.temp._flagsfile := $$(call sm.fun.shift-flags-to-file, sm.var.flags, compile.$(sm.var.source.lang), $($(sm._this).compile.flags.infile))
  ifdef sm.temp._flagsfile
    $($(sm._this).out.classes).list : $$(sm.temp._flagsfile)
    sm.var.argfiles := @$$(sm.temp._flagsfile)
    sm.var.flags :=
  endif

  #$$(call sm-remove-duplicates,sm.var.flags)
 )\
$(eval #
  $(sm._this).intermediates := $($(sm._this).out.classes).list
  $($(sm._this).out.classes).list: sm.var.argfiles := $(sm.var.argfiles)
  $($(sm._this).out.classes).list: sm.var.flags := $(sm.var.flags)
  $($(sm._this).out.classes).list: sm.var.sources.java += $(sm.var.source.computed)
  $($(sm._this).out.classes).list: $(sm.var.source.computed)
  sm.var.flags :=
 )
endef #sm.tool.android-sdk.transform-source-apk

##
##
define sm.tool.android-sdk.transform-source-jar
$(sm.tool.android-sdk.transform-source-apk)
endef #sm.tool.android-sdk.transform-source-jar

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
 , android-sdk: unknown language)\
$(eval #
  ifdef sm.this.keystore.found
    $(sm._this).targets += $($(sm._this).out.apk)/signed.apk
  else
    $(sm._this).targets += $($(sm._this).out.apk)/unsigned.apk
    android-sign-apk :     $($(sm._this).out.apk)/signed.apk
    .PHONY: android-sign-apk
  endif
 )\
$(sm.tool.android-sdk.define-adb-commands)\
$(sm.tool.android-sdk.define-android-commands)
endef #sm.tool.android-sdk.transform-intermediates-apk

##
##
define sm.tool.android-sdk.transform-intermediates-jar
$(call sm-check-not-empty, sm._this \
  $(sm._this).name \
  $(sm._this).lang \
  $(sm._this).type \
 , android-sdk: unknown language)\
$(eval #
  $(sm._this).targets += $($(sm._this).out.jar)/library.jar
 )
endef #sm.tool.android-sdk.transform-intermediates-jar

##
##
define sm.tool.android-sdk.define-adb-commands
$(eval #
  sm.temp._cmdgoals := $(MAKECMDGOALS)
  sm.temp._adb := $(firstword $(MAKECMDGOALS))
  sm.temp._adb_args := $(filter-out adb,$(MAKECMDGOALS))
 )\
$(eval #
  sm.temp._adb_cmd := $(firstword $(sm.temp._adb_args))
 )\
$(eval #
  sm.temp._adb_cmd_args := $(filter-out $(sm.temp._adb_cmd),$(sm.temp._adb_args))
 )\
$(eval #
  ifeq ($(sm.temp._adb), adb)
    $(filter-out -%,$(sm.temp._adb_args)): ; @true
    .PHONY: adb adb-install
    adb: adb-$(sm.temp._adb_cmd)
    adb-install: $($(sm._this).out.apk)/signed.apk
	@adb $(addprefix -s ,$S) install -r $$<
  endif
 )
endef #sm.tool.android-sdk.define-adb-commands

##
##
define sm.tool.android-sdk.define-android-commands
$(eval #
  sm.temp._cmdgoals := $(MAKECMDGOALS)
  sm.temp._android := $(firstword $(MAKECMDGOALS))
  sm.temp._android_args := $(filter-out android,$(MAKECMDGOALS))
 )\
$(eval #
  sm.temp._android_cmd := $(firstword $(sm.temp._android_args))
 )\
$(eval #
  sm.temp._android_cmd_args := $(filter-out $(sm.temp._android_cmd),$(sm.temp._android_args))
 )\
$(eval #
  ifeq ($(sm.temp._android), android)
    $(filter-out -%,$(sm.temp._android_args)): ; @true
    .PHONY: android android-create android-update android-create-project android-update-project
    android: android-$(sm.temp._android_cmd)
    android-create: android-create-$(firstword $(sm.temp._android_cmd_args))
    android-update: android-update-$(firstword $(sm.temp._android_cmd_args))
    android-create-project:
	$$(if $$(TARGET),,$$(error requires the TARGET))\
	$$(if $$(PACKAGE),,$$(error requires the PACKAGE))\
	$$(if $$(ACTIVITY),,$$(error requires the ACTIVITY))\
	@android create project\
	  --path $($(sm._this).dir)\
	  --name $($(sm._this).name)\
	  --target $(TARGET)\
	  --package $(PACKAGE)\
	  --activity $(ACTIVITY)
    android-update-project:
	$$(if $$(TARGET),,$$(error requires the TARGET))\
	$$(if $$(PACKAGE),,$$(error requires the PACKAGE))\
	$$(if $$(ACTIVITY),,$$(error requires the ACTIVITY))\
	@android update project\
	  --path $($(sm._this).dir)\
	  --name $($(sm._this).name)
  endif
 )
endef #sm.tool.android-sdk.define-android-commands
