# -*- mode: Makefile:gnu -*-
#	Copyright(c) 2009, by Zhan Xin-ming, duzy@duzy.info
#	

# Check make version
sm.make.version.compatible := 3.80 3.81
ifeq ($(filter $(MAKE_VERSION),$(sm.make.version.compatible)),)
  $(error "smart: Bad GNU/Make version, expects one of: $(sm.make.version.compatible)")
endif

## Smart Build directory, internal use only, must always contain a '/' tail.
sm.dir.buildsys := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

SHELL := /bin/bash

ifeq ($(wildcard $(sm.dir.buildsys)/defuns.mk),)
  $(error "smart: Can't find smart build system directory.")
else
  # Predefined functions.
  include $(sm.dir.buildsys)/defuns.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/init.mk),)
  $(error "smart: can't find smart build system directory")
else
  # Variables of 'sm.*' spec
  include $(sm.dir.buildsys)/init.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/rules.mk),)  # funs for gen rules
  $(error "smart: can't find smart build system directory")
else
  include $(sm.dir.buildsys)/rules.mk
endif

ifeq ($(wildcard $(sm.dir.buildsys)/conf.mk),)
  $(error "smart: Can't find smart build system directory.")
else
  # Automate configuration for build parameters.
  include $(sm.dir.buildsys)/conf.mk
endif

.DEFAULT_GOAL := build-goals

##################################################

sm.global.smartfiles.toplevel := $(wildcard $(sm.top)/smart.mk)
#_sm_mods += $(call sm-find-sub-modules, $(sm.top))

ifneq ($(strip $(sm.global.smartfiles.toplevel)),)
  sm.global.goals :=
  sm.global.modules :=
  $(foreach v,$(sm.global.smartfiles.toplevel),$(eval $$(call sm-load-module,$v)))
  #$(foreach v,$(sm.global.modules),$(info smart: module '$v' by $(sm.global.modules.$v)))
else
  $(info smart: ************************************************************)
  $(info smart:  You have to provide the root build script 'smart.mk' at top)
  $(info smart:  level directory of the project.)
  $(info smart: ************************************************************)
  $(error Can't find the root build script 'smart.mk') #'
endif

# .PRECIOUS: foo bar
# .DELETE_ON_ERROR: foo bar

# $(info phony: $(sm.rules.phony.*))
# $(info rules: $(sm.rules.*))
# $(info goals: $(sm.global.goals))
.PHONY: build-goals clean $(sm.rules.phony.*)
ifneq ($(sm.global.goals),)
  build-goals: $(sm.global.goals)
  clean: $(sm.global.goals:goal-%=clean-%)
else
  build-goals:; $(info smart: no goals) @true
  clean:; $(info smart: nothing dirty) @true
endif

.DEFAULT_GOAL := build-goals

#$(info smart: modules: $(sm.global.modules))
