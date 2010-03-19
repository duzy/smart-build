# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

define sm-this-dir
$(eval _sm_this_dir := $$(lastword $$(MAKEFILE_LIST)))\
$(patsubst %/,%,$(dir $(_sm_this_dir)))
endef

define sm-module-dir
$(if $(sm.module.name),$(call sm-this-dir),\
  $(error sm.module.name is empty, please use sm-this-dir instead))
endef

define sm-new-module
$(if $1,$(if $(findstring $1,$(sm.global.module.names)),\
          $(error smart: Module of name '$1' already defined))\
  $(eval sm.global.module.names+=$(strip $1))\
  $(eval sm.module.name:=$(strip $1))\
  $(eval SM_MODULE_SUFFIX:=$$(suffix $(strip $1))))\
$(if $2,$(eval sm.module.type:=$(strip $2)
  ifeq ($$(sm.module.type),static)
    sm.module.suffix := .a
  endif
  ifeq ($$(sm.module.type),shared)
    sm.module.suffix := .so
  endif
  ),)\
$(eval sm.module.dir:=$$(call sm-module-dir))
endef

## Load the build script for the specified module.
define load-module
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




################
# Check helpers
################
define check-exists
$(if $(wildcard $(strip $1)),,$(error $(strip $2)))
endef
