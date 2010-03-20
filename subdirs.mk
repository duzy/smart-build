# -*- mode: Makefile:gnu -*-

ifeq ($(sm.module.type),subdirs)
  $(error Using sm-load-sub-modules instead of 'subdirs' module type)
endif

ifeq ($(wildcard $(sm.module.dir)),)
  $(error sm.module.dir must be specified first)
endif

#$(info smart: sub $(sm.module.dir))

_submods := $(if $(sm.module.dirs),\
  $(foreach v,$(sm.module.dirs),$(wildcard $(sm.module.dir)/$v/smart.mk)),\
  $(call sm-find-sub-modules, $(sm.module.dir)))

#$(info submods: $(_submods) in '$(sm.module.dir)')

#$(foreach v,$(_submods),$(eval $$(call sm-load-module,$v))\
#  $(eval include $(SB_DIR)/buildmod.mk))
$(foreach v,$(_submods),$(eval $$(call sm-load-module,$v)))

