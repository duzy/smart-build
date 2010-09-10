# -*- mode: Makefile:gnu -*-

ifeq ($(sm.this.type),subdirs)
  $(error using sm-load-sub-modules instead of 'subdirs' module type)
endif

ifeq ($(wildcard $(sm.this.dir)),)
  $(error sm.this.dir must be specified first)
endif

#$(info smart: sub $(sm.this.dir))

_submods := $(if $(sm.this.dirs),\
  $(foreach v,$(sm.this.dirs),$(wildcard $(sm.this.dir)/$v/smart.mk)),\
  $(call sm-find-sub-modules, $(sm.this.dir)))

#$(info submods: $(_submods) in '$(sm.this.dir)')

#$(foreach v,$(_submods),$(eval $$(call sm-load-module,$v))\
#  $(eval include $(SB_DIR)/buildmod.mk))
$(foreach v,$(_submods),$(eval $$(call sm-load-module,$v)))

