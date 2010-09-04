# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#

#####
# Logic
#####
define equal
$(if $(findstring x$1x,x$2x),true,)
endef
# $(info equal: $(call equal,foo,foo))
# $(info equal: $(call equal,foo, foo))
# $(info equal: $(call equal,foobar,foo))
# $(info equal: $(call equal,foo,foobar))

#####
# 
#####
define sm-deprecated
$(error smart: $(strip $1) is deprecated, use $(strip $2) instead)
endef

define sm-this-dir
$(eval _sm_this_dir:=$$(lastword $$(MAKEFILE_LIST)))\
$(patsubst %/,%,$(dir $(_sm_this_dir)))
endef

define sm-this-makefile
$(eval _sm_this_makefile:=$$(lastword $$(MAKEFILE_LIST)))\
$(_sm_this_makefile)
endef

define sm-module-dir
$(if $(sm.this.name),$(call sm-this-dir),\
  $(error 'sm.this.name' is empty, please use 'sm-this-dir' instead))
endef

define sm-module-type-name
  $(if $(call equal,$1,dynamic),shared,\
      $(if $(call equal,$1,executable),exe,\
          $(if $(call equal,$1,tests),t,$1)))
endef

# $(findstring $1,$(sm.global.modules))
define sm-new-module
$(if $1,$(if $(filter $1,$(sm.global.modules)),\
          $(error Module of name '$1' already exists))\
  $(eval sm.this.name:=$(basename $(strip $1))
         $$(if $$(sm.this.name),,$$(error The module name is empty))
         sm.this.suffix:=$(suffix $(strip $1))
         sm.this.dir:=$$(call sm-module-dir)
         sm.this.makefile:=$$(call sm-this-makefile)
         sm.global.modules+=$(strip $1)
         sm.global.modules.$(strip $1):=$$(sm.this.makefile))\
  ,$(error Invalid usage of 'sm-new-module', module name required))\
$(if $2,$(eval sm.this.type:=$(call sm-module-type-name,$(strip $2))
  ifeq ($$(filter $$(sm.this.type),$(sm.global.module_types)),)
    $$(error Unsuported module type '$(strip $2)', only supports '$(sm.global.module_types)')
  endif
  ifeq ($$(sm.this.suffix),)
    ifeq ($$(sm.this.type),static)
      sm.this.suffix := .a
    endif
    ifeq ($$(sm.this.type),shared)
      sm.this.suffix := .so
      sm.this.out_implib:=$(sm.this.name)
    else
     ifeq ($$(sm.this.type),exe)
       sm.this.suffix := $(if $(sm.os.name.win32),.exe)
     else
      ifeq ($$(sm.this.type),t)
       sm.this.suffix := $(if $(sm.os.name.win32),.test.exe,.test)
      endif
     endif
    endif
  endif
  ),)
endef

## Load the build script for the specified module.
define sm-load-module
$(if $1,\
  $(if $(wildcard $1),,$(error Module build script '$1' missed!))\
  $(eval $$(info smart: Load '$1'..)
    include $(sm.dir.buildsys)/preload.mk
    include $1
    -include $(sm.dir.buildsys)/postload.mk
    ),\
  $(error "Must specify the smart.mk file for the module."))
endef

## Find level-one sub-modules.
define sm-find-sub-modules
$(wildcard $(strip $1)/*/smart.mk)
endef

## Generate compilation rules for sources
define sm-generate-objects
 $(if $(strip $(sm.this.sources) $(sm.this.sources.external)),\
    $(eval _sm_log = $$(if $(sm.log.filename),echo $$1 >> $(sm.dir.out)/$(sm.log.filename),true))\
    $(info smart: objects for '$(sm.this.name)' by $(strip $(sm-this-makefile)))\
    $(eval include $(sm.dir.buildsys)/objrules.mk),\
    $(error smart: No sources defined))
endef

## Copy headers to $(sm.dir.out.inc)
##	usage 1: $(call sm-copy-files, $(headers))
##	usage 2: $(call sm-copy-files, $(headers), subdir)
define sm-copy-files
 $(if $(strip $1),\
    $(eval sm.var.__copyfiles := $(strip $1)
           sm.var.__copyfiles.to := $(strip $2)
           include $(sm.dir.buildsys)/copyfiles.mk
           sm.var.__copyfiles :=
           sm.var.__copyfiles.to :=
	),\
    $(error smart: You must specify files for arg one))
endef

## Copy headers
define sm-copy-headers
 $(call sm-check-not-empty, sm.dir.out.inc)\
 $(call sm-copy-files,$1,$(sm.dir.out.inc)/$(strip $2))
endef

## Build the current module
define sm-build-this
 $(if $(sm.this.sources)$(sm.this.sources.external)$(sm.this.objects),,\
   $(error No source or objects defined for '$(sm.this.name)'))\
 $(if $(sm.this.name),\
    $(eval sm.global.goals += goal-$(sm.this.name)
           include $(sm.dir.buildsys)/buildmod.mk),\
   $(error sm.this.name must be specified.))
endef

## Load all smart.mk in sub directories.
define sm-load-sub-modules
$(error Use sm-load-subdirs instead)
endef

define sm-load-subdirs
$(eval include $(sm.dir.buildsys)/subdirs.mk)
endef

## Define variable prefixed by 'sm.var.temp.'.
## NOTE: Donot use it in multi-level 'include's
##   usage 1: $(call sm-var-temp, :=, value list)
##          : $(call sm-var-temp, ?=, value list)
define sm-var-temp
 $(if $(strip $1),$(if $(filter $(strip $2),= := ?=),\
        $(eval sm.var.temp.$(strip $1)$(strip $2)$(strip $3)
           sm.var.temp.*:=$(strip $1) $(sm.var.temp.*)),
       $(warning Invalid usage of fun 'sm-var-temp'.)),\
   $(warning Defining local variable must provide a name.))
endef

## Unset variables prefixed by 'sm.var.temp.'
define sm-var-temp-clean
 $(foreach v,$(sm.var.temp.*),$(eval sm.var.temp.$v:=))\
 $(eval sm.var.temp.*:=)
endef

## Command for making out dir
define sm-util-mkdir
$(if $(wildcard $1),,$(info mkdir: $1)$(shell mkdir -p $1))
endef

## Convert path to relative path (to $(sm.dir.top)).
define sm-to-relative-path
$(patsubst $(sm.dir.top)/%,%,$(strip $1))
endef

################
# Check helpers
################
check-exists = $(sm-deprecated check-exists, sm-check-exists)
define sm-check-exists
$(if $(wildcard $(strip $1)),,$(error $(or $(strip $2),$(strip $1) is not ready)))
endef

define sm-check-not-empty
$(if $(strip $1),\
  $(if $(strip $($(strip $1))),,$(error $(strip $1) is empty)),\
  $(error sm-check-not-empty accept a var-name))
endef

