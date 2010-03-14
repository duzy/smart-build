# -*- mode: Makefile:gnu -*-

ifeq ($(SM_MODULE_TYPE),subdirs)
  $(error Using sm-load-sub-modules instead of 'subdirs' module type)
endif

ifeq ($(wildcard $(SM_MODULE_DIR)),)
  $(error SM_MODULE_DIR must be specified first)
endif

#$(info smart: sub $(SM_MODULE_DIR))

_submods := $(if $(SM_MODULE_SUBDIRS),\
  $(foreach v,$(SM_MODULE_SUBDIRS),$(wildcard $(SM_MODULE_DIR)/$v/smart.mk)),\
  $(call sm-find-sub-modules, $(SM_MODULE_DIR)))

#$(info submods: $(_submods) in '$(SM_MODULE_DIR)')

#$(foreach v,$(_submods),$(eval $$(call load-module,$v))\
#  $(eval include $(SB_DIR)/buildmod.mk))
$(foreach v,$(_submods),$(eval $$(call load-module,$v)))

