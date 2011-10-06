# -*- mode: Makefile:gnu -*-

ifeq ($(sm.this.type),subdirs)
  $(error using sm-load-sub-modules instead of 'subdirs' module type)
endif

ifeq ($(wildcard $(sm.this.dir)),)
  $(error sm.this.dir must be specified first)
endif

#$(info dir: $(sm.this.dir))
#$(info subdirs: $(sm.this.dirs))

# avoid: if upper level module is 'subdirs', that sm.this.dirs will
#	 affect 'this' module
sm.var.temp._dir := $(sm.this.dir)
sm.var.temp._subdirs := $(sm.this.dirs)
sm.this.dir :=
sm.this.dirs :=

sm.var.temp._subdir_mods := $(if $(sm.var.temp._subdirs),\
  $(foreach v,$(sm.var.temp._subdirs),$(wildcard $(sm.var.temp._dir)/$v/smart.mk)),\
  $(call sm-find-sub-modules, $(sm.var.temp._dir)))

$(foreach v,$(sm.var.temp._subdir_mods),$(eval $$(call sm-load-module,$v)))

#sm.this.dir := $(sm.var.temp._dir)
sm.this.dir :=
sm.this.dirs :=
