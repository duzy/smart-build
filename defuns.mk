# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

define sm-this-dir
$(eval _sm_this_dir:=$$(lastword $$(MAKEFILE_LIST)))\
$(patsubst %/,%,$(dir $(_sm_this_dir)))
endef

define sm-this-makefile
$(eval _sm_this_makefile:=$$(lastword $$(MAKEFILE_LIST)))\
$(_sm_this_makefile)
endef

define sm-module-dir
$(if $(sm.module.name),$(call sm-this-dir),\
  $(error 'sm.module.name' is empty, please use 'sm-this-dir' instead))
endef

# $(findstring $1,$(sm.global.modules))
define sm-new-module
$(if $1,$(if $(filter $1,$(sm.global.modules)),\
          $(error Module of name '$1' already exists))\
  $(eval sm.module.name:=$(basename $(strip $1))
         sm.module.suffix:=$(suffix $(strip $1))
         sm.module.dir:=$$(call sm-module-dir)
         sm.module.makefile:=$$(call sm-this-makefile)
         sm.global.modules+=$(strip $1)
         sm.global.modules.$(strip $1):=$$(sm.module.makefile))\
  ,$(error Invalid usage of 'sm-new-module', module name required))\
$(if $2,$(eval sm.module.type:=$(strip $2)
  ifeq ($$(filter $$(sm.module.type),$(sm.global.module_types)),)
    $$(error Unsuported module type '$(strip $2)', only supports '$(sm.global.module_types)')
  endif
  ifeq ($$(sm.module.suffix),)
    ifeq ($$(sm.module.type),static)
      sm.module.suffix := .a
    endif
    ifeq ($$(sm.module.type),shared)
      sm.module.suffix := .so
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
 $(if $(strip $(sm.module.sources) $(sm.module.sources.generated)),\
    $(eval _sm_log = $$(if $(sm.log.filename),echo $$1 >> $(sm.dir.out)/$(sm.log.filename),true))\
    $(eval include $(sm.dir.buildsys)/objrules.mk),\
    $(error smart: No sources defined))
endef

## Build the current module
define sm-build-this
 $(if $(sm.module.name),\
    $(eval sm.global.goals += goal-$(sm.module.name)
           include $(sm.dir.buildsys)/buildmod.mk),\
   $(error sm.module.name must be specified.))
endef

## Load all smart.mk in sub directories.
define sm-load-sub-modules
$(error Use sm-load-subdirs instead)
endef

define sm-load-subdirs
$(eval include $(sm.dir.buildsys)/subdirs.mk)
endef

## Define variable prefixed by 'sm.var.local.'.
## NOTE: Donot use it in multi-level 'include's
##   usage 1: $(call sm-var-local, :=, value list)
##          : $(call sm-var-local, ?=, value list)
define sm-var-local
 $(if $(strip $1),$(if $(filter $(strip $2),= := ?=),\
        $(eval sm.var.local.$(strip $1)$(strip $2)$(strip $3)
           sm.var.local.*:=$(strip $1) $(sm.var.local.*)),
       $(warning Invalid usage of fun 'sm-var-local'.)),\
   $(warning Defining local variable must provide a name.))
endef

## Unset variables prefixed by 'sm.var.local.'
define sm-var-local-clean
$(foreach v,$(sm.var.local.*),$(eval sm.var.local.$v:=))\
$(eval sm.var.local.*:=)
endef

## Command for making out dir
define sm-util-mkdir
$(if $(wildcard $1),,$(info mkdir: $1)$(shell mkdir -p $1))
endef


################
# Check helpers
################
define check-exists
  $(error smart: check-exists is deprecated, use sm-check-exists instead)
endef
define sm-check-exists
$(if $(wildcard $(strip $1)),,$(error $(strip $2)))
endef
