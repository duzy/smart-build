# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

define sm-this-dir
$(eval _sm_this_dir := $$(lastword $$(MAKEFILE_LIST)))\
$(patsubst %/,%,$(dir $(_sm_this_dir)))
endef

define sm-module-dir
$(if $(SM_MODULE_NAME),$(call sm-this-dir),\
  $(error SM_MODULE_NAME is empty, please use sm-this-dir instead))
endef

define sm-new-module
$(if $1,$(if $(findstring $1,$(SM_GLOBAL_MODULE_NAMES)),\
          $(error smart: Module of name '$1' already defined))\
  $(eval SM_GLOBAL_MODULE_NAMES+=$(strip $1))\
  $(eval SM_MODULE_NAME:=$(strip $1))\
  $(eval SM_MODULE_SUFFIX:=$$(suffix $(strip $1))))\
$(if $2,$(eval SM_MODULE_TYPE:=$(strip $2)),)\
$(eval SM_MODULE_DIR:=$$(call sm-module-dir))
endef

## Load the build script for the specified module.
define load-module
$(if $1,\
  $(if $(wildcard $1),,$(error Module build script '$1' missed!))\
  $(eval $$(info smart: Load '$1'..)
    include $(sm_build_dir)/preload.mk
    include $1
    -include $(sm_build_dir)/postload.mk
    ),\
  $(error "Must specify the smart.mk file for the module."))
endef

## Find level-one sub-modules.
define sm-find-sub-modules
$(wildcard $(strip $1)/*/smart.mk)
endef

## Build the current module
define sm-build-this
 $(if $(SM_MODULE_NAME),\
    $(eval SM_GLOBAL_GOALS += goal-$(SM_MODULE_NAME)
           include $(sm_build_dir)/buildmod.mk),\
   $(error SM_MODULE_NAME must be specified.))
endef

## Load all smart.mk in sub directories.
define sm-load-sub-modules
$(error Use sm-load-subdirs instead)
endef

define sm-load-subdirs
$(eval include $(sm_build_dir)/subdirs.mk)
endef




################
# Check helpers
################
define check-exists
$(if $(wildcard $(strip $1)),,$(error $(strip $2)))
endef
